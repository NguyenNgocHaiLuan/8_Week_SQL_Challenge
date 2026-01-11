CREATE DATABASE pizza_runner;
use pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME2
); 

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),0
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" NVARCHAR(50)
);

INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

----Solution----
--1.How many pizzas were ordered?
SELECT
	COUNT(*) as total_pizzas
FROM customer_orders
--2.How many unique customer orders were made?
SELECT
	DISTINCT(order_id) as unique_orders
FROM customer_orders;
--3.How many successful orders were delivered by each runner?
SELECT
	runner_id,
	COUNT(order_id) as delivered_orders
FROM runner_orders
WHERE pickup_time != 'null'
GROUP BY runner_id;
--4.How many of each type of pizza was delivered?
SELECT 
	pizza_name, 
	COUNT(a.pizza_id) as delivered_pizzas 
FROM 
	customer_orders a 
INNER JOIN pizza_names b
ON a.pizza_id = b.pizza_id 
INNER JOIN runner_orders c
ON a.order_id = c.order_id 
WHERE 
	pickup_time != 'null'
GROUP BY 
	pizza_name;
--5.How many Vegetarian and Meatlovers were ordered by each customer?
WITH pizza_cte AS (
	SELECT
		a.customer_id,
		b.pizza_name,
		CASE
			WHEN b.pizza_name = 'vegetarian' then 1 else 0 end as vegetarian,
		CASE
			WHEN b.pizza_name = 'Meatlovers' then 1 else 0 end as meatlovers
	FROM customer_orders a
	INNER JOIN pizza_names b
	ON a.pizza_id = b.pizza_id
	WHERE b.pizza_id is not null
)
SELECT
	customer_id,
	SUM(meatlovers) as meatlovers_count,
	SUM(vegetarian) as vegetarian_count
FROM pizza_cte
GROUP BY customer_id;
--6.What was the maximum number of pizzas delivered in a single order?
WITH max_pizza AS (
	SELECT
	a.order_id,
	COUNT(pizza_id) AS number_pizzas
	FROM customer_orders a
	INNER JOIN runner_orders b
	ON a.order_id = b.order_id
	WHERE pickup_time != 'null'
	GROUP BY a.order_id
)
SELECT
	TOP 1 order_id,
	MAX(number_pizzas) as np
FROM max_pizza
GROUP BY order_id
ORDER BY np DESC;
--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
    a.customer_id,
    SUM(
        CASE 
            WHEN (
                (a.exclusions IS NOT NULL AND a.exclusions != 'null' AND LEN(a.exclusions) > 0)
                OR 
                (a.extras IS NOT NULL AND a.extras != 'null' AND LEN(a.extras) > 0)
            )
            THEN 1 ELSE 0 
        END
    ) AS with_changes,
    SUM(
        CASE 
            WHEN (
                (a.exclusions IS NULL OR a.exclusions = 'null' OR LEN(a.exclusions) = 0)
                AND
                (a.extras IS NULL OR a.extras = 'null' OR LEN(a.extras) = 0)
            )
            THEN 1 ELSE 0 
        END
    ) AS no_changes
FROM customer_orders a
INNER JOIN runner_orders b
    ON a.order_id = b.order_id
WHERE b.pickup_time IS NOT NULL
GROUP BY a.customer_id
ORDER BY a.customer_id;
--8.How many pizzas were delivered that had both exclusions and extras?
SELECT
	COUNT(pizza_id) as pizza_delevered
FROM customer_orders a
INNER JOIN runner_orders b
ON a.order_id = b.order_id
WHERE b.pickup_time != 'null' 
AND (a.exclusions IS NOT NULL AND a.exclusions != 'null' AND LEN(a.exclusions) > 0 )
AND (a.extras IS NOT NULL AND a.extras != 'null' AND LEN(a.extras) > 0 )
--9.What was the total volume of pizzas ordered for each hour of the day?
SELECT
	DATEPART(hour, order_time) as hour,
	COUNT(*) as ordered_pizzas
from customer_orders
GROUP BY DATEPART(hour, order_time)
--10.What was the volume of orders for each day of the week?
SELECT
	DATEPART(DAY, order_time) as day,
	COUNT(*) as ordered_pizzas
