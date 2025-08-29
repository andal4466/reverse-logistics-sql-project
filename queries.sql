-- Reverse Logistics & Returns Analysis Project
-- Author: M.S. Suvetha Andal
-- Database: SQLite (works in DB Browser for SQLite)

---------------------------------------------------
-- A. Basic KPIs
---------------------------------------------------
-- Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders FROM orders;

-- Total Quantity Sold
SELECT SUM(quantity) AS total_qty_sold FROM order_items;

-- Total Quantity Returned
SELECT SUM(return_qty) AS total_qty_returned FROM returns;

-- Return Rate (%)
SELECT 
  (CAST((SELECT SUM(return_qty) FROM returns) AS REAL) /
   CAST((SELECT SUM(quantity) FROM order_items) AS REAL)) * 100.0
  AS return_rate_pct;

---------------------------------------------------
-- B. Returns by Month
---------------------------------------------------
SELECT strftime('%Y-%m', return_date) AS month,
       SUM(return_qty) AS returned_qty,
       SUM(return_cost) AS returned_cost
FROM returns
GROUP BY month
ORDER BY month;

---------------------------------------------------
-- C. Top Return Reasons
---------------------------------------------------
SELECT return_reason,
       SUM(return_qty) AS total_returned_qty,
       SUM(return_cost) AS total_return_cost
FROM returns
GROUP BY return_reason
ORDER BY total_returned_qty DESC;

---------------------------------------------------
-- D. Top SKUs by Return Rate
---------------------------------------------------
SELECT p.sku,
       p.product_name,
       SUM(oi.quantity) AS sold_qty,
       COALESCE(SUM(r.return_qty),0) AS returned_qty,
       ROUND(COALESCE(SUM(r.return_qty),0)*1.0 / SUM(oi.quantity), 4) AS return_rate
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN returns r ON oi.order_id = r.order_id AND oi.product_id = r.product_id
GROUP BY p.sku, p.product_name
ORDER BY return_rate DESC
LIMIT 10;

---------------------------------------------------
-- E. Average Days to Return
---------------------------------------------------
SELECT ROUND(AVG(julianday(r.return_date) - julianday(o.ship_date)),1) AS avg_days_to_return
FROM returns r
JOIN orders o ON r.order_id = o.order_id;

---------------------------------------------------
-- F. Warehouse-wise Returns
---------------------------------------------------
SELECT w.name AS warehouse,
       SUM(r.return_qty) AS total_returned_qty,
       SUM(r.return_cost) AS total_return_cost,
       ROUND(SUM(r.return_cost) * 1.0 / NULLIF(SUM(r.return_qty),0),2) AS avg_cost_per_return
FROM returns r
JOIN orders o ON r.order_id = o.order_id
JOIN warehouses w ON o.warehouse_id = w.warehouse_id
GROUP BY w.name
ORDER BY total_returned_qty DESC;

---------------------------------------------------
-- G. Supplier-wise Returns
---------------------------------------------------
SELECT pr.supplier_id,
       COUNT(DISTINCT r.return_id) AS return_events,
       SUM(r.return_qty) AS returned_qty,
       SUM(r.return_cost) AS total_return_cost
FROM returns r
JOIN products pr ON r.product_id = pr.product_id
GROUP BY pr.supplier_id
ORDER BY returned_qty DESC;

---------------------------------------------------
-- H. Resellability %
---------------------------------------------------
SELECT 
  SUM(CASE WHEN resellable=1 THEN return_qty ELSE 0 END) * 1.0 / SUM(return_qty) AS pct_resellable
FROM returns;

---------------------------------------------------
-- I. High-Cost + High-Rate SKUs
---------------------------------------------------
WITH sku_stats AS (
  SELECT p.sku, p.product_name,
         SUM(oi.quantity) AS sold_qty,
         COALESCE(SUM(r.return_qty),0) AS returned_qty,
         COALESCE(SUM(r.return_cost),0) AS return_cost,
         ROUND(COALESCE(SUM(r.return_qty),0)*1.0 / SUM(oi.quantity),4) AS return_rate
  FROM order_items oi
  JOIN products p ON oi.product_id = p.product_id
  LEFT JOIN returns r ON oi.order_id = r.order_id AND oi.product_id = r.product_id
  GROUP BY p.sku, p.product_name
)
SELECT *,
       (return_rate * return_cost) AS priority_score
FROM sku_stats
ORDER BY priority_score DESC
LIMIT 10;

---------------------------------------------------
-- J. View for Easy Export
---------------------------------------------------
CREATE VIEW IF NOT EXISTS returns_summary AS
SELECT p.sku, p.product_name, p.category,
       SUM(oi.quantity) AS sold_qty,
       COALESCE(SUM(r.return_qty),0) AS returned_qty,
       COALESCE(SUM(r.return_cost),0) AS total_return_cost,
       ROUND(COALESCE(SUM(r.return_qty),0)*1.0 / SUM(oi.quantity),4) AS return_rate
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN returns r ON oi.order_id = r.order_id AND oi.product_id = r.product_id
GROUP BY p.sku, p.product_name, p.category;
