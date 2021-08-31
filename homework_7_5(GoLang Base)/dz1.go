package main

import "fmt"

func main() {
    fmt.Print("Введите число для пересчета метров в футы: ")
    var input float64
    fmt.Scanf("%f", &input)

    output := input / 0.3048
    fmt.Println("Футов = ", output)
}