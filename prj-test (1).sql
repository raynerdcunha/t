PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Trade;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Holding;
DROP TABLE IF EXISTS Account;
DROP TABLE IF EXISTS MarketPrice;
DROP TABLE IF EXISTS Stock;
DROP TABLE IF EXISTS Exchange;
DROP TABLE IF EXISTS Company;
DROP TABLE IF EXISTS Users;

CREATE TABLE Users (
    uid   INTEGER,
    pwd   TEXT NOT NULL,
    role  TEXT NOT NULL,
    PRIMARY KEY (uid),
    CHECK (role IN ('client', 'manager'))
);

CREATE TABLE Company (
    company_id INTEGER,
    name       TEXT NOT NULL,
    sector     TEXT,
    industry   TEXT,
    country    TEXT,
    PRIMARY KEY (company_id)
);

CREATE TABLE Exchange (
    code       TEXT,
    name       TEXT NOT NULL,
    country    TEXT,
    timezone   TEXT,
    PRIMARY KEY (code)
);

CREATE TABLE Stock (
    ticker              TEXT,
    exg_code            TEXT,
    company_id          INTEGER NOT NULL,
    currency            TEXT,
    shares_outstanding  INTEGER,
    ipo_date            DATE,
    PRIMARY KEY (exg_code, ticker),
    FOREIGN KEY (exg_code) REFERENCES Exchange(code),
    FOREIGN KEY (company_id) REFERENCES Company(company_id),
    CHECK (shares_outstanding IS NULL OR shares_outstanding >= 0)
);

CREATE TABLE MarketPrice (
    exg_code    TEXT,
    ticker      TEXT,
    tday        DATE,
    open_price  REAL,
    high_price  REAL,
    low_price   REAL,
    close_price REAL,
    volume      INTEGER,
    PRIMARY KEY (exg_code, ticker, tday),
    FOREIGN KEY (exg_code, ticker)
        REFERENCES Stock(exg_code, ticker),
    CHECK (open_price  IS NULL OR open_price  >= 0),
    CHECK (high_price  IS NULL OR high_price  >= 0),
    CHECK (low_price   IS NULL OR low_price   >= 0),
    CHECK (close_price IS NULL OR close_price >= 0),
    CHECK (volume      IS NULL OR volume      >= 0),
    CHECK (
        high_price IS NULL OR low_price IS NULL OR high_price >= low_price
    )
);

CREATE TABLE Account (
    account_id     INTEGER,
    customer_name  TEXT NOT NULL,
    account_type   TEXT,
    cash_balance   REAL NOT NULL DEFAULT 0,
    creation_date  DATE,
    PRIMARY KEY (account_id),
    FOREIGN KEY (account_id) REFERENCES Users(uid),
    CHECK (cash_balance >= 0)
);

CREATE TABLE Holding (
    account_id  INTEGER,
    exg_code    TEXT,
    ticker      TEXT,
    qty         INTEGER NOT NULL,
    avg_cost    REAL NOT NULL,
    PRIMARY KEY (account_id, exg_code, ticker),
    FOREIGN KEY (account_id)
        REFERENCES Account(account_id),
    FOREIGN KEY (exg_code, ticker)
        REFERENCES Stock(exg_code, ticker),
    CHECK (qty > 0),
    CHECK (avg_cost >= 0)
);

CREATE TABLE Orders (
    order_id    INTEGER,
    account_id  INTEGER NOT NULL,
    exg_code    TEXT NOT NULL,
    ticker      TEXT NOT NULL,
    order_type  TEXT NOT NULL,
    side        TEXT NOT NULL,
    qty         INTEGER NOT NULL,
    price       REAL,
    status      TEXT NOT NULL,
    created_at  DATETIME NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (account_id)
        REFERENCES Account(account_id),
    FOREIGN KEY (exg_code, ticker)
        REFERENCES Stock(exg_code, ticker),
    CHECK (order_type IN ('market', 'limit')),
    CHECK (side IN ('buy', 'sell')),
    CHECK (qty > 0),
    CHECK (
        (order_type = 'market' AND price IS NULL)
        OR
        (order_type = 'limit' AND price IS NOT NULL AND price > 0)
    ),
    CHECK (status IN ('open', 'executed', 'cancelled'))
);

CREATE TABLE Trade (
    no           INTEGER,
    order_id     INTEGER,
    qty          INTEGER NOT NULL,
    price        REAL NOT NULL,
    executed_at  DATETIME NOT NULL,
    PRIMARY KEY (order_id, no),
    FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),
    CHECK (qty > 0),
    CHECK (price > 0)
);

