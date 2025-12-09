-- ============================================
-- PHASE VII: Step 3 - Triggers Implementation
-- Purpose: Create simple and compound triggers
-- Database: Language Learning Progress System
-- ============================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT '========================================';
PROMPT 'CREATING TRIGGERS';
PROMPT '========================================';
PROMPT '';

-- ============================================
-- SIMPLE TRIGGER 1: LEARNERS Table Protection
-- Purpose: Prevent learner registration during restricted times
-- ============================================

PROMPT 'Creating SIMPLE TRIGGER: trg_learners_restriction...';

CREATE OR REPLACE TRIGGER trg_learners_restriction
BEFORE INSERT OR UPDATE OR DELETE ON LEARNERS
FOR EACH ROW
DECLARE
    v_allowed       BOOLEAN;
    v_error_msg     VARCHAR2(500);
    v_operation     VARCHAR2(10);
    v_audit_id      NUMBER;
    v_old_values    VARCHAR2(4000);
    v_new_values    VARCHAR2(4000);
BEGIN
    -- Determine operation type
    v_operation := CASE 
        WHEN INSERTING THEN 'INSERT'
        WHEN UPDATING THEN 'UPDATE'
        WHEN DELETING THEN 'DELETE'
    END;
    
    -- Build old/new values for audit
    IF UPDATING OR DELETING THEN
        v_old_values := 'ID:' || :OLD.learner_id || ', Name:' || :OLD.first_name || ' ' || :OLD.last_name;
    END IF;
    
    IF INSERTING OR UPDATING THEN
        v_new_values := 'Name:' || :NEW.first_name || ' ' || :NEW.last_name || ', Email:' || :NEW.email;
    END IF;
    
    -- Check if operation is allowed
    v_allowed := check_operation_allowed(v_operation, v_error_msg);
    
    IF NOT v_allowed THEN
        -- Log denied operation
        v_audit_id := log_audit_trail(
            p_table_name => 'LEARNERS',
            p_operation_type => v_operation,
            p_status => 'DENIED',
            p_denial_reason => v_error_msg,
            p_old_values => v_old_values,
            p_new_values => v_new_values
        );
        
        -- Raise error to block operation
        RAISE_APPLICATION_ERROR(-20001, v_error_msg);
    ELSE
        -- Log allowed operation
        v_audit_id := log_audit_trail(
            p_table_name => 'LEARNERS',
            p_operation_type => v_operation,
            p_status => 'ALLOWED',
            p_old_values => v_old_values,
            p_new_values => v_new_values
        );
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20001 THEN
            RAISE; -- Re-raise our custom error
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Trigger Error: ' || SQLERRM);
        END IF;
END trg_learners_restriction;
/

PROMPT '✓ Trigger trg_learners_restriction created';
PROMPT '';

-- ============================================
-- SIMPLE TRIGGER 2: PROGRESS_RECORDS Protection
-- Purpose: Prevent progress submission during restricted times
-- ============================================

PROMPT 'Creating SIMPLE TRIGGER: trg_progress_restriction...';

CREATE OR REPLACE TRIGGER trg_progress_restriction
BEFORE INSERT OR UPDATE OR DELETE ON PROGRESS_RECORDS
FOR EACH ROW
DECLARE
    v_allowed       BOOLEAN;
    v_error_msg     VARCHAR2(500);
    v_operation     VARCHAR2(10);
    v_audit_id      NUMBER;
    v_old_values    VARCHAR2(4000);
    v_new_values    VARCHAR2(4000);
BEGIN
    -- Determine operation type
    v_operation := CASE 
        WHEN INSERTING THEN 'INSERT'
        WHEN UPDATING THEN 'UPDATE'
        WHEN DELETING THEN 'DELETE'
    END;
    
    -- Build audit trail
    IF UPDATING OR DELETING THEN
        v_old_values := 'Learner:' || :OLD.learner_id || ', Module:' || :OLD.module_id || ', Score:' || :OLD.score;
    END IF;
    
    IF INSERTING OR UPDATING THEN
        v_new_values := 'Learner:' || :NEW.learner_id || ', Module:' || :NEW.module_id || ', Score:' || :NEW.score;
    END IF;
    
    -- Check restrictions
    v_allowed := check_operation_allowed(v_operation, v_error_msg);
    
    IF NOT v_allowed THEN
        -- Log and deny
        v_audit_id := log_audit_trail(
            p_table_name => 'PROGRESS_RECORDS',
            p_operation_type => v_operation,
            p_status => 'DENIED',
            p_denial_reason => v_error_msg,
            p_old_values => v_old_values,
            p_new_values => v_new_values
        );
        
        RAISE_APPLICATION_ERROR(-20003, v_error_msg);
    ELSE
        -- Log allowed
        v_audit_id := log_audit_trail(
            p_table_name => 'PROGRESS_RECORDS',
            p_operation_type => v_operation,
            p_status => 'ALLOWED',
            p_old_values => v_old_values,
            p_new_values => v_new_values
        );
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE BETWEEN -20003 AND -20001 THEN
            RAISE;
        ELSE
            RAISE_APPLICATION_ERROR(-20004, 'Trigger Error: ' || SQLERRM);
        END IF;
