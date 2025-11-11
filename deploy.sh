#!/bin/bash

# Build Docker image
docker build -t flask-app:latest .

# Create Kind cluster
kind create cluster --name flask-cluster --config kind-cluster.yaml

# Load image into Kind cluster
kind load docker-image flask-app:latest --name flask-cluster

# Deploy to Kubernetes
kubectl apply -f k8s/

# Wait for deployment to be ready
kubectl wait --for=condition=ready pod -l app=flask-app --timeout=60s

# Get service info
echo "Deployment complete!"
echo "Access your app at: http://localhost:8080"
kubectl get services