CREATE DATABASE OnlineStore;
USE OnlineStore;

CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2),
    stock INT DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE OrderDetails (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2),
    payment_method VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);
INSERT INTO Categories (category_name) VALUES 
('Electronics'),
('Clothing'),
('Books'),
('Home & Kitchen'),
('Toys & Games');

INSERT INTO Products (product_name, category_id, price, stock) VALUES
('Laptop', 1, 1000.00, 15),
('Smartphone', 1, 700.00, 25),
('Headphones', 1, 50.00, 100),
('T-Shirt', 2, 20.00, 50),
('Jeans', 2, 40.00, 30),
('Jacket', 2, 60.00, 20),
('Novel - Fiction', 3, 15.00, 40),
('Science Book', 3, 25.00, 35),
('Cookware Set', 4, 80.00, 20),
('Coffee Maker', 4, 120.00, 10),
('Lego Set', 5, 60.00, 15),
('Puzzle', 5, 10.00, 50);

INSERT INTO Customers (first_name, last_name, email, phone) VALUES
('Jane', 'Smith', 'jane@example.com', '2345678901'),
('Alice', 'Johnson', 'alice@example.com', '3456789012'),
('Bob', 'Williams', 'bob@example.com', '4567890123'),
('Carol', 'Davis', 'carol@example.com', '5678901234');

INSERT INTO Orders (customer_id, order_date, status) VALUES
(1, '2025-09-20 10:30:00', 'Completed'),
(2, '2025-09-21 14:15:00', 'Pending'),
(3, '2025-09-22 09:45:00', 'Completed'),
(1, '2025-09-23 11:00:00', 'Completed'),
(4, '2025-09-24 16:20:00', 'Pending');


INSERT INTO OrderDetails (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1000.00),   -- Laptop for John
(1, 3, 2, 100.00),    -- Headphones for John
(2, 4, 3, 60.00),     -- T-Shirts for Jane
(3, 7, 1, 15.00),     -- Novel for Alice
(3, 8, 2, 50.00),     -- Science books for Alice
(4, 2, 1, 700.00),    -- Smartphone for John
(4, 5, 1, 40.00),     -- Jeans for John
(5, 11, 1, 60.00);    -- Lego Set for Bob

INSERT INTO Payments (order_id, payment_date, amount, payment_method) VALUES
(1, '2025-09-20 11:00:00', 1100.00, 'Credit Card'),
(2, '2025-09-21 15:00:00', 60.00, 'PayPal'),
(3, '2025-09-22 10:00:00', 65.00, 'Debit Card'),
(4, '2025-09-23 12:00:00', 740.00, 'Credit Card'),
(5, '2025-09-24 17:00:00', 60.00, 'Credit Card');


-- 1. List all products with their category
SELECT p.product_name, c.category_name, p.price, p.stock
FROM Products p
JOIN Categories c ON p.category_id = c.category_id;

-- 2. Show all orders with customer info 
SELECT o.order_id, o.order_date, o.status,
       c.first_name, c.last_name, c.email
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id;
-- 3. Get order details for a specific order (e.g., order_id = 1)
SELECT od.order_id, p.product_name, od.quantity, od.price, (od.quantity * od.price) AS total
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
WHERE od.order_id = 1;

-- 4. Total amount paid by each customer
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_paid
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payments p ON o.order_id = p.order_id
GROUP BY c.customer_id;

-- 5. Top-selling products (by quantity)
SELECT p.product_name, SUM(od.quantity) AS total_sold
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_sold DESC;

--  6. Total revenue per product
SELECT p.product_name, SUM(od.quantity * od.price) AS revenue
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.product_id
ORDER BY revenue DESC;

-- 7. Customers with more than 1 order
SELECT c.first_name, c.last_name, COUNT(o.order_id) AS orders_count
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING orders_count > 1;

-- 8. Products with low stock (less than 20 units)
SELECT product_name, stock
FROM Products
WHERE stock < 20;

-- 9. Orders with total amount

SELECT o.order_id, c.first_name, c.last_name,
      SUM(od.quantity * od.price) AS order_total
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
GROUP BY o.order_id;

-- 10. Daily revenue
SELECT DATE(payment_date) AS day, SUM(amount) AS daily_revenue
FROM Payments
GROUP BY day
ORDER BY day;

-- 11. Products never ordered

SELECT product_name
FROM Products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM OrderDetails);

-- 12. Average order value per customer
SELECT c.first_name, c.last_name, AVG(od.quantity * od.price) AS avg_order_value
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
GROUP BY c.customer_id;


