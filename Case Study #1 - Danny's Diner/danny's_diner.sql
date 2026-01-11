CREATE database dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	a.customer_id,
	SUM(b.product_id) as the_total_amount
FROM sales a
INNER JOIN menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id;
-- 2. How many days has each customer visited the restaurant?
SELECT
	a.customer_id,
	COUNT(a.order_date) as days_has_each_customer_visited_the_restaurant
FROM sales a
GROUP BY a.customer_id;
-- 3. What was the first item from the menu purchased by each customer? *
SELECT
	a.customer_id,
	b.product_name
FROM sales a
INNER JOIN menu b
ON a.product_id = b.product_id
WHERE a.order_date = (
						SELECT MIN(order_date)
						FROM sales
						WHERE customer_id = a.customer_id
					)
----Solution 2----
SELECT customer_id, product_name
FROM (
  SELECT
    s.customer_id,
    m.product_name,
    ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date, s.product_id
    ) AS rn
  FROM sales s
  JOIN menu m
    ON s.product_id = m.product_id
) ranked
WHERE rn = 1;
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	a.customer_id,
	b.product_name,
	COUNT(a.product_id) as the_most_purchased_item_on_the_menu
FROM sales a
INNER JOIN menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id, b.product_name;
-- 5. Which item was the most popular for each customer?
SELECT
	a.customer_id,
	b.product_name,
	COUNT(a.product_id) as item_was_the_most_popular_for_each_customer
FROM sales a
INNER JOIN menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id, b.product_name;
-- 6. Which item was purchased first by the customer after they became a member? *
SELECT
	a.customer_id,
	b.product_name
FROM sales a
INNER JOIN menu b
ON a.product_id = b.product_id
INNER JOIN members c
ON a.customer_id = c.customer_id
WHERE a.order_date > c.join_date AND a.order_date = (
														SELECT MIN(order_date)
														FROM sales
														WHERE customer_id = a.customer_id
														AND order_date > c.join_date
													)
-- 7. Which item was purchased just before the customer became a member? *
SELECT
	a.customer_id,
	b.product_name
FROM sales a
INNER JOIN menu b
ON a.product_id = b.product_id
INNER JOIN members c
ON a.customer_id = c.customer_id
WHERE a.order_date < c.join_date AND a.order_date = (
														SELECT MAX(order_date)
														FROM sales
														WHERE customer_id = a.customer_id
														AND order_date < c.join_date
													)
-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
	a.customer_id,
	b.price,
	COUNT(b.product_id) as total
FROM sales a
INNER JOIN menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id, b.price;
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	a.customer_id,
	b.product_name,
	SUM(CASE
		WHEN b.product_name = 'sushi' THEN b.price * 10 * 2
		ELSE b.price * 10
	END) AS Score_customer
FROM sales a
INNER JOIN menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id, b.product_name;
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN m.join_date AND DATEADD(day, 6, m.join_date) THEN me.price * 10 * 2
            WHEN me.product_name = 'sushi' THEN me.price * 10 * 2
            ELSE me.price * 10
        END
    ) AS total_points
FROM sales s
INNER JOIN menu me
    ON s.product_id = me.product_id
INNER JOIN members m
    ON s.customer_id = m.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY s.customer_id;
-- 11. Bonus Recreate the following table output using the available data
CREATE VIEW view_data AS
SELECT 
	a.customer_id,
	a.order_date,
	b.product_name,
	b.price,
	CASE
		WHEN a.order_date < c.join_date THEN 'N'
		ELSE 'Y'
	END AS member
FROM sales a
INNER JOIN menu b
ON a.product_id = b.product_id
INNER JOIN members c
ON a.customer_id = c.customer_id
SELECT * FROM view_data;

SELECT 
	*,
	CASE
		WHEN member = 'N' THEN NULL
		ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
	END as ranking
FROM view_data;
