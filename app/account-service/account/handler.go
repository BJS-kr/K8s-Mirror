package account

import (
	"accountservice/connector"
	"accountservice/currency"
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"
	"time"
)

type Nullary func() error

type CreateAccount struct {
	AccountName string `json:"accountName"`
}

type ChangeBalance struct {
	AccountId int   `json:"accountId"`
	Currency  uint8 `json:"currency"`
	Amount    int   `json:"amount"`
}

type AccountHandler struct {
	accountRepo          *AccountRepo
	loanServiceConnector connector.LoanServiceConnector
}

func NewAccountHandler(accountRepo *AccountRepo, loanServiceConnector connector.LoanServiceConnector) *AccountHandler {
	return &AccountHandler{
		accountRepo:          accountRepo,
		loanServiceConnector: loanServiceConnector,
	}
}

func (h *AccountHandler) createAccount(w http.ResponseWriter, r *http.Request) {
	createAccount, err := jsonBody(r, new(CreateAccount))

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	nameLength := len(createAccount.AccountName)

	if nameLength == 0 || nameLength < 5 || nameLength > 10 {
		http.Error(w, "Account name must be between 5 and 10 characters long", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), time.Second*10)
	defer cancel()

	accountId, err := h.accountRepo.CreateAccount(ctx, createAccount.AccountName)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	w.Write([]byte(strconv.Itoa(accountId)))
}

func (h *AccountHandler) changeBalance(w http.ResponseWriter, r *http.Request) {
	changeBalance, err := jsonBody(r, new(ChangeBalance))

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), time.Second*10)
	defer cancel()

	currency, err := currency.AsValidCurrency(changeBalance.Currency)

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if changeBalance.Amount == 0 {
		http.Error(w, "Amount must be non-zero", http.StatusBadRequest)
		return
	}

	boundTasks := []Nullary{
		func() error {
			return h.accountRepo.ChangeBalance(ctx, changeBalance.AccountId, currency, changeBalance.Amount)
		},
		func() error {
			if changeBalance.Amount < 0 {
				return h.loanServiceConnector.ReturnLoan(ctx, currency, changeBalance.Amount)
			} else {
				return h.loanServiceConnector.RequestLoan(ctx, currency, changeBalance.Amount)
			}
		},
	}

	err = runInTx(ctx, h.accountRepo.conn, boundTasks)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *AccountHandler) getBalance(w http.ResponseWriter, r *http.Request) {
	accountIdStr, currencyStr := r.PathValue("accountId"), r.PathValue("currency")

	if accountIdStr == "" {
		http.Error(w, "Account id is required", http.StatusBadRequest)
		return
	}

	accountId, err := strconv.Atoi(accountIdStr)

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), time.Second*10)
	defer cancel()

	currencyInt, err := strconv.Atoi(currencyStr)

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	currency, err := currency.AsValidCurrency(uint8(currencyInt))

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	balance, err := h.accountRepo.GetBalance(ctx, accountId, currency)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte(strconv.Itoa(balance)))
}

func notFound(w http.ResponseWriter, r *http.Request) {
	http.NotFound(w, r)
}

func runInTx(ctx context.Context, conn *sql.DB, fns []Nullary) error {
	tx, err := conn.BeginTx(ctx, nil)

	if err != nil {
		return err
	}

	for _, fn := range fns {
		err = fn()

		if err != nil {
			tx.Rollback()
			return err
		}
	}

	return tx.Commit()
}

func jsonBody[T any](r *http.Request, target T) (T, error) {
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(target)

	return target, err
}
