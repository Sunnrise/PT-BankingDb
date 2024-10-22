CREATE OR REPLACE FUNCTION create_debit_card()
RETURNS TRIGGER AS $$
DECLARE
    card_number VARCHAR(16);  -- Variable to store the card number
BEGIN
    -- Check if there are no debit cards in the table yet (i.e., first card)
    IF (SELECT COUNT(*) FROM debit_cards) = 0 THEN
        -- Set the first card number as the hardcoded value
        card_number := '1234987654645489';
    ELSE
        -- For subsequent cards, generate the card number using the sequence
        card_number := '1234' || lpad((nextval('debit_card_sequence') % 10000000000000000)::text, 12, '0');
    END IF;

    -- Insert the debit card with either the hardcoded or generated card number
    INSERT INTO debit_cards (id, card_number, account_id, created_at)
    VALUES (
        gen_random_uuid(),   -- Generate a new UUID for the debit card
        card_number,         -- Use the card number (either hardcoded or generated)
        NEW.id,              -- Use the ID of the newly created account
        CURRENT_TIMESTAMP    -- Set the created_at timestamp
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the function after an account is inserted
CREATE TRIGGER after_account_insert
AFTER INSERT ON accounts
FOR EACH ROW
EXECUTE FUNCTION create_debit_card();
CREATE SEQUENCE debit_card_sequence START WITH 2 INCREMENT BY 1;