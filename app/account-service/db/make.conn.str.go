package db

import (
	"fmt"
	"log"
	"os"
)

func MakeConnString() string {
	DB_USER := os.Getenv("DB_USER")
	if DB_USER == "" {
		log.Fatal("DB_USER is not set")
	}

	DB_PASSWORD := os.Getenv("DB_PASSWORD")
	if DB_PASSWORD == "" {
		log.Fatal("DB_PASSWORD is not set")
	}

	DB_HOST := os.Getenv("DB_HOST")
	if DB_HOST == "" {
		log.Fatal("DB_HOST is not set")
	}

	DB_PORT := os.Getenv("DB_PORT")
	if DB_PORT == "" {
		log.Fatal("DB_PORT is not set")
	}

	DB_NAME := os.Getenv("DB_NAME")
	if DB_NAME == "" {
		log.Fatal("DB_NAME is not set")
	}

	return fmt.Sprintf("user=%s host=%s port=%s password=%s dbname=%s sslmode=disable", DB_USER, DB_HOST, DB_PORT, DB_PASSWORD, DB_NAME)
}
