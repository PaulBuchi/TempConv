package conversion

import "testing"

func TestCelsiusToFahrenheit(t *testing.T) {
    tests := []struct {
        celsius float64
        want   float64
    }{
        {0, 32},
        {100, 212},
        {-40, -40},
    }
    for _, tt := range tests {
        got := CelsiusToFahrenheit(tt.celsius)
        if got != tt.want {
            t.Errorf("CelsiusToFahrenheit(%v) = %v; want %v", tt.celsius, got, tt.want)
        }
    }
}

func TestFahrenheitToCelsius(t *testing.T) {
    tests := []struct {
        fahrenheit float64
        want       float64
    }{
        {32, 0},
        {212, 100},
        {-40, -40},
    }
    for _, tt := range tests {
        got := FahrenheitToCelsius(tt.fahrenheit)
        if got != tt.want {
            t.Errorf("FahrenheitToCelsius(%v) = %v; want %v", tt.fahrenheit, got, tt.want)
        }
    }
}