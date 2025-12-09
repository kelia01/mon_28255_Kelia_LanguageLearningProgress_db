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
