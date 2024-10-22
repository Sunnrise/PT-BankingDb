CREATE OR REPLACE PROCEDURE make_transaction(
    p_card_number VARCHAR(16),
    p_transaction_type VARCHAR(50), -- Either 'debit', 'credit', 'withdrawal', or 'deposit'
    p_amount DECIMAL(15, 2),
    p_description VARCHAR(255)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_credit_card_id UUID;
    v_debit_card_id UUID;
    v_account_id UUID;
    v_limit_amount DECIMAL(15, 2);
    v_balance DECIMAL(15, 2);
    v_used_amount DECIMAL(15, 2);
BEGIN
    -- Start transaction
    PERFORM pg_advisory_xact_lock(hashtext(p_card_number));--lock card_number 

    -- Credit Card Transaction
    IF p_transaction_type = 'credit' THEN
        -- Get the credit card ID and limit amount for the specified card number
        SELECT id, limit_amount INTO v_credit_card_id, v_limit_amount
        FROM credit_cards
        WHERE card_number = p_card_number;

        -- Check if the credit card exists
        IF v_credit_card_id IS NULL THEN
            RAISE EXCEPTION 'Credit card not found';
        END IF;

        -- Calculate used amount (sum of all transactions for the card)
        SELECT COALESCE(SUM(amount), 0) INTO v_used_amount
        FROM transactions
        WHERE credit_card_id = v_credit_card_id;

        -- Debugging output for used amount and limit
        RAISE NOTICE 'Used amount: %, Limit amount: %, Transaction amount: %', v_used_amount, v_limit_amount, p_amount;

        -- Check if the transaction amount exceeds the credit limit
        IF v_used_amount + p_amount > v_limit_amount THEN
            RAISE EXCEPTION 'Transaction exceeds credit limit';
        END IF;

        -- Use JOIN to retrieve the associated account ID
        SELECT a.id INTO v_account_id
        FROM accounts a
        JOIN credit_cards cc ON a.customer_id = cc.customer_id
        WHERE cc.id = v_credit_card_id
        LIMIT 1;

        -- Insert the credit card transaction
        INSERT INTO transactions (
            id,
            customer_id,
            account_id,
            credit_card_id,
            debit_card_id,
            transaction_type,
            amount,
            description
        )
        VALUES (
            gen_random_uuid(),
            (SELECT customer_id FROM credit_cards WHERE id = v_credit_card_id),
            v_account_id,
            v_credit_card_id,
            NULL,
            p_transaction_type,
            -p_amount,  -- Positive amount for credit
            p_description
        );

        -- Update the credit card limit
        UPDATE credit_cards
        SET limit_amount = limit_amount - p_amount
        WHERE id = v_credit_card_id;

    -- Debit Card Transaction
    ELSIF p_transaction_type IN ('debit', 'withdrawal') THEN
        -- Get the debit card ID and account balance for the specified card number
        SELECT id, account_id INTO v_debit_card_id, v_account_id
        FROM debit_cards
        WHERE card_number = p_card_number;

        -- Check if the debit card exists
        IF v_debit_card_id IS NULL THEN
            RAISE EXCEPTION 'Debit card not found';
        END IF;

        -- Get the current account balance
        SELECT balance_amount INTO v_balance
        FROM accounts
        WHERE id = v_account_id;

        -- Check if the transaction amount exceeds the account balance for withdrawals
        IF p_transaction_type = 'withdrawal' AND p_amount > v_balance THEN
            RAISE EXCEPTION 'Insufficient balance in account for withdrawal';
        END IF;

        -- Insert the debit card transaction with negative amount for expenditure (withdrawal)
        INSERT INTO transactions (
            id,
            customer_id,
            account_id,
            credit_card_id, -- For debit card transactions, credit_card_id is NULL
            debit_card_id,
            transaction_type,
            amount,
            description
        )
        VALUES (
            gen_random_uuid(),
            (SELECT customer_id FROM accounts WHERE id = v_account_id),
            v_account_id,
            NULL, -- No credit card ID for debit transactions
            v_debit_card_id,
            p_transaction_type,
            -p_amount,  -- Negative amount for expenditure (withdrawal)
            p_description
        );

        -- Update the account balance for withdrawals
        IF p_transaction_type = 'withdrawal' THEN
            UPDATE accounts
            SET balance_amount = balance_amount - p_amount
            WHERE id = v_account_id;
        END IF;

    -- Handling Deposits (yatırma)
    ELSIF p_transaction_type = 'deposit' THEN
        -- Get the debit card ID and account ID for the specified card number
        SELECT id, account_id INTO v_debit_card_id, v_account_id
        FROM debit_cards
        WHERE card_number = p_card_number;

        -- Check if the debit card exists
        IF v_debit_card_id IS NULL THEN
            RAISE EXCEPTION 'Debit card not found';
        END IF;

        -- Insert the deposit transaction with positive amount
        INSERT INTO transactions (
            id,
            customer_id,
            account_id,
            credit_card_id,
            debit_card_id,
            transaction_type,
            amount,
            description
        )
        VALUES (
            gen_random_uuid(),
            (SELECT customer_id FROM accounts WHERE id = v_account_id),
            v_account_id,
            NULL, -- No credit card ID for deposits
            v_debit_card_id,
            p_transaction_type,
            p_amount,  -- Positive amount for deposit
            p_description
        );

        -- Update the account balance for deposits
        UPDATE accounts
        SET balance_amount = balance_amount + p_amount
        WHERE id = v_account_id;

    ELSE
        RAISE EXCEPTION 'Invalid transaction type. Must be ''debit'', ''credit'', ''deposit'', or ''withdrawal''.';
    END IF;

    -- No explicit commit needed
END;
$$;
