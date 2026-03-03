#!/bin/bash
# deploy.sh - Deploys the React app Docker container to the server

set -e  # Exit immediately on error

IMAGE_NAME="react-devops-app"
IMAGE_TAG="${1:-latest}"
CONTAINER_NAME="react-app"

echo "========================================"
echo "  Deploying Docker Container"
echo "  Image: $IMAGE_NAME:$IMAGE_TAG"
echo "========================================"

# Stop and remove existing container if running
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "⏹️  Stopping existing container: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME"
fi

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "🗑️  Removing existing container: $CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi

# Run the new container
echo "🚀 Starting new container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    --restart always \
    -p 80:80 \
    "$IMAGE_NAME:$IMAGE_TAG"

echo ""
echo "✅ Deployment successful!"
echo "   App is running at http://localhost"
echo "========================================"
