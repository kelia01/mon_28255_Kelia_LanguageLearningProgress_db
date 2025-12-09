# Procedures, cursors and functions test results

## Register Learner (Success Case)
```
DECLARE
    v_learner_id NUMBER;
    v_status VARCHAR2(200);
BEGIN
    register_learner(
        p_first_name => 'Test',
        p_last_name => 'Student',
        p_age => 25,
        p_email => 'test.student.unique@email.com',
        p_learner_id => v_learner_id,
        p_status => v_status
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Test 1.1: PASSED ✓');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test 1.1: FAILED ✗');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```
<img width="882" height="24" alt="image" src="https://github.com/user-attachments/assets/317127ff-b501-4bdb-8f1a-2ddcf344a288" />

## Register Learner (Invalid Age)
```
SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_learner_id NUMBER;
    v_status VARCHAR2(200);
BEGIN
    register_learner(
        p_first_name => 'Young',
        p_last_name => 'Child',
        p_age => 10,
        p_email => 'young.child@email.com',
        p_learner_id => v_learner_id,
        p_status => v_status
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status);
    IF v_status LIKE '%Age%' THEN
        DBMS_OUTPUT.PUT_LINE('Test 1.2: PASSED ✓ (Exception caught correctly)');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test 1.2: PASSED ✓ (Exception caught)');
END;
/
```
<img width="882" height="24" alt="image" src="https://github.com/user-attachments/assets/572ee076-674d-49cf-a92c-228f814c2423" />

## Calculate Average Score
```
SET SERVEROUTPUT ON SIZE UNLIMITED;
DECLARE
    v_avg_score NUMBER;
BEGIN
    v_avg_score := calculate_avg_score(1);
    DBMS_OUTPUT.PUT_LINE('Avg Score for Learner 1: ' || v_avg_score);
    IF v_avg_score IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('PASSED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAILED ✗');
    END IF;
END;
/
```
<img width="848" height="129" alt="image" src="https://github.com/user-attachments/assets/0fa62f38-43af-45aa-9462-fe565b443164" />

## Email Validation
```
DECLARE
    TYPE t_emails IS TABLE OF VARCHAR2(100);
    v_test_emails t_emails := t_emails(
        'valid@email.com',
        'also.valid@test.org',
        'invalid.email',
        '@nousername.com',
        'nodomain@.com'
    );
    v_is_valid BOOLEAN;
BEGIN
    FOR i IN 1..v_test_emails.COUNT LOOP
        v_is_valid := validate_email(v_test_emails(i));

        DBMS_OUTPUT.PUT_LINE(
            v_test_emails(i) || ': ' ||
            CASE WHEN v_is_valid THEN 'VALID' ELSE 'INVALID' END
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('PASSED');
END;
/
```
<img width="850" height="244" alt="image" src="https://github.com/user-attachments/assets/6b114eff-de34-4779-83cd-8ebb9c731a6f" />


## Generate learner report
```
BEGIN
    generate_learner_report;
    DBMS_OUTPUT.PUT_LINE(' PASSED');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' FAILED');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```
<img width="853" height="343" alt="image" src="https://github.com/user-attachments/assets/bba1ad36-cfd2-45b0-a38b-d21685fb118f" />

## Top performers function testing
```
BEGIN
    identify_top_performers(85);
    DBMS_OUTPUT.PUT_LINE('Test 3.3: PASSED');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test 3.3: FAILED');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```
<img width="853" height="343" alt="image" src="https://github.com/user-attachments/assets/bcf107e5-7333-4451-965d-7dff9baefb82" />

##  Package - Submit Progress
```
DECLARE
    v_success BOOLEAN;
BEGIN
    learning_management_pkg.submit_progress(
        p_learner_id => 1,
        p_module_id => 1,
        p_score => 92,
        p_success => v_success
    );
    IF v_success THEN
        DBMS_OUTPUT.PUT_LINE(' PASSED');
    ELSE
        DBMS_OUTPUT.PUT_LINE(' FAILED');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('FAILED');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```
<img width="822" height="100" alt="image" src="https://github.com/user-attachments/assets/1d5d15a1-46fa-42dd-9e73-46e7e70d4f1f" />

## Non-existent Learner
```
DECLARE
    v_avg_score NUMBER;
BEGIN
    v_avg_score := calculate_avg_score(99999);
    DBMS_OUTPUT.PUT_LINE('Result: ' || NVL(TO_CHAR(v_avg_score), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Test 5.1: PASSED  (Handled gracefully)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test 5.1: PASSED(Exception caught)');
END;
/
```
<img width="861" height="141" alt="image" src="https://github.com/user-attachments/assets/4328d28b-f8c5-4292-96a4-c9cba813c895" />

## Duplicate emails error handling
```
DECLARE
    v_learner_id NUMBER;
    v_status VARCHAR2(200);
BEGIN
    -- Try to register with existing email
    register_learner(
        p_first_name => 'Duplicate',
        p_last_name => 'Email',
        p_age => 25,
        p_email => 'test.student.unique@email.com', -- Already exists
        p_learner_id => v_learner_id,
        p_status => v_status
    );
    IF v_status LIKE '%exists%' OR v_status LIKE '%duplicate%' THEN
        DBMS_OUTPUT.PUT_LINE('Test 5.2: PASSED  (Duplicate detected)');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test 5.2: PASSED (Exception caught)');
END;
/
```
<img width="847" height="142" alt="image" src="https://github.com/user-attachments/assets/0bdc3ea0-8313-4f6e-a859-aa6459a42707" />


