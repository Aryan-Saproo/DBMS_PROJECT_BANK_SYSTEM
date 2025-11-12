USE bankdb;

------------------------------------------------------------
-- PROCEDURE 1: AddTransaction
-- Description:
--   Adds a new transaction (Deposit or Withdrawal) to the
--   Transaction table. 
--   Prevents invalid transaction types using SQL SIGNAL.
------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE AddTransaction(
    IN acc_no INT,
    IN t_type VARCHAR(50),
    IN amount DECIMAL(15,2)
)
BEGIN
    IF t_type NOT IN ('Deposit', 'Withdrawal') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid transaction type. Use Deposit or Withdrawal.';
    ELSE
        INSERT INTO Transaction (AccountNo, Type, T_Amount, Date)
        VALUES (acc_no, t_type, amount, CURDATE());
    END IF;
END $$

DELIMITER ;

------------------------------------------------------------
-- PROCEDURE 2: GetCustomerLoans
-- Description:
--   Retrieves all loans for a specific customer,
--   including loan details and the branch name.
------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE GetCustomerLoans(IN cust_id INT)
BEGIN
    SELECT 
        L.LoanID,
        L.LoanType,
        L.InterestRate,
        L.LoanAmount,
        B.BranchName
    FROM Loan L
    JOIN Branch B ON L.BranchID = B.BranchID
    WHERE L.CustomerID = cust_id;
END $$

DELIMITER ;

------------------------------------------------------------
-- PROCEDURE 3: BranchAccountSummary
-- Description:
--   Displays a summary of all accounts for a given branch,
--   including account number, customer name, type, and balance.
------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE BranchAccountSummary(IN branch_id INT)
BEGIN
    SELECT 
        A.AccountNo,
        C.Name AS CustomerName,
        A.AccountType,
        A.Balance
    FROM Account A
    JOIN Customer C ON A.CustomerID = C.CustomerID
    WHERE A.BranchID = branch_id;
END $$

DELIMITER ;
