PROTO_SRC=./tempconv.proto

# Output directories for generated code
GO_OUT=../backend/pb
FLUTTER_OUT=../frontend/lib/src/generated

all: go dart

# Generate Go code with gRPC support
go:
	mkdir -p $(GO_OUT)
	protoc --go_out=$(GO_OUT) --go_opt=paths=source_relative \
		--go-grpc_out=$(GO_OUT) --go-grpc_opt=paths=source_relative \
		-I . $(PROTO_SRC)

# Generate Dart code for Flutter with gRPC support
dart:
	mkdir -p $(FLUTTER_OUT)
	protoc --dart_out=grpc:$(FLUTTER_OUT) -I . $(PROTO_SRC)

clean:
	rm -rf $(GO_OUT) $(FLUTTER_OUT)

.PHONY: all go dart clean