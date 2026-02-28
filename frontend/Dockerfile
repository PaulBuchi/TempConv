# syntax=docker/dockerfile:1

# Build stage: use the official Flutter image to build the web app
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy pubspec files first to leverage Docker layer caching for dependencies
COPY pubspec.* ./

RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Accept API_BASE_URL at build time
ARG API_BASE_URL=http://localhost:8080

RUN flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL} \
    --web-renderer html --tree-shake-icons

# Runtime stage: use Nginx to serve static files
FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]