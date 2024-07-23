package main

import (
    "fmt"
    "net/http"
    "os"
)

func main() {
    http.HandleFunc("/", hello)
    http.HandleFunc("/healthcheck", healthcheck)


    port := os.Getenv("PORT")
    if port == "" {
        port = "8888"
    }

    err := http.ListenAndServe(":" + port, nil)
    if err != nil {
        panic(err)
    }
}

func hello(res http.ResponseWriter, req *http.Request) {
    fmt.Fprintln(res, "hello, world!")
}

func healthcheck(res http.ResponseWriter, req *http.Request) {
    fmt.Fprintln(res, "WORKING")
}
