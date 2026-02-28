# TempConv

TempConv is a simple temperature conversion application implemented using gRPC and Protocol Buffers.  It provides two RPC methods for converting temperatures between Celsius and Fahrenheit.  The project is designed to be cloud‑native, containerised with Docker and deployable on Google Kubernetes Engine (GKE).  A Flutter web frontend communicates with the Go backend via gRPC‑Web through an Envoy proxy.

## Repository Structure

    .
    ├── backend/         # Go gRPC server implementation
    │   ├── cmd/server   # Main server entry point
    │   ├── internal     # Conversion logic and tests
    │   ├── pb           # Generated Go code from proto definitions
    │   └── Dockerfile   # Multi‑stage build for backend
    ├── frontend/        # Flutter web client
    │   ├── lib          # Dart source, including gRPC client
    │   ├── pubspec.yaml # Flutter dependencies
    │   ├── nginx.conf   # Nginx configuration for serving the web app
    │   └── Dockerfile   # Multi‑stage build for frontend
    ├── proto/           # Protocol Buffer definitions and Makefile
    ├── deploy/k8s/      # Kubernetes manifests (envoy, backend, frontend)
    ├── scripts/         # Load testing script using k6
    └── README.md        # This file

## Getting Started

### Prerequisites

To build and run this project you need the following tools installed locally:

* **Go** 1.20 or higher
* **Flutter** with web support (`flutter config --enable-web`)
* **protoc** and the `protoc-gen-go`, `protoc-gen-go-grpc` and `protoc-gen-dart` plugins
* **Docker** with Buildx for multi‑arch builds
* **kubectl** and **gcloud** if deploying to GKE

### Generating gRPC Code

The protocol definitions reside in `proto/tempconv.proto`.  Use the Makefile to generate Go and Dart code:

    cd proto
    make

The generated Go code will be output to `backend/pb/` and the Dart code will be output to `frontend/lib/src/generated/`.

### Running the Backend Locally

From the `backend/` directory, run:

    go run ./cmd/server

The server listens on port `50051`.  You can test it using [grpcurl](https://github.com/fullstorydev/grpcurl):

    grpcurl -plaintext localhost:50051 tempconv.TempConvService/CelsiusToFahrenheit -d '{"value":100}'

### Running the Frontend Locally

In the `frontend/` directory run:

    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:50051

This command starts a Flutter development server.  The UI will call the backend directly at the specified base URL.  Note that for production you should use Envoy as a gRPC‑Web proxy.

### Building Docker Images

Use `docker buildx` to build multi‑arch images for the backend and frontend:

    # Build backend image
    cd backend
    docker buildx build --platform linux/amd64 -t tempconv-backend:latest .

    # Build frontend image
    cd ../frontend
    docker buildx build --platform linux/amd64 -t tempconv-frontend:latest .

### Deploying to GKE

Refer to the `deploy/k8s/` manifests to deploy Envoy, backend and frontend services on a Kubernetes cluster.  Replace `<project>` placeholders with your actual Google Cloud project ID and push images to Artifact Registry before applying the manifests.

    kubectl apply -f deploy/k8s/envoy.yaml
    kubectl apply -f deploy/k8s/backend.yaml
    kubectl apply -f deploy/k8s/frontend.yaml

After deployment, use `kubectl get svc envoy` to obtain the external LoadBalancer IP.  The frontend will be available at `http://<external-ip>/` and the gRPC endpoint at `http://<external-ip>/api.tempconv.TempConvService/`.

### Load Testing

The `scripts/loadtest.js` file uses k6 to simulate concurrent gRPC requests against the service.  To run the test, set the `GRPC_TARGET` environment variable to the Envoy service address and use the `grafana/k6` Docker image:

    docker run --rm -i grafana/k6 run -e GRPC_TARGET=<envoy_ip>:80 scripts/loadtest.js

### CI/CD

A GitHub Actions workflow can be added to automatically run tests, build images and deploy to GKE on every push.  See the project guide for details.