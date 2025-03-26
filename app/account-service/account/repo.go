package account

import (
	"accountservice/currency"
	"context"
	"database/sql"
	"errors"

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

	tx, err := r.conn.Begin()
	if err != nil {

		return accountId, err
	}

	defer func() {
		if err != nil {
			tx.Rollback()
		} else {
			tx.Commit()
		}
	}()

	err = tx.QueryRowContext(ctx, "INSERT INTO accounts (name) VALUES ($1) RETURNING id", accountName).Scan(&accountId)

	if err != nil {
		return accountId, err
	}

	for _, cur := range [3]currency.Currency{currency.USD, currency.YEN, currency.WON} {
		_, err = tx.ExecContext(ctx, `
			INSERT INTO balances (account_id, currency, balance) VALUES ($1, $2, $3);
		`, accountId, cur, 0)

		if err != nil {
			return accountId, err
		}
	}

	return accountId, err
}

func (r *AccountRepo) ChangeBalance(ctx context.Context, accountId int, currency currency.Currency, amount int) error {
	if amount < 0 {
		amount = -amount
		result, err := r.conn.ExecContext(ctx, "UPDATE balances SET balance = balance - $1 WHERE account_id = $2 AND currency = $3 AND balance >= $1", amount, accountId, currency)

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
		_, err := r.conn.ExecContext(ctx, "UPDATE balances SET balance = balance + $1 WHERE account_id = $2 AND currency = $3", amount, accountId, currency)

		if err != nil {
			return err
		}
	}

	return nil
}

func (r *AccountRepo) GetBalance(ctx context.Context, accountId int, currency currency.Currency) (int, error) {
	var balance int
	err := r.conn.QueryRowContext(ctx, "SELECT balance FROM balances WHERE account_id = $1 AND currency = $2", accountId, currency).Scan(&balance)

	return balance, err
}
