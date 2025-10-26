#!/bin/bash
PROTO_DIR="./proto"
OUT_DIR="./lib/proto"

mkdir -p $OUT_DIR

protoc \
  --dart_out=grpc:$OUT_DIR \
  --proto_path=$PROTO_DIR \
  $(find $PROTO_DIR -name "*.proto")