-- ================= TEST DATA (CMPUT 291 F26 Mini Project 1 demo) =================
-- Default file. Dates use LOCAL time.
-- Re-create before EVERY demo: sqlite3 prj-test.db < prj-test.sql

INSERT INTO Users VALUES (1, 'alice123', 'client');
INSERT INTO Users VALUES (2, 'bob456', 'client');
INSERT INTO Users VALUES (3, 'carol789', 'client');
INSERT INTO Users VALUES (4, 'dan000', 'client');
INSERT INTO Users VALUES (5, 'admin291', 'manager');
INSERT INTO Account VALUES (1, 'Alice Chen', 'cash', 25000.00, '2024-01-15');
INSERT INTO Account VALUES (2, 'Bob Singh', 'margin', 50000.00, '2023-06-01');
INSERT INTO Account VALUES (3, 'Carol Wong', 'TFSA', 8000.00, '2025-03-10');
INSERT INTO Account VALUES (4, 'Dan Okafor', 'cash', 10000.00, '2025-09-20');

INSERT INTO Exchange VALUES ('NYSE', 'New York Stock Exchange', 'USA', 'America/New_York');
INSERT INTO Exchange VALUES ('NASDAQ', 'Nasdaq Stock Market', 'USA', 'America/New_York');
INSERT INTO Exchange VALUES ('TSX', 'Toronto Stock Exchange', 'Canada', 'America/Toronto');
INSERT INTO Company VALUES (1, 'Maple Leaf Technologies', 'Technology', 'Software', 'Canada');
INSERT INTO Company VALUES (2, 'Polaris Microsystems', 'Technology', 'Semiconductors', 'USA');
INSERT INTO Company VALUES (3, 'Bluewater Cloud Inc.', 'Technology', 'Cloud Computing', 'USA');
INSERT INTO Company VALUES (4, 'Quantum Ridge Software', 'Technology', 'Software', 'USA');
INSERT INTO Company VALUES (5, 'Aurora Data Systems', 'Technology', 'IT Services', 'Canada');
INSERT INTO Company VALUES (6, 'Prairie Gold Corp.', 'Materials', 'Gold Mining', 'Canada');
INSERT INTO Company VALUES (7, 'Yukon Gold Resources', 'Materials', 'Gold Mining', 'Canada');
INSERT INTO Company VALUES (8, 'Rocky Mountain Energy', 'Energy', 'Oil & Gas', 'Canada');
INSERT INTO Company VALUES (9, 'Sunbeam Power', 'Utilities', 'Renewable Energy', 'USA');
INSERT INTO Company VALUES (10, 'Granite Bank Financial', 'Financials', 'Banking', 'Canada');
INSERT INTO Company VALUES (11, 'Liberty Harbor Bank', 'Financials', 'Banking', 'USA');
INSERT INTO Company VALUES (12, 'Evergreen Health', 'Health Care', 'Pharmaceuticals', 'USA');
INSERT INTO Company VALUES (13, 'Techno Foods Ltd.', 'Consumer Staples', 'Packaged Foods', 'Canada');
INSERT INTO Company VALUES (14, 'Nova Biotech', 'Health Care', 'Biotechnology', 'Canada');
INSERT INTO Company VALUES (15, 'Zephyr Airlines', 'Industrials', 'Airlines', 'USA');
INSERT INTO Stock VALUES ('MLT', 'TSX', 1, 'CAD', 210000000, '2011-05-02');
INSERT INTO Stock VALUES ('MLT', 'NASDAQ', 1, 'USD', 210000000, '2015-09-14');
INSERT INTO Stock VALUES ('PLMS', 'NASDAQ', 2, 'USD', 450000000, '2004-06-15');
INSERT INTO Stock VALUES ('WAVE', 'NYSE', 3, 'USD', 120000000, '2019-03-21');
INSERT INTO Stock VALUES ('QRS', 'NASDAQ', 4, 'USD', 80000000, '2016-11-08');
INSERT INTO Stock VALUES ('ADS', 'TSX', 5, 'CAD', 60000000, '2012-02-27');
INSERT INTO Stock VALUES ('PGC', 'TSX', 6, 'CAD', 300000000, '2008-07-01');
INSERT INTO Stock VALUES ('YGR', 'TSX', 7, 'CAD', 95000000, '2018-10-10');
INSERT INTO Stock VALUES ('RME', 'TSX', 8, 'CAD', 175000000, '2001-04-17');
INSERT INTO Stock VALUES ('SUNP', 'NYSE', 9, 'USD', 260000000, '2014-08-05');
INSERT INTO Stock VALUES ('GBF', 'TSX', 10, 'CAD', 520000000, '1998-01-12');
INSERT INTO Stock VALUES ('LHB', 'NYSE', 11, 'USD', 340000000, '2003-05-30');
INSERT INTO Stock VALUES ('EVGH', 'NYSE', 12, 'USD', 150000000, '2010-12-01');
INSERT INTO Stock VALUES ('TFL', 'TSX', 13, 'CAD', 40000000, '2013-06-18');
INSERT INTO Stock VALUES ('NVB', 'TSX', 14, 'CAD', 70000000, '2020-09-09');
INSERT INTO Stock VALUES ('ZPHR', 'NYSE', 15, 'USD', 25000000, '2026-10-01');

