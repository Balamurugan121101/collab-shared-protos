#!/bin/bash
PROTO_DIR="./proto"
OUT_DIR="./gen/go"

mkdir -p $OUT_DIR

protoc \
  --go_out=$OUT_DIR \
  --go-grpc_out=$OUT_DIR \
  --proto_path=$PROTO_DIR \
  $(find $PROTO_DIR -name "*.proto")