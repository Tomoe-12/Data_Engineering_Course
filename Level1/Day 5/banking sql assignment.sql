-- =====================================================
-- BANKING DATABASE SETUP
-- =====================================================
DROP DATABASE IF EXISTS banking_lab;
CREATE DATABASE banking_lab;
USE banking_lab;
-- Customers
CREATE TABLE customers (
 customer_id INT PRIMARY KEY AUTO_INCREMENT,
 customer_name VARCHAR(100),
 city VARCHAR(50)
);
-- Accounts
CREATE TABLE accounts (
 account_id INT PRIMARY KEY AUTO_INCREMENT,
 customer_id INT,
 account_type VARCHAR(50), -- Savings / Current
 balance DECIMAL(12,2),
 FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
-- Transactions
CREATE TABLE transactions (
 transaction_id INT PRIMARY KEY AUTO_INCREMENT,
 account_id INT,
 transaction_type VARCHAR(50), -- Deposit / Withdrawal
 amount DECIMAL(12,2),
 transaction_date DATE,
 FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- =====================================================
-- Sample Data
-- =====================================================

-- Customers
INSERT INTO customers (customer_name, city) VALUES
('Aung Aung', 'Yangon'),
('Su Su', 'Mandalay'),
('Kyaw Kyaw', 'Yangon'),
('Mya Mya', 'Bago'),
('Ko Ko', 'Yangon');
-- Accounts
INSERT INTO accounts (customer_id, account_type, balance) VALUES
(1, 'Savings', 5000),
(2, 'Current', 8000),
(3, 'Savings', 12000),
(4, 'Savings', 3000),
(5, 'Current', 15000);
-- Transactions
INSERT INTO transactions (account_id, transaction_type, amount, transaction_date) VALUES
(1, 'Deposit', 2000, '2025-01-01'),
(1, 'Withdrawal', 500, '2025-01-02'),
(2, 'Deposit', 3000, '2025-01-03'),
(3, 'Deposit', 4000, '2025-01-04'),
(3, 'Withdrawal', 1000, '2025-01-05'),
(4, 'Deposit', 1500, '2025-01-06'),
(5, 'Deposit', 7000, '2025-01-07'),
(5, 'Withdrawal', 2000, '2025-01-08');

-- =====================================================
-- Assignment Questions
 -- =====================================================
-- SELECT & FROM
-- 1. Display all customers
select * from customers;

-- 2. Show customer name and city only
select customer_name , city from customers ;

-- 3. Display all accounts with balance
select account_id , balance from accounts;

-- =====================================================
-- PART B: WHERE
-- =====================================================

-- 4. Find customers from Yangon
select * from customers where city = "yangon";

-- 5. Find accounts with balance greater than 10,000
select account_id,balance from accounts a where a.balance > 10000 ;

-- 6. Show all Deposit transactions only
select * from transactions t where t.transaction_type = "deposit";

-- 7. Find transactions between '2025-01-01' and '2025-01-05'
select * from transactions t where t.transaction_date between '2025-01-01' and '2025-01-05';

-- =====================================================
 -- PART C: ORDER BY
 -- =====================================================
 
-- 8. Display accounts sorted by balance (highest first)
select * from accounts order by balance desc;

-- 9. Show transactions sorted by date (latest first)
select * from transactions order by transaction_date desc;

-- =====================================================
-- PART D: GROUP BY
-- =====================================================

-- 10. Total balance per account type
select  account_type , SUM(balance) as Total_Balance 
from accounts group by account_type;

-- 11. Total transaction amount per account
select account_id , sum(amount) as Total_Transaction_Amount 
from transactions group by account_id;

-- 12. Number of transactions per account
select account_id , count(*) as Total_Transaction 
from transactions group by account_id;

 -- =====================================================
 -- PART E: HAVING
  -- =====================================================
  
-- 13. Show account types with total balance > 10,000
select account_type,SUM(balance) as Total_Balance 
from accounts group by account_type having SUM(balance) > 10000;

-- 14. Show accounts with total transaction amount > 5,000
select account_id,SUM(amount) as Total_Transaction_Amount 
from transactions group by account_id having SUM(amount) > 5000;

-- =====================================================
-- PART F: COMBINED QUERY
-- =====================================================
  
-- 15. For each customer show total transactions , show total amount ,  only include customers with total amount > 3,000
select c.customer_name , c.customer_id  ,
count(t.transaction_id) AS total_transactions,
sum(t.amount) as total_amount  
from customers c 
JOIN accounts a on c.customer_id = a.customer_id
JOIN transactions t on a.account_id = t.account_id
group by c.customer_id , c.customer_name
Having SUM(t.amount) > 3000
order by total_amount desc; 

-- =====================================================
-- PART G: ADVANCED (JOIN + CLAUSES)
-- =====================================================
-- 16. Show customer name, account type, and balance
select c.customer_name, a.account_type , a.balance 
from customers c 
JOIN accounts a ON c.customer_id = a.customer_id 
order by a.balance desc;

-- 17. Show total deposits per customer
select c.customer_name,
sum(t.amount) as Total_Deposits
from customers c 
join accounts a on c.customer_id = a.customer_id
join transactions t on a.account_id = t.account_id
where t.transaction_type = 'deposit'
group by c.customer_id , c.customer_name
order by total_deposits desc;

-- 18. Show customers who made more than 1 transaction
select c.customer_name , 
count(t.transaction_id) as transaction_count 
from customers c 
join accounts a on c.customer_id = a.customer_id
join transactions t on a.account_id = t.account_id 
group by c.customer_id,c.customer_name
having count(t.transaction_id ) > 1 
order by transaction_count desc;

-- 19. Show customers with total withdrawals > 1,000
select c.customer_name , 
sum(t.amount) as total_withdrawals 
from customers c 
join accounts a on c.customer_id = a.customer_id
join transactions t on a.account_id = t.account_id 
where t.transaction_type = 'withdrawal'
group by c.customer_id,c.customer_name
having sum(t.amount ) > 1000 
order by total_withdrawals desc;

