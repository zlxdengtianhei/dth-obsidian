#!/bin/bash
# Obsidian Image Handler Script
# Place this in your vault and use with Obsidian Shell Commands plugin
# Or run manually to copy images from the root to their referenced _assets folders

VAULT_DIR="/Users/lexuanzhang/Library/Mobile Documents/iCloud~md~obsidian/Documents"
cd "$VAULT_DIR" || exit 1

# Find all PNG/JPG images in vault root that were just pasted
for img in *.png *.jpg *.jpeg 2>/dev/null; do
  [ -f "$img" ] || continue
  
  # Find which markdown file references this image
  ref=$(grep -rl "$img" . --include="*.md" 2>/dev/null | head -1)
  
  if [ -n "$ref" ]; then
    # Get the directory of the referencing markdown file
    ref_dir=$(dirname "$ref")
    
    # Create _assets folder if it doesn't exist
    assets_dir="${ref_dir}/_assets"
    mkdir -p "$assets_dir"
    
    # Move image to assets folder
    mv "$img" "$assets_dir/"
    
    # Update the reference in the markdown file
    new_path="${ref_dir}/_assets/${img}"
    sed -i '' "s|$img|$new_path|g" "$ref"
    
    echo "Moved $img to $assets_dir/"
  fi
done
