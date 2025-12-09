# Business Intelligence Requirements  
Language Learning Progress Tracking System  
Author: Iradukunda Kelia  

## 1. KPIs That Matter
The BI layer focuses on measuring learner performance, module effectiveness, language difficulty, and system operations.

### A. Learning Performance KPIs
- Average score per module  
- Module completion rate (%)  
- Language difficulty success rate  
- Learner progression speed  
- Low-performance alerts (score < 40%)

### B. System Operations & Audit KPIs
- Number of denied operations  
- Number of weekday violations (blocked transactions)  
- Frequency of public-holiday violations  
- Trigger executions by table  
- Daily user activity (inserts, updates, deletes)

### C. Module & Language Usage KPIs
- Most active modules  
- Most popular languages  
- Language completion speed  
- Module dropout frequency

---

## 2. Stakeholders
| Stakeholder | Needs |
|------------|--------|
| **System Administrator** | Monitor system violations, holiday rules, trigger behavior |
| **BI Analyst** | Generate dashboards, trends, predictions |
| **Project Owner / AUCA Reviewer** | High-level KPIs, performance summary |
| **Learner (optional)** | View personal performance dashboard |

---

## 3. Decision Support Needs
- Identify which languages are harder based on performance  
- Detect high-performing vs low-performing learners  
- Detect abnormal system activity (security perspective)  
- Determine if maintenance windows or holiday rules are effective  
- Monitor usage to justify system scaling or optimization  

---

## 4. Reporting Frequency
| Report | Frequency |
|--------|------------|
| Executive KPI Summary | Weekly |
| Learning Performance Dashboard | Daily |
| Audit & Violations Dashboard | Real-time / Daily |
| System Usage Report | Monthly |
| Module Trends Report | Weekly |

---

## 5. Required BI Deliverables
- KPI Definitions  
- Dashboard Mockups  
- Analytical SQL Queries  
- Executive Summary Visualization  
