package connector

import (
	"accountservice/currency"
	"context"
	"log"
	"net/url"
	"os"
)

type CurrencyStockConnector interface {
	RequestCurrency(ctx context.Context, currency currency.Currency, amount int) error
	ReturnCurrency(ctx context.Context, currency currency.Currency, amount int) error
}

type CurrencyStock struct {
	serviceAddr string
	url         *url.URL
}

func NewCurrencyStock() *CurrencyStock {
	currencyStockServiceAddr := os.Getenv("CURRENCY_STOCK_SERVICE_ADDR")

	if currencyStockServiceAddr == "" {
		log.Fatal("CURRENCY_STOCK_SERVICE_ADDR is not set")
	}

	currencyStock := &CurrencyStock{serviceAddr: currencyStockServiceAddr}
	currencyStockSvcUrl, err := url.Parse(currencyStockServiceAddr)

	if err != nil {
		log.Fatal("CURRENCY_STOCK_SERVICE_ADDR is invalid address")
	}

	currencyStock.url = currencyStockSvcUrl

	return currencyStock
}

func (c *CurrencyStock) RequestCurrency(ctx context.Context, currency currency.Currency, amount int) error {
	return nil
}

func (c *CurrencyStock) ReturnCurrency(ctx context.Context, currency currency.Currency, amount int) error {
	return nil
}
