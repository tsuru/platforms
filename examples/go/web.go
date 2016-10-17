// Copyright 2016 tsuru authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"flag"
	"net/http"
	"os"
)

var hook bool

func init() {
	flag.BoolVar(&hook, "h", false, "run hook")
}

func main() {
	flag.Parse()
	if hook {
		println("hello")
		return
	}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello world from tsuru"))
	})
	port := os.Getenv("PORT")
	if port == "" {
		port = "5000"
	}
	http.ListenAndServe(":"+port, nil)
}
