package main

import (
	"accountservice/account"
	"accountservice/connector"
	"accountservice/db"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

func main() {
	godotenv.Load()

	conn := db.NewConn()

	defer conn.Close()

	err := db.Init(conn)

	if err != nil {
		log.Fatal(err)
	}

	accountRepo := account.NewAccountRepo(conn)
	loanServiceConnector := connector.NewLoanServiceConnector()
	accountHandler := account.NewAccountHandler(accountRepo, loanServiceConnector)

	appMux := http.NewServeMux()
	accountMux := account.NewAccountMux(accountHandler)

	appMux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
	appMux.Handle("/api/", http.StripPrefix("/api", accountMux))

	log.Println("Account service started on port " + os.Getenv("HTTP_PORT"))
	http.ListenAndServe(":"+os.Getenv("HTTP_PORT"), appMux)
}
