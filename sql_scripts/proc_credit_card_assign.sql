CREATE OR REPLACE PROCEDURE assign_credit_cards(
    customer_id UUID,
    card_number_1 VARCHAR(16),
    limit_amount_1 DECIMAL(6, 2),
    card_number_2 VARCHAR(16),
    limit_amount_2 DECIMAL(6, 2)
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Insert the first credit card
    INSERT INTO credit_cards (id, card_number, limit_amount, customer_id, created_at)
    VALUES (
        gen_random_uuid(),      -- Generate a new UUID for the first credit card
        card_number_1,          -- Use the first card number passed as a parameter
        limit_amount_1,         -- Use the first limit amount passed as a parameter
        customer_id,            -- Link to the specified customer
        CURRENT_TIMESTAMP       -- Set the created_at timestamp
    );

    -- Insert the second credit card
    INSERT INTO credit_cards (id, card_number, limit_amount, customer_id, created_at)
    VALUES (
        gen_random_uuid(),      -- Generate a new UUID for the second credit card
        card_number_2,          -- Use the second card number passed as a parameter
        limit_amount_2,         -- Use the second limit amount passed as a parameter
        customer_id,            -- Link to the specified customer
        CURRENT_TIMESTAMP       -- Set the created_at timestamp
    );
END;
$$;