FROM customer_orders
GROUP BY DATEPART(DAY, order_time)
----B. Runner and Customer Experience----
--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
	DATEADD(WEEK, DATEDIFF(WEEK, '2021-01-01',registration_date), '2021-01-01') AS week_start_date,
	COUNT(*) as runners_signed
FROM runners
GROUP BY DATEADD(WEEK, DATEDIFF(WEEK, '2021-01-01',registration_date), '2021-01-01');
--Solution 2--
SELECT
    DATEDIFF(WEEK, '2021-01-01', registration_date) + 1 AS week_number,
    COUNT(*) AS runners_signed
FROM runners
GROUP BY DATEDIFF(WEEK, '2021-01-01', registration_date)
ORDER BY week_number;
--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
	b.runner_id,
	AVG(DATEDIFF(MINUTE, order_time, pickup_time)) as minutes_it_took  
FROM customer_orders a
INNER JOIN runner_orders b
ON a.order_id = b.order_id
WHERE pickup_time != 'null' and pickup_time IS NOT NULL
GROUP BY b.runner_id;
--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH relationship_CTE AS (
  SELECT 
    a.order_id, 
    COUNT(pizza_id) as number_of_pizzas, 
    MAX(DATEDIFF(minute, order_time, pickup_time)) as order_prep_time 
  FROM 
    runner_orders a
    INNER JOIN customer_orders b 
	ON a.order_id = b.order_id 
  WHERE 
    pickup_time != 'null' 
  GROUP BY 
    a.order_id
) 
SELECT 
  number_of_pizzas, 
  AVG(order_prep_time) as avg_order_prep_time 
FROM 
  relationship_CTE
GROUP BY 
  number_of_pizzas;
--4. What was the average distance travelled for each customer?
SELECT
	customer_id,
	AVG(CAST(REPLACE(distance, 'km', '') AS FLOAT)) as Average_distance_travelled
FROM customer_orders a
INNER JOIN runner_orders b
ON a.order_id = b.order_id
WHERE b.distance != 'null'
GROUP BY customer_id;
--5. What was the difference between the longest and shortest delivery times for all orders?
WITH longest_cte AS (
    SELECT 
        MAX(
            CASE
                WHEN b.duration LIKE '%minutes%' THEN CAST(REPLACE(b.duration, 'minutes', '') AS INT)
                WHEN b.duration LIKE '%mins%' THEN CAST(REPLACE(b.duration, 'mins', '') AS INT)
                ELSE NULL
            END
        ) AS longest_delivery
    FROM runner_orders b
    WHERE b.duration IS NOT NULL AND b.duration != 'null'
),
shortest_cte AS (
    SELECT 
        MIN(
            CASE
                WHEN b.duration LIKE '%minutes%' THEN CAST(REPLACE(b.duration, 'minutes', '') AS INT)
                WHEN b.duration LIKE '%mins%' THEN CAST(REPLACE(b.duration, 'mins', '') AS INT)
                ELSE NULL
            END
        ) AS shortest_delivery
    FROM runner_orders b
    WHERE b.duration IS NOT NULL AND b.duration != 'null'
)
SELECT 
    l.longest_delivery - s.shortest_delivery AS diff_delivery_time
FROM longest_cte l
CROSS JOIN shortest_cte s;
--Solution 2--
SELECT
    MAX(
        CASE
            WHEN b.duration LIKE '%minutes%' THEN CAST(REPLACE(b.duration, 'minutes', '') AS INT)
            WHEN b.duration LIKE '%mins%' THEN CAST(REPLACE(b.duration, 'mins', '') AS INT)
            ELSE NULL
        END
    )
    - 
    MIN(
        CASE
            WHEN b.duration LIKE '%minutes%' THEN CAST(REPLACE(b.duration, 'minutes', '') AS INT)
            WHEN b.duration LIKE '%mins%' THEN CAST(REPLACE(b.duration, 'mins', '') AS INT)
            ELSE NULL
        END
    ) AS difference_in_delivery_time
FROM runner_orders b
WHERE b.duration IS NOT NULL
  AND b.duration != 'null';
