#!/bin/bash
# build.sh - Builds the Docker image for the React app

set -e  # Exit immediately on error

IMAGE_NAME="react-devops-app"
IMAGE_TAG="${1:-latest}"  # Accept tag as argument, default to 'latest'

echo "========================================"
echo "  Building Docker Image"
echo "  Image: $IMAGE_NAME:$IMAGE_TAG"
echo "========================================"

docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

echo ""
echo "✅ Build successful: $IMAGE_NAME:$IMAGE_TAG"
echo "========================================"
