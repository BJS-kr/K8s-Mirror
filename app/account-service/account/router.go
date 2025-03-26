package account

import (
	"net/http"
)

func NewAccountMux(accountHandler *AccountHandler) *http.ServeMux {
	topLevel := http.NewServeMux()
	accountMux := http.NewServeMux()

	topLevel.Handle("/account/", http.StripPrefix("/account", accountMux))

	accountMux.HandleFunc("POST /", accountHandler.createAccount)
	accountMux.HandleFunc("PATCH /", accountHandler.changeBalance)
	accountMux.HandleFunc("GET /{accountId}/{currency}", accountHandler.getBalance)
	accountMux.HandleFunc("/", notFound)

	return topLevel
}
