package main

import (
	"github.com/marcusbello/proglog/internal/server"
	"log"
)

func main() {
	srv := server.NewHTTPServer(":8000")
	log.Fatal(srv.ListenAndServe())
}
