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
