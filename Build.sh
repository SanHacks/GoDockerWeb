#!/bin/bash

## Pull the Docker image if it's not available
#docker pull mysql:latest

# Build the Docker image
#docker build -t <image-name> .
# Build Docker image

# Use the official Golang image as the base image
FROM golang:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . .

# Install any required dependencies
RUN go mod download

# Build the Go application
RUN go build -o app .

# Use the official MySQL image as the base image for the database
FROM mysql:latest

# Set the root password
ENV MYSQL_ROOT_PASSWORD=root

# Create the database and set permissions
RUN echo "CREATE DATABASE StorePlatform;" | mysql -u root --password=$MYSQL_ROOT_PASSWORD
RUN echo "GRANT ALL PRIVILEGES ON StorePlatform.* TO 'root'@'%' WITH GRANT OPTION;" | mysql -u root --password=$MYSQL_ROOT_PASSWORD

# Use the Go image as the base image again
FROM golang:latest


docker build -t app .

# Start MySQL container
docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=StorePlatform -d -p 3306:3306 mysql:latest

# Copy the built Go application from the first stage
COPY --from=0 /app/app .

# Copy any required files
COPY config.yml .

# Expose the port the application will listen on
EXPOSE 8095

# Start the Go application
CMD ["./app"]
# Create basic template files
mkdir app
# shellcheck disable=SC2164
cd app
touch main.go
echo 'package main

import (
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello, World!"))
	})

	http.ListenAndServe(":8080", nil)
}' > main.go
touch Dockerfile
echo 'FROM golang:latest
RUN mkdir /app
ADD . /app
WORKDIR /app
EXPOSE 8080
CMD ["go", "run", "main.go"]' > Dockerfile
touch go.mod
echo 'module app

go 1.16

require (
	github.com/gorilla/mux v1.8.0
)' > go.mod
touch handlers.go
echo 'package main

import (
	"net/http"

	"github.com/gorilla/mux"
)

func homeHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Welcome to my app!"))
}

func userHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	username := vars["username"]
	w.Write([]byte("Hello, " + username))
}' > handlers.go
touch routes.go
echo 'package main

import (
	"github.com/gorilla/mux"
)

func routes() *mux.Router {
	router := mux.NewRouter()
	router.HandleFunc("/", homeHandler)
	router.HandleFunc("/users/{username}", userHandler).Methods("GET")
	return router
}' > routes.go

echo "Done."

