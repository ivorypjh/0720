import pymysql
import sys

try:
    # 데이터베이스 연결 객체 생성
    connec = pymysql.connect(host='localhost', port=3306,
                         db = 'mysql', user = 'root', passwd='!!',
                         charset='utf8')
    # SQL 객체 생성
    cursor = connec.cursor()

    # 삽입할 이미지 파일의 내용 읽기
    # 자신의 파일 경로 사용
    #img = open('./7월/0720/TP.jpg', 'rb')
    #tp = img.read()
    #img.close()
    #
    # 데이터 삽입
    #cursor.execute("INSERT INTO FILET VALUES(%s, %s)",
    #               ("TP.jpg", tp))

    # 데이터 읽어오기
    cursor.execute("SELECT * FROM FILET")
    DATA = cursor.fetchone()
    # 두번째 데이터가 blob 이므로 두번째 데이터를 파일로 변경해야 함
    print(DATA[0]) # 파일명
    # 파일을 쓰기 모드로 기록함
    f = open(DATA[0], 'wb')
    f.write(DATA[1]) # 읽은 데이터를 파일로 기록
    f.close()
    
    # select를 통해 파일을 읽어오므로 commit은 없어도 됨
    connec.commit()


except:
    print("예외 발생함", sys.exe_info())
finally:
    if connec != None:
        connec.close()
