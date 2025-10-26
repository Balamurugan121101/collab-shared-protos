#!/bin/bash
set -e

echo "🚀 Generating all proto stubs..."
echo ""

# Run Go generation
if [ -f "scripts/generate-go.sh" ]; then
    ./scripts/generate-go.sh
else
    echo "⚠️  generate-go.sh not found, skipping..."
fi

echo ""

# Run Dart generation
if [ -f "scripts/generate-dart.sh" ]; then
    ./scripts/generate-dart.sh
else
    echo "⚠️  generate-dart.sh not found, skipping..."
fi

echo ""
echo "✅ All proto generation complete!"
