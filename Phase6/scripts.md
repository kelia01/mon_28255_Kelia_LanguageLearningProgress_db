## Procedures
## Procedure register_learner
```
CREATE OR REPLACE PROCEDURE register_learner (
    p_first_name    IN VARCHAR2,
    p_last_name     IN VARCHAR2,
    p_age           IN NUMBER,
    p_email         IN VARCHAR2,
    p_learner_id    OUT NUMBER,
    p_status        OUT VARCHAR2
) IS
    v_email_count   NUMBER;
    e_invalid_age   EXCEPTION;
    e_duplicate_email EXCEPTION;
    e_invalid_email EXCEPTION;
BEGIN
    IF p_age < 13 THEN
        RAISE e_invalid_age;
    END IF;
    IF p_email NOT LIKE '%@%.%' THEN
        RAISE e_invalid_email;
    END IF;
    
    -- Check for duplicate email
    SELECT COUNT(*) INTO v_email_count
    FROM LEARNERS
    WHERE email = p_email;
    
    IF v_email_count > 0 THEN
        RAISE e_duplicate_email;
    END IF;
    
    -- Insert new learner (trigger will generate ID)
    INSERT INTO LEARNERS (first_name, last_name, age, email)
    VALUES (p_first_name, p_last_name, p_age, p_email)
    RETURNING learner_id INTO p_learner_id;
    
    COMMIT;
    
    p_status := 'SUCCESS: Learner registered with ID ' || p_learner_id;
    
    DBMS_OUTPUT.PUT_LINE('✓ New learner registered: ' || p_first_name || ' ' || p_last_name);
    DBMS_OUTPUT.PUT_LINE('  Learner ID: ' || p_learner_id);
    
EXCEPTION
    WHEN e_invalid_age THEN
        ROLLBACK;
        p_learner_id := NULL;
        p_status := 'ERROR: Age must be 13 or older';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN e_duplicate_email THEN
        ROLLBACK;
        p_learner_id := NULL;
        p_status := 'ERROR: Email already exists';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN e_invalid_email THEN
        ROLLBACK;
        p_learner_id := NULL;
        p_status := 'ERROR: Invalid email format';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN OTHERS THEN
        ROLLBACK;
        p_learner_id := NULL;
        p_status := 'ERROR: ' || SQLERRM;
        DBMS_OUTPUT.PUT_LINE('✗ Unexpected error: ' || SQLERRM);
END register_learner;
/
```
## Procedure record_progress
```
CREATE OR REPLACE PROCEDURE record_progress (
    p_learner_id        IN NUMBER,
    p_module_id         IN NUMBER,
    p_score             IN NUMBER,
    p_completion_date   IN DATE DEFAULT SYSDATE,
    p_progress_id       OUT NUMBER,
    p_status            OUT VARCHAR2
) IS
    v_learner_exists    NUMBER;
    v_module_exists     NUMBER;
    e_invalid_learner   EXCEPTION;
    e_invalid_module    EXCEPTION;
    e_invalid_score     EXCEPTION;
BEGIN
    -- Validate score range
    IF p_score < 0 OR p_score > 100 THEN
        RAISE e_invalid_score;
    END IF;
    
    -- Check if learner exists
    SELECT COUNT(*) INTO v_learner_exists
    FROM LEARNERS
    WHERE learner_id = p_learner_id;
    
    IF v_learner_exists = 0 THEN
        RAISE e_invalid_learner;
    END IF;
    
    -- Check if module exists
    SELECT COUNT(*) INTO v_module_exists
    FROM LEARNING_MODULES
    WHERE module_id = p_module_id;
    
    IF v_module_exists = 0 THEN
        RAISE e_invalid_module;
    END IF;
    
    -- Insert progress record
    INSERT INTO PROGRESS_RECORDS (learner_id, module_id, score, completion_date)
    VALUES (p_learner_id, p_module_id, p_score, p_completion_date)
    RETURNING progress_id INTO p_progress_id;
    
    COMMIT;
    
    p_status := 'SUCCESS: Progress recorded with ID ' || p_progress_id;
    DBMS_OUTPUT.PUT_LINE('✓ Progress recorded for Learner ' || p_learner_id);
    DBMS_OUTPUT.PUT_LINE('  Module: ' || p_module_id || ' | Score: ' || p_score);
    
EXCEPTION
    WHEN e_invalid_score THEN
        ROLLBACK;
        p_progress_id := NULL;
        p_status := 'ERROR: Score must be between 0 and 100';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN e_invalid_learner THEN
        ROLLBACK;
        p_progress_id := NULL;
        p_status := 'ERROR: Learner ID does not exist';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN e_invalid_module THEN
        ROLLBACK;
        p_progress_id := NULL;
        p_status := 'ERROR: Module ID does not exist';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN OTHERS THEN
        ROLLBACK;
        p_progress_id := NULL;
        p_status := 'ERROR: ' || SQLERRM;
        DBMS_OUTPUT.PUT_LINE('✗ Unexpected error: ' || SQLERRM);
END record_progress;
/
```
## Procedure update_learner_profile
```
CREATE OR REPLACE PROCEDURE update_learner_profile (
    p_learner_id    IN NUMBER,
    p_first_name    IN OUT VARCHAR2,
    p_last_name     IN OUT VARCHAR2,
    p_age           IN OUT NUMBER,
    p_email         IN OUT VARCHAR2,
    p_status        OUT VARCHAR2
) IS
    v_learner_exists    NUMBER;
    v_old_first_name    VARCHAR2(50);
    v_old_last_name     VARCHAR2(50);
    v_old_age           NUMBER;
    v_old_email         VARCHAR2(100);
    e_learner_not_found EXCEPTION;
    e_invalid_age       EXCEPTION;
BEGIN
    -- Check if learner exists and get current values
    SELECT COUNT(*) INTO v_learner_exists
    FROM LEARNERS
    WHERE learner_id = p_learner_id;
    
    IF v_learner_exists = 0 THEN
        RAISE e_learner_not_found;
    END IF;
    
    -- Get old values
    SELECT first_name, last_name, age, email
    INTO v_old_first_name, v_old_last_name, v_old_age, v_old_email
    FROM LEARNERS
    WHERE learner_id = p_learner_id;
    
    -- Use old values if new ones are NULL
    IF p_first_name IS NULL THEN p_first_name := v_old_first_name; END IF;
    IF p_last_name IS NULL THEN p_last_name := v_old_last_name; END IF;
    IF p_age IS NULL THEN p_age := v_old_age; END IF;
    IF p_email IS NULL THEN p_email := v_old_email; END IF;
    
    -- Validate age
    IF p_age < 13 THEN
        RAISE e_invalid_age;
    END IF;
    
    -- Update learner
    UPDATE LEARNERS
    SET first_name = p_first_name,
        last_name = p_last_name,
        age = p_age,
        email = p_email
    WHERE learner_id = p_learner_id;
    
    COMMIT;
    
    p_status := 'SUCCESS: Profile updated for learner ' || p_learner_id;
    DBMS_OUTPUT.PUT_LINE('✓ Profile updated: ' || p_first_name || ' ' || p_last_name);
    
EXCEPTION
    WHEN e_learner_not_found THEN
        ROLLBACK;
        p_status := 'ERROR: Learner not found';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN e_invalid_age THEN
        ROLLBACK;
        p_status := 'ERROR: Age must be 13 or older';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR: ' || SQLERRM;
        DBMS_OUTPUT.PUT_LINE('✗ Unexpected error: ' || SQLERRM);
END update_learner_profile;
/
```
## Procedure bulk_update_scores
```
CREATE OR REPLACE PROCEDURE bulk_update_scores (
    p_module_id         IN NUMBER,
    p_adjustment_pct    IN NUMBER,
    p_updated_count     OUT NUMBER,
    p_status            OUT VARCHAR2
) IS
    v_module_exists NUMBER;
    e_invalid_module EXCEPTION;
    e_invalid_adjustment EXCEPTION;
BEGIN
    -- Validate adjustment percentage
    IF p_adjustment_pct < -50 OR p_adjustment_pct > 50 THEN
        RAISE e_invalid_adjustment;
    END IF;
    
    -- Check if module exists
    SELECT COUNT(*) INTO v_module_exists
    FROM LEARNING_MODULES
    WHERE module_id = p_module_id;
    
    IF v_module_exists = 0 THEN
        RAISE e_invalid_module;
    END IF;
    
    -- Bulk update with cap at 100
    UPDATE PROGRESS_RECORDS
    SET score = LEAST(100, score + (score * p_adjustment_pct / 100))
    WHERE module_id = p_module_id;
    
    p_updated_count := SQL%ROWCOUNT;
    
    COMMIT;
    
    p_status := 'SUCCESS: Updated ' || p_updated_count || ' scores by ' || p_adjustment_pct || '%';
    DBMS_OUTPUT.PUT_LINE('✓ ' || p_status);
    
EXCEPTION
    WHEN e_invalid_adjustment THEN
        ROLLBACK;
        p_updated_count := 0;
        p_status := 'ERROR: Adjustment must be between -50% and +50%';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN e_invalid_module THEN
        ROLLBACK;
        p_updated_count := 0;
        p_status := 'ERROR: Module does not exist';
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_status);
    WHEN OTHERS THEN
        ROLLBACK;
        p_updated_count := 0;
        p_status := 'ERROR: ' || SQLERRM;
        DBMS_OUTPUT.PUT_LINE('✗ Unexpected error: ' || SQLERRM);
END bulk_update_scores;
/
```

