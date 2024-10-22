CREATE OR REPLACE PROCEDURE make_transfer(
    p_from_account_id UUID,            -- Account ID from which the transfer is made
    p_to_card_number VARCHAR(16),      -- Card number of the credit card to which the funds are transferred
    p_transaction_type VARCHAR(50),    -- 'transfer'
    p_amount DECIMAL(15, 2),
    p_description VARCHAR(255)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_credit_card_id UUID;
    v_balance DECIMAL(15, 2);
BEGIN
    -- Start transaction
    PERFORM pg_advisory_xact_lock(hashtext(p_from_account_id::text));--lock for accunt_id 

    -- Get the current account balance for the account ID
    SELECT balance_amount INTO v_balance
    FROM accounts
    WHERE id = p_from_account_id;

    -- Check if the account exists and has sufficient balance for transfer
    IF v_balance IS NULL THEN
        RAISE EXCEPTION 'Account not found';
    ELSIF p_amount > v_balance THEN
        RAISE EXCEPTION 'Insufficient balance in account for transfer';
    END IF;

    -- Get the credit card ID for the destination credit card
    SELECT id INTO v_credit_card_id
    FROM credit_cards
    WHERE card_number = p_to_card_number;

    -- Check if the credit card exists
    IF v_credit_card_id IS NULL THEN
        RAISE EXCEPTION 'Credit card not found';
    END IF;

    -- Insert the transfer transaction (debit from account and credit to credit card)
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
        (SELECT customer_id FROM accounts WHERE id = p_from_account_id),
        p_from_account_id,
        v_credit_card_id,
        NULL,  -- No debit card ID for transfer transactions
        'transfer',
        -p_amount,  -- Negative amount for debit (from account)
        p_description || ' (transfer to credit card)'
    );

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
        NULL,  -- No account ID for credit card transactions
        v_credit_card_id,
        NULL,  -- No debit card ID for credit card transactions
        'transfer',
        p_amount,  -- Positive amount for credit (to credit card)
        p_description || ' (transfer from account)'
    );

    -- Update the account balance after transfer
    UPDATE accounts
    SET balance_amount = balance_amount - p_amount
    WHERE id = p_from_account_id;

    -- Update the credit card limit after receiving the transfer
    UPDATE credit_cards
    SET limit_amount = limit_amount + p_amount
    WHERE id = v_credit_card_id;

END;
$$;




