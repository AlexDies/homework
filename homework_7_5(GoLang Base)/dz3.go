package main

import "fmt"

func main() {
    end := 0
    for i := 0; i<100; i++ {
        end +=i
        if i % 3 ==0 && i != 0 {
        fmt.Println(i)
        }
    }
}
