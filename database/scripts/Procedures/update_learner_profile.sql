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
