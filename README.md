- Method_calling includes calling methods

- Create_delete_tables easily create and drop database, Account 'name' has been created with merge of 'branch' and 'account_type'. 

- Customers can  get credit card without bank account. So our credit cards related with customers. 
- Each account have at least one debit card and one customer. (One account can have more than one debit card it means that they'll share same balance ) 
    Because of this reason we kept balance related to account not debit card, only credit cards have their own limit. 

- So, when a customer has a bank account, our trigger assign a debit card for the customer. We also used sequence for other customers cards, so we will avoid the conflicts(card id is unique)

- We use transaction control and log for exceptions.

- We also add some queries for show related data.