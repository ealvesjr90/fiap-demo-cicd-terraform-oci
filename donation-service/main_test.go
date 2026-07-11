package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
)

// ── /health ─────────────────────────────────────────────────────────

func TestHealthHandler(t *testing.T) {
	app := &App{}
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	w := httptest.NewRecorder()

	app.HealthHandler(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var body map[string]string
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}
	if body["status"] != "ok" {
		t.Errorf("expected status ok, got %s", body["status"])
	}
	if body["service"] != "donation-service" {
		t.Errorf("expected service donation-service, got %s", body["service"])
	}
}

// ── POST /donations ─────────────────────────────────────────────────

func TestDonationHandler_Post_Success(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock: %v", err)
	}
	defer db.Close()

	app := &App{DB: db}
	now := time.Now()

	mock.ExpectQuery("INSERT INTO donations").
		WithArgs(1, 100.0, "Alice", "APPROVED").
		WillReturnRows(sqlmock.NewRows([]string{"id", "created_at"}).AddRow(1, now))

	payload, _ := json.Marshal(Donation{NgoID: 1, Amount: 100, DonorName: "Alice"})
	req := httptest.NewRequest(http.MethodPost, "/donations", bytes.NewReader(payload))
	w := httptest.NewRecorder()

	app.DonationHandler(w, req)

	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d – body: %s", w.Code, w.Body.String())
	}

	var d Donation
	if err := json.Unmarshal(w.Body.Bytes(), &d); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}
	if d.ID != 1 || d.DonorName != "Alice" || d.Status != "APPROVED" {
		t.Errorf("unexpected donation: %+v", d)
	}

	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("unmet expectations: %v", err)
	}
}

func TestDonationHandler_Post_InvalidPayload(t *testing.T) {
	app := &App{}
	req := httptest.NewRequest(http.MethodPost, "/donations", bytes.NewReader([]byte("{bad")))
	w := httptest.NewRecorder()

	app.DonationHandler(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", w.Code)
	}
}

func TestDonationHandler_Post_DBError(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock: %v", err)
	}
	defer db.Close()

	app := &App{DB: db}

	mock.ExpectQuery("INSERT INTO donations").
		WithArgs(1, 50.0, "Bob", "APPROVED").
		WillReturnError(sqlmock.ErrCancelled)

	payload, _ := json.Marshal(Donation{NgoID: 1, Amount: 50, DonorName: "Bob"})
	req := httptest.NewRequest(http.MethodPost, "/donations", bytes.NewReader(payload))
	w := httptest.NewRecorder()

	app.DonationHandler(w, req)

	if w.Code != http.StatusInternalServerError {
		t.Fatalf("expected 500, got %d", w.Code)
	}
}

// ── GET /donations ──────────────────────────────────────────────────

func TestDonationHandler_Get_Success(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock: %v", err)
	}
	defer db.Close()

	app := &App{DB: db}
	now := time.Now()

	rows := sqlmock.NewRows([]string{"id", "ngo_id", "amount", "donor_name", "status", "created_at"}).
		AddRow(1, 1, 100.0, "Alice", "APPROVED", now).
		AddRow(2, 2, 50.0, "Bob", "APPROVED", now)

	mock.ExpectQuery("SELECT id, ngo_id, amount, donor_name, status, created_at FROM donations").
		WillReturnRows(rows)

	req := httptest.NewRequest(http.MethodGet, "/donations", nil)
	w := httptest.NewRecorder()

	app.DonationHandler(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var donations []Donation
	if err := json.Unmarshal(w.Body.Bytes(), &donations); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}
	if len(donations) != 2 {
		t.Errorf("expected 2 donations, got %d", len(donations))
	}
}

func TestDonationHandler_Get_DBError(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock: %v", err)
	}
	defer db.Close()

	app := &App{DB: db}
	mock.ExpectQuery("SELECT").WillReturnError(sqlmock.ErrCancelled)

	req := httptest.NewRequest(http.MethodGet, "/donations", nil)
	w := httptest.NewRecorder()

	app.DonationHandler(w, req)

	if w.Code != http.StatusInternalServerError {
		t.Fatalf("expected 500, got %d", w.Code)
	}
}

func TestDonationHandler_Get_EmptyList(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock: %v", err)
	}
	defer db.Close()

	app := &App{DB: db}
	rows := sqlmock.NewRows([]string{"id", "ngo_id", "amount", "donor_name", "status", "created_at"})
	mock.ExpectQuery("SELECT").WillReturnRows(rows)

	req := httptest.NewRequest(http.MethodGet, "/donations", nil)
	w := httptest.NewRecorder()

	app.DonationHandler(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var donations []Donation
	json.Unmarshal(w.Body.Bytes(), &donations)
	if len(donations) != 0 {
		t.Errorf("expected empty list, got %d", len(donations))
	}
}

// ── Method Not Allowed ──────────────────────────────────────────────

func TestDonationHandler_MethodNotAllowed(t *testing.T) {
	app := &App{}
	req := httptest.NewRequest(http.MethodPut, "/donations", nil)
	w := httptest.NewRecorder()

	app.DonationHandler(w, req)

	if w.Code != http.StatusMethodNotAllowed {
		t.Fatalf("expected 405, got %d", w.Code)
	}
}
