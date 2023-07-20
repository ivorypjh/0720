import pymysql
import sys

try:
    # 데이터베이스 연결 객체 생성
    connec = pymysql.connect(host='localhost', port=3306,
                         db = 'mysql', user = 'root', passwd='!!',
                         charset='utf8')
    # SQL 객체 생성
    cursor = connec.cursor()
    # SQL 실행 - 값을 직접 SQL에 작성
    #cursor.execute("INSERT INTO DEPT VALUES(50, 'STU', 'SEOUL')")
    # SQL 실행 - SQL에 서식을 설정하고 파라미터를 대입하는 코드 작성
    # 위의 방식보다 권장하는 방식
    # 여기까지만 하면 반영되지 않음
    #cursor.execute("INSERT INTO DEPT VALUES(%s, %s, %s)", (60, 'STU', 'INCHEON'))
    #cursor.execute("INSERT INTO SAMPLESAL VALUES(%s, %s, %s)", (1, 1000, 1234))
    #cursor.execute("INSERT INTO EMP VALUES(%s, %s, %s, %s, %s, %s, %s, %s)",
    #               (3000, 'PARK', 'STU', 8080, '2023-07-20', 9000, 0, 10))
    #cursor.execute("UPDATE SAMPLESAL SET SALNO = %s, SAL = %s, EMPNO = %s",
    #               (3, 2000, 1212))

    # 50에 대한 데이터를 조회
    # 조회할 데이터가 1개인 상황
    cursor.execute(
        "SELECT * FROM DEPT WHERE DEPTNO < %s", (50)
    )
    # fetchone이므로 select를 통해 검색된 결과가 없으면 None
    # 결과가 있으면 tuple
    # fetchall이면 tuple의 tuple
    # record = cursor.fetchone()
    #record = cursor.fetchall()
    #if record == None:
    #    print('검색 결과 없음')
    #else:
    #    for items in record:
    #        print(items)

    # 검색 결과 전체 데이터를 읽어오기
    # 여러 개의 데이터를 가져오는 경우 데이터가 없으면
    # 빈 튜플을 리턴
    record = cursor.fetchall()
    # 여러 개를 리턴하는 함수를 호출해서 데이터가 없다는 사실을 확인하는 방법은
    # 데이터의 갯수가 0개인지 확인하는 것
    if len(record) == 0:
        print('검색 결과 없음')
    else:
        for items in record:
            print(items)

    # 원본에 반영
    # 파이썬과 DBeaver 는 세션이 다르기 때문에 COMMIT을 해줘야 함.
    # select를 통해 조회만 하는 경우에 commit 은 필요 없음
    connec.commit()

except:
    print("예외 발생함", sys.exe_info())
finally:
    if connec != None:
        connec.close()
