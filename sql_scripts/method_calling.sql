CALL drop_tables();
CALL create_tables();

-- Insert a new customer
INSERT INTO customers (id, tc_no, name, surname, birthdate, hometown)
VALUES (
    gen_random_uuid(),
    '11111111111',
    'Gün',
    'Gören',
    '1993-02-01',
    'Eskişehir'
);

-- Insert a new account for the customer
INSERT INTO accounts (id, iban, branch, balance_amount, account_type, customer_id)
VALUES (
    gen_random_uuid(),
    'TR011234154645788999',
    'Anadolu',
    0,
    'Vadesiz',
    (SELECT id FROM customers WHERE tc_no = '11111111111')
);
--Trigger should have createn a debit card
-- Check if the debit card was created with the correct account_id
SELECT * FROM debit_cards;

-- Declare a variable to hold the customer_id
DO $$
DECLARE
    my_customer_id UUID;  -- Variable to store the customer's UUID
BEGIN
    -- Get the customer_id for "Gün Gören"
    SELECT id INTO my_customer_id
    FROM customers 
    WHERE name = 'Gün' AND surname = 'Gören';

    -- Call the procedure to assign two credit cards
    CALL assign_credit_cards(
        my_customer_id,                       -- The customer's UUID
        '1234879654645488',                   -- Card number 1
        5000.00,                              -- Limit amount 1
        '1234879654645487',                   -- Card number 2
        3000.00                               -- Limit amount 2
    );
END $$;
select * from credit_cards cc     --Check if the credit cards were created with the correct customer_id

CALL make_transaction('1234879654645488', 'credit', 750.25, 'Yaz Tatili');

CALL make_transaction('1234879654645487', 'credit', 15.50, 'Pandemi');

CALL make_transaction('1234987654645489', 'deposit', 1500, 'Deposit to Account');

call make_transaction('1234987654645489', 'withdrawal', 350, 'Withdrawal from ATM');


DO $$ 
DECLARE
    my_account_id UUID;  -- Variable to store the account's UUID
BEGIN
    -- Get the account_id for "Vadesiz Anadolu"
    SELECT id INTO my_account_id
    FROM accounts 
    WHERE iban = 'TR011234154645788999' AND name = 'Vadesiz Anadolu';

    -- Call the procedure to assign a debit card
    CALL assign_debit_card(
        my_account_id,                       -- The account's UUID
        '1234987654645490'                   -- Card number
    );
END $$;

CALL make_transaction('1234987654645490', 'withdrawal', 125 ,'Withdrawal from ATM');



CALL make_transfer('258263c5-0070-497e-bd2b-8388515ce408', '1234879654645488','transfer', '750.25','Transfer from account to credit card');