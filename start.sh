#!/bin/bash
# Quartz 启动脚本
# 用法: ./start.sh [端口号]

PORT=${1:-8090}
DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$DIR"
node ./quartz/bootstrap-cli.mjs build --serve --port "$PORT"
