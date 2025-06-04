#!/bin/bash
# Batch format all Objective-C files

echo "Formatting Objective-C files..."

# Find and format all .m and .h files
find . -type f \( -name "*.m" -o -name "*.h" \) -not -path "./Pods/*" -not -path "./build/*" | while read -r file; do
    echo "Formatting: $file"
    clang-format -i "$file"
done

echo "Formatting complete!"