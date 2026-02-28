package main

import (
    "context"
    "log"
    "net"
    "os"
    "os/signal"
    "syscall"

    pb "github.com/PaulBuchi/TempConv/backend/pb"
    "github.com/PaulBuchi/TempConv/backend/internal/conversion"
    "google.golang.org/grpc"
)

// tempConvServer implements the TempConvService defined in the proto.
type tempConvServer struct {
    pb.UnimplementedTempConvServiceServer
}

// CelsiusToFahrenheit implements the gRPC method to convert Celsius to Fahrenheit.
func (s *tempConvServer) CelsiusToFahrenheit(ctx context.Context, req *pb.TemperatureRequest) (*pb.TemperatureResponse, error) {
    result := conversion.CelsiusToFahrenheit(req.GetValue())
    log.Printf("Converted %.2f°C to %.2f°F", req.GetValue(), result)
    return &pb.TemperatureResponse{Value: result}, nil
}

// FahrenheitToCelsius implements the gRPC method to convert Fahrenheit to Celsius.
func (s *tempConvServer) FahrenheitToCelsius(ctx context.Context, req *pb.TemperatureRequest) (*pb.TemperatureResponse, error) {
    result := conversion.FahrenheitToCelsius(req.GetValue())
    log.Printf("Converted %.2f°F to %.2f°C", req.GetValue(), result)
    return &pb.TemperatureResponse{Value: result}, nil
}

// healthServer implements the Health service defined in the proto.
type healthServer struct {
    pb.UnimplementedHealthServer
}

// Check simply returns a healthy status for liveness/readiness probes.
func (h *healthServer) Check(ctx context.Context, _ *pb.HealthCheckRequest) (*pb.HealthCheckResponse, error) {
    return &pb.HealthCheckResponse{Ok: true}, nil
}

func main() {
    addr := ":50051"
    lis, err := net.Listen("tcp", addr)
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }
    grpcServer := grpc.NewServer()
    pb.RegisterTempConvServiceServer(grpcServer, &tempConvServer{})
    pb.RegisterHealthServer(grpcServer, &healthServer{})

    // Setup graceful shutdown
    go func() {
        c := make(chan os.Signal, 1)
        signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
        <-c
        log.Println("Shutting down gRPC server…")
        grpcServer.GracefulStop()
    }()

    log.Printf("Starting TempConv gRPC server on %s", addr)
    if err := grpcServer.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}