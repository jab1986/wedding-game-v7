#!/usr/bin/env python3
"""
Art Asset Reorganizer
Reorganizes downloaded OpenGameArt assets by content type for easier game development use.

Usage:
    python reorganize_art.py [--source-dir] [--output-dir]

Features:
- Analyzes filenames and metadata to categorize content
- Creates organized folder structure by asset type
- Preserves attribution information
- Creates usage guides for each category
"""

import os
import json
import shutil
import re
from pathlib import Path
from typing import Dict, List, Set
import argparse

class ArtReorganizer:
    def __init__(self, source_dir: str, output_dir: str):
        self.source_dir = Path(source_dir)
        self.output_dir = Path(output_dir)
        
        # Create organized directory structure
        self.categories = {
            'sprite_sheets': 'Character and object sprite sheets',
            'characters': 'Individual character sprites and animations',
            'tilesets': 'Map tiles and tileset collections',
            'backgrounds': 'Background images and scenery',
            'ui_elements': 'User interface components and menus',
            'icons': 'Small icons and inventory items',
            'props': 'Objects, items, and decorative elements',
            'effects': 'Particle effects and visual effects',
            'weapons': 'Weapons, tools, and equipment',
            'environments': 'Environment and level assets',
            'misc': 'Other uncategorized assets'
        }
        
        # Keywords for categorization
        self.keywords = {
            'sprite_sheets': [
                'spritesheet', 'sprite_sheet', 'sheet', 'animation', 'frames',
                'walk', 'run', 'idle', 'attack', 'death', 'cycle'
            ],
            'characters': [
                'character', 'player', 'hero', 'npc', 'person', 'human',
                'warrior', 'mage', 'knight', 'archer', 'rogue', 'priest',
                'enemy', 'monster', 'creature', 'boss', 'alien', 'zombie'
            ],
            'tilesets': [
                'tileset', 'tile', 'tiles', 'terrain', 'ground', 'floor',
                'wall', 'dungeon', 'cave', 'grass', 'stone', 'brick',
                'platform', 'block', 'cliff', 'mountain'
            ],
            'backgrounds': [
                'background', 'backdrop', 'scenery', 'landscape', 'sky',
                'clouds', 'forest', 'city', 'space', 'underwater', 'parallax'
            ],
            'ui_elements': [
                'ui', 'interface', 'menu', 'button', 'panel', 'window',
                'hud', 'health', 'bar', 'frame', 'border', 'dialog',
                'inventory', 'shop', 'pause', 'game_over'
            ],
            'icons': [
                'icon', 'item', 'pickup', 'collectible', 'coin', 'gem',
                'key', 'potion', 'scroll', 'book', 'food', 'rpg_icon'
            ],
            'props': [
                'prop', 'object', 'furniture', 'decoration', 'barrel',
                'chest', 'table', 'chair', 'tree', 'rock', 'crystal',
                'torch', 'lamp', 'door', 'gate', 'statue'
            ],
            'effects': [
                'effect', 'particle', 'explosion', 'fire', 'smoke', 'magic',
                'spell', 'impact', 'blood', 'dust', 'sparkle', 'glow'
            ],
            'weapons': [
                'weapon', 'sword', 'axe', 'bow', 'staff', 'gun', 'knife',
                'hammer', 'spear', 'shield', 'armor', 'equipment'
            ],
            'environments': [
                'environment', 'level', 'world', 'map', 'area', 'zone',
                'castle', 'village', 'town', 'field', 'desert', 'winter'
            ]
        }
        
    def analyze_content(self, filepath: Path, metadata: Dict) -> str:
        """Analyze file and metadata to determine content category."""
        
        # Combine all text for analysis
        text_to_analyze = []
        text_to_analyze.append(filepath.name.lower())
        text_to_analyze.append(metadata.get('title', '').lower())
        text_to_analyze.append(metadata.get('description', '').lower())
        
        combined_text = ' '.join(text_to_analyze)
        
        # Score each category based on keyword matches
        category_scores = {}
        for category, keywords in self.keywords.items():
            score = 0
            for keyword in keywords:
                # Count occurrences of each keyword
                score += combined_text.count(keyword)
                # Bonus for exact filename matches
                if keyword in filepath.stem.lower():
                    score += 2
            category_scores[category] = score
        
        # Return category with highest score, or 'misc' if no clear match
        best_category = max(category_scores.items(), key=lambda x: x[1])
        return best_category[0] if best_category[1] > 0 else 'misc'
    
    def create_directory_structure(self):
        """Create the organized directory structure."""
        self.output_dir.mkdir(exist_ok=True)
        
        for category, description in self.categories.items():
            category_dir = self.output_dir / category
            category_dir.mkdir(exist_ok=True)
            
            # Create README for each category
            readme_file = category_dir / "README.md"
            with open(readme_file, 'w', encoding='utf-8') as f:
                f.write(f"# {category.replace('_', ' ').title()}\n\n")
                f.write(f"{description}\n\n")
                f.write("## Contents\n\n")
                f.write("This folder contains art assets organized by content type for easy game development use.\n\n")
                f.write("## Attribution\n\n")
                f.write("Each asset folder contains a `metadata.json` file with:\n")
                f.write("- Original author and license information\n")
                f.write("- Attribution requirements\n")
                f.write("- Source URL\n\n")
                f.write("⚠️ **Important**: Always check the metadata.json file for proper attribution requirements!\n\n")
    
    def copy_and_organize_assets(self):
        """Copy assets from license-based structure to content-based structure."""
        
        print("🔍 Analyzing and reorganizing assets...")
        
        # Track what we've organized
        organized_count = 0
        category_counts = {category: 0 for category in self.categories.keys()}
        
        # Process each license directory
        for license_dir in self.source_dir.iterdir():
            if not license_dir.is_dir() or license_dir.name in ['metadata']:
                continue
                
            print(f"📂 Processing {license_dir.name} assets...")
            
            # Process each art item folder
            for item_dir in license_dir.iterdir():
                if not item_dir.is_dir():
                    continue
                
                # Load metadata
                metadata_file = item_dir / "metadata.json"
                metadata = {}
                if metadata_file.exists():
                    try:
                        with open(metadata_file, 'r', encoding='utf-8') as f:
                            metadata = json.load(f)
                    except:
                        pass
                
                # Find art files in this item
                art_files = []
                for file_path in item_dir.iterdir():
                    if file_path.suffix.lower() in ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.zip', '.tar.gz']:
                        art_files.append(file_path)
                
                if not art_files:
                    continue
                
                # Analyze content to determine category
                # Use the first art file for analysis, but consider all
                primary_file = art_files[0]
                category = self.analyze_content(primary_file, metadata)
                
                # Create destination folder
                safe_title = self.sanitize_filename(metadata.get('title', item_dir.name))
                dest_folder = self.output_dir / category / f"{safe_title}_{license_dir.name}"
                dest_folder.mkdir(exist_ok=True)
                
                # Copy all files
                for art_file in art_files:
                    dest_file = dest_folder / art_file.name
                    if not dest_file.exists():
                        shutil.copy2(art_file, dest_file)
                
                # Copy/create metadata with license info
                dest_metadata = dest_folder / "metadata.json"
                enhanced_metadata = metadata.copy()
                enhanced_metadata['original_license_folder'] = license_dir.name
                enhanced_metadata['category'] = category
                enhanced_metadata['files'] = [f.name for f in art_files]
                
                with open(dest_metadata, 'w', encoding='utf-8') as f:
                    json.dump(enhanced_metadata, f, indent=2, ensure_ascii=False)
                
                organized_count += 1
                category_counts[category] += 1
                
                print(f"  ✓ {safe_title} → {category}")
        
        return organized_count, category_counts
    
    def sanitize_filename(self, filename: str) -> str:
        """Clean filename for filesystem compatibility."""
        filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
        filename = re.sub(r'\s+', '_', filename)
        return filename[:50]  # Limit length
    
    def generate_summary_report(self, organized_count: int, category_counts: Dict):
        """Generate a summary report of the reorganization."""
        
        report_file = self.output_dir / "ORGANIZATION_SUMMARY.md"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("# Art Assets Organization Summary\n\n")
            f.write(f"**Total Assets Organized**: {organized_count}\n\n")
            
            f.write("## Assets by Category\n\n")
            for category, count in sorted(category_counts.items()):
                category_name = category.replace('_', ' ').title()
                f.write(f"- **{category_name}**: {count} items\n")
            
            f.write("\n## Directory Structure\n\n")
            f.write("```\n")
            f.write("organized_art/\n")
            for category in self.categories.keys():
                f.write(f"├── {category}/\n")
                f.write(f"│   ├── README.md\n")
                f.write(f"│   └── [asset folders...]\n")
            f.write("└── ORGANIZATION_SUMMARY.md\n")
            f.write("```\n\n")
            
            f.write("## Usage Guide\n\n")
            f.write("### For Game Development\n\n")
            for category, description in self.categories.items():
                category_name = category.replace('_', ' ').title()
                f.write(f"**{category_name}** (`{category}/`)\n")
                f.write(f"- {description}\n")
                f.write(f"- Perfect for: {self.get_usage_examples(category)}\n\n")
            
            f.write("### Attribution Requirements\n\n")
            f.write("Each asset folder contains `metadata.json` with:\n")
            f.write("- Original author and license\n")
            f.write("- Attribution requirements\n") 
            f.write("- Source URL for reference\n")
            f.write("- Original license folder (cc0, cc-by, etc.)\n\n")
            
            f.write("⚠️ **Remember**: Always check metadata.json for proper attribution!\n")
        
        print(f"📋 Summary report saved: {report_file}")
    
    def get_usage_examples(self, category: str) -> str:
        """Get usage examples for each category."""
        examples = {
            'sprite_sheets': 'Player animations, enemy movement cycles, character actions',
            'characters': 'Player sprites, NPCs, enemies, bosses',
            'tilesets': 'Level design, map creation, environment building',
            'backgrounds': 'Scene backgrounds, parallax layers, environment art',
            'ui_elements': 'Menus, HUD elements, interface design',
            'icons': 'Inventory items, collectibles, status indicators',
            'props': 'Environment decoration, interactive objects, scenery',
            'effects': 'Visual feedback, spell effects, explosions',
            'weapons': 'Player equipment, enemy weapons, power-ups',
            'environments': 'Complete level assets, themed areas',
            'misc': 'General purpose assets, mixed content'
        }
        return examples.get(category, 'Various game development purposes')
    
    def reorganize(self):
        """Main reorganization process."""
        print("🎨 Starting Art Asset Reorganization")
        print(f"📂 Source: {self.source_dir}")
        print(f"📁 Output: {self.output_dir}")
        print("-" * 50)
        
        # Create directory structure
        self.create_directory_structure()
        print("✓ Created organized directory structure")
        
        # Copy and organize assets
        organized_count, category_counts = self.copy_and_organize_assets()
        
        # Generate summary
        self.generate_summary_report(organized_count, category_counts)
        
        print(f"\n🎉 Reorganization Complete!")
        print(f"📊 {organized_count} assets organized into {len([c for c in category_counts.values() if c > 0])} categories")
        print(f"📁 Assets available in: {self.output_dir}")

def main():
    parser = argparse.ArgumentParser(description='Reorganize art assets by content type')
    parser.add_argument('--source-dir', type=str, 
                       default='../../assets/downloaded_opengameart',
                       help='Source directory with license-organized assets')
    parser.add_argument('--output-dir', type=str,
                       default='../../assets/organized_art',
                       help='Output directory for content-organized assets')
    
    args = parser.parse_args()
    
    # Validate source directory
    source_path = Path(args.source_dir)
    if not source_path.exists():
        print(f"❌ Source directory not found: {source_path}")
        print("Make sure you've run the OpenGameArt downloader first!")
        return
    
    # Create reorganizer and run
    reorganizer = ArtReorganizer(args.source_dir, args.output_dir)
    reorganizer.reorganize()

if __name__ == "__main__":
    main()
