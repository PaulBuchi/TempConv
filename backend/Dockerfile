# syntax=docker/dockerfile:1

# Multi-stage build for TempConv backend
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Copy go mod and sum files
COPY go.mod* ./

# Download dependencies early to leverage layer caching
RUN go mod download

# Copy source code
COPY . .

# Build the Go binary for linux/amd64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o tempconv ./cmd/server

FROM gcr.io/distroless/base-debian11
# Use non-root user for security
USER nonroot:nonroot

COPY --from=builder /app/tempconv /usr/local/bin/tempconv

EXPOSE 50051
ENTRYPOINT ["/usr/local/bin/tempconv"]