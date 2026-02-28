package main

import (
	"context"
	"fmt"
	"log"
	"time"

	pb "github.com/PaulBuchi/TempConv/backend/pb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	conn, err := grpc.NewClient("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	c := pb.NewTempConvServiceClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	resp, err := c.CelsiusToFahrenheit(ctx, &pb.TemperatureRequest{Value: 100})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("100C -> %.2fF\n", resp.Value)
}
