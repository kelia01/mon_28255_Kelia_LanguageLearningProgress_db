# mon_28255_Kelia_LanguageLearningProgress_db
# Language Learning Progress Tracking System

**Student Name:** Iradukunda Kelia  
**Student ID:** 28255

---

## 📋 Project Overview

This project is a database-driven system designed to manage learner performance in a language training program. It stores learner information, assessments, and scores, and uses PL/SQL functions, procedures, packages, triggers, and validation logic to ensure accuracy and integrity of the grading process.

---

## 🎯 Problem Statement

Language training programs often struggle with inconsistent grading, manual score calculations, and data integrity issues when tracking learner progress across multiple assessments. This system addresses these challenges by providing an automated, reliable database solution that ensures accurate score management and maintains data consistency throughout the learning lifecycle.

---

## 🚀 Key Objectives

1. **Centralized Data Management** - Store and organize learner profiles, assessment records, and performance metrics in a structured relational database.

2. **Automated Score Calculation** - Utilize PL/SQL functions (e.g., `calculate_avg_score`) to automatically compute learner averages and performance indicators.

3. **Data Integrity & Validation** - Implement triggers and constraints to prevent invalid score entries and maintain database consistency.

4. **Efficient Data Processing** - Leverage PL/SQL packages, procedures, and bulk operations for organized score entry, reporting, and efficient data handling.

5. **Error Handling & Testing** - Incorporate comprehensive error-handling mechanisms and test cases to ensure safe and reliable grading operations.

---

## 🛠️ Technologies Used

- **Oracle SQL** - Tables, Relations, Constraints, Indexes
- **PL/SQL** - Functions, Procedures, Packages, Cursors, Triggers
- **Bulk Operations** - Efficient data processing and batch updates
- **Exception Handling** - Robust error management

---

## ⚡ Quick Start Instructions

### Prerequisites
- Oracle Database 11g or higher
- SQL*Plus or Oracle SQL Developer
- Basic understanding of SQL and PL/SQL

### Installation Steps

1. **Clone or Download the Project**
   ```bash
   git clone https://github.com/kelia01/wed_28255_Kelia_LanguageLearningProgress_db.git
   cd wed_28255_Kelia_LanguageLearningProgress_db
   ```

2. **Set Up the Database**
   ```sql
   -- Connect to your Oracle database
   sqlplus username/kelia@database
   
   -- Run the database setup scripts
   @database/scripts/create_tables.sql
   @database/scripts/create_functions.sql
   @database/scripts/create_procedures.sql
   @database/scripts/create_triggers.sql
   ```

3. **Load Sample Data (Optional)**
   ```sql
   @database/scripts/insert_sample_data.sql
   ```

4. **Test the System**
   ```sql
   @test_results/run_tests.sql
   ```

---

## 📁 Project Structure

```
language-learning-tracker/
│
├── database/
│   ├── documentation/          # Database design docs
│   ├── scripts/                # SQL and PL/SQL scripts
│   └── project_overview.md     # Database project overview
│
├── documentation/
│   ├── BI_consideration_and_normalias...  # BI and normalization docs
│   ├── architecture_modeling.md           # System architecture
│   └── data_dictionary.md                 # Data dictionary
│
├── queries/
│   └── data_retrieval.md       # Common queries and reports
│
├── screenshots/                # System screenshots
│
├── test_results/               # Test cases and results
│
└── README.md                   # This file
```

---

## 📚 Documentation

### Core Documentation
- [Project Overview](./database/project_overview.md) - Detailed project description and goals
- [Architecture Modeling](./documentation/architecture_modeling.md) - System design and ER diagrams
- [Data Dictionary](./documentation/data_dictionary.md) - Complete table and column specifications
- [BI Considerations & Normalization](./documentation/BI_consideration_and_normalias...) - Business intelligence and database normalization

### Database Scripts
- **Tables Creation** - `./database/scripts/` (create_tables.sql)
- **Functions** - `./database/scripts/` (create_functions.sql)
- **Procedures** - `./database/scripts/` (create_procedures.sql)
- **Triggers** - `./database/scripts/` (create_triggers.sql)
- **Packages** - `./database/scripts/` (create_packages.sql)

### Queries & Reports
- [Data Retrieval Queries](./queries/data_retrieval.md) - Common queries for reporting and analysis

### Testing
- **Test Cases** - `./test_results/` - Comprehensive test scenarios and results

---

## 🔑 Key Features

### 1. Learner Management
- Store comprehensive learner profiles
- Track enrollment and course progress
- Maintain historical performance records

### 2. Assessment Tracking
- Record assessment details and types
- Link assessments to specific courses and modules
- Track submission dates and status

### 3. Score Management
- Automated score calculation using PL/SQL functions
- Real-time average computation (`calculate_avg_score`)
- Grade assignment based on performance thresholds

### 4. Data Validation
- **Triggers** - Prevent invalid score entries (e.g., scores > 100)
- **Constraints** - Enforce referential integrity and business rules
- **Exception Handling** - Graceful error management

### 5. Reporting & Analytics
- Generate learner performance reports
- Calculate class averages and statistics
- Identify high performers and students needing support

---

## 🧪 Testing

The system includes comprehensive test cases covering:
- Valid and invalid score entries
- Average calculation accuracy
- Trigger validation logic
- Procedure execution and error handling
- Bulk operation performance

Run all tests:
```sql
@test_results/run_all_tests.sql
```

---

## 📊 Database Schema Overview

**Main Tables:**
- `LEARNERS` - Learner profiles and personal information
- `COURSES` - Language courses offered
- `ASSESSMENTS` - Assessment details and types
- `SCORES` - Individual assessment scores
- `ENROLLMENTS` - Learner-course relationships

**Key Functions:**
- `calculate_avg_score(learner_id)` - Computes learner's average score
- Additional functions documented in code

**Packages:**
- Score management package
- Reporting utilities package

---

## 👥 Contributing

This is an academic project. For questions or suggestions:
- **Student:** Iradukunda Kelia
- **Student ID:** 28255

---

## 📝 License

This project is created for educational purposes as part of a database management course.

---

## 🙏 Acknowledgments

- Course instructor and teaching assistants
- Oracle documentation and PL/SQL resources
- Classmates for collaboration and feedback

---

**Last Updated:** December 2024
