-- Sunrise Supermarket: JOIN, CTE and window-function queries (Oracle SQL)

-- ===== JOIN 1: every order with customer name, city, order date =====
SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- ===== JOIN 2: every order item with product name, category, price, quantity =====
SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
ORDER BY oi.order_item_id;

-- ===== JOIN 3: all customers and their orders, including customers with no orders =====
SELECT c.customer_id, c.customer_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_id;

-- ===== CTE: customers whose total spend is above the average customer spend =====
WITH customer_totals AS (
  SELECT c.customer_id, c.customer_name,
         SUM(oi.quantity * p.price) AS total_spend
  FROM customers c
  JOIN orders o       ON o.customer_id = c.customer_id
  JOIN order_items oi ON oi.order_id   = o.order_id
  JOIN products p     ON p.product_id  = oi.product_id
  GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spend
FROM customer_totals
WHERE total_spend > (SELECT AVG(total_spend) FROM customer_totals)
ORDER BY total_spend DESC;

-- ===== WINDOW 1: rank customers by total amount spent (highest first) =====
WITH customer_totals AS (
  SELECT c.customer_id, c.customer_name,
         SUM(oi.quantity * p.price) AS total_spend
  FROM customers c
  JOIN orders o       ON o.customer_id = c.customer_id
  JOIN order_items oi ON oi.order_id   = o.order_id
  JOIN products p     ON p.product_id  = oi.product_id
  GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spend,
       RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
FROM customer_totals
ORDER BY spend_rank;

-- ===== WINDOW 2: number each customer's orders in the order they were placed =====
SELECT c.customer_name, o.order_id, o.order_date,
       ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date, o.order_id) AS order_seq
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY c.customer_name, order_seq;

-- ===== WINDOW 3: running total of revenue over time =====
-- Revenue is summed per day first so two orders on the same date do not give an unstable running total.
WITH daily_revenue AS (
  SELECT o.order_date, SUM(oi.quantity * p.price) AS revenue
  FROM orders o
  JOIN order_items oi ON oi.order_id  = o.order_id
  JOIN products p     ON p.product_id = oi.product_id
  GROUP BY o.order_date
)
SELECT order_date, revenue,
       SUM(revenue) OVER (ORDER BY order_date) AS running_total
FROM daily_revenue
ORDER BY order_date;

-- ===== WINDOW 4: days between current and previous order (customers with > 1 order) =====
SELECT customer_name, order_id, order_date, previous_order_date,
       order_date - previous_order_date AS days_since_previous
FROM (
  SELECT c.customer_name, o.order_id, o.order_date,
         LAG(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date, o.order_id) AS previous_order_date,
         COUNT(*)          OVER (PARTITION BY o.customer_id) AS order_count
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
)
WHERE order_count > 1
ORDER BY customer_name, order_date, order_id;

-- ===== VALIDATION: row counts per table =====
SELECT (SELECT COUNT(*) FROM customers)   AS customers,
       (SELECT COUNT(*) FROM products)    AS products,
       (SELECT COUNT(*) FROM orders)      AS orders,
       (SELECT COUNT(*) FROM order_items) AS order_items
FROM dual;
