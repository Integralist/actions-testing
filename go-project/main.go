package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Printf("%#v\n", os.Environ())
	// 4
}
