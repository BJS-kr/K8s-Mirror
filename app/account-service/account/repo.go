package account

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	_ "github.com/lib/pq"
)

type AccountRepo struct {
	conn *sql.DB
}

func NewAccountRepo(conn *sql.DB) *AccountRepo {
	return &AccountRepo{conn: conn}
}

func (r *AccountRepo) CreateAccount(ctx context.Context, accountName string) (int, error) {
	var accountId int
	err := r.conn.QueryRowContext(ctx, "INSERT INTO accounts (name) VALUES ($1) RETURNING id", accountName).Scan(&accountId)

	if err != nil {
		return accountId, err
	}

	return accountId, err
}

func (r *AccountRepo) ChangeBalance(ctx context.Context, accountId int, currency string, amount int) error {
	currencyId, err := r.GetCurrencyId(ctx, currency)

	if err != nil {
		return err
	}

	if amount < 0 {
		amount = -amount
		result, err := r.conn.ExecContext(ctx, "UPDATE balances SET balance = balance - $1 WHERE account_id = $2 AND currency = $3 AND balance >= $1", amount, accountId, currencyId)

		if err != nil {
			return err
		}

		affected, err := result.RowsAffected()

		if err != nil {
			return err
		}

		if affected == 0 {
			return errors.New("insufficient balance")
		}
	} else {
		_, err := r.conn.ExecContext(ctx, `
		INSERT INTO balances (account_id, currency, balance) VALUES ($1, $2, $3) 
		ON CONFLICT (account_id, currency)
		DO UPDATE SET balance = balances.balance + $3
		`, accountId, currencyId, amount)

		if err != nil {

			return err
		}
	}

	return nil
}

func (r *AccountRepo) GetBalance(ctx context.Context, accountId int, currency string) (int, error) {
	currencyId, err := r.GetCurrencyId(ctx, currency)

	if err != nil {
		return 0, err
	}

	var balance int
	err = r.conn.QueryRowContext(ctx, "SELECT balance FROM balances WHERE account_id = $1 AND currency = $2", accountId, currencyId).Scan(&balance)

	return balance, err
}

func (r *AccountRepo) GetCurrencyId(ctx context.Context, currency string) (int, error) {
	var currencyId int
	err := r.conn.QueryRowContext(ctx, "SELECT id FROM currencies WHERE name = $1", currency).Scan(&currencyId)

	if errors.Is(err, sql.ErrNoRows) {
		return currencyId, fmt.Errorf("there's no such currency: %s origin: %w", currency, err)
	}

	return currencyId, nil
}
