import json
import threading
import schedule
import time

import dianfei
import weather_related
from tasks import HomeworkNotifyTask, DianfeiTask, GoodMorningNighTask, ClassNotifyTask
from users import user_list, searchUserbyIDinList, checkTaskinTaskList, lyn_id, wyn_id
import goodmorning


def check_class_notify():
    #print("Check CLASS!!!!!!!!")
    for user in user_list:
        if checkTaskinTaskList(ClassNotifyTask.get('url'), user.getTask()):
            course = user.classnotify.get_closest_class()
            print(course)
            if course is not None and course.get('deltaSeconds') <= 600:
                content = "地点：" + course.get('classroomName') + "\n"
                content += "时间：" + course.get('startTime') + "----" + course.get('endTIme') + "\n"
                content += "老师：" + course.get('teacherName')
                notification = {
                    'urgent': 2,
                    'title': course.get('courseName') + "上课提醒",
                    'content': content,
                    'time': time.time(),
                }
                user.insertNotification(notification)


def check_ucloud_notification_and_notify():
    for user in user_list:
        if checkTaskinTaskList(HomeworkNotifyTask.get('url'), user.getTask()):
            notify_str = user.homework.get_ucloud_notify()
            if notify_str != "":
                notification = {
                    'urgent': 2,
                    'title': notify_str,
                    'content': notify_str,
                    'time': time.time(),
                }
                user.insertNotification(notification)


def check_dianfei_enough():
    for user in user_list:
        if checkTaskinTaskList(DianfeiTask.get('url'), user.getTask()):
            dianfeimsg = ""
            trytime = 5
            while trytime > 0:
                dianfeimsg = dianfei.get_dianfei(user.getDianfeiPayload(), user.getBuptAcc(), user.getBuptPass())
                if dianfeimsg.startswith('错误'):
                    trytime -= 1
                else:
                    break
            split_message = dianfeimsg.split("剩余金额：")
            # 如果剩余电量部分成功拆分，则获取剩余电量数值部分
            if len(split_message) > 1:
                remaining_power = split_message[1].split()[0]
                remaining_power_float = float(remaining_power.rstrip('元'))
                print(remaining_power_float)
                if  remaining_power_float< 20:  # 去除字符串中的度数单位，并转换为浮点数
                    notification = {
                        'urgent': 2,
                        'title': "电费不足二十元，请尽快充值",
                        'content': "电费余额：" + remaining_power,
                        'time': time.time(),
                    }
                    user.insertNotification(notification)


# 定义一个任务
def seconds10Job():
    pass

def minutes1Job():
    threading.Thread(target= check_ucloud_notification_and_notify).start()

def minutes5Job():
    threading.Thread(target= check_class_notify).start()

def hourJob():
    pass

def morningJob():
    threading.Thread(target= check_dianfei_enough).start()

def eveningJob():
    content = goodmorning.get_GoodNight()
    chunk_size = 500
    # 使用for循环逐块处理
    for i in range(0, len(content), chunk_size):
        chunk = content[i:i + chunk_size]
        notification = {
            'urgent': 2,
            'title': "夜深了，晚安",
            'content': chunk,
            'time': time.time(),
        }
        for user in user_list:
            if checkTaskinTaskList(GoodMorningNighTask.get('url'), user.getTask()):
                user.insertNotification(notification)

def weatherTask():
    failcount = 0
    weather = weather_related.get_weather()
    weather_bj = weather_related.get_weather(province_id_in='10101', area_id_in='00', county_id_in='07')
    user_me = searchUserbyIDinList(lyn_id)
    user_wyn = searchUserbyIDinList(wyn_id)
    while (weather[0] is not True or weather_bj[0] is not True) and failcount < 8:
        failcount += 1
        weather = weather_related.get_weather()
        if weather[0] is not True:
            notify = {
                'urgent': 2,
                'title': '获取天气失败1',
                'content': weather[1],
                'time': time.time()
            }
            user_me.insertNotification(notify)
        if weather_bj[0] is not True:
            notify = {
                'urgent': 2,
                'title': '获取天气失败2',
                'content': weather_bj[1],
                'time': time.time()
            }
            user_me.insertNotification(notify)
    if weather[0] is True:
        notify = {
            'urgent': 0,
            'title': '今日天气：龙口',
            'content': weather[1],
            'time': time.time()
        }
        user_me.insertNotification(notify)
    if weather_bj[0] is True:
        notify = {
            'urgent': 0,
            'title': '今日天气：北京市昌平区',
            'content': weather_bj[1],
            'time': time.time()
        }
        user_me.insertNotification(notify)
        user_wyn.insertNotification(notify)

def scheduleMain():
    schedule.every(10).seconds.do(seconds10Job)
    schedule.every(60).seconds.do(minutes1Job)
    schedule.every(300).seconds.do(minutes5Job)
    schedule.every(1).hour.do(hourJob)
    schedule.every().day.at("07:00").do(morningJob)
    schedule.every().day.at("23:00").do(eveningJob)
    schedule.every().day.at("07:15").do(weatherTask)
    while True:
        schedule.run_pending()
        time.sleep(1)  # 每秒检查一次
