#!/bin/bash
set -e

# Configuration
PROTO_DIR="./proto/proto"
OUT_DIR="./lib/protos"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔨 Generating Dart stubs from proto files...${NC}"

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}❌ protoc not found. Please install it first.${NC}"
    exit 1
fi

# Check if Dart protoc plugin is installed
if ! command -v protoc-gen-dart &> /dev/null; then
    echo -e "${YELLOW}⚠️  protoc-gen-dart not found. Installing...${NC}"
    dart pub global activate protoc_plugin
    export PATH="$PATH:$HOME/.pub-cache/bin"
fi

# Verify proto directory exists
if [ ! -d "$PROTO_DIR" ]; then
    echo -e "${RED}❌ Proto directory not found: $PROTO_DIR${NC}"
    exit 1
fi

# Clean and create output directory
echo -e "${BLUE}📁 Cleaning output directory...${NC}"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

# Find all proto files
PROTO_FILES=$(find "$PROTO_DIR" -name "*.proto")

if [ -z "$PROTO_FILES" ]; then
    echo -e "${RED}❌ No .proto files found in $PROTO_DIR${NC}"
    exit 1
fi

# Count proto files
PROTO_COUNT=$(echo "$PROTO_FILES" | wc -l | tr -d ' ')
echo -e "${BLUE}📄 Found $PROTO_COUNT proto file(s)${NC}"

# Generate Dart code
echo -e "${BLUE}⚙️  Generating Dart code...${NC}"
protoc \
  --proto_path=. \
  --dart_out=grpc:"$OUT_DIR" \
  $PROTO_FILES

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dart code generation complete!${NC}"
    echo -e "${GREEN}   Output: $OUT_DIR${NC}"
    
    # Show generated files
    GENERATED_COUNT=$(find "$OUT_DIR" -name "*.dart" | wc -l | tr -d ' ')
    echo -e "${GREEN}   Generated $GENERATED_COUNT Dart file(s)${NC}"
else
    echo -e "${RED}❌ Code generation failed${NC}"
    exit 1
fi
