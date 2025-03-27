package connector

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"net/url"
	"os"
)

var (
	ErrRequestLoanDenied error = errors.New("request loan denied")
	ErrReturnLoanDenied  error = errors.New("return loan denied")
)

type LoanServiceConnector interface {
	RequestLoan(ctx context.Context, accountName, currency string, amount int) error
	ReturnLoan(ctx context.Context, accountName, currency string, amount int) error
}

type LoanRequestDto struct {
	Account  string `json:"account"`
	Currency string `json:"currency"`
	Amount   int    `json:"amount"`
}

type LoanConnector struct {
	url *url.URL
}

func NewLoanServiceConnector() *LoanConnector {
	loanServiceAddr := os.Getenv("LOAN_SERVICE_ADDR")

	if loanServiceAddr == "" {
		log.Fatal("LOAN_SERVICE_ADDR is not set")
	}

	loanService := new(LoanConnector)
	loanServiceUrl, err := url.Parse(loanServiceAddr)

	if err != nil {
		log.Fatal("LOAN_SERVICE_ADDR is invalid address")
	}

	loanService.url = loanServiceUrl

	return loanService
}

func (l *LoanConnector) DoLoanRequest(accountName, currency, path string, amount int) error {
	client := http.Client{}

	data, err := json.Marshal(LoanRequestDto{
		Amount:   amount,
		Account:  accountName,
		Currency: currency,
	})

	if err != nil {
		return err
	}

	req, err := http.NewRequest(http.MethodPatch, l.url.JoinPath(path).String(), bytes.NewReader(data))

	if err != nil {
		return err
	}

	res, err := client.Do(req)

	if err != nil {
		return err
	}

	if res.StatusCode != http.StatusOK {
		return errors.New("loan service denied request")
	}

	return nil
}

func (l *LoanConnector) RequestLoan(ctx context.Context, accountName, currency string, amount int) error {
	return l.DoLoanRequest(accountName, currency, "/api/loan/request", amount)
}

func (l *LoanConnector) ReturnLoan(ctx context.Context, accountName, currency string, amount int) error {
	return l.DoLoanRequest(accountName, currency, "/api/loan/return", amount)
}
