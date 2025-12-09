## Data Dictionary

### Table 1: LEARNERS

**Purpose:** Stores information about language learners in the system.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| learner_id | NUMBER | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | Unique identifier for each learner |
| first_name | VARCHAR2(50) | NOT NULL | Learner's first name |
| last_name | VARCHAR2(50) | NOT NULL | Learner's last name |
| age | NUMBER | NOT NULL, CHECK (age >= 13) | Learner's age (minimum 13 years) |
| email | VARCHAR2(100) | UNIQUE, NOT NULL | Learner's email address (must be unique) |

**Primary Key:** learner_id  
**Foreign Keys:** None  
**Indexes:** Unique index on email

### Table 2: LANGUAGES

**Purpose:** Stores the catalog of available languages with their difficulty levels.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| language_id | NUMBER | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | Unique identifier for each language |
| language_name | VARCHAR2(50) | UNIQUE, NOT NULL | Name of the language (e.g., French, Spanish) |
| difficulty_level | VARCHAR2(20) | NOT NULL, CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced')) | Overall difficulty rating of the language |

**Primary Key:** language_id  
**Foreign Keys:** None  
**Indexes:** Unique index on language_name

### Table 3: LEARNING_MODULES

**Purpose:** Stores individual learning modules for each language.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| module_id | NUMBER | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | Unique identifier for each module |
| language_id | NUMBER | FOREIGN KEY, NOT NULL | References LANGUAGES(language_id) |
| module_title | VARCHAR2(100) | NOT NULL | Title of the learning module |
| module_type | VARCHAR2(30) | NOT NULL, CHECK (module_type IN ('Vocabulary', 'Grammar', 'Speaking', 'Listening')) | Type of learning content |

**Primary Key:** module_id  
**Foreign Keys:** 
- language_id REFERENCES LANGUAGES(language_id) ON DELETE CASCADE

**Indexes:** Index on language_id for faster joins

### Table 4: PROGRESS_RECORDS

**Purpose:** Tracks learner performance on completed modules (FACT TABLE for BI).

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| progress_id | NUMBER | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | Unique identifier for each progress record |
| learner_id | NUMBER | FOREIGN KEY, NOT NULL | References LEARNERS(learner_id) |
| module_id | NUMBER | FOREIGN KEY, NOT NULL | References LEARNING_MODULES(module_id) |
| score | NUMBER | NOT NULL, CHECK (score >= 0 AND score <= 100) | Performance score (0-100 percentage) |
| completion_date | DATE | NOT NULL, DEFAULT SYSDATE | Date when module was completed |

**Primary Key:** progress_id  
**Foreign Keys:** 
- learner_id REFERENCES LEARNERS(learner_id) ON DELETE CASCADE
- module_id REFERENCES LEARNING_MODULES(module_id) ON DELETE CASCADE

**Indexes:** 
- Index on learner_id for faster learner-specific queries
- Index on module_id for faster module-specific queries
- Index on completion_date for time-based analytics

**BI Role:** This is the central FACT table containing measurable events (scores, dates)

## Relationship Summary

| Parent Table | Child Table | Relationship Type | Description |
|--------------|-------------|-------------------|-------------|
| LEARNERS | PROGRESS_RECORDS | One-to-Many (1:N) | One learner can have multiple progress records |
| LEARNING_MODULES | PROGRESS_RECORDS | One-to-Many (1:N) | One module can be completed by multiple learners |
| LANGUAGES | LEARNING_MODULES | One-to-Many (1:N) | One language contains multiple modules |

## Key Assumptions

### Business Rules

1. **Minimum Age:** Learners must be at least 13 years old to comply with data protection regulations (COPPA, GDPR).

2. **Email Uniqueness:** Each learner must have a unique email address for identification and communication.

3. **Score Range:** All scores are recorded as percentages from 0 to 100.

4. **Language Difficulty:** Each language is assigned one difficulty level (Beginner, Intermediate, or Advanced) in the current design.

5. **Module Types:** Learning modules are categorized into four types: Vocabulary, Grammar, Speaking, and Listening.

### Data Integrity

6. **Cascading Deletes:** If a language is deleted, all associated modules are deleted. If a learner or module is deleted, all associated progress records are deleted.

7. **No Orphaned Records:** Foreign key constraints prevent progress records without valid learner or module references.

8. **Automatic Timestamps:** Completion dates are automatically set to the current date/time when records are created.

9. **Module Retakes:** Learners can complete the same module multiple times (creates multiple progress records with different scores and dates).

### System Behavior

10. **Performance Threshold:** PL/SQL triggers evaluate scores against a configurable threshold (default: 60%) to identify low performance.

11. **Automatic Evaluation:** Performance analysis is triggered automatically when progress records are inserted or updated via PL/SQL triggers.

12. **Automatic Progress Updates:** Progress summaries and learning trends are automatically updated by stored procedures when new scores are recorded (not calculated on-demand).

13. **Improvement Suggestions:** When a score falls below the threshold, the system automatically generates personalized improvement suggestions.

### Future Extensibility

14. **Multiple Difficulty Levels:** Current design supports one difficulty level per language. To support multiple levels (e.g., French Beginner, French Intermediate), a LANGUAGE_COURSES table could be added without breaking existing tables.

15. **Enhanced Audit Trail:** Future versions may add created_by, modified_by, created_date, and modified_date columns for comprehensive change tracking.