--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH distance_CTE as (
	SELECT
		b.runner_id,
		a.order_id,
		REPLACE(b.distance, 'km', '') as new_distance
	FROM customer_orders a
	INNER JOIN runner_orders b
	ON a.order_id = b.order_id
	WHERE b.distance IS NOT NULL AND b.distance != 'null'
),
duration_CTE as (
	SELECT
		b.customer_id,
		a.order_id,
		CASE
			WHEN a.duration LIKE '%minutes%' THEN CAST(REPLACE(a.duration, 'minutes', '') AS FLOAT)
			WHEN a.duration LIKE '%mins%' THEN CAST(REPLACE(a.duration, 'mins', '') AS FLOAT)
			ELSE NULL
		END AS new_duration
	FROM runner_orders a
	INNER JOIN customer_orders b
	ON a.order_id = b.order_id
	WHERE a.duration IS NOT NULL and a.duration != 'null' 
)
SELECT
	b.new_distance / a.new_duration as avg_speed_for_each_runner
FROM duration_CTE a
INNER JOIN distance_CTE b
ON a.order_id = b.order_id
--7. What is the successful delivery percentage for each runner?
SELECT 
  runner_id, 
  COUNT(order_id) as orders, 
  SUM(
    CASE 
        WHEN pickup_time = 'null' THEN 0
        ELSE 1 
    END
  ) / COUNT(order_id) as delivery_percentage 
FROM 
  runner_orders 
GROUP BY 
  runner_id
----C. Ingredient Optimisation----

--1. What are the standard ingredients for each pizza?
SELECT 
    CAST(T.topping_name AS VARCHAR(100)) AS topping_name,
    COUNT(DISTINCT R.pizza_id) AS appears_on_x_many_pizzas
FROM pizza_recipes AS R
CROSS APPLY STRING_SPLIT(CAST(R.toppings AS VARCHAR(MAX)), ',') AS S
INNER JOIN pizza_toppings AS T 
    ON T.topping_id = CAST(LTRIM(RTRIM(S.value)) AS INT)
GROUP BY CAST(T.topping_name AS VARCHAR(100))
HAVING COUNT(DISTINCT R.pizza_id) = 2;

--2. What was the most commonly added extras
SELECT 
    CAST(T.topping_name AS VARCHAR(100)) AS topping_name,
    COUNT(co.order_id) AS extras
FROM customer_orders AS co
CROSS APPLY STRING_SPLIT(CAST(co.extras AS VARCHAR(MAX)), ',') AS S
INNER JOIN pizza_toppings AS T 
    ON T.topping_id = CAST(LTRIM(RTRIM(S.value)) AS INT)
WHERE S.value <> 'null'
  AND LEN(S.value) > 0
GROUP BY CAST(T.topping_name AS VARCHAR(100))
ORDER BY COUNT(co.order_id) DESC;
--3. What was the most common exclusion?
SELECT
	CAST(c.topping_name AS VARCHAR(100)) AS topping_name,
	COUNT(a.order_id) as exclusions
FROM customer_orders a
CROSS APPLY STRING_SPLIT(CAST(a.exclusions AS VARCHAR(MAX)), ',') AS S
INNER JOIN pizza_toppings c
ON c.topping_id = CAST(LTRIM(RTRIM(S.value)) AS INT)
WHERE S.value <> 'null' AND LEN(S.value) > 0
GROUP BY CAST(c.topping_name AS VARCHAR(100))
ORDER BY COUNT(a.order_id) DESC;
--4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers 
--Meat Lovers - Exclude Beef 
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH extras_cte AS (
    SELECT
        co.order_id,
        STRING_AGG(CAST(t.topping_name AS VARCHAR(100)), ', ') as added_Extra
    FROM customer_orders co
    CROSS APPLY STRING_SPLIT(CAST(co.extras AS VARCHAR(MAX)), ',') AS s
    INNER JOIN pizza_toppings t 
        ON t.topping_id = TRY_CAST(LTRIM(RTRIM(s.value)) AS INT)
    WHERE s.value IS NOT NULL AND s.value <> 'null' AND LTRIM(RTRIM(s.value)) <> ''
    GROUP BY co.order_id
),
exclusions_cte AS (
    SELECT
        co.order_id,
        STRING_AGG(CAST(t.topping_name AS VARCHAR(100)), ', ') as Excluded
    FROM customer_orders co
    CROSS APPLY STRING_SPLIT(CAST(co.exclusions AS VARCHAR(MAX)), ',') AS s
    INNER JOIN pizza_toppings t 
        ON t.topping_id = TRY_CAST(LTRIM(RTRIM(s.value)) AS INT)
    WHERE s.value IS NOT NULL AND s.value <> 'null' AND LTRIM(RTRIM(s.value)) <> ''
    GROUP BY co.order_id
)
SELECT
    co.order_id,
    pn.pizza_name
        + CASE 
            WHEN ex.Excluded IS NOT NULL THEN ' - Exclude ' + ex.Excluded
            ELSE ''
        END
        + CASE
            WHEN exs.added_Extra IS NOT NULL THEN ' - Extra ' + exs.added_Extra
            ELSE ''
        END AS order_item
