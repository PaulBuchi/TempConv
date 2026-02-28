# syntax=docker/dockerfile:1

FROM ghcr.io/cirruslabs/flutter:stable AS flutter_build
WORKDIR /app

# Make Git happy with the Flutter SDK repo (safe.directory)
RUN git config --system --add safe.directory /sdks/flutter

# Create non-root user
RUN adduser --disabled-password --gecos "" --uid 10001 flutteruser \
  && mkdir -p /home/flutteruser/.flutter-cache \
  && mkdir -p /home/flutteruser/.pub-cache \
  && chown -R flutteruser:flutteruser /app /home/flutteruser

# Allow non-root to write Flutter SDK caches and tool package config
RUN mkdir -p /sdks/flutter/bin/cache \
  && chown -R flutteruser:flutteruser /sdks/flutter/bin/cache

RUN mkdir -p /sdks/flutter/packages/flutter_tools/.dart_tool \
  && chown -R flutteruser:flutteruser /sdks/flutter/packages/flutter_tools/.dart_tool

USER flutteruser

# Redirect Flutter/Dart caches away from /sdks/flutter
ENV FLUTTER_HOME=/sdks/flutter
ENV PUB_CACHE=/home/flutteruser/.pub-cache
ENV FLUTTER_CACHE_DIR=/home/flutteruser/.flutter-cache
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

# Cache deps first
COPY --chown=flutteruser:flutteruser pubspec.* ./
RUN flutter config --no-analytics && flutter pub get

# Copy source
COPY --chown=flutteruser:flutteruser . .

# Build args
#ARG API_BASE_URL=http://localhost:8080
ARG API_BASE_URL=

# Flutter 3.41: no --web-renderer flag
RUN rm -rf .dart_tool build && flutter build web --release \
  --dart-define=API_BASE_URL=${API_BASE_URL} \
  --tree-shake-icons

FROM nginx:alpine AS runtime
RUN rm -rf /usr/share/nginx/html/*
COPY --from=flutter_build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]