CREATE OR REPLACE PROCEDURE assign_debit_card(
    account_id UUID,
    card_number VARCHAR(16)
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Insert the debit card
    INSERT INTO debit_cards (id, card_number, account_id, created_at)
    VALUES (
        gen_random_uuid(),      -- Generate a new UUID for the debit card
        card_number,            -- Use the card number passed as a parameter
        account_id,             -- Link to the specified account
        CURRENT_TIMESTAMP        -- Set the created_at timestamp
    );
END;
$$;


