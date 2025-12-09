# KPI Definitions  
Language Learning Progress Tracking System  
Author: Iradukunda Kelia  

---

## 1. Learning Performance KPIs

### **1. Average Score per Module**
**Definition:** The mean score achieved in each learning module.  
**Formula:** `AVG(score)`  
**SQL Query:**
```sql
SELECT module_id, AVG(score) AS avg_score
FROM progress_records
GROUP BY module_id;
