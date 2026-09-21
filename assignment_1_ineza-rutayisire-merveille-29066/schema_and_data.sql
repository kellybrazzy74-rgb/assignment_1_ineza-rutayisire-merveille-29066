-- Sunrise Supermarket: schema + sample data (Oracle SQL; DATE literals also work in PostgreSQL/MySQL)

-- Clean re-run: drop the tables if they already exist (errors are ignored on the first run)
BEGIN
  FOR t IN (SELECT column_value AS name FROM TABLE(sys.odcivarchar2list('ORDER_ITEMS','ORDERS','PRODUCTS','CUSTOMERS'))) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE ' || t.name;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP;
END;
/

CREATE TABLE customers (
  customer_id NUMBER PRIMARY KEY,
  customer_name VARCHAR2(100),
  email VARCHAR2(100),
  city VARCHAR2(50)
);

CREATE TABLE products (
  product_id NUMBER PRIMARY KEY,
  product_name VARCHAR2(100),
  category VARCHAR2(50),
  price NUMBER(10,2)
);

CREATE TABLE orders (
  order_id NUMBER PRIMARY KEY,
  customer_id NUMBER REFERENCES customers(customer_id),
  order_date DATE
);

CREATE TABLE order_items (
  order_item_id NUMBER PRIMARY KEY,
  order_id NUMBER REFERENCES orders(order_id),
  product_id NUMBER REFERENCES products(product_id),
  quantity NUMBER
);

-- Customers (6; customer 6 has no orders on purpose, to demonstrate the LEFT JOIN)
INSERT INTO customers VALUES (1, 'Aline Uwase', 'aline.uwase@example.com', 'Kigali');
INSERT INTO customers VALUES (2, 'Jean Bosco Nkurunziza', 'jb.nkurunziza@example.com', 'Huye');
INSERT INTO customers VALUES (3, 'Grace Mukamana', 'grace.mukamana@example.com', 'Kigali');
INSERT INTO customers VALUES (4, 'Eric Habimana', 'eric.habimana@example.com', 'Musanze');
INSERT INTO customers VALUES (5, 'Diane Ingabire', 'diane.ingabire@example.com', 'Rubavu');
INSERT INTO customers VALUES (6, 'Patrick Mugisha', 'patrick.mugisha@example.com', 'Kigali');

-- Products (8 products, 4 categories)
INSERT INTO products VALUES (1, 'Rice 5kg', 'Grocery', 6500);
INSERT INTO products VALUES (2, 'Cooking Oil 1L', 'Grocery', 3200);
INSERT INTO products VALUES (3, 'Fresh Milk 1L', 'Dairy', 1200);
INSERT INTO products VALUES (4, 'Cheddar Cheese 500g', 'Dairy', 4500);
INSERT INTO products VALUES (5, 'Orange Juice 1L', 'Beverages', 2500);
INSERT INTO products VALUES (6, 'Bottled Water 1.5L', 'Beverages', 800);
INSERT INTO products VALUES (7, 'Dish Soap 500ml', 'Household', 1800);
INSERT INTO products VALUES (8, 'Laundry Detergent 2kg', 'Household', 5200);

-- Orders (15 orders; orders 9 and 10 share a date on purpose)
INSERT INTO orders VALUES (1, 1, DATE '2026-01-05');
INSERT INTO orders VALUES (2, 2, DATE '2026-01-08');
INSERT INTO orders VALUES (3, 3, DATE '2026-01-12');
INSERT INTO orders VALUES (4, 1, DATE '2026-01-19');
INSERT INTO orders VALUES (5, 4, DATE '2026-01-23');
INSERT INTO orders VALUES (6, 5, DATE '2026-02-02');
INSERT INTO orders VALUES (7, 2, DATE '2026-02-06');
INSERT INTO orders VALUES (8, 3, DATE '2026-02-14');
INSERT INTO orders VALUES (9, 1, DATE '2026-02-20');
INSERT INTO orders VALUES (10, 3, DATE '2026-02-20');
INSERT INTO orders VALUES (11, 5, DATE '2026-03-04');
INSERT INTO orders VALUES (12, 1, DATE '2026-03-11');
INSERT INTO orders VALUES (13, 2, DATE '2026-03-18');
INSERT INTO orders VALUES (14, 3, DATE '2026-03-25');
INSERT INTO orders VALUES (15, 5, DATE '2026-04-01');

-- Order items (33 rows)
INSERT INTO order_items VALUES (1, 1, 1, 2);
INSERT INTO order_items VALUES (2, 1, 3, 4);
INSERT INTO order_items VALUES (3, 2, 5, 3);
INSERT INTO order_items VALUES (4, 2, 6, 6);
INSERT INTO order_items VALUES (5, 3, 4, 1);
INSERT INTO order_items VALUES (6, 3, 2, 1);
INSERT INTO order_items VALUES (7, 3, 7, 2);
INSERT INTO order_items VALUES (8, 4, 8, 1);
INSERT INTO order_items VALUES (9, 4, 3, 2);
INSERT INTO order_items VALUES (10, 5, 1, 1);
INSERT INTO order_items VALUES (11, 5, 2, 2);
INSERT INTO order_items VALUES (12, 5, 6, 4);
INSERT INTO order_items VALUES (13, 6, 7, 1);
INSERT INTO order_items VALUES (14, 6, 5, 2);
INSERT INTO order_items VALUES (15, 7, 3, 3);
INSERT INTO order_items VALUES (16, 7, 4, 2);
INSERT INTO order_items VALUES (17, 8, 1, 2);
INSERT INTO order_items VALUES (18, 8, 8, 1);
INSERT INTO order_items VALUES (19, 9, 6, 10);
INSERT INTO order_items VALUES (20, 9, 5, 1);
INSERT INTO order_items VALUES (21, 10, 2, 1);
INSERT INTO order_items VALUES (22, 10, 4, 1);
INSERT INTO order_items VALUES (23, 10, 3, 2);
INSERT INTO order_items VALUES (24, 11, 8, 2);
INSERT INTO order_items VALUES (25, 11, 7, 1);
INSERT INTO order_items VALUES (26, 12, 1, 1);
INSERT INTO order_items VALUES (27, 12, 3, 5);
INSERT INTO order_items VALUES (28, 13, 5, 4);
INSERT INTO order_items VALUES (29, 13, 2, 2);
INSERT INTO order_items VALUES (30, 14, 6, 6);
INSERT INTO order_items VALUES (31, 14, 7, 3);
INSERT INTO order_items VALUES (32, 15, 4, 2);
INSERT INTO order_items VALUES (33, 15, 1, 1);

COMMIT;
