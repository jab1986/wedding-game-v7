#!/bin/bash
# Demo usage examples for the OpenGameArt downloader

echo "🎨 OpenGameArt Downloader - Usage Examples"
echo "=========================================="
echo ""

echo "📋 Available commands:"
echo ""

echo "1. Basic download (5 pages, 2s delay):"
echo "   python3 opengameart_downloader.py"
echo ""

echo "2. Conservative download (3 pages, 3s delay):"
echo "   python3 opengameart_downloader.py --max-pages=3 --delay=3.0"
echo ""

echo "3. Wedding game assets (custom directory):"
echo "   python3 opengameart_downloader.py --max-pages=5 --output-dir=../assets/downloaded_opengameart"
echo ""

echo "4. Large collection (be very careful!):"
echo "   python3 opengameart_downloader.py --max-pages=10 --delay=4.0"
echo ""

echo "📁 Output structure will be:"
echo "   downloaded_art/"
echo "   ├── cc0/              # Public domain"
echo "   ├── cc-by/            # Attribution required"
echo "   ├── cc-by-sa/         # Attribution + share-alike"
echo "   ├── gpl/              # GPL licensed"
echo "   ├── other/            # Other licenses"
echo "   ├── download_log.json # Resume capability"
echo "   └── download_summary.md # Usage report"
echo ""

echo "⚠️  Important:"
echo "   - Each page has ~24 art items"
echo "   - Respect the 2+ second delay minimum"
echo "   - Always check metadata.json for attribution"
echo "   - Script can be interrupted and resumed"
echo ""

echo "🚀 To start downloading:"
echo "   cd scripts/tools"
echo "   python3 opengameart_downloader.py --max-pages=3"
