USE bankdb;

------------------------------------------------------------
-- TRIGGER 1: UpdateBalanceAfterTransaction
-- Description: Automatically updates account balance
--              when a transaction (Deposit/Withdrawal) occurs
------------------------------------------------------------

DELIMITER $$

CREATE TRIGGER UpdateBalanceAfterTransaction
AFTER INSERT ON Transaction
FOR EACH ROW
BEGIN
    IF NEW.Type = 'Deposit' THEN
        UPDATE Account
        SET Balance = Balance + NEW.T_Amount
        WHERE AccountNo = NEW.AccountNo;
    ELSEIF NEW.Type = 'Withdrawal' THEN
        UPDATE Account
        SET Balance = Balance - NEW.T_Amount
        WHERE AccountNo = NEW.AccountNo;
    END IF;
END $$

DELIMITER ;

------------------------------------------------------------
-- TRIGGER 2: after_payment_insert
-- Description: Reduces loan amount automatically
--              when a new payment record is added
------------------------------------------------------------

DELIMITER $$

CREATE TRIGGER after_payment_insert
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    UPDATE Loan
    SET LoanAmount = LoanAmount - NEW.P_Amount
    WHERE LoanID = NEW.LoanID;
END $$

DELIMITER ;

------------------------------------------------------------
-- TRIGGER 3: PreventAccountDeletionWithLoan
-- Description: Prevents deletion of an account if the
--              associated customer has existing loans
------------------------------------------------------------

DELIMITER $$

CREATE TRIGGER PreventAccountDeletionWithLoan
BEFORE DELETE ON Account
FOR EACH ROW
BEGIN
    DECLARE loan_count INT;

    SELECT COUNT(*) INTO loan_count
    FROM Loan
    WHERE Loan.CustomerID = OLD.CustomerID;

    IF loan_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete account: this customer has existing loans.';
    END IF;
END $$

DELIMITER ;
