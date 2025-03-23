package main

import (
	"accountservice/account"
	"accountservice/connector"
	"accountservice/db"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	conn := db.NewConn()

	defer conn.Close()

	err := db.Init(conn)

	if err != nil {
		log.Fatal(err)
	}

	accountRepo := account.NewAccountRepo(conn)
	currencyStockConnector := connector.NewCurrencyStock()
	accountHandler := account.NewAccountHandler(accountRepo, currencyStockConnector)

	apiMux := http.NewServeMux()
	accountMux := account.NewAccountMux(accountHandler)

	apiMux.Handle("/api", http.StripPrefix("/api", accountMux))

	http.ListenAndServe(":"+os.Getenv("HTTP_PORT"), apiMux)
}
