-- ================================================================
-- LANGUAGE LEARNING PROGRESS TRACKING SYSTEM
-- Database Creation Scripts
-- Student: Iradukunda Kelia (ID: 28255)
-- ================================================================

-- ================================================================
-- PART 1: CREATE SEQUENCES FOR AUTO-INCREMENT IDs
-- ================================================================

-- Sequence for Learners table
CREATE SEQUENCE learners_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Sequence for Languages table
CREATE SEQUENCE languages_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Sequence for Learning_modules table
CREATE SEQUENCE learning_modules_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Sequence for Progress_records table
CREATE SEQUENCE progress_records_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- ================================================================
-- PART 2: CREATE TABLES
-- ================================================================

-- ----------------------------------------------------------------
-- LEARNERS TABLE
-- Stores learner profiles and personal information
-- ----------------------------------------------------------------
CREATE TABLE Learners (
    learner_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    registration_date DATE DEFAULT SYSDATE,
    -- Add other columns from your screenshot here
    CONSTRAINT learners_email_check CHECK (email LIKE '%@%.%')
);

-- ----------------------------------------------------------------
-- LANGUAGES TABLE
-- Stores available languages for learning
-- ----------------------------------------------------------------
CREATE TABLE Languages (
    language_id NUMBER PRIMARY KEY,
    language_name VARCHAR2(50) UNIQUE NOT NULL,
    language_code VARCHAR2(10) UNIQUE NOT NULL,
    -- Add other columns from your screenshot here
    difficulty_level VARCHAR2(20)
);

-- ----------------------------------------------------------------
-- LEARNING_MODULES TABLE
-- Stores modules/courses for each language
-- ----------------------------------------------------------------
CREATE TABLE Learning_modules (
    module_id NUMBER PRIMARY KEY,
    language_id NUMBER NOT NULL,
    module_name VARCHAR2(100) NOT NULL,
    module_description VARCHAR2(500),
    -- Add other columns from your screenshot here
    difficulty_level VARCHAR2(20),
    CONSTRAINT fk_module_language FOREIGN KEY (language_id) 
        REFERENCES Languages(language_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------
-- PROGRESS_RECORDS TABLE
-- Tracks learner progress and scores
-- ----------------------------------------------------------------
CREATE TABLE Progress_records (
    progress_id NUMBER PRIMARY KEY,
    learner_id NUMBER NOT NULL,
    module_id NUMBER NOT NULL,
    score NUMBER(5,2),
    completion_date DATE,
    status VARCHAR2(20),
    -- Add other columns from your screenshot here
    CONSTRAINT fk_progress_learner FOREIGN KEY (learner_id) 
        REFERENCES Learners(learner_id) ON DELETE CASCADE,
    CONSTRAINT fk_progress_module FOREIGN KEY (module_id) 
        REFERENCES Learning_modules(module_id) ON DELETE CASCADE,
    CONSTRAINT score_check CHECK (score >= 0 AND score <= 100)
);

-- ================================================================
-- PART 3: CREATE TRIGGERS FOR AUTO-INCREMENT IDs
-- ================================================================

-- ----------------------------------------------------------------
-- Trigger for Learners table
-- ----------------------------------------------------------------
CREATE OR REPLACE TRIGGER learners_id_trigger
BEFORE INSERT ON Learners
FOR EACH ROW
BEGIN
    IF :NEW.learner_id IS NULL THEN
        SELECT learners_seq.NEXTVAL INTO :NEW.learner_id FROM DUAL;
    END IF;
END;
/

-- ----------------------------------------------------------------
-- Trigger for Languages table
-- ----------------------------------------------------------------
CREATE OR REPLACE TRIGGER languages_id_trigger
BEFORE INSERT ON Languages
FOR EACH ROW
BEGIN
    IF :NEW.language_id IS NULL THEN
        SELECT languages_seq.NEXTVAL INTO :NEW.language_id FROM DUAL;
    END IF;
END;
/

-- ----------------------------------------------------------------
-- Trigger for Learning_modules table
-- ----------------------------------------------------------------
CREATE OR REPLACE TRIGGER learning_modules_id_trigger
BEFORE INSERT ON Learning_modules
FOR EACH ROW
BEGIN
    IF :NEW.module_id IS NULL THEN
        SELECT learning_modules_seq.NEXTVAL INTO :NEW.module_id FROM DUAL;
    END IF;
END;
/

-- ----------------------------------------------------------------
-- Trigger for Progress_records table
-- ----------------------------------------------------------------
CREATE OR REPLACE TRIGGER progress_records_id_trigger
BEFORE INSERT ON Progress_records
FOR EACH ROW
BEGIN
    IF :NEW.progress_id IS NULL THEN
        SELECT progress_records_seq.NEXTVAL INTO :NEW.progress_id FROM DUAL;
    END IF;
END;
/

-- ================================================================
-- PART 4: VALIDATION TRIGGER - Score Validation
-- ================================================================

-- Prevent invalid scores
CREATE OR REPLACE TRIGGER validate_score_trigger
BEFORE INSERT OR UPDATE OF score ON Progress_records
FOR EACH ROW
BEGIN
    IF :NEW.score < 0 OR :NEW.score > 100 THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Invalid score: Score must be between 0 and 100');
    END IF;
END;
/

-- ================================================================
-- PART 5: VERIFICATION QUERIES
-- ================================================================

-- Verify all tables were created
SELECT table_name 
FROM user_tables 
WHERE table_name IN ('LEARNERS', 'LANGUAGES', 'LEARNING_MODULES', 'PROGRESS_RECORDS')
ORDER BY table_name;

-- Verify all sequences were created
SELECT sequence_name 
FROM user_sequences 
WHERE sequence_name LIKE '%_SEQ'
ORDER BY sequence_name;

-- Verify all triggers were created
SELECT trigger_name, table_name, status
FROM user_triggers
WHERE table_name IN ('LEARNERS', 'LANGUAGES', 'LEARNING_MODULES', 'PROGRESS_RECORDS')
ORDER BY table_name, trigger_name;

-- ================================================================
-- NOTES FOR COMPLETION:
-- ================================================================
-- 1. Review your screenshots and add any missing columns to each CREATE TABLE statement
-- 2. Update data types and constraints based on your actual design
-- 3. Add any additional triggers or validation logic you have
-- 4. Run this script in SQL*Plus or SQL Developer
-- ================================================================
