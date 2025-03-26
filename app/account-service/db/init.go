package db

import (
	"database/sql"
	"strings"

	_ "github.com/lib/pq"
)

func Init(conn *sql.DB) error {
	_, err := conn.Exec(`
	CREATE DATABASE account_service
	`)

	if err != nil && !strings.Contains(err.Error(), "already exists") {
		return err
	}

	_, err = conn.Exec(`
		CREATE TABLE IF NOT EXISTS currencies (
			id SMALLSERIAL PRIMARY KEY,
			name VARCHAR(10) UNIQUE NOT NULL
		)
	`)

	if err != nil {
		return err
	}

	_, err = conn.Exec(`
		INSERT INTO currencies (name) VALUES ('USD') 
		ON CONFLICT (name) DO NOTHING;
	`)

	if err != nil {
		return err
	}

	_, err = conn.Exec(`
		INSERT INTO currencies (name) VALUES ('YEN') 
		ON CONFLICT (name) DO NOTHING;
	`)

	if err != nil {
		return err
	}

	_, err = conn.Exec(`
		INSERT INTO currencies (name) VALUES ('WON') 
		ON CONFLICT (name) DO NOTHING;
	`)

	if err != nil {
		return err
	}

	_, err = conn.Exec(`
	CREATE TABLE IF NOT EXISTS accounts (
		id SERIAL PRIMARY KEY,
		name VARCHAR(10) UNIQUE NOT NULL
	)
	`)

	if err != nil {
		return err
	}

	_, err = conn.Exec(`
	CREATE TABLE IF NOT EXISTS balances (
		account_id INTEGER,
		currency SMALLINT,
		balance INTEGER,

		PRIMARY KEY (account_id, currency),
		FOREIGN KEY (account_id) REFERENCES accounts(id),
		FOREIGN KEY (currency) REFERENCES currencies(id)
	)
	`)

	if err != nil {
		return err
	}

	return nil
}