INSERT INTO MarketPrice VALUES ('TSX', 'MLT', date('now','localtime','-1 days'), 41.30, 42.00, 41.00, 41.50, 107919);
INSERT INTO MarketPrice VALUES ('TSX', 'MLT', date('now','localtime','-2 days'), 40.89, 41.59, 40.59, 41.09, 115838);
INSERT INTO MarketPrice VALUES ('TSX', 'MLT', date('now','localtime','-3 days'), 40.47, 41.17, 40.17, 40.67, 123757);
INSERT INTO MarketPrice VALUES ('TSX', 'MLT', date('now','localtime','-4 days'), 40.05, 40.75, 39.75, 40.25, 131676);
INSERT INTO MarketPrice VALUES ('TSX', 'MLT', date('now','localtime','-5 days'), 39.64, 40.34, 39.34, 39.84, 139595);
INSERT INTO MarketPrice VALUES ('TSX', 'MLT', date('now','localtime','-6 days'), 39.22, 39.92, 38.92, 39.42, 147514);
INSERT INTO MarketPrice VALUES ('TSX', 'MLT', date('now','localtime','-7 days'), 38.81, 39.51, 38.51, 39.01, 105433);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'MLT', date('now','localtime','-1 days'), 31.00, 31.70, 30.70, 31.20, 107919);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'MLT', date('now','localtime','-2 days'), 30.69, 31.39, 30.39, 30.89, 115838);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'MLT', date('now','localtime','-3 days'), 30.38, 31.08, 30.08, 30.58, 123757);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'MLT', date('now','localtime','-4 days'), 30.06, 30.76, 29.76, 30.26, 131676);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'MLT', date('now','localtime','-5 days'), 29.75, 30.45, 29.45, 29.95, 139595);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'MLT', date('now','localtime','-6 days'), 29.44, 30.14, 29.14, 29.64, 147514);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'MLT', date('now','localtime','-7 days'), 29.13, 29.83, 28.83, 29.33, 105433);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'PLMS', date('now','localtime','-1 days'), 23.20, 23.90, 22.90, 23.40, 107919);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'PLMS', date('now','localtime','-2 days'), 22.97, 23.67, 22.67, 23.17, 115838);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'PLMS', date('now','localtime','-3 days'), 22.73, 23.43, 22.43, 22.93, 123757);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'PLMS', date('now','localtime','-4 days'), 22.50, 23.20, 22.20, 22.70, 131676);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'PLMS', date('now','localtime','-5 days'), 22.26, 22.96, 21.96, 22.46, 139595);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'PLMS', date('now','localtime','-6 days'), 22.03, 22.73, 21.73, 22.23, 147514);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'PLMS', date('now','localtime','-7 days'), 21.80, 22.50, 21.50, 22.00, 105433);
INSERT INTO MarketPrice VALUES ('NYSE', 'WAVE', date('now','localtime','-1 days'), 50.80, 51.50, 50.50, 51.00, 107919);
INSERT INTO MarketPrice VALUES ('NYSE', 'WAVE', date('now','localtime','-2 days'), 50.29, 50.99, 49.99, 50.49, 115838);
INSERT INTO MarketPrice VALUES ('NYSE', 'WAVE', date('now','localtime','-3 days'), 49.78, 50.48, 49.48, 49.98, 123757);
INSERT INTO MarketPrice VALUES ('NYSE', 'WAVE', date('now','localtime','-4 days'), 49.27, 49.97, 48.97, 49.47, 131676);
INSERT INTO MarketPrice VALUES ('NYSE', 'WAVE', date('now','localtime','-5 days'), 48.76, 49.46, 48.46, 48.96, 139595);
INSERT INTO MarketPrice VALUES ('NYSE', 'WAVE', date('now','localtime','-6 days'), 48.25, 48.95, 47.95, 48.45, 147514);
INSERT INTO MarketPrice VALUES ('NYSE', 'WAVE', date('now','localtime','-7 days'), 47.74, 48.44, 47.44, 47.94, 105433);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'QRS', date('now','localtime','-1 days'), 29.30, 30.00, 29.00, 29.50, 107919);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'QRS', date('now','localtime','-2 days'), 29.00, 29.70, 28.70, 29.20, 115838);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'QRS', date('now','localtime','-3 days'), 28.71, 29.41, 28.41, 28.91, 123757);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'QRS', date('now','localtime','-4 days'), 28.41, 29.11, 28.11, 28.61, 131676);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'QRS', date('now','localtime','-5 days'), 28.12, 28.82, 27.82, 28.32, 139595);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'QRS', date('now','localtime','-6 days'), 27.82, 28.52, 27.52, 28.02, 147514);
INSERT INTO MarketPrice VALUES ('NASDAQ', 'QRS', date('now','localtime','-7 days'), 27.53, 28.23, 27.23, 27.73, 105433);
INSERT INTO MarketPrice VALUES ('TSX', 'ADS', date('now','localtime','-1 days'), 11.80, 12.50, 11.50, 12.00, 107919);
INSERT INTO MarketPrice VALUES ('TSX', 'ADS', date('now','localtime','-2 days'), 11.68, 12.38, 11.38, 11.88, 115838);
INSERT INTO MarketPrice VALUES ('TSX', 'ADS', date('now','localtime','-3 days'), 11.56, 12.26, 11.26, 11.76, 123757);
INSERT INTO MarketPrice VALUES ('TSX', 'ADS', date('now','localtime','-4 days'), 11.44, 12.14, 11.14, 11.64, 131676);
INSERT INTO MarketPrice VALUES ('TSX', 'ADS', date('now','localtime','-5 days'), 11.32, 12.02, 11.02, 11.52, 139595);
INSERT INTO MarketPrice VALUES ('TSX', 'ADS', date('now','localtime','-6 days'), 11.20, 11.90, 10.90, 11.40, 147514);
INSERT INTO MarketPrice VALUES ('TSX', 'ADS', date('now','localtime','-7 days'), 11.08, 11.78, 10.78, 11.28, 105433);
INSERT INTO MarketPrice VALUES ('TSX', 'PGC', date('now','localtime','-1 days'), 8.40, 9.10, 8.10, 8.60, 107919);
INSERT INTO MarketPrice VALUES ('TSX', 'PGC', date('now','localtime','-2 days'), 8.31, 9.01, 8.01, 8.51, 115838);
INSERT INTO MarketPrice VALUES ('TSX', 'PGC', date('now','localtime','-3 days'), 8.23, 8.93, 7.93, 8.43, 123757);
INSERT INTO MarketPrice VALUES ('TSX', 'PGC', date('now','localtime','-4 days'), 8.14, 8.84, 7.84, 8.34, 131676);
INSERT INTO MarketPrice VALUES ('TSX', 'PGC', date('now','localtime','-5 days'), 8.06, 8.76, 7.76, 8.26, 139595);
INSERT INTO MarketPrice VALUES ('TSX', 'PGC', date('now','localtime','-6 days'), 7.97, 8.67, 7.67, 8.17, 147514);
INSERT INTO MarketPrice VALUES ('TSX', 'PGC', date('now','localtime','-7 days'), 7.88, 8.58, 7.58, 8.08, 105433);
INSERT INTO MarketPrice VALUES ('TSX', 'YGR', date('now','localtime','-1 days'), 2.90, 3.60, 2.60, 3.10, 107919);
INSERT INTO MarketPrice VALUES ('TSX', 'YGR', date('now','localtime','-2 days'), 2.87, 3.57, 2.57, 3.07, 115838);
INSERT INTO MarketPrice VALUES ('TSX', 'YGR', date('now','localtime','-3 days'), 2.84, 3.54, 2.54, 3.04, 123757);
INSERT INTO MarketPrice VALUES ('TSX', 'YGR', date('now','localtime','-4 days'), 2.81, 3.51, 2.51, 3.01, 131676);
INSERT INTO MarketPrice VALUES ('TSX', 'YGR', date('now','localtime','-5 days'), 2.78, 3.48, 2.48, 2.98, 139595);
INSERT INTO MarketPrice VALUES ('TSX', 'YGR', date('now','localtime','-6 days'), 2.74, 3.44, 2.44, 2.94, 147514);
INSERT INTO MarketPrice VALUES ('TSX', 'YGR', date('now','localtime','-7 days'), 2.71, 3.41, 2.41, 2.91, 105433);
INSERT INTO MarketPrice VALUES ('TSX', 'RME', date('now','localtime','-1 days'), 60.80, 61.50, 60.50, 61.00, 107919);
INSERT INTO MarketPrice VALUES ('TSX', 'RME', date('now','localtime','-2 days'), 60.19, 60.89, 59.89, 60.39, 115838);
INSERT INTO MarketPrice VALUES ('TSX', 'RME', date('now','localtime','-3 days'), 59.58, 60.28, 59.28, 59.78, 123757);
INSERT INTO MarketPrice VALUES ('TSX', 'RME', date('now','localtime','-4 days'), 58.97, 59.67, 58.67, 59.17, 131676);
INSERT INTO MarketPrice VALUES ('TSX', 'RME', date('now','localtime','-5 days'), 58.36, 59.06, 58.06, 58.56, 139595);
INSERT INTO MarketPrice VALUES ('TSX', 'RME', date('now','localtime','-6 days'), 57.75, 58.45, 57.45, 57.95, 147514);
INSERT INTO MarketPrice VALUES ('TSX', 'RME', date('now','localtime','-7 days'), 57.14, 57.84, 56.84, 57.34, 105433);
INSERT INTO MarketPrice VALUES ('NYSE', 'SUNP', date('now','localtime','-1 days'), 17.60, 18.30, 17.30, 17.80, 107919);
INSERT INTO MarketPrice VALUES ('NYSE', 'SUNP', date('now','localtime','-2 days'), 17.42, 18.12, 17.12, 17.62, 115838);
INSERT INTO MarketPrice VALUES ('NYSE', 'SUNP', date('now','localtime','-3 days'), 17.24, 17.94, 16.94, 17.44, 123757);
INSERT INTO MarketPrice VALUES ('NYSE', 'SUNP', date('now','localtime','-4 days'), 17.07, 17.77, 16.77, 17.27, 131676);
INSERT INTO MarketPrice VALUES ('NYSE', 'SUNP', date('now','localtime','-5 days'), 16.89, 17.59, 16.59, 17.09, 139595);
INSERT INTO MarketPrice VALUES ('NYSE', 'SUNP', date('now','localtime','-6 days'), 16.71, 17.41, 16.41, 16.91, 147514);
INSERT INTO MarketPrice VALUES ('NYSE', 'SUNP', date('now','localtime','-7 days'), 16.53, 17.23, 16.23, 16.73, 105433);
INSERT INTO MarketPrice VALUES ('TSX', 'GBF', date('now','localtime','-1 days'), 69.30, 70.00, 69.00, 69.50, 107919);
INSERT INTO MarketPrice VALUES ('TSX', 'GBF', date('now','localtime','-2 days'), 68.60, 69.30, 68.30, 68.80, 115838);
INSERT INTO MarketPrice VALUES ('TSX', 'GBF', date('now','localtime','-3 days'), 67.91, 68.61, 67.61, 68.11, 123757);
INSERT INTO MarketPrice VALUES ('TSX', 'GBF', date('now','localtime','-4 days'), 67.21, 67.91, 66.91, 67.41, 131676);
INSERT INTO MarketPrice VALUES ('TSX', 'GBF', date('now','localtime','-5 days'), 66.52, 67.22, 66.22, 66.72, 139595);
INSERT INTO MarketPrice VALUES ('TSX', 'GBF', date('now','localtime','-6 days'), 65.82, 66.52, 65.52, 66.02, 147514);
INSERT INTO MarketPrice VALUES ('TSX', 'GBF', date('now','localtime','-7 days'), 65.13, 65.83, 64.83, 65.33, 105433);
INSERT INTO MarketPrice VALUES ('NYSE', 'LHB', date('now','localtime','-1 days'), 43.80, 44.50, 43.50, 44.00, 107919);
INSERT INTO MarketPrice VALUES ('NYSE', 'LHB', date('now','localtime','-2 days'), 43.36, 44.06, 43.06, 43.56, 115838);
INSERT INTO MarketPrice VALUES ('NYSE', 'LHB', date('now','localtime','-3 days'), 42.92, 43.62, 42.62, 43.12, 123757);
INSERT INTO MarketPrice VALUES ('NYSE', 'LHB', date('now','localtime','-4 days'), 42.48, 43.18, 42.18, 42.68, 131676);
INSERT INTO MarketPrice VALUES ('NYSE', 'LHB', date('now','localtime','-5 days'), 42.04, 42.74, 41.74, 42.24, 139595);
INSERT INTO MarketPrice VALUES ('NYSE', 'LHB', date('now','localtime','-6 days'), 41.60, 42.30, 41.30, 41.80, 147514);
INSERT INTO MarketPrice VALUES ('NYSE', 'LHB', date('now','localtime','-7 days'), 41.16, 41.86, 40.86, 41.36, 105433);
INSERT INTO MarketPrice VALUES ('NYSE', 'EVGH', date('now','localtime','-1 days'), 92.80, 93.50, 92.50, 93.00, 107919);
INSERT INTO MarketPrice VALUES ('NYSE', 'EVGH', date('now','localtime','-2 days'), 91.87, 92.57, 91.57, 92.07, 115838);
INSERT INTO MarketPrice VALUES ('NYSE', 'EVGH', date('now','localtime','-3 days'), 90.94, 91.64, 90.64, 91.14, 123757);
INSERT INTO MarketPrice VALUES ('NYSE', 'EVGH', date('now','localtime','-4 days'), 90.01, 90.71, 89.71, 90.21, 131676);
INSERT INTO MarketPrice VALUES ('NYSE', 'EVGH', date('now','localtime','-5 days'), 89.08, 89.78, 88.78, 89.28, 139595);
INSERT INTO MarketPrice VALUES ('NYSE', 'EVGH', date('now','localtime','-6 days'), 88.15, 88.85, 87.85, 88.35, 147514);
INSERT INTO MarketPrice VALUES ('NYSE', 'EVGH', date('now','localtime','-7 days'), 87.22, 87.92, 86.92, 87.42, 105433);
INSERT INTO MarketPrice VALUES ('TSX', 'TFL', date('now','localtime','-1 days'), 21.80, 22.50, 21.50, 22.00, 107919);
INSERT INTO MarketPrice VALUES ('TSX', 'TFL', date('now','localtime','-2 days'), 21.58, 22.28, 21.28, 21.78, 115838);
INSERT INTO MarketPrice VALUES ('TSX', 'TFL', date('now','localtime','-3 days'), 21.36, 22.06, 21.06, 21.56, 123757);
INSERT INTO MarketPrice VALUES ('TSX', 'TFL', date('now','localtime','-4 days'), 21.14, 21.84, 20.84, 21.34, 131676);
INSERT INTO MarketPrice VALUES ('TSX', 'TFL', date('now','localtime','-5 days'), 20.92, 21.62, 20.62, 21.12, 139595);
INSERT INTO MarketPrice VALUES ('TSX', 'TFL', date('now','localtime','-6 days'), 20.70, 21.40, 20.40, 20.90, 147514);
INSERT INTO MarketPrice VALUES ('TSX', 'TFL', date('now','localtime','-7 days'), 20.48, 21.18, 20.18, 20.68, 105433);
INSERT INTO MarketPrice VALUES ('TSX', 'NVB', date('now','localtime','-1 days'), 6.10, 6.80, 5.80, 6.30, 107919);
INSERT INTO MarketPrice VALUES ('TSX', 'NVB', date('now','localtime','-2 days'), 6.04, 6.74, 5.74, 6.24, 115838);
INSERT INTO MarketPrice VALUES ('TSX', 'NVB', date('now','localtime','-3 days'), 5.97, 6.67, 5.67, 6.17, 123757);
INSERT INTO MarketPrice VALUES ('TSX', 'NVB', date('now','localtime','-4 days'), 5.91, 6.61, 5.61, 6.11, 131676);
INSERT INTO MarketPrice VALUES ('TSX', 'NVB', date('now','localtime','-5 days'), 5.85, 6.55, 5.55, 6.05, 139595);
INSERT INTO MarketPrice VALUES ('TSX', 'NVB', date('now','localtime','-6 days'), 5.78, 6.48, 5.48, 5.98, 147514);
INSERT INTO MarketPrice VALUES ('TSX', 'NVB', date('now','localtime','-7 days'), 5.72, 6.42, 5.42, 5.92, 105433);

