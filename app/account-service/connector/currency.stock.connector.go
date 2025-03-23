package connector

import (
	"accountservice/currency"
	"context"
	"log"
	"os"
)

type CurrencyStockConnector interface {
	RequestCurrency(ctx context.Context, currency currency.Currency, amount int) error
	ReturnCurrency(ctx context.Context, currency currency.Currency, amount int) error
}

type CurrencyStock struct {
	serviceAddr string
}

func NewCurrencyStock() *CurrencyStock {
	currencyStockServiceAddr := os.Getenv("CURRENCY_STOCK_SERVICE_ADDR")

	if currencyStockServiceAddr == "" {
		log.Fatal("CURRENCY_STOCK_SERVICE_ADDR is not set")
	}

	return &CurrencyStock{serviceAddr: currencyStockServiceAddr}
}

func (c *CurrencyStock) RequestCurrency(ctx context.Context, currency currency.Currency, amount int) error {
	return nil
}

func (c *CurrencyStock) ReturnCurrency(ctx context.Context, currency currency.Currency, amount int) error {
	return nil
}
