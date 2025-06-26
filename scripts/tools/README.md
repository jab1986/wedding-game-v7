# OpenGameArt Downloader

A Python script to responsibly download 2D art assets from [OpenGameArt.org](https://opengameart.org/art-search-advanced?keys=&field_art_type_tid%5B%5D=9&sort_by=count&sort_order=DESC) with proper attribution and license management.

## Features

✅ **Respectful Downloading**
- Rate limiting (2+ seconds between requests)
- Proper User-Agent headers
- Resume interrupted downloads
- Error handling and retry logic

✅ **License Management**
- Automatically organizes files by license type
- Saves complete attribution metadata
- Generates usage summary reports

✅ **File Organization**
```
downloaded_art/
├── cc0/           # Public domain assets
├── cc-by/         # Attribution required
├── cc-by-sa/      # Attribution + share-alike
├── gpl/           # GPL licensed assets
├── other/         # Other licenses
└── metadata/      # Download logs and reports
```

## Installation

1. **Install Python dependencies:**
```bash
pip install -r requirements.txt
```

2. **Verify the script:**
```bash
python opengameart_downloader.py --help
```

## Usage

### Basic Usage
Download 5 pages of the most popular 2D art:
```bash
python opengameart_downloader.py
```

### Custom Options
```bash
# Download more pages (be respectful!)
python opengameart_downloader.py --max-pages=10

# Increase delay between requests
python opengameart_downloader.py --delay=3.0

# Custom output directory
python opengameart_downloader.py --output-dir=./game_assets

# Combine options
python opengameart_downloader.py --max-pages=3 --delay=2.5 --output-dir=./wedding_game_assets
```

## Important Usage Guidelines

⚠️ **Respect the Server**
- Default 2-second delay is the minimum recommended
- Don't run multiple instances simultaneously
- Consider the server load and community

⚠️ **License Compliance**
- Always check `metadata.json` files for attribution requirements
- CC-BY and CC-BY-SA require proper attribution
- GPL assets have specific sharing requirements
- CC0 assets are public domain but attribution is appreciated

⚠️ **Legal Considerations**
- Only download assets you have legitimate use for
- Respect the terms of service of OpenGameArt.org
- This script is for educational and game development purposes

## Output Structure

Each downloaded item creates a folder containing:
- `metadata.json` - Complete attribution and license information
- Art files (PNG, JPG, ZIP, etc.)

Example metadata.json:
```json
{
  "title": "Fantasy Character Sprites",
  "author": "ArtistName",
  "license": "CC-BY 3.0",
  "description": "Character sprites for RPG games...",
  "url": "https://opengameart.org/content/...",
  "download_links": ["https://..."]
}
```

## Resume Downloads

The script automatically:
- Saves progress in `download_log.json`
- Skips already downloaded items
- Can be safely interrupted and resumed

## Troubleshooting

**Common Issues:**
1. **Network errors:** Script will retry and continue
2. **Missing dependencies:** Run `pip install -r requirements.txt`
3. **Permission errors:** Check write permissions in output directory

**For Wedding Game Project:**
```bash
# Download wedding/fantasy themed assets
python opengameart_downloader.py --max-pages=5 --output-dir=./assets/downloaded_opengameart
```

## Ethical Usage

This script is designed to:
- Respect OpenGameArt.org's resources
- Maintain proper attribution
- Support the open source game art community

Please:
- Use reasonable download limits
- Contribute back to the community when possible
- Follow all license requirements
- Consider donating to OpenGameArt.org

## License

This downloader script is provided under MIT license for educational use.
Downloaded art assets retain their original licenses as specified by their creators.
