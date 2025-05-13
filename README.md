# 🏥 Hospital ICU Bed Capacity Analysis – SQL Data Warehouse

## 📌 Project Summary
Built a scalable, query-optimized **star schema data warehouse** in MySQL to analyze **ICU and SICU bed availability** across U.S. hospitals. Leveraged real-world hospital infrastructure data to support critical care planning by identifying where resources like licensed, staffed, and occupied beds are most concentrated.

> 🎯 *Objective*: Enable healthcare analysts and decision-makers to efficiently query and interpret hospital bed utilization metrics during high-demand periods such as pandemics or seasonal surges.

---

## ⚙️ Tools & Technologies
- **MySQL & MySQL Workbench** – Database schema design and querying
- **ERDPlus** – Entity-Relationship Diagram modeling
- **SQL** – DDL, DML, JOINs, filtering, aggregations
- **CSV Import Wizard** – MySQL bulk data ingestion from structured files

---

## 🧱 Star Schema Design

### 📘 Dimension Tables
- `dim_bed_type`: Type of bed (ICU, SICU, Pediatric ICU, etc.)
- `dim_business`: Hospital ID, name, and regional grouping

### 📗 Fact Table
- `fact_beds`: Stores metrics like licensed beds, staffed beds, and census (occupied) beds, linked to dimension keys

✔️ Schema was normalized and optimized for analytical querying.

---

## ❓ Business Questions Solved

- 🏥 **Which hospitals have the most ICU and SICU licensed beds?**
- 👩‍⚕️ **Which hospitals are best staffed to manage critical care demand?**
- 📊 **Where are the largest gaps between licensed and staffed beds?**
- 🏨 **What regions have the highest current ICU bed census?**

---

## 📈 Key Insights

- **Saint Mary’s Hospital** topped the list in both licensed and staffed ICU capacity.
- **Census data** revealed usage concentration in major metro hospitals.
- **Staffing gaps** highlight a need for better resource allocation even in facilities with high licensing capacity.

---

## 👩‍💻 Author
**Sruthi Kondra**  
🎓 Master’s in Analytics – Northeastern University  
🔗 [LinkedIn](https://www.linkedin.com/in/sruthi-kondra-5773981a1)
