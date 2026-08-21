-- 01_schema.sql
-- Restaurant Orders Analytics
-- Designed for a star-schema style analytical database.

CREATE DATABASE SupplyChain;
-- Connect/use the database before executing the remaining statements.

CREATE TABLE Dim_Customer_Demographics (
    Customer_demographics_Key INT PRIMARY KEY,
    Customer_demographics VARCHAR(50) NOT NULL
);

CREATE TABLE Dim_Product (
    Product_type_Key INT PRIMARY KEY,
    Product_type VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Dim_Supplier (
    Supplier_name_Key INT NOT NULL,
    Supplier_name VARCHAR(100) NOT NULL,
    Product_type_Key INT NOT NULL,
    PRIMARY KEY (Supplier_name_Key, Product_type_Key),
    FOREIGN KEY (Product_type_Key)
        REFERENCES Dim_Product(Product_type_Key)
);

CREATE TABLE Fact_Orders (
    Order_Key INT IDENTITY(1,1) PRIMARY KEY,
    SKU VARCHAR(50) NOT NULL,
    Product_type_Key INT NOT NULL,
    Supplier_name_Key INT NOT NULL,
    Customer_demographics_Key INT NOT NULL,
    Price DECIMAL(18,4),
    Availability INT,
    Number_of_products_sold INT,
    Revenue_generated DECIMAL(18,4),
    Stock_levels INT,
    Lead_times INT,
    Order_quantities INT,
    Shipping_times INT,
    Shipping_carrier VARCHAR(100),
    Shipping_costs DECIMAL(18,4),
    Location VARCHAR(100),
    Lead_time INT,
    Production_volumes INT,
    Manufacturing_lead_time INT,
    Manufacturing_costs DECIMAL(18,4),
    Inspection_results VARCHAR(50),
    Defect_rates DECIMAL(18,6),
    Transportation_mode VARCHAR(50),
    Route VARCHAR(50),
    Costs DECIMAL(18,4),
    Gross_Sales DECIMAL(18,4),
    FOREIGN KEY (Product_type_Key) REFERENCES Dim_Product(Product_type_Key),
    FOREIGN KEY (Customer_demographics_Key) REFERENCES Dim_Customer_Demographics(Customer_demographics_Key)
);
