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
