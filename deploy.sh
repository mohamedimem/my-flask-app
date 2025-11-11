#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Flask App Kubernetes Deployment ===${NC}"
echo ""

# Check if required tools are installed
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed. Please install it first.${NC}"
        exit 1
    fi
}

echo -e "${YELLOW}Checking prerequisites...${NC}"
check_command docker
check_command kubectl
check_command kind

# Function to print status
print_status() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Build Docker image
echo ""
echo -e "${YELLOW}=== Building Docker Image ===${NC}"
docker build -t flask-app:latest .

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Docker build failed${NC}"
    exit 1
fi
print_status "Docker image built successfully"

# Check if cluster exists and delete if it does
echo ""
echo -e "${YELLOW}=== Managing Kind Cluster ===${NC}"
if kind get clusters | grep -q "flask-cluster"; then
    print_warning "Cluster 'flask-cluster' already exists. Deleting it..."
    kind delete cluster --name flask-cluster
fi

# Create Kind cluster
echo ""
echo -e "${YELLOW}=== Creating Kind Cluster ===${NC}"
kind create cluster --name flask-cluster --config kind-cluster.yaml

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Kind cluster creation failed${NC}"
    exit 1
fi
print_status "Kind cluster created successfully"

# Install NGINX Ingress Controller
echo ""
echo -e "${YELLOW}=== Installing NGINX Ingress Controller ===${NC}"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo -e "${YELLOW}Waiting for Ingress Controller to be ready...${NC}"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Ingress controller failed to become ready${NC}"
    exit 1
fi
print_status "NGINX Ingress Controller installed and ready"

# Load Docker image into Kind cluster
echo ""
echo -e "${YELLOW}=== Loading Docker Image into Cluster ===${NC}"
kind load docker-image flask-app:latest --name flask-cluster
print_status "Docker image loaded into cluster"

# Deploy database (if postgresql.yaml exists)
if [ -f "k8s/postgresql.yaml" ]; then
    echo ""
    echo -e "${YELLOW}=== Deploying PostgreSQL Database ===${NC}"
    kubectl apply -f k8s/postgresql.yaml
    
    # Wait for database to be ready
    echo -e "${YELLOW}Waiting for database to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=postgresql --timeout=60s
    print_status "PostgreSQL database deployed and ready"
fi

# Deploy application components
echo ""
echo -e "${YELLOW}=== Deploying Application Components ===${NC}"

echo "1. Creating ConfigMap..."
kubectl apply -f k8s/configmap.yaml

echo "2. Creating Secrets..."
kubectl apply -f k8s/secret.yaml

echo "3. Deploying Application..."
kubectl apply -f k8s/deployment.yaml

echo "4. Creating Service..."
kubectl apply -f k8s/service.yaml

echo "5. Setting up Ingress..."
kubectl apply -f k8s/ingress.yaml

print_status "All application components deployed"

# Wait for application pods to be ready
echo ""
echo -e "${YELLOW}=== Waiting for Application to be Ready ===${NC}"
kubectl wait --for=condition=ready pod -l app=flask-app --timeout=120s

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Application pods failed to become ready${NC}"
    echo -e "${YELLOW}Checking pod status...${NC}"
    kubectl get pods -l app=flask-app
    kubectl describe pods -l app=flask-app
    exit 1
fi
print_status "Application pods are ready"

# Display deployment information
echo ""
echo -e "${BLUE}=== Deployment Complete! ===${NC}"
echo ""

echo -e "${YELLOW}=== Access Information ===${NC}"
echo ""
echo "To access your application, add these entries to your /etc/hosts file:"
echo -e "${GREEN}sudo tee -a /etc/hosts << EOF"
echo "127.0.0.1 flask-app.local"
echo "127.0.0.1 api.flask-app.local"
echo "127.0.0.1 admin.flask-app.local"
echo "EOF"
echo -e "${NC}"

echo -e "${YELLOW}Access URLs:${NC}"
echo -e "${GREEN}Main Application:  http://flask-app.local${NC}"
echo -e "${GREEN}API Endpoint:      http://api.flask-app.local${NC}"
echo -e "${GREEN}Admin Interface:   http://admin.flask-app.local${NC}"
echo -e "${GREEN}Direct Access:     http://localhost:8080${NC}"
echo ""

echo -e "${YELLOW}Test Endpoints:${NC}"
echo -e "${GREEN}Health Check:     http://flask-app.local/health${NC}"
echo -e "${GREEN}Configuration:    http://flask-app.local/config${NC}"
echo -e "${GREEN}Users API:        http://flask-app.local/users${NC}"
echo ""

# Display Kubernetes resources
echo -e "${YELLOW}=== Kubernetes Resources ===${NC}"
echo ""
echo -e "${BLUE}Pods:${NC}"
kubectl get pods -o wide

echo ""
echo -e "${BLUE}Services:${NC}"
kubectl get services

echo ""
echo -e "${BLUE}Ingress:${NC}"
kubectl get ingress

echo ""
echo -e "${BLUE}ConfigMaps:${NC}"
kubectl get configmaps

echo ""
echo -e "${BLUE}Secrets:${NC}"
kubectl get secrets

# Display useful commands
echo ""
echo -e "${YELLOW}=== Useful Commands ===${NC}"
echo -e "${GREEN}View all resources:          kubectl get all${NC}"
echo -e "${GREEN}View application logs:       kubectl logs -l app=flask-app${NC}"
echo -e "${GREEN}View ingress details:        kubectl describe ingress flask-app-ingress${NC}"
echo -e "${GREEN}View pod details:            kubectl describe pod -l app=flask-app${NC}"
echo -e "${GREEN}Scale application:           kubectl scale deployment flask-app --replicas=3${NC}"
echo -e "${GREEN}Delete deployment:           kubectl delete -f k8s/${NC}"
echo -e "${GREEN}Delete cluster:              kind delete cluster --name flask-cluster${NC}"

# Quick test
echo ""
echo -e "${YELLOW}=== Quick Test ===${NC}"
echo "Testing application health endpoint..."
sleep 5  # Give it a moment to fully initialize

if curl -s http://localhost:8080/health > /dev/null; then
    echo -e "${GREEN}Health check: PASSED${NC}"
    curl -s http://localhost:8080/health | jq . 2>/dev/null || curl -s http://localhost:8080/health
else
    echo -e "${RED}Health check: FAILED${NC}"
    echo "Application might need more time to initialize."
    echo "Run 'kubectl logs -l app=flask-app' to check logs."
fi

echo ""
echo -e "${GREEN}Deployment completed successfully! 🚀${NC}"