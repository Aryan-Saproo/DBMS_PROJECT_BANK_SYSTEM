CREATE DATABASE IF NOT EXISTS BankDB;
USE BankDB;

CREATE TABLE Customer (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(15),
    DOB DATE,
    Address VARCHAR(255),
    Age INT
);

-- INSERT SAMPLE CUSTOMERS
INSERT INTO Customer (Name, Email, Phone, DOB, Address, Age)
VALUES
('Amit Sharma', 'amit@gmail.com', '9876543210', '1989-05-10', 'Delhi', 36),
('Priya Nair', 'priya@gmail.com', '9123456789', '1992-08-15', 'Mumbai', 33),
('Rohan Das', 'rohan@gmail.com', '9876501234', '1995-03-22', 'Bangalore', 30),
('Sneha Iyer', 'sneha@gmail.com', '9988776655', '1990-12-02', 'Chennai', 35),
('Karan Patel', 'karan@gmail.com', '9998887776', '1993-04-19', 'Ahmedabad', 32),
('Ananya Rao', 'ananya@gmail.com', '9776655443', '1998-09-09', 'Hyderabad', 27),
('Vikram Singh', 'vikram@gmail.com', '9887766554', '1988-11-15', 'Pune', 37),
('Meera Joshi', 'meera@gmail.com', '9090909090', '1996-02-20', 'Kolkata', 29),
('Arjun Mehta', 'arjun@gmail.com', '9876543200', '1991-01-11', 'Surat', 34),
('Tanya Kapoor', 'tanya@gmail.com', '9898989898', '1994-07-23', 'Jaipur', 31);

CREATE TABLE Branch (
    BranchID INT AUTO_INCREMENT PRIMARY KEY,
    BranchName VARCHAR(100),
    Location VARCHAR(100),
    ContactNumber VARCHAR(15)
);

-- INSERT SAMPLE BRANCHES
INSERT INTO Branch (BranchName, Location, ContactNumber)
VALUES
('Connaught Place Branch', 'Delhi', '01122334455'),
('Andheri Branch', 'Mumbai', '02266778899'),
('Koramangala Branch', 'Bangalore', '08011223344'),
('T. Nagar Branch', 'Chennai', '04499887766'),
('Navrangpura Branch', 'Ahmedabad', '07933445566'),
('Banjara Hills Branch', 'Hyderabad', '04077889911'),
('Koregaon Park Branch', 'Pune', '02022334411'),
('Salt Lake Branch', 'Kolkata', '03366778899'),
('City Light Branch', 'Surat', '02612233445'),
('MI Road Branch', 'Jaipur', '01415556677');

CREATE TABLE Account (
    AccountNo INT AUTO_INCREMENT PRIMARY KEY,
    AccountType VARCHAR(50),
    Balance DECIMAL(15,2),
    CustomerID INT,
    BranchID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- INSERT SAMPLE ACCOUNTS
INSERT INTO Account (AccountType, Balance, CustomerID, BranchID)
VALUES
('Savings', 55000.00, 1, 1),
('Current', 125000.00, 2, 2),
('Savings', 80000.00, 3, 3),
('Current', 220000.00, 4, 4),
('Savings', 60000.00, 5, 5),
('Current', 145000.00, 6, 6),
('Savings', 72000.00, 7, 7),
('Savings', 98000.00, 8, 8),
('Current', 110000.00, 9, 9),
('Savings', 50000.00, 10, 10);

CREATE TABLE Transaction (
    TransactionID INT AUTO_INCREMENT,
    AccountNo INT,
    Type VARCHAR(50),
    T_Amount DECIMAL(15,2),
    Date DATE,
    PRIMARY KEY (TransactionID, AccountNo),
    FOREIGN KEY (AccountNo) REFERENCES Account(AccountNo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- INSERT SAMPLE TRANSACTIONS
INSERT INTO Transaction (AccountNo, Type, T_Amount, Date)
VALUES
(1, 'Deposit', 10000.00, '2024-09-15'),
(1, 'Withdrawal', 5000.00, '2024-10-01'),
(2, 'Deposit', 20000.00, '2024-10-05'),
(3, 'Withdrawal', 7000.00, '2024-10-10'),
(4, 'Deposit', 25000.00, '2024-09-22'),
(5, 'Deposit', 30000.00, '2024-09-28'),
(6, 'Withdrawal', 15000.00, '2024-10-03'),
(7, 'Deposit', 12000.00, '2024-10-07'),
(8, 'Deposit', 9000.00, '2024-10-08'),
(9, 'Withdrawal', 5000.00, '2024-10-10');

CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Role VARCHAR(50),
    Salary DECIMAL(10,2),
    BranchID INT,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- INSERT SAMPLE EMPLOYEES
INSERT INTO Employee (Name, Role, Salary, BranchID)
VALUES
('Ravi Kumar', 'Manager', 75000.00, 1),
('Anjali Singh', 'Clerk', 40000.00, 2),
('Manish Verma', 'Cashier', 42000.00, 3),
('Lakshmi Rao', 'Loan Officer', 50000.00, 4),
('Rahul Bhatia', 'Manager', 78000.00, 5),
('Pooja Shah', 'Cashier', 41000.00, 6),
('Suresh Menon', 'Clerk', 38000.00, 7),
('Divya Reddy', 'Loan Officer', 52000.00, 8),
('Neha Patel', 'Manager', 76000.00, 9),
('Vivek Gupta', 'Cashier', 43000.00, 10);

CREATE TABLE Loan (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    LoanType VARCHAR(50),
    InterestRate DECIMAL(5,2),
    LoanAmount DECIMAL(15,2),
    BranchID INT,
    CustomerID INT,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- INSERT SAMPLE LOANS
INSERT INTO Loan (LoanType, InterestRate, LoanAmount, BranchID, CustomerID)
VALUES
('Home Loan', 8.50, 1200000.00, 1, 1),
('Car Loan', 9.00, 600000.00, 2, 2),
('Personal Loan', 11.00, 250000.00, 3, 3),
('Education Loan', 7.50, 400000.00, 4, 4),
('Home Loan', 8.25, 950000.00, 5, 5),
('Car Loan', 9.25, 500000.00, 6, 6),
('Personal Loan', 10.50, 300000.00, 7, 7),
('Education Loan', 7.75, 350000.00, 8, 8),
('Home Loan', 8.10, 850000.00, 9, 9),
('Car Loan', 9.00, 700000.00, 10, 10);

CREATE TABLE Payment (
    PaymentID INT AUTO_INCREMENT,
    LoanID INT,
    P_Amount DECIMAL(15,2),
    Date DATE,
    PRIMARY KEY (PaymentID, LoanID),
    FOREIGN KEY (LoanID) REFERENCES Loan(LoanID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- INSERT SAMPLE PAYMENTS
INSERT INTO Payment (LoanID, P_Amount, Date)
VALUES
(1, 25000.00, '2024-09-25'),
(1, 25000.00, '2024-10-25'),
(2, 30000.00, '2024-09-15'),
(3, 10000.00, '2024-10-05'),
(4, 15000.00, '2024-10-10'),
(5, 20000.00, '2024-09-28'),
(6, 22000.00, '2024-10-01'),
(7, 12000.00, '2024-10-04'),
(8, 18000.00, '2024-10-07'),
(9, 25000.00, '2024-10-10');

SHOW TABLES; 