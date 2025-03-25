package account_test

import (
	"accountservice/account"
	"accountservice/currency"
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

const path = "/account/"

type MockLoanServiceConnector struct {
	errorFlag bool
}

func (c *MockLoanServiceConnector) RequestLoan(ctx context.Context, currency currency.Currency, amount int) error {
	if c.errorFlag {
		return errors.New("error")
	}

	return nil
}

func (c *MockLoanServiceConnector) ReturnLoan(ctx context.Context, currency currency.Currency, amount int) error {
	if c.errorFlag {
		return errors.New("error")
	}

	return nil
}

func NewTestComponents() (*sql.DB, sqlmock.Sqlmock, *http.ServeMux, *MockLoanServiceConnector) {
	db, mock, err := sqlmock.New()

	if err != nil {
		log.Fatalf("error opening mock db: %s", err)
	}

	accountRepo := account.NewAccountRepo(db)
	mockConnector := &MockLoanServiceConnector{errorFlag: false}
	accountHandler := account.NewAccountHandler(accountRepo, mockConnector)
	accountMux := account.NewAccountMux(accountHandler)

	return db, mock, accountMux, mockConnector
}

func TestCreateAccount(t *testing.T) {
	db, dbMock, accountMux, _ := NewTestComponents()

	defer db.Close()

	createAccount := account.CreateAccount{
		AccountName: "test_acc",
	}

	body, err := json.Marshal(createAccount)

	if err != nil {
		t.Fatalf("failed to marshal create account: %v", err)
	}

	dbMock.ExpectBegin()
	dbMock.ExpectQuery("INSERT INTO accounts").WithArgs(createAccount.AccountName).WillReturnRows(sqlmock.NewRows([]string{"id"}).AddRow(1))
	dbMock.ExpectExec("INSERT INTO balances").WithArgs(1, currency.USD, currency.WON, currency.YEN, 0).WillReturnResult(sqlmock.NewResult(3, 3))
	dbMock.ExpectCommit()

	resp := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, path, bytes.NewReader(body))

	accountMux.ServeHTTP(resp, req)
	result := resp.Result()

	if result.StatusCode != http.StatusCreated {
		message, err := io.ReadAll(result.Body)

		if err != nil {
			t.Fatalf("failed to read response body: %v", err)
		}

		t.Errorf("expected status code %d, got %d", http.StatusCreated, result.StatusCode)
		t.Errorf("error message: %s", string(message))
	}

	if err = dbMock.ExpectationsWereMet(); err != nil {
		t.Fatalf("expectations were not met: %v", err)
	}
}

func TestChangeBalanceShouldSuccess(t *testing.T) {
	db, dbMock, accountMux, _ := NewTestComponents()

	defer db.Close()

	changeBalance := account.ChangeBalance{
		AccountId: 1,
		Currency:  uint8(currency.USD),
		Amount:    100,
	}

	body, err := json.Marshal(changeBalance)

	if err != nil {
		t.Fatalf("failed to marshal change balance: %v", err)
	}

	dbMock.ExpectBegin()
	dbMock.ExpectExec("UPDATE balances").WithArgs(changeBalance.Amount, changeBalance.AccountId, changeBalance.Currency).WillReturnResult(sqlmock.NewResult(1, 1))
	dbMock.ExpectCommit()

	resp := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPatch, path, bytes.NewReader(body))

	accountMux.ServeHTTP(resp, req)
	result := resp.Result()

	if result.StatusCode != http.StatusOK {
		t.Errorf("expected status code %d, got %d", http.StatusOK, result.StatusCode)
	}

	if err = dbMock.ExpectationsWereMet(); err != nil {
		t.Fatalf("expectations were not met: %v", err)
	}

}

func TestChangeBalanceShouldFail(t *testing.T) {
	db, dbMock, accountMux, connector := NewTestComponents()
	connector.errorFlag = true

	defer db.Close()

	changeBalance := account.ChangeBalance{
		AccountId: 1,
		Currency:  uint8(currency.USD),
		Amount:    100,
	}

	body, err := json.Marshal(changeBalance)

	if err != nil {
		t.Fatalf("failed to marshal change balance: %v", err)
	}

	dbMock.ExpectBegin()
	dbMock.ExpectExec("UPDATE balances").WithArgs(changeBalance.Amount, changeBalance.AccountId, changeBalance.Currency).WillReturnError(errors.New("error"))
	dbMock.ExpectRollback()

	resp := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPatch, path, bytes.NewReader(body))

	accountMux.ServeHTTP(resp, req)
	result := resp.Result()

	if result.StatusCode != http.StatusInternalServerError {
		t.Errorf("expected status code %d, got %d", http.StatusInternalServerError, result.StatusCode)
	}

	if err = dbMock.ExpectationsWereMet(); err != nil {
		t.Fatalf("expectations were not met: %v", err)
	}
}

func TestGetBalanceShouldSuccess(t *testing.T) {
	db, dbMock, accountMux, _ := NewTestComponents()

	defer db.Close()

	dbMock.ExpectQuery("SELECT balance FROM balances").WithArgs(1, currency.USD).WillReturnRows(sqlmock.NewRows([]string{"balance"}).AddRow(100))

	resp := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, fmt.Sprintf("%s%d/%d", path, 1, currency.USD), nil)

	accountMux.ServeHTTP(resp, req)
	result := resp.Result()

	if result.StatusCode != http.StatusOK {
		t.Errorf("expected status code %d, got %d", http.StatusOK, result.StatusCode)
	}
}

func TestGetBalanceShouldFail(t *testing.T) {
	db, _, accountMux, _ := NewTestComponents()

	defer db.Close()

	resp := httptest.NewRecorder()
	// request with invalid currency
	req := httptest.NewRequest(http.MethodGet, fmt.Sprintf("%s%d/%d", path, 1, 10), nil)

	accountMux.ServeHTTP(resp, req)
	result := resp.Result()

	if result.StatusCode != http.StatusBadRequest {
		t.Errorf("expected status code %d, got %d", http.StatusBadRequest, result.StatusCode)
	}
}
