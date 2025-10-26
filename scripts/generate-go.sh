#!/bin/bash
set -e  # Exit on error

# Configuration
PROTO_DIR="./proto"  # Your proto files directory
OUT_DIR="./internal/pb"    # Output directory for generated Go code

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Generating Go stubs from proto files...${NC}"

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}❌ protoc not found. Please install Protocol Buffers compiler:${NC}"
    echo "   macOS:    brew install protobuf"
    echo "   Ubuntu:   sudo apt install protobuf-compiler"
    echo "   Windows:  Download from https://github.com/protocolbuffers/protobuf/releases"
    exit 1
fi

# Check if Go protoc plugins are installed
if ! command -v protoc-gen-go &> /dev/null; then
    echo -e "${YELLOW}⚠️  protoc-gen-go not found. Installing...${NC}"
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

if ! command -v protoc-gen-go-grpc &> /dev/null; then
    echo -e "${YELLOW}⚠️  protoc-gen-go-grpc not found. Installing...${NC}"
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
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

# Generate Go code
echo -e "${BLUE}⚙️  Generating Go code...${NC}"
protoc \
  --proto_path=. \
  --go_out="$OUT_DIR" \
  --go_opt=paths=source_relative \
  --go-grpc_out="$OUT_DIR" \
  --go-grpc_opt=paths=source_relative \
  $PROTO_FILES

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Go code generation complete!${NC}"
    echo -e "${GREEN}   Output: $OUT_DIR${NC}"
    
    # Show generated files
    GENERATED_COUNT=$(find "$OUT_DIR" -name "*.go" | wc -l | tr -d ' ')
    echo -e "${GREEN}   Generated $GENERATED_COUNT Go file(s)${NC}"
else
    echo -e "${RED}❌ Code generation failed${NC}"
    exit 1
fi
