package main

import (
	"fmt"
	"io/ioutil"
	"os"
)

// Running:
// go run example.go

func check(e error) {
	if e != nil {
		panic(e)
	}
}

type solver struct {
	filename string
}

func (s solver) Solve() string {
	var input = s.ReadFile()
	return input
}

func (s solver) ReadFile() string {
	dat, err := ioutil.ReadFile(s.filename)
	check(err)
	return string(dat)
}

func main() {
	var s solver
	if len(os.Args) > 1 {
		s = solver{os.Args[1]}
	} else {
		s = solver{"input.txt"}
	}

	var result = s.Solve()
	fmt.Println(result)
}
