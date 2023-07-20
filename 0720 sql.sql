use mysql;

select * 
from DEPT;

-- DEPT 테이블에 데이터 삽입
INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES(50, 'SALES', 'SEOUL');

-- 철회 : SAVEPOINT 를 입력하지 않으면 트랜잭션의 시작 전으로 복구됨
ROLLBACK;

-- INSERT 트랜잭션이 적용되기 전으로 돌아감
SELECT *
FROM DEPT;

-- INSERT(삽입)을 진행하면 다시 트랜잭션이 생성
INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES(50, 'COUNT', 'SEOUL');

-- DEPT 테이블의 모든 내용을 가직 COPY 테이블을 생성
-- DDL(CREATE, DROP, ALTER, TRUNCATE, RENAME)이나
-- DCL(GRANT, REVOKE)를 수행하면 AUTO COMMIT (DDL, DCL은 관리자 명령어)
-- COMMIT 수행 : 트랜잭션은 변경된 내용을 반영하고 종료
CREATE TABLE COPY
AS
SELECT *
FROM DEPT;

-- 철회
ROLLBACK;

-- ROLLBACK을 진행했지만 삽입한 50 이 남아있음
SELECT *
FROM DEPT;

-- 트랜잭션 생성
INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES(60, 'COUNT', 'SEOUL');

SAVEPOINT SV1;

INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES(70, 'COUNT', 'SEOUL');

SAVEPOINT SV2;

INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES(80, 'COUNT', 'SEOUL');

SELECT *
FROM DEPT;

-- SAVEPOINT SV1 을 생성한 지점으로 되돌아감
-- SV1 지점에서는 아직 INSERT 트랜잭션이 처리되지 않고 남아있으므로 LOCK이 걸림
-- 이걸 없애기 위해서는 COMMIT 이나 ROLLBACK 으로 트랜잭션을 처리해줘야 함
ROLLBACK TO SV1;

SELECT *
FROM DEPT;

-- 트랜잭션 완료
COMMIT;

-- 일반적인 JOIN 방법을 통해 JOB 이 CLERK 인 데이터를 조회
SELECT *
FROM EMP, DEPT
WHERE EMP.DEPTNO = EMP.DEPTNO AND JOB = 'CLERK';

-- INLINE VIEW를 활용한 방식
-- 구문에서 가장 먼저 처리되는 FROM 절 안에서 먼저 필터링을 거치는 방식
-- 먼저 EMP 테이블에서 조건에 맞는 데이터들만 가져와서 TEMP라는 이름을 부여
-- 조회할 데이터의 수를 크게 줄일 수 있는 방법
SELECT *
FROM (SELECT * FROM EMP WHERE JOB = 'CLERK') TEMP, DEPT 
WHERE TEMP.DEPTNO = DEPT.DEPTNO;


-- EMP 테이블에서 EMPNO, ENAME, SAL, COMM 만으로 구성된 뷰를 생성
-- 컬럼에는 권한을 부여할 수 없고 테이블에만 부여할 수 있음
CREATE VIEW TEMP
AS
SELECT EMPNO, ENAME, SAL, COMM
FROM EMP;

-- 만들어진 VIEW는 테이블처럼 사용 가능
-- EMP 테이블에 대한 정보를 감추면서 데이터를 제공할 수 있음(보안 역할)
SELECT *
FROM TEMP;

-- VIEW에는 DML(삽입, 삭제, 갱신) 작업이 가능한 경우도 있고 아닌 경우도 있음
-- VIEW 에 사용된 컬럼을 제외한 나머지 중에 NOT NULL 이 없으므로 가능
DESC EMP;

-- VIEW에 데이터 삽입 : VIEW를 만들 때 사용한 EMP 테이블에 데이터가 삽입됨
INSERT INTO TEMP(EMPNO, ENAME, SAL, COMM) VALUES(1000, 'KIM', 10000, 1000);

-- VIEW 에 데이터가 삽입된 걸 볼 수 있음
SELECT *
FROM TEMP;

-- EMP 테이블에 데이터가 삽입됨
SELECT *
FROM EMP;

-- VIEW 의 구조도 테이블처럼 확인 가능
DESC TEMP;

-- VIEW 삭제
DROP VIEW TEMP;


