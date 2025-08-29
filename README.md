# reverse-logistics-sql-project
SQL project analyzing reverse logistics &amp; product returns — SKU, warehouse, and supplier insights.

**Author:** M.S. Suvetha Andal  
**Profile:** Aspiring Supply Chain Analyst | SQL • Power BI • Lean Six Sigma  

---

## 📌 Overview
This project analyzes **reverse logistics & product returns** in an e-commerce/manufacturing context using SQL.  
The goal is to identify **top return reasons, SKU-level return rates, supplier/warehouse hotspots, and cost impact**.

---

## 📂 Dataset
- **Orders** – order_id, dates, warehouse_id, total_amount  
- **Order Items** – product_id, quantity, unit price, unit cost  
- **Returns** – return_id, product_id, reason, qty, cost, resellable flag  
- **Products** – product_id, SKU, category, supplier_id  
- **Warehouses** – warehouse_id, name, region  

---

## 🛠 SQL Analysis Performed
1. **KPI Dashboard**: Orders, units sold, units returned, return rate %  
2. **Trend Analysis**: Returns by month (volume & cost)  
3. **Root Cause Analysis**: Top return reasons  
4. **SKU-Level Insights**: Top 10 SKUs by return rate  
5. **Warehouse Impact**: Returns & costs by warehouse  
6. **Supplier Reliability**: Supplier-wise return events  
7. **Operational Metric**: Avg days to return  
8. **Profitability Impact**: Resellability %  
9. **Prioritization Score**: High-cost + high-rate SKUs  

---

 
- Supplier `S1` contributed 40% of total returns, requiring a quality review.  
- Only 45% of returned items were resellable, leading to significant write-offs.  

---

## 📁 Repository Structure

