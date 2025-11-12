USE bankdb;

-- ===========================================
-- 🧾 TEST CASE: FUNCTION 1 - CalculateAge(dob)
-- ===========================================

SELECT '--- TESTING FUNCTION: CalculateAge ---' AS Test;

-- Step 1️⃣: View sample customer DOBs
SELECT CustomerID, Name, DOB, Age AS Stored_Age FROM Customer LIMIT 5;

-- Step 2️⃣: Calculate age using function
SELECT 
    CustomerID,
    Name,
    DOB,
    Age AS Stored_Age,
    CalculateAge(DOB) AS Calculated_Age,
    (CalculateAge(DOB) - Age) AS Difference
FROM Customer;

-- Step 3️⃣: Check if stored ages differ from calculated
SELECT 
    CustomerID, Name, DOB, Age AS Stored_Age, CalculateAge(DOB) AS Calculated_Age
FROM Customer
WHERE Age <> CalculateAge(DOB);

SELECT '--- FUNCTION 1 TEST COMPLETE ---' AS Status;



-- ===========================================
-- 🧾 TEST CASE: FUNCTION 2 - TotalBalance(cust_id)
-- ===========================================

SELECT '--- TESTING FUNCTION: TotalBalance ---' AS Test;

-- Step 1️⃣: View customers and accounts
SELECT C.CustomerID, C.Name, A.AccountNo, A.Balance
FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID
ORDER BY C.CustomerID;

-- Step 2️⃣: Calculate total balance per customer
SELECT 
    C.CustomerID,
    C.Name,
    TotalBalance(C.CustomerID) AS Calculated_Total,
    SUM(A.Balance) AS Manual_Total
FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID;

SELECT '--- FUNCTION 2 TEST COMPLETE ---' AS Status;



-- ===========================================
-- ⚙️ TEST CASE: PROCEDURE 1 - AddTransaction
-- ===========================================

SELECT '--- TESTING PROCEDURE: AddTransaction ---' AS Test;

-- Step 1️⃣: View balance before transaction
SELECT AccountNo, Balance FROM Account WHERE AccountNo = 1001;

-- Step 2️⃣: Add a deposit transaction
CALL AddTransaction(1001, 'Deposit', 2000.00);

-- Step 3️⃣: View new balance (trigger 1 auto-updates balance)
SELECT AccountNo, Balance FROM Account WHERE AccountNo = 1001;

-- Step 4️⃣: Try invalid type (should raise an error)
-- CALL AddTransaction(1001, 'Transfer', 1000.00);

SELECT '--- PROCEDURE 1 TEST COMPLETE ---' AS Status;

-- ===========================================
-- ⚙️ TEST CASE: PROCEDURE 2 - GetCustomerLoans
-- ===========================================

SELECT '--- TESTING PROCEDURE: GetCustomerLoans ---' AS Test;

-- Step 1️⃣: Pick a customer with loans
SELECT CustomerID, Name FROM Customer LIMIT 3;

-- Step 2️⃣: Run procedure for one of them
CALL GetCustomerLoans(1);

SELECT '--- PROCEDURE 2 TEST COMPLETE ---' AS Status;



-- ===========================================
-- ⚙️ TEST CASE: PROCEDURE 3 - BranchAccountSummary
-- ===========================================

SELECT '--- TESTING PROCEDURE: BranchAccountSummary ---' AS Test;

-- Step 1️⃣: View all branches
SELECT BranchID, BranchName FROM Branch;

-- Step 2️⃣: Run summary for one branch
CALL BranchAccountSummary(1);

SELECT '--- PROCEDURE 3 TEST COMPLETE ---' AS Status;



-- ===========================================
-- ⚡ TEST CASE: TRIGGER 1 - UpdateBalanceAfterTransaction
-- ===========================================

SELECT '--- TESTING TRIGGER 1: UpdateBalanceAfterTransaction ---' AS Test;

-- Step 1️⃣: Check balance before transaction
SELECT AccountNo, Balance FROM Account WHERE AccountNo = 1001;

-- Step 2️⃣: Insert transaction directly (trigger updates balance)
INSERT INTO Transaction (AccountNo, Type, T_Amount, Date)
VALUES (5, 'Withdrawal', 500.00, CURDATE());
select * FROM account;

-- Step 3️⃣: Verify balance updated
SELECT AccountNo, Balance FROM Account WHERE AccountNo = 1001;

SELECT '--- TRIGGER 1 TEST COMPLETE ---' AS Status;



-- ===========================================
-- ⚡ TEST CASE: TRIGGER 2 - after_payment_insert
-- ===========================================

SELECT '--- TESTING TRIGGER 2: after_payment_insert ---' AS Test;

-- Step 1️⃣: Check loan amount before payment
SELECT LoanID, LoanAmount FROM Loan WHERE LoanID = 1;

-- Step 2️⃣: Insert new payment
INSERT INTO Payment (PaymentID, LoanID, P_Amount, PaymentDate)
VALUES (10001, 1, 5000.00, CURDATE());

-- Step 3️⃣: Verify loan amount reduced
SELECT LoanID, LoanAmount FROM Loan WHERE LoanID = 1;

SELECT '--- TRIGGER 2 TEST COMPLETE ---' AS Status;



-- ===========================================
-- ⚡ TEST CASE: TRIGGER 3 - PreventAccountDeletionWithLoan
-- ===========================================

SELECT '--- TESTING TRIGGER 3: PreventAccountDeletionWithLoan ---' AS Test;

-- Step 1️⃣: Try deleting an account linked to a customer with loan
DELETE FROM Account WHERE AccountNo = 1001;

-- Expected: ERROR → “Cannot delete account: this customer has existing loans.”

-- Step 2️⃣: Try deleting account of customer with no loans
-- (Use an AccountNo not linked to any loan)
DELETE FROM Account WHERE AccountNo = 2002;

SELECT '--- TRIGGER 3 TEST COMPLETE ---' AS Status;
