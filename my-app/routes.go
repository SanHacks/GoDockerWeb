package main

import (
	"github.com/gorilla/mux"
)

func routes() *mux.Router {
	router := mux.NewRouter()
	router.HandleFunc("/", homeHandler)
	router.HandleFunc("/users/{username}", userHandler).Methods("GET")
	return router
}
