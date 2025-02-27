import requests
from crypto_related import aes_encrypt_base64_base64
import datetime
aeskey = b"qzkj1kjghd=876&*"


def calculate_time_difference(given_time_str):
    # 获取当前日期和时间
    current_time = datetime.datetime.now() #- datetime.timedelta(hours=5)# 测试
    # 获取当前日期和给定时间的时间
    given_time = datetime.datetime.strptime(given_time_str, "%H:%M").replace(year=current_time.year,
                                                                             month=current_time.month,
                                                                             day=current_time.day)
    # 判断给定时间是否在当前时间之后
    if given_time > current_time:
        difference = given_time - current_time
        return difference.total_seconds()
    else:
        # 如果给定时间已经过去
        return -1


class jwglwx():
    def __init__(self,buptacc, buptpass):
        self.buptacc = buptacc
        self.buptpass = buptpass
        self.token = ""
        self.encrypted_password =aes_encrypt_base64_base64(aeskey,'"' + self.buptpass + '"')
        if self.buptacc != "" and self.buptpass != "":
            self.login()
    def login(self):
        try:
            url = "http://jwglweixin.bupt.edu.cn/bjyddx/login"
            jdata = {
                'userNo': self.buptacc,
                'pwd': self.encrypted_password,
                'encode': 1,
                'captchaData':None,
                'codeVal': None,
            }
            headers = {
                "Content-Type": "application/x-www-form-urlencoded"
            }
            resp = requests.post(url,headers=headers, data=jdata)
            result = resp.json()
            if result.get('code') == '1':
                data = result.get('data')
                self.token = data.get('token')
        except Exception as e:
            print("Login error.")
            print(e)

    def get_closest_class(self):
        try:
            url = 'http://jwglweixin.bupt.edu.cn/bjyddx/student/curriculum'
            header = {
                #"Content-Type": "application/x-www-form-urlencoded",
                'user-agent' : "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36 Edg/133.0.0.0",
                'token': self.token,
            }
            jdata = {
                'week':'',
                'kbjcmsid': '',
            }
            closest_class = None
            resp = requests.post(url,headers=header, data=jdata)
            result = resp.json()
            minTime = 86400
            if result.get('code') != '1':
                self.login()
                resp = requests.post(url,headers=header, data=jdata)
                result = resp.json()
            
            current_date = datetime.datetime.now()
            day_of_week = (current_date.weekday() + 1) % 7 # 当前是周几
            class_data = result.get('data')
            courses = class_data[0].get('courses')
            for course in courses:
                if course.get('weekDay') != str(day_of_week):
                    continue
                startTime = course.get('startTime')
                delta = calculate_time_difference(startTime)
                if delta < 0:
                    continue
                else:
                    if delta < minTime:
                        minTime = delta
                        closest_class = course
                        closest_class['deltaSeconds'] = delta
                
            return closest_class
        except Exception as e:
            print("Get closest class error")
            print(e)
            return None
        
    def get_today_class(self):
        try:
            self.login()
            url = 'http://jwglweixin.bupt.edu.cn/bjyddx/student/curriculum'
            header = {
                #"Content-Type": "application/x-www-form-urlencoded",
                'user-agent' : "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36 Edg/133.0.0.0",
                'token': self.token,
            }
            jdata = {
                'week':'',
                'kbjcmsid': '',
            }
            today_classes = []
            resp = requests.post(url,headers=header, data=jdata)
            result = resp.json()
            if result.get('code') != '1':
                self.login()
                resp = requests.post(url,headers=header, data=jdata)
                result = resp.json() 
            current_date = datetime.datetime.now()
            day_of_week = (current_date.weekday() + 1) % 7 # 当前是周几
            class_data = result.get('data')
            courses = class_data[0].get('courses')
            for course in courses:
                if course.get('weekDay') != str(day_of_week):
                    continue
                today_classes.append(course)
            return today_classes
        except Exception as e:
            print("Get today class error.")
            print(e)
            return []
