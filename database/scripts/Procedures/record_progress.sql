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
