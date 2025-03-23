package currency

import "fmt"

type Currency uint8

const (
	USD Currency = iota + 1
	WON
	YEN
)

func AsValidCurrency(currency uint8) (Currency, error) {
	if currency < 1 || currency > 3 {
		return 0, fmt.Errorf("invalid currency: %d", currency)
	}

	return Currency(currency), nil
}