FROM customer_orders co
JOIN pizza_names pn 
ON co.pizza_id = pn.pizza_id
LEFT JOIN exclusions_cte ex 
ON co.order_id = ex.order_id
LEFT JOIN extras_cte exs
ON co.order_id = exs.order_id
ORDER BY co.order_id;
--5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH EXCLUSIONS AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        LTRIM(RTRIM(s.value)) AS topping_id
    FROM customer_orders co
    CROSS APPLY STRING_SPLIT(CAST(co.exclusions AS VARCHAR(MAX)), ',') s
    WHERE LTRIM(RTRIM(s.value)) <> '' 
      AND LTRIM(RTRIM(s.value)) <> 'null'
),
EXTRAS AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        LTRIM(RTRIM(s.value)) AS topping_id,
        t.topping_name
    FROM customer_orders co
    CROSS APPLY STRING_SPLIT(CAST(co.extras AS VARCHAR(MAX)), ',') s
    INNER JOIN pizza_toppings t 
        ON t.topping_id = TRY_CAST(LTRIM(RTRIM(s.value)) AS INT)
    WHERE LTRIM(RTRIM(s.value)) <> '' 
      AND LTRIM(RTRIM(s.value)) <> 'null'
),
ORDERS AS (
    SELECT
        co.order_id,
        co.pizza_id,
        LTRIM(RTRIM(s.value)) AS topping_id,
        t.topping_name
    FROM customer_orders co
    INNER JOIN pizza_recipes pr 
        ON co.pizza_id = pr.pizza_id
    CROSS APPLY STRING_SPLIT(CAST(pr.toppings AS VARCHAR(MAX)), ',') s
    INNER JOIN pizza_toppings t 
        ON t.topping_id = TRY_CAST(LTRIM(RTRIM(s.value)) AS INT)
),
ORDERS_WITH_EXTRAS_AND_EXCLUSIONS AS (
    SELECT 
        O.order_id,
        O.pizza_id,
        TRY_CAST(O.topping_id AS INT) AS topping_id,
        O.topping_name
    FROM ORDERS O
    LEFT JOIN EXCLUSIONS EXC
        ON EXC.order_id = O.order_id
        AND EXC.pizza_id = O.pizza_id
        AND EXC.topping_id = O.topping_id
    WHERE EXC.topping_id IS NULL

    UNION ALL

    SELECT 
        order_id,
        pizza_id,
        TRY_CAST(topping_id AS INT) AS topping_id,
        topping_name
    FROM EXTRAS
    WHERE topping_id <> ''
),
TOPPING_COUNT AS (
    SELECT
        order_id,
        pizza_id,
        CAST(topping_name AS NVARCHAR(MAX)) AS topping_name,
        COUNT(*) AS n
    FROM ORDERS_WITH_EXTRAS_AND_EXCLUSIONS
    GROUP BY 
        order_id, 
        pizza_id, 
        CAST(topping_name AS NVARCHAR(MAX))
)
SELECT 
    order_id,
    pizza_id,
    STRING_AGG(
        CASE
            WHEN n > 1 THEN CONCAT(n, 'x', topping_name)
            ELSE topping_name
        END,
        ', '
    ) AS ingredient
