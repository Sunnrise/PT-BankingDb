select c."name",c.surname, a.customer_id, a.name , amount, t.transaction_type , t.created_at, description,iban from accounts a 
  join transactions t ON a.customer_id =t.customer_id 
  JOIN customers c ON a.customer_id = c.id



SELECT c.name, a.customer_id, SUM(t.amount) AS total
FROM accounts a
JOIN transactions t ON a.customer_id = t.customer_id
JOIN customers c ON a.customer_id = c.id
GROUP BY c.name, a.customer_id;


--Total Transaction Count, last transaction date
SELECT a.id, c.name, COUNT(t.id) AS total_transactions, MAX(t.created_at) AS last_transaction_date
FROM accounts a
JOIN customers c ON a.customer_id = c.id
JOIN transactions t ON a.id = t.account_id
GROUP BY a.id, c.name;


SELECT c.id, c.name, SUM(t.amount) AS total_deposits
FROM customers c
JOIN accounts a ON c.id = a.customer_id
JOIN transactions t ON a.id = t.account_id
WHERE t.transaction_type = 'credit'
GROUP BY c.id, c.name
HAVING SUM(t.amount) < 0;


--brings active balance
SELECT t.id, t.account_id, t.created_at, t.description, 
       t.amount, 
       SUM(CASE 
            WHEN t.transaction_type = 'deposit' THEN t.amount
            WHEN t.transaction_type = 'withdrawal' THEN t.amount
            WHEN t.transaction_type = 'transfer' THEN t.amount
            ELSE 0 
           END) OVER (PARTITION BY t.account_id ORDER BY t.created_at) AS running_balance
FROM transactions t
JOIN accounts a ON t.account_id = a.id
JOIN customers c ON a.customer_id = c.id
WHERE c.id = a.customer_id 
ORDER BY t.created_at;