END trg_progress_restriction;
/

PROMPT '✓ Trigger trg_progress_restriction created';
PROMPT '';

-- ============================================
-- COMPOUND TRIGGER: Advanced Audit Tracking
-- Purpose: Track all DML operations with before/after states
-- ============================================

PROMPT 'Creating COMPOUND TRIGGER: trg_learners_audit_compound...';

CREATE OR REPLACE TRIGGER trg_learners_audit_compound
FOR INSERT OR UPDATE OR DELETE ON LEARNERS
COMPOUND TRIGGER
    
    -- Collection types for bulk operations
    TYPE t_audit_records IS TABLE OF AUDIT_LOG%ROWTYPE;
    v_audit_collection t_audit_records := t_audit_records();
    
    -- Counters
    v_insert_count NUMBER := 0;
    v_update_count NUMBER := 0;
    v_delete_count NUMBER := 0;
    
    -- BEFORE STATEMENT: Initialize
    BEFORE STATEMENT IS
    BEGIN
        v_insert_count := 0;
        v_update_count := 0;
        v_delete_count := 0;
        
        DBMS_OUTPUT.PUT_LINE('=== Compound Trigger: BEFORE STATEMENT ===');
        DBMS_OUTPUT.PUT_LINE('Operation starting on LEARNERS table...');
    END BEFORE STATEMENT;
    
    -- BEFORE EACH ROW: Pre-operation check
    BEFORE EACH ROW IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('  Processing row: ' || 
            CASE 
                WHEN INSERTING THEN 'INSERT - ' || :NEW.first_name
                WHEN UPDATING THEN 'UPDATE - ' || :OLD.first_name || ' -> ' || :NEW.first_name
                WHEN DELETING THEN 'DELETE - ' || :OLD.first_name
            END
        );
        
        -- Count operations
        IF INSERTING THEN v_insert_count := v_insert_count + 1; END IF;
        IF UPDATING THEN v_update_count := v_update_count + 1; END IF;
        IF DELETING THEN v_delete_count := v_delete_count + 1; END IF;
    END BEFORE EACH ROW;
    
    -- AFTER EACH ROW: Collect audit data
    AFTER EACH ROW IS
        v_audit_rec AUDIT_LOG%ROWTYPE;
    BEGIN
        -- Prepare audit record
        v_audit_rec.table_name := 'LEARNERS';
        v_audit_rec.operation_type := CASE 
            WHEN INSERTING THEN 'INSERT'
            WHEN UPDATING THEN 'UPDATE'
            WHEN DELETING THEN 'DELETE'
        END;
        v_audit_rec.attempted_by := USER;
        v_audit_rec.attempt_time := SYSTIMESTAMP;
        v_audit_rec.operation_status := 'COMPLETED';
        v_audit_rec.session_id := SYS_CONTEXT('USERENV', 'SESSIONID');
        
        -- Build values
        IF UPDATING OR DELETING THEN
            v_audit_rec.old_values := 'ID:' || :OLD.learner_id || ',Name:' || :OLD.first_name || ' ' || :OLD.last_name;
        END IF;
        
        IF INSERTING OR UPDATING THEN
            v_audit_rec.new_values := 'Name:' || :NEW.first_name || ' ' || :NEW.last_name || ',Email:' || :NEW.email;
        END IF;
        
        -- Add to collection
        v_audit_collection.EXTEND;
        v_audit_collection(v_audit_collection.COUNT) := v_audit_rec;
    END AFTER EACH ROW;
    
    -- AFTER STATEMENT: Bulk insert audit records
    AFTER STATEMENT IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Compound Trigger: AFTER STATEMENT ===');
        DBMS_OUTPUT.PUT_LINE('Summary:');
        DBMS_OUTPUT.PUT_LINE('  Inserts: ' || v_insert_count);
        DBMS_OUTPUT.PUT_LINE('  Updates: ' || v_update_count);
        DBMS_OUTPUT.PUT_LINE('  Deletes: ' || v_delete_count);
        DBMS_OUTPUT.PUT_LINE('  Total Operations: ' || v_audit_collection.COUNT);
        
        -- Bulk insert audit records
        IF v_audit_collection.COUNT > 0 THEN
            FORALL i IN 1..v_audit_collection.COUNT
                INSERT INTO AUDIT_LOG VALUES v_audit_collection(i);
            
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('✓ Audit records saved: ' || v_audit_collection.COUNT);
        END IF;
        
        -- Clear collection
        v_audit_collection.DELETE;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('✗ Error saving audit: ' || SQLERRM);
    END AFTER STATEMENT;
    
END trg_learners_audit_compound;
/

PROMPT '✓ Compound trigger trg_learners_audit_compound created';
PROMPT '';

-- ============================================
-- VERIFICATION
-- ============================================

PROMPT '========================================';
PROMPT 'TRIGGER VERIFICATION';
PROMPT '========================================';
PROMPT '';

SELECT trigger_name, triggering_event, table_name, status, trigger_type
FROM user_triggers
WHERE table_name IN ('LEARNERS', 'PROGRESS_RECORDS')
ORDER BY table_name, trigger_name;

