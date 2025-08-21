package main

import (
	"fmt"
	"time"
)

func main() {
	for {
		fmt.Println("worker")
		time.Sleep(time.Minute)
	}
}