FROM TOPPING_COUNT
GROUP BY order_id, pizza_id;
--6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-- 1. Exclusions (những topping bị loại bỏ)
WITH EXCLUSIONS AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        CAST(s.value AS INT) AS topping_id
    FROM customer_orders co
    CROSS APPLY STRING_SPLIT(CAST(co.exclusions AS NVARCHAR(MAX)), ',') s
    WHERE s.value <> 'null' AND LEN(s.value) > 0
),

-- 2. Extras (những topping được thêm)
EXTRAS AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        CAST(s.value AS INT) AS topping_id
    FROM customer_orders co
    CROSS APPLY STRING_SPLIT(CAST(co.extras AS NVARCHAR(MAX)), ',') s
    WHERE s.value <> 'null' AND LEN(s.value) > 0
),

-- 3. Topping mặc định của pizza (pizza_recipes)
BASE_TOPPINGS AS (
    SELECT
        co.order_id,
        co.pizza_id,
        CAST(s.value AS INT) AS topping_id
    FROM customer_orders co
    INNER JOIN pizza_recipes pr 
        ON co.pizza_id = pr.pizza_id
    CROSS APPLY STRING_SPLIT(CAST(pr.toppings AS NVARCHAR(MAX)), ',') s
),

-- 4. Gộp tất cả topping cuối cùng = base + extras - exclusions
FINAL_TOPPINGS AS (
    -- base toppings (trừ những cái trong exclusions)
    SELECT 
        b.order_id,
        b.pizza_id,
        b.topping_id
    FROM BASE_TOPPINGS b
    LEFT JOIN EXCLUSIONS e 
        ON b.order_id = e.order_id 
        AND b.pizza_id = e.pizza_id
        AND b.topping_id = e.topping_id
    WHERE e.topping_id IS NULL  -- loại bỏ exclusions

    UNION ALL

    -- extras (chỉ cần add thêm)
    SELECT 
        ex.order_id,
        ex.pizza_id,
        ex.topping_id
    FROM EXTRAS ex
),

-- 5. Chỉ lấy các order đã được giao (delivered)
DELIVERED_TOPPINGS AS (
    SELECT 
        ft.order_id,
        ft.pizza_id,
        ft.topping_id
    FROM FINAL_TOPPINGS ft
    INNER JOIN runner_orders ro 
        ON ft.order_id = ro.order_id
    WHERE ro.pickup_time IS NOT NULL 
      AND ro.pickup_time <> 'null'
)

-- 6. Đếm số lượng từng topping
SELECT 
    CAST(t.topping_name AS VARCHAR(MAX)) AS topping_name,
    COUNT(*) AS total_quantity
FROM DELIVERED_TOPPINGS dt
INNER JOIN pizza_toppings t 
    ON dt.topping_id = t.topping_id
GROUP BY CAST(t.topping_name AS VARCHAR(MAX))
ORDER BY total_quantity DESC;

----D. Pricing and Ratings----
--1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
WITH cleaned_orders AS (
    SELECT 
        order_id,
        pizza_id,
        CASE 
            WHEN extras IS NULL OR extras LIKE 'null' OR extras = '' THEN NULL
            ELSE extras 
        END AS extras
    FROM customer_orders
),
extras_count AS (
    SELECT 
        order_id,
        pizza_id,
        CASE 
            WHEN pizza_id = 1 THEN 12 -- Meatlovers
            ELSE 10                   -- Vegetarian
        END AS base_cost,
        CASE 
            WHEN extras IS NULL THEN 0
            ELSE (LEN(extras) - LEN(REPLACE(extras, ',', '')) + 1) * 1 
        END AS extra_cost
    FROM cleaned_orders
)
SELECT 
    SUM(base_cost + extra_cost) AS total_earnings
