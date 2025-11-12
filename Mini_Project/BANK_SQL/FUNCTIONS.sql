     USE bankdb;

------------------------------------------------------------
-- FUNCTION 1: CalculateAge
-- Description:
--   Calculates the age of a customer from their date of birth.
--   Uses TIMESTAMPDIFF to find the difference in years between
--   DOB and the current date.
------------------------------------------------------------

DELIMITER $$

CREATE FUNCTION CalculateAge(dob DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE age INT;
    SET age = TIMESTAMPDIFF(YEAR, dob, CURDATE());
    RETURN age;
END $$

DELIMITER ;

------------------------------------------------------------
-- FUNCTION 2: TotalBalance
-- Description:
--   Calculates the total balance of all accounts
--   belonging to a given customer (by CustomerID).
--   If no accounts exist, it returns 0.
------------------------------------------------------------

DELIMITER $$

CREATE FUNCTION TotalBalance(cust_id INT)
RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(15,2);
    SELECT SUM(Balance) INTO total 
    FROM Account 
    WHERE CustomerID = cust_id;
    RETURN IFNULL(total, 0);
END $$

DELIMITER ;
