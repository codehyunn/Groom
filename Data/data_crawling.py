import urllib.request 
from bs4 import BeautifulSoup
import time
import pandas as pd

cols = ["car_num","receipt_time", "set_time", "ride_time", "start_position(gu)", "start_position(dong)" , "end_position(gu)", "end_position(dong)"]
rows = []

def soup(date): 
    key = '61736c7041776c6733315271516179' 
    url = "http://openAPI.seoul.go.kr:8088/%s/xml/disabledCalltaxi/1/100/%s" % (key,date)
    #rawdata = open('test.xml', 'r', encoding = 'utf-8')
    rawdata = urllib.request.urlopen(url)
    data = rawdata.read()
    soup = BeautifulSoup(data, features="xml")
    time.sleep(5)

    items = soup.select('item')

    for item in items:
        carNum = item.find('no').text
        receiptTime = item.find('receipttime').text
        setTime = item.find("settime").text
        rideTime = item.find("ridetime").text
        start_gu = item.find("startpos1").text
        start_dong = item.find("startpos2").text
        end_gu = item.find("endpos1").text
        end_dong = item.find("endpos2").text

        rows.append({"car_num" : carNum,
                    "receipt_time": receiptTime,
                     "set_time": setTime,
                     "ride_time": rideTime,
                     "start_position(gu)": start_gu,
                     "start_position(dong)": start_dong,
                     "end_position(gu)": end_gu,
                     "end_position(dong)": end_dong})
    
    
#날짜 계산해서 돌리기 ~> date, month, 필요하다면 endDay 수정
date = '20221101' # 크롤링 시작할 날
endDay = [31,28,31,30,31,30,31,31,30,31,30,31] #순서대로 1월부터 12월
while True: 
    month = int(date[4:6])
    day = date[6:]
    if int(day) > endDay[month-1]: 
        output_name = date[:6]+'.csv'
        df = pd.DataFrame(rows, columns=cols)
        df.to_csv(output_name,encoding='cp949')
        
        if (month == 11) : # 크롤링 끝낼 달 | 2021년 12월까지 하면 month=12: 
            print('done')
            break

        rows = []
        date = date.replace(day,"01")
        date = str(int(date) + 100)

    else:
        print(date)
        soup(date)
        date = str(int(date) + 1)
