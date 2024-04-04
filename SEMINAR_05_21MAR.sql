-- 21/03/2024 Seminar 5

-- SET SERVEROUTPUT ON

--  THREE TYPES OF COLLECTIONS
--      INDEX BY TABLE: PLS_INTEGER/VARCHAR2 (ONLY TYPES ALLOWED FOR INDEX), KEYWORD: INDEX BY
--      NESTED TABLE: PLS_INTEGER (ONLY TYPE ALLOWED), KEYWORD NOT NEEDED, NEEDS TO BE EXPANDED WITH `.EXPAND(1)`, BEFORE ADDING NEW ELEMENTS
--      VARRAY: IN VARRAY ELEMENTS CANNOT BE DELETED BY INDEX. `.DELETE` DELETES ALL THE ELEMENTS


-- EXECUTING SQL STATEMENTS IN PL/SQL BLOCKS
-- DML, TCL CAN BE USED WITHOUT RESTRICTIONS
-- DDL, DCL CAN BE USED ONLY WITH EXECUTE IMMEDIATE OR DBMS_SQL

-- CURSORS
-- IMPLICIT/EXPLICIT

-- UPDATE AND DELETE DO NOT RAISE NO_DATA_FOUND

BEGIN
    NULL;
    UPDATE EMPLOYEES SET SALARY=SALARY*1.1 WHERE SALARY < 7000;
    
    -- EACH STATEMENT IS RUN INSIDE OF AN IMPLICIT CURSOR
    -- SQL % FOUND, SQL % NOTFOUND, SQL % ROWCOUNT (BOOL, BOOL, PLS_INTEGER)
    
    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('AT LEAST ONE SALARY WAS UPDATED');
        DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' SALARIES WAS UPDATED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('NO SALARIES WERE UPDATED');
    END IF;
    
    DELETE FROM ORDER_ITEMS;
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' ITEMS WERE DELETED');
    
    ROLLBACK;
END;
/

DECLARE
    V_NAME VARCHAR2(20);

BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE MY_TAB (M_ID NUMBER PRIMARY KEY, NAME VARCHAR(100))'; --DDL
    
    EXECUTE IMMEDIATE 'GRANT SELECT IN MY_TAB TO PUBLIC';
    
    EXECUTE IMMEDIATE 'INSERT INTO MY_TAB VALUES(100, ''JOHN'')';
    
    SELECT FIRST_NAME INTO V_NAME FROM EMPLOYEES WHERE EMPLOYEE_ID=11;
    
    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE(V_NAME);
    END IF;
    
    EXCEPTION
        WHEN OTHERS
        THEN EXECUTE IMMEDIATE 'DROP TABLE MY_TAB';
    NULL;
END;
/

DECLARE
    TYPE T_RES IS RECORD(
        DEPARTMENT_NAME DEPARTMENTS.DEPARTMENT_NAME%TYPE,
        SALARY NUMBER(10, 2)
    );
    TYPE T_VAL IS VARRAY(100) OF T_RES; -- VARRAY WHICH CAN HOLD ONLY A PREDEFINED NUMBER OF ELEMENTS
    V T_VAL;
BEGIN
    SELECT
        UPPER(DEPARTMENT_NAME), ROUND(AVG(SALARY), 2)
    BULK COLLECT INTO
        V -- `BULK COLLECT` IS REQUIRED WHEN POPULATING A COLLECTION
    FROM
        EMPLOYEES E
    JOIN
        DEPARTMENTS D
    ON
        E.DEPARTMENT_ID=D.DEPARTMENT_ID 
    GROUP BY
        DEPARTMENT_NAME
    HAVING
        COUNT(*) > (SELECT COUNT(*) FROM EMPLOYEES WHERE DEPARTMENT_ID = 20);
    
    FOR I IN V.FIRST..V.LAST LOOP
        IF V.EXISTS(I) THEN
            DBMS_OUTPUT.PUT_LINE(V(I).DEPARTMENT_NAME||' HAS AN AVERAGE SALARY OF '||V(I).SALARY);
        END IF;
    END LOOP;
END;
/