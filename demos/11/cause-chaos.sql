-- lets look at some data
USE Northwind
GO

SELECT * 
FROM customers

UPDATE customers
SET Phone = '330-329-6691'

SELECT * 
FROM customers

-- what if I truncate a table too?
SELECT *
FROM [Order Details]

TRUNCATE TABLE [Order Details]

SELECT *
FROM [Order Details]