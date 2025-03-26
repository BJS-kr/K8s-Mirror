package account_test

import (
	"context"
	"database/sql"
	"log"
	"os"
	"testing"
	"time"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/modules/postgres"
	"github.com/testcontainers/testcontainers-go/wait"

	"accountservice/account"
	"accountservice/currency"
	"accountservice/db"

	_ "github.com/lib/pq"
)

var (
	accountRepo *account.AccountRepo
	conn        *sql.DB
)

func TestMain(m *testing.M) {
	ctx := context.Background()

	pgContainer, err := postgres.Run(ctx, "postgres:17.4-alpine",
		postgres.WithDatabase("postgres"),
		postgres.WithUsername("postgres"),
		postgres.WithPassword("test"),
		testcontainers.WithWaitStrategy(
			wait.ForLog("database system is ready to accept connections").
				WithOccurrence(2).WithStartupTimeout(5*time.Second)),
	)

	if err != nil {
		log.Fatal(err)
	}

	connStr, err := pgContainer.ConnectionString(ctx, "sslmode=disable")

	if err != nil {
		log.Fatal(err)
	}

	conn = db.NewConn(connStr)

	defer conn.Close()

	err = db.Init(conn)

	if err != nil {
		log.Fatal(err)
	}

	accountRepo = account.NewAccountRepo(conn)
	exitCode := m.Run()

	if err = pgContainer.Terminate(ctx); err != nil {
		log.Fatal(err)
	}

	os.Exit(exitCode)
}

func TestRepoCreateAccount(t *testing.T) {
	accountId, err := accountRepo.CreateAccount(context.Background(), "test_acc")

	if err != nil {
		t.Fatal(err)
	}

	if accountId != 1 {
		t.Fatalf("expected account id is 1. actual: %d", accountId)
	}

	rows, err := conn.Query("SELECT * FROM balances WHERE account_id = $1", accountId)

	if err != nil {
		t.Fatal("invalid test query")
	}

	var (
		currency uint8
		balance  int
	)

	count := 0
	for rows.Next() {
		rows.Scan(accountId, currency, balance)
		t.Log(accountId, currency, balance)

		if accountId != 1 {
			t.Fatal("unexpected account_id")
		}

		t.Log("inserted currency type:", currency)

		if balance != 0 {
			t.Fatal("initial balance must be 0")
		}

		count++
	}

	if count != 3 {
		t.Fatalf("result rows must be 3, which is equal to count of currency types. actual: %d", count)
	}
}

func TestRepoChangeBalance(t *testing.T) {
	ctx := context.Background()
	err := accountRepo.ChangeBalance(ctx, 1, currency.WON, 100_000)

	if err != nil {
		t.Fatal("deposit balance should success")
	}

	err = accountRepo.ChangeBalance(ctx, 1, currency.WON, -1_000_000)

	if err == nil || err.Error() != "insufficient balance" {
		log.Println(err)
		t.Fatal("withdrawal of exceeding balance should fail with message 'insufficient balance'")
	}

	err = accountRepo.ChangeBalance(ctx, 1, currency.USD, -5_000)

	if err == nil || err.Error() != "insufficient balance" {
		t.Fatal("withdrawal of exceeding balance of other currency should fail with message 'insufficient balance'")
	}

	err = accountRepo.ChangeBalance(ctx, 1, currency.WON, -50_000)

	if err != nil {
		t.Fatal("withdrawal of sufficient amount should success")
	}
}

func TestRepoGetBalance(t *testing.T) {
	var balance int
	row, err := conn.Query("SELECT balance FROM balances WHERE account_id = $1 AND currency = $2", 1, currency.WON)

	if err != nil {
		t.Fatal("invalid test query")
	}

	row.Next()
	row.Scan(&balance)

	if balance != 50_000 {
		t.Fatalf("unexpected remaining balance. actual: %d", balance)
	}
}