## Functions scripts
### Function calculate_avg_score
```
CREATE OR REPLACE FUNCTION calculate_avg_score (
    p_learner_id IN NUMBER
) RETURN NUMBER IS
    v_avg_score NUMBER;
    v_learner_exists NUMBER;
    e_learner_not_found EXCEPTION;
BEGIN
    -- Check if learner exists
    SELECT COUNT(*) INTO v_learner_exists
    FROM LEARNERS
    WHERE learner_id = p_learner_id;
    
    IF v_learner_exists = 0 THEN
        RAISE e_learner_not_found;
    END IF;
    
    -- Calculate average
    SELECT NVL(AVG(score), 0)
    INTO v_avg_score
    FROM PROGRESS_RECORDS
    WHERE learner_id = p_learner_id;
    
    RETURN ROUND(v_avg_score, 2);
    
EXCEPTION
    WHEN e_learner_not_found THEN
        DBMS_OUTPUT.PUT_LINE('✗ Learner not found');
        RETURN NULL;
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error: ' || SQLERRM);
        RETURN NULL;
END calculate_avg_score;
/
```
### Function get_grade
```
CREATE OR REPLACE FUNCTION get_grade (
    p_score IN NUMBER
) RETURN VARCHAR2 IS
    v_grade VARCHAR2(2);
    e_invalid_score EXCEPTION;
BEGIN
    -- Validate score
    IF p_score < 0 OR p_score > 100 THEN
        RAISE e_invalid_score;
    END IF;
    
    -- Determine grade
    v_grade := CASE
        WHEN p_score >= 90 THEN 'A'
        WHEN p_score >= 80 THEN 'B'
        WHEN p_score >= 70 THEN 'C'
        WHEN p_score >= 60 THEN 'D'
        ELSE 'F'
    END;
    
    RETURN v_grade;
    
EXCEPTION
    WHEN e_invalid_score THEN
        DBMS_OUTPUT.PUT_LINE('✗ Invalid score: must be 0-100');
        RETURN 'ERR';
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error: ' || SQLERRM);
        RETURN 'ERR';
END get_grade;
/
```
### Function validate_email
```
CREATE OR REPLACE FUNCTION validate_email (
    p_email IN VARCHAR2
) RETURN BOOLEAN IS
    v_at_count NUMBER;
    v_dot_count NUMBER;
BEGIN
    -- Check for @ symbol
    v_at_count := LENGTH(p_email) - LENGTH(REPLACE(p_email, '@', ''));
    
    -- Check for . after @
    v_dot_count := LENGTH(SUBSTR(p_email, INSTR(p_email, '@'))) - 
                   LENGTH(REPLACE(SUBSTR(p_email, INSTR(p_email, '@')), '.', ''));
    
    -- Valid if exactly one @ and at least one . after @
    IF v_at_count = 1 AND v_dot_count >= 1 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END validate_email;
/
```
### Function calculate_progress_percentage
```
CREATE OR REPLACE FUNCTION calculate_progress_percentage (
    p_learner_id IN NUMBER,
    p_language_id IN NUMBER
) RETURN NUMBER IS
    v_total_modules NUMBER;
    v_completed_modules NUMBER;
    v_percentage NUMBER;
BEGIN
    -- Get total modules for language
    SELECT COUNT(*)
    INTO v_total_modules
    FROM LEARNING_MODULES
    WHERE language_id = p_language_id;
    
    IF v_total_modules = 0 THEN
        RETURN 0;
    END IF;
    
    -- Get completed modules
    SELECT COUNT(DISTINCT pr.module_id)
    INTO v_completed_modules
    FROM PROGRESS_RECORDS pr
    INNER JOIN LEARNING_MODULES lm ON pr.module_id = lm.module_id
    WHERE pr.learner_id = p_learner_id
    AND lm.language_id = p_language_id;
    
    -- Calculate percentage
    v_percentage := (v_completed_modules / v_total_modules) * 100;
    
    RETURN ROUND(v_percentage, 2);
    
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error: ' || SQLERRM);
        RETURN 0;
END calculate_progress_percentage;
/
```