-- 임시 테이블 생성
-- 접속을 종료하고 다시 연결하면 사라지는 테이블
CREATE TEMPORARY TABLE TEMP(
	NAME CHAR(20)
);

-- 데이터 확인
-- 종료하기 전에는 정상적으로 실행됨
-- 종료하고 다시 연결하면 기존의 세션이 사라지므로 에러
SELECT *
FROM TEMP;


-- CTE : SQL 수행 중에만 일시적으로 메모리 공간을 할당 받아서 사용하는 테이블
-- WHERE 절에서 수행되는 서브 쿼리가 FROM 절의 INLINE VIEW 보다 먼저 처리되므로 
-- TEMP 를 사용할 수 없어서 아래 구문은 실행될 수 없음
SELECT *
FROM (SELECT NAME, SALARY, SCORE FROM tStaff 
WHERE DEPART = '영업부' AND GENGER = '남') TEMP
WHERE SALARY >= (SELECT AVG(SALARY) FROM TEMP)

-- SELECT 구문의 결과에 일시적으로 TEMP 라는 테이블 이름을 부여해서 보관
-- WITH 부분이 서브쿼리보다 먼저 처리되기 때문에 TEMP 이름을 사용할 수 있음
-- CTE를 생성하는 구문은 가장 먼저 수행됨
WITH TEMP AS
(SELECT NAME, SALARY, SCORE FROM tStaff WHERE DEPART = '영업부' AND GENDER = '남')
SELECT * FROM TEMP
WHERE SALARY >= (SELECT AVG(SALARY) FROM TEMP);



SELECT *
FROM usertbl;

DESC usertbl;

-- usertbl 테이블에 데이터를 넣는 PROCEDURE 생성
-- DELIMITER는 PROCEDURE의 종료를 알리기 위한 기호를 설정하는 것
-- 기호를 2개 사용하는 이유는 1개로 만들면 데이터로 사용되는 것과 혼동이 올 수 있기 때문임
-- DBeaver 에서는 수행할 때 SQL 스크립트 실행으로 실행해야 함
DELIMITER //
CREATE PROCEDURE PROC(PUSERID CHAR(15), PNAME VARCHAR(20), 
	PBIRTHYEAR INT,	PADDR CHAR(100), PMOBILE CHAR(11), PMDATE DATE)
		BEGIN
			INSERT INTO usertbl(userid, name, birthyear, addr, mobile, mdate)
			VALUES(PUSERID, PNAME, PBIRTHYEAR, PADDR, PMOBILE, PMDATE);
		END //
DELIMITER ; 


-- PROCEDURE 호출
CALL PROC('PARK', '박종호', 1999, '서울', '01012341234', '1999-01-01');

SELECT *
FROM usertbl;


-- TRIGGER 를 수행하기 위한 샘플 테이블 생성
CREATE TABLE SAMPLETABLE(
	EMPNO INT PRIMARY KEY,
	ENAME VARCHAR(30) NOT NULL,
	JOB VARCHAR(100)
);

CREATE TABLE SAMPLESAL(
	SALNO INT PRIMARY KEY AUTO_INCREMENT,
	SAL FLOAT(7, 2),
	EMPNO INT REFERENCES SAMPLETABLE(EMPNO) ON DELETE CASCADE 
);

-- SAMPLETABLE 에 데이터를 추가하면 
-- SAMPLESAL 테이블에 자동으로 데이터가 추가되는 트리거

DELIMITER //
CREATE TRIGGER TRG_01
AFTER INSERT ON SAMPLETABLE
FOR EACH ROW 
BEGIN 
	INSERT INTO SAMPLESAL(SAL, EMPNO) VALUES(100, NEW.EMPNO);
END // 
DELIMITER ;

INSERT INTO SAMPLETABLE VALUES(1, 'PARK', 'STUDENT');

SELECT *
FROM SAMPLESAL;



SHOW TABLES;

-- 사용할 db 설정
use mysql;

-- 테이블 구조 확인
desc DEPT;

SELECT *
FROM DEPT;




-- 파일을 저장할 수 있는 테이블 생성
CREATE TABLE FILET(
	FILENAME VARCHAR(50),
	FILECONTENT LONGBLOB
);

DESC FILET;
SELECT *
FROM FILET;