INSERT INTO Orders VALUES (101, 1, 'NYSE', 'WAVE', 'market', 'buy', 100, NULL, 'executed', datetime('now','localtime','start of day','-60 days','+10 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 101, 100, 40.00, datetime('now','localtime','start of day','-60 days','+10 hours','+0 minutes'));
INSERT INTO Orders VALUES (102, 1, 'TSX', 'GBF', 'limit', 'buy', 50, 60.00, 'executed', datetime('now','localtime','start of day','-45 days','+10 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 102, 50, 60.00, datetime('now','localtime','start of day','-45 days','+10 hours','+0 minutes'));
INSERT INTO Orders VALUES (103, 1, 'TSX', 'MLT', 'market', 'buy', 40, NULL, 'executed', datetime('now','localtime','start of day','-40 days','+10 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 103, 40, 35.00, datetime('now','localtime','start of day','-40 days','+10 hours','+0 minutes'));
INSERT INTO Orders VALUES (104, 1, 'NASDAQ', 'QRS', 'market', 'buy', 40, NULL, 'executed', datetime('now','localtime','start of day','-30 days','+10 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 104, 40, 25.00, datetime('now','localtime','start of day','-30 days','+10 hours','+0 minutes'));
INSERT INTO Orders VALUES (105, 2, 'TSX', 'PGC', 'market', 'buy', 200, NULL, 'executed', datetime('now','localtime','start of day','-20 days','+10 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 105, 200, 8.00, datetime('now','localtime','start of day','-20 days','+10 hours','+0 minutes'));
INSERT INTO Orders VALUES (106, 2, 'TSX', 'RME', 'limit', 'buy', 30, 60.00, 'executed', datetime('now','localtime','start of day','-15 days','+10 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 106, 30, 60.00, datetime('now','localtime','start of day','-15 days','+10 hours','+0 minutes'));
INSERT INTO Orders VALUES (107, 2, 'NYSE', 'EVGH', 'market', 'buy', 20, NULL, 'executed', datetime('now','localtime','start of day','-12 days','+10 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 107, 20, 90.00, datetime('now','localtime','start of day','-12 days','+10 hours','+0 minutes'));
INSERT INTO Orders VALUES (108, 3, 'TSX', 'NVB', 'market', 'buy', 500, NULL, 'executed', datetime('now','localtime','start of day','-10 days','+10 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 108, 500, 6.00, datetime('now','localtime','start of day','-10 days','+10 hours','+0 minutes'));
INSERT INTO Orders VALUES (201, 2, 'NASDAQ', 'QRS', 'market', 'buy', 50, NULL, 'executed', datetime('now','localtime','start of day','-1 days','+11 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 201, 50, 30.00, datetime('now','localtime','start of day','-1 days','+11 hours','+0 minutes'));
INSERT INTO Orders VALUES (202, 2, 'NYSE', 'WAVE', 'market', 'buy', 40, NULL, 'executed', datetime('now','localtime','start of day','-2 days','+11 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 202, 40, 52.00, datetime('now','localtime','start of day','-2 days','+11 hours','+0 minutes'));
INSERT INTO Orders VALUES (203, 3, 'TSX', 'MLT', 'limit', 'buy', 100, 42.00, 'executed', datetime('now','localtime','start of day','-3 days','+11 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 203, 100, 42.00, datetime('now','localtime','start of day','-3 days','+11 hours','+0 minutes'));
INSERT INTO Orders VALUES (204, 2, 'NASDAQ', 'PLMS', 'market', 'buy', 100, NULL, 'executed', datetime('now','localtime','start of day','-3 days','+12 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 204, 100, 24.00, datetime('now','localtime','start of day','-3 days','+12 hours','+0 minutes'));
INSERT INTO Orders VALUES (205, 1, 'TSX', 'MLT', 'limit', 'sell', 15, 41.00, 'executed', datetime('now','localtime','start of day','-5 days','+10 hours','+30 minutes'));
INSERT INTO Trade VALUES (1, 205, 15, 41.00, datetime('now','localtime','start of day','-5 days','+10 hours','+30 minutes'));
INSERT INTO Orders VALUES (206, 3, 'NYSE', 'SUNP', 'market', 'buy', 300, NULL, 'executed', datetime('now','localtime','start of day','-4 days','+11 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 206, 300, 18.00, datetime('now','localtime','start of day','-4 days','+11 hours','+0 minutes'));
INSERT INTO Orders VALUES (207, 2, 'TSX', 'GBF', 'market', 'buy', 60, NULL, 'executed', datetime('now','localtime','start of day','-2 days','+12 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 207, 60, 70.00, datetime('now','localtime','start of day','-2 days','+12 hours','+0 minutes'));
INSERT INTO Orders VALUES (208, 2, 'TSX', 'PGC', 'market', 'sell', 200, NULL, 'executed', datetime('now','localtime','start of day','-1 days','+12 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 208, 200, 8.75, datetime('now','localtime','start of day','-1 days','+12 hours','+0 minutes'));
INSERT INTO Orders VALUES (209, 3, 'TSX', 'NVB', 'limit', 'sell', 200, 6.40, 'executed', datetime('now','localtime','start of day','-5 days','+11 hours','+0 minutes'));
INSERT INTO Trade VALUES (1, 209, 200, 6.40, datetime('now','localtime','start of day','-5 days','+11 hours','+0 minutes'));
INSERT INTO Orders VALUES (301, 1, 'NASDAQ', 'PLMS', 'limit', 'buy', 50, 20.00, 'open', datetime('now','localtime','start of day','+30 seconds'));
INSERT INTO Orders VALUES (302, 1, 'NYSE', 'WAVE', 'limit', 'sell', 30, 60.00, 'open', datetime('now','localtime','start of day','+35 seconds'));
INSERT INTO Orders VALUES (303, 1, 'TSX', 'ADS', 'limit', 'buy', 100, 10.00, 'open', datetime('now','localtime','start of day','+40 seconds'));
INSERT INTO Orders VALUES (304, 1, 'NYSE', 'EVGH', 'limit', 'buy', 10, 80.00, 'open', datetime('now','localtime','start of day','+45 seconds'));
INSERT INTO Orders VALUES (305, 1, 'TSX', 'GBF', 'limit', 'sell', 20, 75.00, 'open', datetime('now','localtime','start of day','+50 seconds'));
INSERT INTO Orders VALUES (306, 1, 'TSX', 'MLT', 'limit', 'sell', 10, 50.00, 'open', datetime('now','localtime','start of day','+55 seconds'));
INSERT INTO Orders VALUES (351, 2, 'NASDAQ', 'QRS', 'limit', 'buy', 10, 28.00, 'open', datetime('now','localtime','start of day','+5 seconds'));
INSERT INTO Orders VALUES (352, 2, 'NASDAQ', 'QRS', 'limit', 'buy', 10, 29.00, 'open', datetime('now','localtime','start of day','+15 seconds'));
INSERT INTO Orders VALUES (401, 1, 'TSX', 'MLT', 'limit', 'sell', 5, 48.00, 'open', datetime('now','localtime','start of day','-2 days','+9 hours','+0 minutes'));
INSERT INTO Orders VALUES (402, 4, 'TSX', 'GBF', 'limit', 'buy', 10, 65.00, 'open', datetime('now','localtime','start of day','-1 days','+9 hours','+0 minutes'));
INSERT INTO Orders VALUES (403, 4, 'NYSE', 'SUNP', 'limit', 'buy', 100, 18.50, 'open', datetime('now','localtime','start of day','+20 seconds'));

INSERT INTO Holding VALUES (1, 'NYSE', 'WAVE', 100, 40.00);
INSERT INTO Holding VALUES (1, 'TSX', 'GBF', 50, 60.00);
INSERT INTO Holding VALUES (1, 'TSX', 'MLT', 25, 35.00);
INSERT INTO Holding VALUES (1, 'NASDAQ', 'QRS', 40, 25.00);
INSERT INTO Holding VALUES (1, 'NYSE', 'ZPHR', 10, 15.00);
INSERT INTO Holding VALUES (2, 'NASDAQ', 'QRS', 50, 30.00);
INSERT INTO Holding VALUES (2, 'NYSE', 'WAVE', 40, 52.00);
INSERT INTO Holding VALUES (2, 'NASDAQ', 'PLMS', 100, 24.00);
INSERT INTO Holding VALUES (2, 'TSX', 'RME', 30, 60.00);
INSERT INTO Holding VALUES (2, 'NYSE', 'EVGH', 20, 90.00);
INSERT INTO Holding VALUES (2, 'TSX', 'GBF', 60, 70.00);
INSERT INTO Holding VALUES (3, 'TSX', 'MLT', 100, 42.00);
INSERT INTO Holding VALUES (3, 'NYSE', 'SUNP', 300, 18.00);
INSERT INTO Holding VALUES (3, 'TSX', 'NVB', 300, 6.00);
