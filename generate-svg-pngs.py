#!/usr/bin/env python3
# generate-svg-pngs.py

import os
import sys
import argparse
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

CONTENT_DIR = "content"

def extract_viewbox_dimensions(svg_path):
    """Extract width and height from SVG viewBox attribute."""
    try:
        tree = ET.parse(svg_path)
        root = tree.getroot()
        
        # Handle SVG namespace
        viewbox = root.get('viewBox')
        if viewbox:
            # viewBox format: "min-x min-y width height"
            parts = viewbox.split()
            if len(parts) == 4:
                width = float(parts[2])
                height = float(parts[3])
                return int(width), int(height)
        
        # Fallback to width/height attributes
        width = root.get('width')
        height = root.get('height')
        if width and height:
            # Strip units like 'px' if present
            width = float(width.rstrip('px'))
            height = float(height.rstrip('px'))
            return int(width), int(height)
            
    except Exception as e:
        print(f"Warning: Could not parse {svg_path}: {e}")
    
    # Default fallback
    return 800, 600

def generate_png(svg_path, png_path, width, height):
    """Generate PNG from SVG using Chrome headless."""
    svg_abs_path = svg_path.resolve()
    png_abs_path = png_path.resolve()
    
    # Chrome saves screenshot relative to cwd, so we need to change directory
    original_cwd = os.getcwd()
    os.chdir(png_path.parent)
    
    cmd = [
        'google-chrome',
        '--headless',
        f'--screenshot={png_path.name}',
        f'--window-size={width},{height}',
        '--default-background-color=00000000',
        '--disable-gpu',
        '--hide-scrollbars',
        f'file://{svg_abs_path}'
    ]
    
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        # Check if file exists using just the filename in current (changed) directory
        success = Path(png_path.name).exists()
        return success
    except subprocess.CalledProcessError as e:
        print(f"Error running Chrome: {e}")
        print(f"  stdout: {e.stdout}")
        print(f"  stderr: {e.stderr}")
        return False
    finally:
        os.chdir(original_cwd)

def main():
    parser = argparse.ArgumentParser(description='Generate PNG files from SVG files')
    parser.add_argument('-f', '--force', action='store_true',
                       help='Force regeneration of all PNGs, ignoring modification times')
    args = parser.parse_args()
    
    content_path = Path(CONTENT_DIR)
    
    if not content_path.exists():
        print(f"Error: {CONTENT_DIR} directory not found")
        return
    
    svg_files = list(content_path.rglob("*.svg"))
    
    if not svg_files:
        print(f"No SVG files found in {CONTENT_DIR}")
        return
    
    for svg_file in svg_files:
        png_file = svg_file.with_suffix('.png')
        
        # Skip if PNG is newer than SVG (unless force flag is set)
        if not args.force and png_file.exists() and png_file.stat().st_mtime > svg_file.stat().st_mtime:
            print(f"Skipping {svg_file.relative_to(content_path)} (PNG up to date)")
            continue
        
        print(f"Generating PNG for {svg_file.relative_to(content_path)}")
        
        width, height = extract_viewbox_dimensions(svg_file)
        print(f"  Dimensions: {width}x{height}")
        
        if generate_png(svg_file, png_file, width, height):
            print(f"  Created {png_file.name}")
        else:
            print(f"  Failed to create {png_file.name}")
    
    print("PNG generation complete")

if __name__ == "__main__":
    main()
