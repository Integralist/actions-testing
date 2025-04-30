package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Printf("%#v\n", os.Environ())
	// new change to test ci label addition
}
