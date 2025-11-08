#!/bin/bash
set -e

# Configuration
PROTO_DIR="./"
OUT_DIR="../lib/protos"

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

# Find all application proto files
APP_PROTO_FILES=$(find "$PROTO_DIR" -name "*.proto")

if [ -z "$APP_PROTO_FILES" ]; then
    echo -e "${RED}❌ No application .proto files found in $PROTO_DIR${NC}"
    exit 1
fi

# --- Cross-Platform Include Path Handling ---

PROTOBUF_INCLUDE_DIR=""

# Try common paths for Linux/macOS
if [ -d "/usr/local/include/google/protobuf" ]; then
    PROTOBUF_INCLUDE_DIR="/usr/local/include"
elif [ -d "/usr/include/google/protobuf" ]; then
    PROTOBUF_INCLUDE_DIR="/usr/include"
fi

# If not found, try common Windows paths (assuming Git Bash or similar env)
if [ -z "$PROTOBUF_INCLUDE_DIR" ] && [ -n "$SYSTEMDRIVE" ]; then
    # Common manual install location (e.g., C:\protoc-3.x.x-win64\)
    WIN_PROTOC_PATH=$(find /c/ -maxdepth 2 -name "protoc-*-win*" 2>/dev/null | head -n 1)
    if [ -n "$WIN_PROTOC_PATH" ] && [ -d "$WIN_PROTOC_PATH/include" ]; then
        PROTOBUF_INCLUDE_DIR="$WIN_PROTOC_PATH/include"
    fi

    # Common Chocolatey install location (C:\ProgramData\chocolatey\lib\protoc\tools\include)
    if [ -z "$PROTOBUF_INCLUDE_DIR" ] && [ -d "/c/ProgramData/chocolatey/lib/protoc/tools/include" ]; then
        PROTOBUF_INCLUDE_DIR="/c/ProgramData/chocolatey/lib/protoc/tools/include"
    fi
fi

if [ -z "$PROTOBUF_INCLUDE_DIR" ]; then
    echo -e "${YELLOW}⚠️  Standard Protobuf include directory not automatically found.${NC}"
    echo -e "${YELLOW}   Please set the PROTOBUF_INCLUDE_DIR variable in the script manually to the location of the 'google/protobuf' folder.${NC}"
    # Example manual set: export PROTOBUF_INCLUDE_DIR="/c/path/to/your/protoc/install/include"
fi

# Count proto files
PROTO_COUNT=$(echo "$APP_PROTO_FILES" | wc -l | tr -d ' ')
echo -e "${BLUE}📄 Found $PROTO_COUNT application proto file(s)${NC}"

# Generate Dart code
echo -e "${BLUE}⚙️  Generating Dart code...${NC}"

PROTO_PATHS="-I$PROTO_DIR"

if [ -n "$PROTOBUF_INCLUDE_DIR" ]; then
    PROTO_PATHS="$PROTO_PATHS -I$PROTOBUF_INCLUDE_DIR"
fi

protoc \
  $PROTO_PATHS \
  --dart_out=grpc:"$OUT_DIR" \
  $APP_PROTO_FILES \
  google/protobuf/timestamp.proto # Explicitly include the well-known type file

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
