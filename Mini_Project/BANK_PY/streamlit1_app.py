import streamlit as st
import mysql.connector
from mysql.connector import Error
import pandas as pd
from dotenv import load_dotenv
import os
import streamlit as st

# Clear cache on every run (for debugging)
st.cache_data.clear()
st.cache_resource.clear()

# Load environment variables
load_dotenv('env.env')

# Database configuration
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASS", ""),
    "database": os.getenv("DB_NAME", "BankDB")
}

if 'conn' not in st.session_state:
    st.session_state.conn = None

def get_connection():
    """Establish database connection"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        st.error(f"Database connection error: {e}")
        return None

def load_all_tables():
    """Get list of all tables"""
    conn = get_connection()
    if conn is None:
        return []
    try:
        cursor = conn.cursor()
        cursor.execute("SHOW TABLES")
        tables = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return tables
    except Error as e:
        st.error(f"Error loading tables: {e}")
        return []

def load_table_data(table_name):
    """Load data from a specific table"""
    conn = get_connection()
    if conn is None:
        return None
    try:
        query = f"SELECT * FROM `{table_name}`"
        df = pd.read_sql(query, conn)
        conn.close()
        return df
    except Error as e:
        st.error(f"Error loading table {table_name}: {e}")
        return None

def add_row(table_name, columns, values):
    """Add a new row to a table"""
    conn = get_connection()
    if conn is None:
        return False
    try:
        cursor = conn.cursor()
        placeholders = ", ".join(["%s"] * len(values))
        cols_formatted = ", ".join([f"`{c}`" for c in columns])
        sql = f"INSERT INTO `{table_name}` ({cols_formatted}) VALUES ({placeholders})"
        cursor.execute(sql, tuple(values))
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Error as e:
        st.error(f"Error adding row: {e}")
        return False

def delete_row(table_name, pk_column, pk_value):
    """Delete a row from a table"""
    conn = get_connection()
    if conn is None:
        return False
    try:
        cursor = conn.cursor()
        sql = f"DELETE FROM `{table_name}` WHERE `{pk_column}` = %s"
        cursor.execute(sql, (pk_value,))
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Error as e:
        st.error(f"Error deleting row: {e}")
        return False

def get_primary_key(table_name):
    """Get primary key column of a table"""
    conn = get_connection()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        cursor.execute(f"SHOW COLUMNS FROM `{table_name}`")
        cols_info = cursor.fetchall()
        cursor.close()
        conn.close()
        for col in cols_info:
            if col[3] == "PRI":
                return col[0]
        return None
    except Error as e:
        st.error(f"Error getting primary key: {e}")
        return None

# ============ FUNCTIONS TESTING ============
def test_calculate_age_function():
    """Test CalculateAge function"""
    conn = get_connection()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        query = "SELECT CustomerID, Name, DOB, CalculateAge(DOB) AS Age FROM Customer LIMIT 5"
        cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return results
    except Error as e:
        st.error(f"Error testing CalculateAge: {e}")
        return None

def test_total_balance_function():
    """Test TotalBalance function"""
    conn = get_connection()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        query = "SELECT CustomerID, Name, TotalBalance(CustomerID) AS TotalBalance FROM Customer LIMIT 5"
        cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return results
    except Error as e:
        st.error(f"Error testing TotalBalance: {e}")
        return None

def test_combined_functions():
    """Test both functions together"""
    conn = get_connection()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        query = """
        SELECT 
            CustomerID, Name,
            CalculateAge(DOB) AS Age,
            TotalBalance(CustomerID) AS TotalBalance
        FROM Customer WHERE CalculateAge(DOB) > 30
        """
        cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return results
    except Error as e:
        st.error(f"Error testing combined functions: {e}")
        return None

# ============ PROCEDURES TESTING ============
def test_get_customer_loans(customer_id):
    """Test GetCustomerLoans procedure"""
    conn = get_connection()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        cursor.callproc('GetCustomerLoans', [customer_id])
        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
        cursor.close()
        conn.close()
        return results
    except Error as e:
        st.error(f"Error calling GetCustomerLoans: {e}")
        return None

def test_branch_account_summary(branch_id):
    """Test BranchAccountSummary procedure"""
    conn = get_connection()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        cursor.callproc('BranchAccountSummary', [branch_id])
        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
        cursor.close()
        conn.close()
        return results
    except Error as e:
        st.error(f"Error calling BranchAccountSummary: {e}")
        return None

# ============ TRIGGERS TESTING ============
def test_add_transaction(account_no, trans_type, amount):
    """Test AddTransaction procedure and trigger"""
    conn = get_connection()
    if conn is None:
        return False
    try:
        cursor = conn.cursor()
        cursor.callproc('AddTransaction', [account_no, trans_type, amount])
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Error as e:
        st.error(f"Error calling AddTransaction: {e}")
        return False

def get_account_balance(account_no):
    """Get current account balance"""
    conn = get_connection()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        cursor.execute(f"SELECT Balance FROM Account WHERE AccountNo = {account_no}")
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return result[0] if result else None
    except Error as e:
        st.error(f"Error getting balance: {e}")
        return None

def get_transactions(account_no, limit=5):
    """Get recent transactions for an account"""
    conn = get_connection()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        cursor.execute(f"SELECT TransactionID, AccountNo, Type, T_Amount, Date FROM Transaction WHERE AccountNo = {account_no} ORDER BY TransactionID DESC LIMIT {limit}")
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return results
    except Error as e:
        st.error(f"Error getting transactions: {e}")
        return None

# Streamlit UI
st.set_page_config(page_title="BankDB Manager", layout="wide", initial_sidebar_state="expanded")
st.title("🏦 BankDB - Database Management System")
st.markdown("---")

# Sidebar navigation
with st.sidebar:
    st.header("📊 Navigation")
    tables = load_all_tables()
    
    if not tables:
        st.warning("No tables found in database.")
    else:
        selected_table = st.selectbox("Select a table:", tables)
        st.markdown("---")
        mode = st.radio("Choose action:", ["📋 View Data", "➕ Add Row", "🗑️ Delete Row", "🔧 Test All"])

# Main content area
if tables:
    if mode == "📋 View Data":
        st.subheader(f"Table: {selected_table}")
        df = load_table_data(selected_table)
        
        if df is not None:
            st.dataframe(df, use_container_width=True, height=400)
            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("Total Rows", len(df))
            with col2:
                st.metric("Total Columns", len(df.columns))
            with col3:
                st.info(f"Database: **BankDB**")
    
    elif mode == "➕ Add Row":
        st.subheader(f"Add New Row to {selected_table}")
        df = load_table_data(selected_table)
        
        if df is not None:
            columns = df.columns.tolist()
            pk_column = get_primary_key(selected_table)
            input_columns = [col for col in columns if col != pk_column]
            
            with st.form(f"add_row_{selected_table}"):
                values = []
                for col in input_columns:
                    col_type = df[col].dtype
                    if col_type == 'object':
                        val = st.text_input(f"{col}:", key=f"add_{col}")
                    elif 'int' in str(col_type):
                        val = st.number_input(f"{col}:", value=0, step=1, key=f"add_{col}")
                    elif 'float' in str(col_type):
                        val = st.number_input(f"{col}:", value=0.0, step=0.01, key=f"add_{col}")
                    else:
                        val = st.text_input(f"{col}:", key=f"add_{col}")
                    values.append(val)
                
                if st.form_submit_button("✅ Add Row"):
                    if add_row(selected_table, input_columns, values):
                        st.success(f"Row added successfully to {selected_table}!")
                        st.rerun()
                    else:
                        st.error("Failed to add row.")
    
    elif mode == "🗑️ Delete Row":
        st.subheader(f"Delete Row from {selected_table}")
        df = load_table_data(selected_table)
        
        if df is not None:
            pk_column = get_primary_key(selected_table)
            if pk_column is None:
                st.error("Cannot delete: Primary key not found.")
            else:
                st.dataframe(df, use_container_width=True)
                pk_value = st.selectbox(f"Select {pk_column} to delete:", df[pk_column].tolist())
                
                if st.button("🗑️ Delete Selected Row", type="secondary"):
                    if delete_row(selected_table, pk_column, pk_value):
                        st.success("Row deleted successfully!")
                        st.rerun()
                    else:
                        st.error("Failed to delete row.")
    
    elif mode == "🔧 Test All":
        st.subheader("🧪 Testing Functions, Procedures & Triggers")
        
        # Create tabs for organization
        tab1, tab2, tab3, tab4 = st.tabs(["Functions", "Procedures", "Triggers", "Demo"])
        
        with tab1:
            st.write("### 1️⃣ CalculateAge() Function")
            age_results = test_calculate_age_function()
            if age_results:
                age_df = pd.DataFrame(age_results, columns=["CustomerID", "Name", "DOB", "Calculated Age"])
                st.dataframe(age_df, use_container_width=True)
                st.success("✅ CalculateAge() is WORKING!")
            else:
                st.error("❌ CalculateAge() function failed")
            
            st.markdown("---")
            st.write("### 2️⃣ TotalBalance() Function")
            balance_results = test_total_balance_function()
            if balance_results:
                balance_df = pd.DataFrame(balance_results, columns=["CustomerID", "Name", "Total Balance"])
                st.dataframe(balance_df, use_container_width=True)
                st.success("✅ TotalBalance() is WORKING!")
            else:
                st.error("❌ TotalBalance() function failed")
            
            st.markdown("---")
            st.write("### 3️⃣ COMBINED Functions (Customers > 30 years)")
            combined_results = test_combined_functions()
            if combined_results:
                combined_df = pd.DataFrame(combined_results, columns=["CustomerID", "Name", "Age", "Total Balance"])
                st.dataframe(combined_df, use_container_width=True)
                st.success("✅ COMBINED functions are WORKING!")
            else:
                st.warning("⚠️ No customers found over 30 years old")
        
        with tab2:
            st.write("### 📞 GetCustomerLoans Procedure")
            customer_id = st.number_input("Enter Customer ID:", min_value=1, value=1, step=1, key="cust_loans")
            if st.button("🔍 Get Loans", key="btn_loans"):
                results = test_get_customer_loans(customer_id)
                if results:
                    loans_df = pd.DataFrame(results, columns=["LoanID", "LoanType", "InterestRate", "LoanAmount", "BranchName"])
                    st.dataframe(loans_df, use_container_width=True)
                    st.success(f"✅ Found {len(results)} loans for Customer {customer_id}")
                else:
                    st.warning("⚠️ No loans found for this customer")
            
            st.markdown("---")
            st.write("### 🏢 BranchAccountSummary Procedure")
            branch_id = st.number_input("Enter Branch ID:", min_value=1, value=1, step=1, key="branch_acc")
            if st.button("🔍 Get Branch Accounts", key="btn_branch"):
                results = test_branch_account_summary(branch_id)
                if results:
                    accounts_df = pd.DataFrame(results, columns=["AccountNo", "CustomerName", "AccountType", "Balance"])
                    st.dataframe(accounts_df, use_container_width=True)
                    st.success(f"✅ Found {len(results)} accounts in Branch {branch_id}")
                else:
                    st.warning("⚠️ No accounts found in this branch")
        
        with tab3:
            st.write("### 💰 AddTransaction Procedure & Trigger Test")
            st.info("This tests the AddTransaction procedure and UpdateBalanceAfterTransaction trigger")
            
            col1, col2, col3 = st.columns(3)
            with col1:
                account_no = st.number_input("Account No:", min_value=1, value=1, step=1)
            with col2:
                trans_type = st.selectbox("Type:", ["Deposit", "Withdrawal"])
            with col3:
                amount = st.number_input("Amount:", min_value=0.0, value=1000.0, step=100.0)
            
            if st.button("💳 Execute Transaction", key="btn_trans"):
                balance_before = get_account_balance(account_no)
                
                if balance_before is not None:
                    st.info(f"💰 Balance BEFORE: ₹{balance_before:,.2f}")
                    
                    if test_add_transaction(account_no, trans_type, amount):
                        st.success("✅ Transaction added successfully!")
                        
                        balance_after = get_account_balance(account_no)
                        st.info(f"💰 Balance AFTER: ₹{balance_after:,.2f}")
                        
                        change = balance_after - balance_before
                        if trans_type == "Deposit":
                            st.success(f"✅ Balance increased by ₹{change:,.2f} - Trigger WORKED! 🎉")
                        else:
                            st.success(f"✅ Balance decreased by ₹{abs(change):,.2f} - Trigger WORKED! 🎉")
                        
                        st.markdown("---")
                        st.write("### Recent Transactions:")
                        transactions = get_transactions(account_no)
                        if transactions:
                            trans_df = pd.DataFrame(transactions, columns=["T_ID", "AccountNo", "Type", "Amount", "Date"])
                            st.dataframe(trans_df, use_container_width=True)
                    else:
                        st.error("❌ Failed to add transaction")
                else:
                    st.error("❌ Could not fetch account balance")
        
        with tab4:
            st.write("### 🎓 Quick Demo & Summary")
            st.markdown("""
            **What's Being Tested:**
            
            ✅ **Functions**: Custom database functions that calculate data
            - CalculateAge(): Computes customer age from DOB
            - TotalBalance(): Sums account balances per customer
            
            ✅ **Procedures**: Reusable SQL routines
            - GetCustomerLoans(): Retrieves customer loans
            - BranchAccountSummary(): Lists accounts in a branch
            
            ✅ **Triggers**: Automatic actions on database events
            - UpdateBalanceAfterTransaction: Auto-updates account balance on transactions
            - PreventAccountDeletionWithLoan: Blocks deletion if customer has loans
            
            **Try This Demo:**
            1. Go to "Triggers" tab
            2. Select Account 1, Deposit, Amount 5000
            3. Click "Execute Transaction"
            4. Watch the balance change automatically! 🎉
            """)

st.markdown("---")
st.caption("🏦 BankDB Management System | Functions + Procedures + Triggers | Built with Streamlit")
