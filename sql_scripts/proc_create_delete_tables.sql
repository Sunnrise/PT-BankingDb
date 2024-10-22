CREATE OR REPLACE PROCEDURE create_tables()
LANGUAGE plpgsql AS $$
BEGIN
    -- Customers Table
    EXECUTE 'CREATE TABLE IF NOT EXISTS customers (
        id UUID PRIMARY KEY,
        tc_no VARCHAR(11) UNIQUE NOT NULL,
        name VARCHAR(50) NOT NULL,
        surname VARCHAR(50) NOT NULL,
        birthdate DATE NOT NULL,
        hometown VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );';

    -- Accounts Table
    EXECUTE 'CREATE TABLE IF NOT EXISTS accounts (
        id UUID PRIMARY KEY,
        iban VARCHAR(26) UNIQUE NOT NULL,
        branch VARCHAR(30) NOT NULL,
		balance_amount DECIMAL(6, 2) NOT NULL,
        account_type VARCHAR(50) NOT NULL,
        name VARCHAR(80) GENERATED ALWAYS AS (account_type || '' '' || branch) STORED,
        customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );';

    -- Debit Cards Table
    EXECUTE 'CREATE TABLE IF NOT EXISTS debit_cards (
        id UUID PRIMARY KEY,
        card_number VARCHAR(16) UNIQUE NOT NULL,
        account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );';

    -- Credit Cards Table
    EXECUTE 'CREATE TABLE IF NOT EXISTS credit_cards (
        id UUID PRIMARY KEY,
        card_number VARCHAR(16) UNIQUE NOT NULL,
        limit_amount DECIMAL(6, 2) NOT NULL,
        customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );';

	EXECUTE 'CREATE TABLE transactions (
    id UUID PRIMARY KEY,                          
    customer_id UUID REFERENCES customers(id),     -- Direct link to customer
    account_id UUID REFERENCES accounts(id),       
    credit_card_id UUID REFERENCES credit_cards(id),
	debit_card_id UUID REFERENCES debit_cards(id), 
    transaction_type VARCHAR(20) NOT NULL,        
    amount DECIMAL(15, 2) NOT NULL,               
    description VARCHAR(255),                     
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);';


END;
$$;

CREATE OR REPLACE PROCEDURE drop_tables()
LANGUAGE plpgsql AS $$
BEGIN
    -- Drop Transactions Table with Cascade
    EXECUTE 'DROP TABLE IF EXISTS transactions CASCADE;';

    -- Drop Credit Cards Table with Cascade
    EXECUTE 'DROP TABLE IF EXISTS credit_cards CASCADE;';

    -- Drop Debit Cards Table with Cascade
    EXECUTE 'DROP TABLE IF EXISTS debit_cards CASCADE;';

    -- Drop Accounts Table with Cascade
    EXECUTE 'DROP TABLE IF EXISTS accounts CASCADE;';

    -- Drop Customers Table with Cascade
    EXECUTE 'DROP TABLE IF EXISTS customers CASCADE;';
END;
$$;