FROM extras_count;
--2. What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra
WITH cleaning_orders AS (
    SELECT 
        c.order_id,
        c.pizza_id,
        c.extras
    FROM customer_orders c
    JOIN runner_orders r ON c.order_id = r.order_id
    WHERE r.cancellation IS NULL OR r.cancellation NOT LIKE '%Cancellation%'
),
split_extras AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        TRIM(value) AS topping_id
    FROM cleaning_orders co
    CROSS APPLY STRING_SPLIT(co.extras, ',') 
    WHERE co.extras IS NOT NULL AND co.extras <> '' AND co.extras <> 'null'
),
orders_cost AS (
    SELECT 
        order_id,
        CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END AS pizza_cost,
        CASE 
            WHEN topping_id = 4 THEN 1
            ELSE 1
        END AS extra_cost
    FROM split_extras
    
    UNION ALL
  
    SELECT 
        order_id,
        CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END AS pizza_cost,
        0 AS extra_cost
    FROM cleaning_orders
    WHERE extras IS NULL OR extras = '' OR extras = 'null'
)

SELECT SUM(pizza_cost + extra_cost) AS total_revenue
FROM orders_cost;
--3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
--how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for 
--ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings (
    order_id INTEGER PRIMARY KEY,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    created_at DATETIME DEFAULT GETDATE()
);

INSERT INTO runner_ratings (order_id, rating)
SELECT 
    order_id,
    NTILE(5) OVER (ORDER BY duration_int DESC) as auto_rating
FROM (
    SELECT 
        order_id,
        TRY_CAST(
            REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'mins', ''), 'minute', '') 
            AS INT
        ) AS duration_int
    FROM runner_orders
    WHERE cancellation IS NULL OR cancellation = ''
) AS clean_data
WHERE duration_int IS NOT NULL;
--4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--customer_id
--order_id
--runner_id
--rating
--order_time
--pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas
WITH cleaned_runner_orders AS (
    SELECT 
        order_id,
        runner_id,
        TRY_CAST(pickup_time AS DATETIME) AS pickup_time,
        TRY_CAST(REPLACE(distance, 'km', '') AS FLOAT) AS distance_km,
        TRY_CAST(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'mins', ''), 'minute', '') AS FLOAT) AS duration_min
    FROM runner_orders
    WHERE cancellation IS NULL OR cancellation = '' AND cancellation = 'null'
)
SELECT
    c.customer_id,
    c.order_id,
    r.runner_id,
    rt.rating,
    c.order_time,
    r.pickup_time,
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS time_between_order_pickup,
    r.duration_min AS delivery_duration,
    ROUND(r.distance_km / (r.duration_min / 60), 2) AS average_speed,
    COUNT(c.pizza_id) AS total_pizzas
FROM customer_orders c
JOIN cleaned_runner_orders r ON c.order_id = r.order_id
LEFT JOIN runner_ratings rt ON c.order_id = rt.order_id
GROUP BY 
    c.customer_id,
    c.order_id,
    r.runner_id,
    rt.rating,
    c.order_time,
    r.pickup_time,
    r.duration_min,
    r.distance_km;
--5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
WITH new_order AS (
	SELECT order_id
    FROM runner_orders
    WHERE cancellation IS NULL OR cancellation = '' OR cancellation LIKE 'null'
),
income AS (
	SELECT 
        SUM(
            CASE 
                WHEN c.pizza_id = 1 THEN 12
                ELSE 10
            END
        ) AS total_revenue
    FROM customer_orders c
    JOIN new_order s ON c.order_id = s.order_id
),
expenses AS (
    SELECT 
        SUM(
            CAST(REPLACE(r.distance, 'km', '') AS FLOAT) * 0.30
        ) AS runner_cost
    FROM runner_orders r
    WHERE r.cancellation IS NULL OR r.cancellation = '' OR r.cancellation LIKE 'null'
)
SELECT 
    i.total_revenue,
    e.runner_cost,
    (i.total_revenue - e.runner_cost) AS profit
FROM income i, expenses e;

---- E. Bonus Questions ----
--If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
-- Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');
INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES ( 3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
---- Learn week 2 ----
--CROSS APPLY STRING_SPLIT(co.exclusions, ',')
--CTEs
--CONCAT
--STRING_SPLIT
--CAST
--TRY_CAST
--CROSS APPLY
--STRING_AGG(co,exclusions, ',')
--REPLACE
--DATEDIFF
--DATEADD