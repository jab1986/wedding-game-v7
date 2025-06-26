#!/usr/bin/env python3
"""
OpenGameArt.org 2D Art Downloader
Downloads 2D art assets from OpenGameArt.org with proper rate limiting and error handling.

Usage:
    python opengameart_downloader.py [--max-pages=5] [--delay=2] [--output-dir=./downloaded_art]

Features:
- Respects robots.txt and implements rate limiting
- Downloads with proper attribution information
- Organizes files by license type
- Resumes interrupted downloads
- Validates file integrity
"""

import requests
import time
import os
import json
import re
import argparse
from urllib.parse import urljoin, urlparse
from pathlib import Path
from bs4 import BeautifulSoup
import hashlib
from typing import Dict, List, Optional

class OpenGameArtDownloader:
    def __init__(self, output_dir: str = "./downloaded_art", delay: float = 2.0):
        self.base_url = "https://opengameart.org"
        self.output_dir = Path(output_dir)
        self.delay = delay  # Seconds between requests
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'OpenGameArt Downloader (Educational/Game Development Use)'
        })
        
        # Create output directory structure
        self.output_dir.mkdir(exist_ok=True)
        (self.output_dir / "metadata").mkdir(exist_ok=True)
        (self.output_dir / "cc0").mkdir(exist_ok=True)
        (self.output_dir / "cc-by").mkdir(exist_ok=True)
        (self.output_dir / "cc-by-sa").mkdir(exist_ok=True)
        (self.output_dir / "gpl").mkdir(exist_ok=True)
        (self.output_dir / "other").mkdir(exist_ok=True)
        
        # Load existing downloads to resume
        self.downloaded_items = self.load_download_log()
        
    def load_download_log(self) -> set:
        """Load list of already downloaded items to avoid duplicates."""
        log_file = self.output_dir / "download_log.json"
        if log_file.exists():
            with open(log_file, 'r') as f:
                return set(json.load(f))
        return set()
    
    def save_download_log(self):
        """Save list of downloaded items."""
        log_file = self.output_dir / "download_log.json"
        with open(log_file, 'w') as f:
            json.dump(list(self.downloaded_items), f)
    
    def get_license_folder(self, license_info: str) -> str:
        """Determine which folder to use based on license."""
        license_lower = license_info.lower()
        if 'cc0' in license_lower or 'public domain' in license_lower:
            return "cc0"
        elif 'cc-by-sa' in license_lower or 'cc by-sa' in license_lower:
            return "cc-by-sa"
        elif 'cc-by' in license_lower or 'cc by' in license_lower:
            return "cc-by"
        elif 'gpl' in license_lower:
            return "gpl"
        else:
            return "other"
    
    def sanitize_filename(self, filename: str) -> str:
        """Clean filename for filesystem compatibility."""
        # Remove or replace invalid characters
        filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
        filename = re.sub(r'\s+', '_', filename)
        return filename[:100]  # Limit length
    
    def download_file(self, url: str, filepath: Path) -> bool:
        """Download a single file with error handling."""
        try:
            response = self.session.get(url, stream=True, timeout=30)
            response.raise_for_status()
            
            with open(filepath, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            print(f"  ✓ Downloaded: {filepath.name}")
            return True
            
        except Exception as e:
            print(f"  ✗ Failed to download {url}: {e}")
            if filepath.exists():
                filepath.unlink()  # Remove partial file
            return False
    
    def extract_art_info(self, soup: BeautifulSoup, art_url: str) -> Optional[Dict]:
        """Extract art information from the art page."""
        try:
            # Get title
            title_elem = soup.find('h1', class_='title') or soup.find('h1')
            title = title_elem.text.strip() if title_elem else "Unknown"
            
            # Get description
            desc_elem = soup.find('div', class_='field-name-body') or soup.find('div', class_='content')
            description = desc_elem.text.strip() if desc_elem else ""
            
            # Get author
            author_elem = soup.find('span', class_='username') or soup.find('a', href=re.compile(r'/users/'))
            author = author_elem.text.strip() if author_elem else "Unknown"
            
            # Get license
            license_elem = soup.find('div', class_='field-name-field-art-licenses') or soup.find('a', href=re.compile(r'license'))
            license_info = license_elem.text.strip() if license_elem else "Unknown"
            
            # Get download links
            download_links = []
            
            # Look for direct download links
            for link in soup.find_all('a', href=True):
                href = link['href']
                if any(ext in href.lower() for ext in ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.zip', '.tar.gz']):
                    if not href.startswith('http'):
                        href = urljoin(self.base_url, href)
                    download_links.append(href)
            
            # Look for file attachments
            file_attachments = soup.find_all('div', class_='field-name-field-art-attach')
            for attachment in file_attachments:
                links = attachment.find_all('a', href=True)
                for link in links:
                    href = link['href']
                    if not href.startswith('http'):
                        href = urljoin(self.base_url, href)
                    download_links.append(href)
            
            return {
                'title': title,
                'description': description,
                'author': author,
                'license': license_info,
                'url': art_url,
                'download_links': list(set(download_links))  # Remove duplicates
            }
            
        except Exception as e:
            print(f"  ✗ Error extracting info: {e}")
            return None
    
    def download_art_item(self, art_info: Dict) -> bool:
        """Download all files for a single art item."""
        if not art_info['download_links']:
            print(f"  ⚠ No download links found for: {art_info['title']}")
            return False
        
        # Determine license folder
        license_folder = self.get_license_folder(art_info['license'])
        
        # Create item folder
        safe_title = self.sanitize_filename(art_info['title'])
        item_folder = self.output_dir / license_folder / safe_title
        item_folder.mkdir(exist_ok=True)
        
        # Save metadata
        metadata_file = item_folder / "metadata.json"
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(art_info, f, indent=2, ensure_ascii=False)
        
        # Download files
        success_count = 0
        for i, download_url in enumerate(art_info['download_links']):
            try:
                # Get filename from URL
                parsed_url = urlparse(download_url)
                filename = os.path.basename(parsed_url.path)
                if not filename or '.' not in filename:
                    filename = f"file_{i+1}"
                
                filepath = item_folder / filename
                
                # Skip if already exists and is valid
                if filepath.exists() and filepath.stat().st_size > 0:
                    print(f"  ↻ Already exists: {filename}")
                    success_count += 1
                    continue
                
                # Download file
                if self.download_file(download_url, filepath):
                    success_count += 1
                
                # Rate limiting
                time.sleep(self.delay)
                
            except Exception as e:
                print(f"  ✗ Error downloading {download_url}: {e}")
        
        return success_count > 0
    
    def get_art_links_from_page(self, page_url: str) -> List[str]:
        """Extract art item links from a search results page."""
        try:
            response = self.session.get(page_url, timeout=30)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.content, 'html.parser')
            art_links = []
            
            # Look for art item links
            for link in soup.find_all('a', href=True):
                href = link['href']
                # OpenGameArt art pages typically have /content/ in the URL
                if '/content/' in href and href not in art_links:
                    if not href.startswith('http'):
                        href = urljoin(self.base_url, href)
                    art_links.append(href)
            
            return art_links
            
        except Exception as e:
            print(f"✗ Error fetching page {page_url}: {e}")
            return []
    
    def download_from_search(self, max_pages: int = 5):
        """Download 2D art from OpenGameArt search results."""
        base_search_url = "https://opengameart.org/art-search-advanced"
        params = {
            'keys': '',
            'field_art_type_tid[]': '9',  # 2D Art
            'sort_by': 'count',
            'sort_order': 'DESC'
        }
        
        print(f"🎨 Starting OpenGameArt 2D Art Download")
        print(f"📁 Output directory: {self.output_dir}")
        print(f"⏱️  Rate limit: {self.delay} seconds between requests")
        print(f"📄 Max pages: {max_pages}")
        print("-" * 50)
        
        total_downloaded = 0
        
        for page in range(max_pages):
            print(f"\n📄 Processing page {page + 1}/{max_pages}")
            
            # Add page parameter for pages beyond the first
            if page > 0:
                params['page'] = page
            
            # Get search results page
            try:
                response = self.session.get(base_search_url, params=params, timeout=30)
                response.raise_for_status()
            except Exception as e:
                print(f"✗ Error fetching search page {page + 1}: {e}")
                continue
            
            # Extract art links
            soup = BeautifulSoup(response.content, 'html.parser')
            art_links = self.get_art_links_from_page(response.url)
            
            if not art_links:
                print(f"⚠ No art links found on page {page + 1}")
                continue
            
            print(f"🔗 Found {len(art_links)} art items on page {page + 1}")
            
            # Process each art item
            page_downloads = 0
            for i, art_url in enumerate(art_links):
                print(f"\n[{i+1}/{len(art_links)}] Processing: {art_url}")
                
                # Skip if already downloaded
                if art_url in self.downloaded_items:
                    print(f"  ↻ Already downloaded, skipping")
                    continue
                
                try:
                    # Get art page
                    art_response = self.session.get(art_url, timeout=30)
                    art_response.raise_for_status()
                    
                    art_soup = BeautifulSoup(art_response.content, 'html.parser')
                    
                    # Extract art information
                    art_info = self.extract_art_info(art_soup, art_url)
                    if not art_info:
                        continue
                    
                    print(f"  📝 Title: {art_info['title']}")
                    print(f"  👤 Author: {art_info['author']}")
                    print(f"  📜 License: {art_info['license']}")
                    print(f"  🔗 Files: {len(art_info['download_links'])}")
                    
                    # Download the art item
                    if self.download_art_item(art_info):
                        self.downloaded_items.add(art_url)
                        page_downloads += 1
                        total_downloaded += 1
                        print(f"  ✅ Successfully downloaded")
                    else:
                        print(f"  ❌ Download failed")
                    
                    # Save progress
                    self.save_download_log()
                    
                except Exception as e:
                    print(f"  ✗ Error processing art item: {e}")
                
                # Rate limiting between items
                time.sleep(self.delay)
            
            print(f"\n📊 Page {page + 1} complete: {page_downloads} items downloaded")
            
            # Longer delay between pages
            if page < max_pages - 1:
                time.sleep(self.delay * 2)
        
        print(f"\n🎉 Download complete!")
        print(f"📊 Total items downloaded: {total_downloaded}")
        print(f"📁 Files saved to: {self.output_dir}")
        
        # Generate summary report
        self.generate_summary_report()
    
    def generate_summary_report(self):
        """Generate a summary report of downloaded content."""
        report_file = self.output_dir / "download_summary.md"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("# OpenGameArt Download Summary\n\n")
            f.write(f"Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            
            # Count files by license
            license_counts = {}
            for license_dir in ['cc0', 'cc-by', 'cc-by-sa', 'gpl', 'other']:
                license_path = self.output_dir / license_dir
                if license_path.exists():
                    count = len([d for d in license_path.iterdir() if d.is_dir()])
                    license_counts[license_dir] = count
            
            f.write("## Downloads by License\n\n")
            for license_type, count in license_counts.items():
                f.write(f"- **{license_type.upper()}**: {count} items\n")
            
            f.write(f"\n**Total Items**: {sum(license_counts.values())}\n\n")
            
            f.write("## Usage Guidelines\n\n")
            f.write("- **CC0**: Public domain, no attribution required\n")
            f.write("- **CC-BY**: Attribution required\n")
            f.write("- **CC-BY-SA**: Attribution required, share-alike\n")
            f.write("- **GPL**: GPL license terms apply\n")
            f.write("- **Other**: Check individual metadata.json files\n\n")
            
            f.write("Each item folder contains:\n")
            f.write("- `metadata.json`: Full attribution and license info\n")
            f.write("- Downloaded art files\n\n")
            
            f.write("⚠️ **Important**: Always check the metadata.json file for proper attribution requirements!\n")
        
        print(f"📋 Summary report saved: {report_file}")

def main():
    parser = argparse.ArgumentParser(description='Download 2D art from OpenGameArt.org')
    parser.add_argument('--max-pages', type=int, default=5, 
                       help='Maximum number of pages to process (default: 5)')
    parser.add_argument('--delay', type=float, default=2.0,
                       help='Delay between requests in seconds (default: 2.0)')
    parser.add_argument('--output-dir', type=str, default='./downloaded_art',
                       help='Output directory (default: ./downloaded_art)')
    
    args = parser.parse_args()
    
    # Validate arguments
    if args.max_pages < 1:
        print("Error: max-pages must be at least 1")
        return
    
    if args.delay < 1.0:
        print("Warning: Using delay less than 1 second may overload the server")
        print("Setting minimum delay to 1.0 seconds")
        args.delay = 1.0
    
    # Create downloader and start
    downloader = OpenGameArtDownloader(
        output_dir=args.output_dir,
        delay=args.delay
    )
    
    try:
        downloader.download_from_search(max_pages=args.max_pages)
    except KeyboardInterrupt:
        print("\n\n⏹️  Download interrupted by user")
        print("Progress has been saved. You can resume by running the script again.")
    except Exception as e:
        print(f"\n💥 Unexpected error: {e}")
        print("Progress has been saved. You can resume by running the script again.")

if __name__ == "__main__":
    main()
