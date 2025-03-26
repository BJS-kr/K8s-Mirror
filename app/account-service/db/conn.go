package db

import (
	"database/sql"
	"log"

	_ "github.com/lib/pq"
)

func NewConn(connStr string) *sql.DB {

	db, err := sql.Open("postgres", connStr)

	if err != nil {
		log.Fatal(err)
	}

	return db
}
