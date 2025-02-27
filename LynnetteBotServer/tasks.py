import requests
import time

import ai
import RPi.GPIO as GPIO
from ai import *
from dianfei import get_dianfei

GPIO.setmode(GPIO.BCM)
GPIO.setup(14,GPIO.OUT)

ChatTask = {
    'url' : "chat",
    'title' : "AI对话",
    'content' : "与GPT进行聊天",
    'executable': False
}

NotificationTask = {
    'url' : "get_notification",
    'title' : "消息通知",
    'content' : "机器人的自动消息通知",
    'executable': False
}

DoorTask = {
    'url' : "Door",
    'title' : "开门",
    'content' : "打开家的大门",
    'executable': True
}

NasTask = {
    'url' : "NasStatus",
    'title' : "Nas状态",
    'content' : "查询Nas状态",
    'executable': True
}

RebootNasTask = {
    'url' : "RebootNas",
    'title' : "重启NAS",
    'content' : "重启NAS整机",
    'executable': True
}
RebootNasArozOSTask = {
    'url' : "RebootAroz",
    'title' : "重启ArozOS",
    'content' : "重启NAS上的ArozOS",
    'executable': True
}

HomeworkTask = {
    'url' : "get_homework",
    'title' : "作业遍历",
    'content' : "查询未完成的作业",
    'executable': True
}
HomeworkGradeTask = {
    'url' : "get_homework_grade",
    'title' : "作业得分",
    'content' : "查询所有作业的得分",
    'executable': True
}
HomeworkNotifyTask = {
    'url': "get_ucloudNotify",
    'title': "云平台通知",
    'content': "自动监控云平台新通知并发送消息",
    'executable': False
}
ClassNotifyTask = {
    'url': "get_classNotify",
    'title': "上课提醒",
    'content': "快要上课时通过消息提醒",
    'executable': False
}
ClassCheckTask = {
    'url': "checkTodayClass",
    'title': "查课表",
    'content': "查询今日所有课程",
    'executable': True
}
DianfeiTask = {
    'url' : "dianfei",
    'title' : "电费查询",
    'content' : "查询电费并返回结果，同时每天早上电量不足会告警",
    'executable': True
}
AIBalanceTask = {
    'url' : "aiBalance",
    'title' : "用量查询",
    'content' : "ChatGPT API余额",
    'executable': True
}

GoodMorningNighTask = {
    'url': "goodmorning_night",
    'title': "早安晚安",
    'content': "定时发送问候",
    'executable': False
}

GetUcloudFileTask = {
    'url': "ucloudFile",
    'title': "云邮文件",
    'content': "遍历和下载云邮教学空间的文件",
    'executable': False
}

NAS_URL = 'http://192.168.2.100:8091'
NAS_STATUS_URL = '/check_status'
NAS_COMMAND_URL = '/check_online'

def launch_task(user, task_type, datain,filein=None):
    result = {}
    if task_type == NasTask.get('url'):
        result = NAS_Status_Task(user, datain)
    elif task_type == DoorTask.get('url'):
        result = OpenDoor_Task(user, datain)
    elif task_type == RebootNasTask.get('url'):
        result = RebootNas_Task(user, datain)
    elif task_type == RebootNasArozOSTask.get('url'):
        result = RebootArozOS_Task(user, datain)
    elif task_type == ChatTask.get('url'):
        result = chat_Task(user, datain, filein)
    elif task_type == DianfeiTask.get('url'):
        result = Dianfei_Task(user, datain)
    elif task_type == HomeworkTask.get('url'):
        result = Homework_Task(user, datain)
    elif task_type == HomeworkGradeTask.get('url'):
        result = Homework_score_Task(user, datain)
    elif task_type == AIBalanceTask.get('url'):
        result = AIBalance_Task(user, datain)
    elif task_type == ClassCheckTask.get('url'):
        result = getTodayClass_Task(user, datain)
    elif task_type == GetUcloudFileTask.get('url'):
        result = getUcloudFileTask(user, datain)
    return result

def NAS_Status_Task(user, datain):
    rep = requests.get(NAS_URL + NAS_STATUS_URL)
    result = rep.text
    notification = {
        'urgent': 0,
        'title': "NAS状态",
        'content': result,
        'time': time.time(),
    }
    user.insertNotification(notification)
    return {'status': 1, 'message': '成功'}

def OpenDoor_Task(user, datain):
    GPIO.output(14, GPIO.HIGH)
    time.sleep(1)
    GPIO.output(14, GPIO.LOW)
    notification = {
        'urgent': 0,
        'title': "开门",
        'content': "大门已打开",
        'time': time.time(),
    }
    user.insertNotification(notification)
    return {'status': 1, 'message': '成功'}

def RebootNas_Task(user, datain):
    data = {
        'command': 'reboot'
    }
    rep = requests.post(NAS_URL + NAS_COMMAND_URL, json=data)
    result = rep.text
    notification = {
        'urgent': 2,
        'title': "NAS重启",
        'content': result,
        'time': time.time(),
    }
    user.insertNotification(notification)
    return  {'status': 1,'message': '成功'}

def RebootArozOS_Task(user, datain):
    data = {
        'command': 'reboot_arozos'
    }
    rep = requests.post(NAS_URL + NAS_COMMAND_URL, json=data)
    result = rep.text
    notification = {
        'urgent': 1,
        'title': "ArozOS重启",
        'content': result,
        'time': time.time(),
    }
    user.insertNotification(notification)
    return {'status': 1, 'message': '成功'}

def chat_Task(user, datain, file=None):
    history = datain.get('history')
    usermsg = datain.get('usermsg')
    mode = datain.get('mode')
    if mode == 0 or mode == 1:
        response = askai(history, usermsg, mode)
        return {'status': 1, 'message': '成功', 'Bot': response}
    elif mode == 2:
        response = draw_pic(usermsg)
        return {'status': 1, 'message': '成功', 'imageUrl': response}
    elif mode == 3 and file is not None:
        pic = file.read()
        response = vision_pic(pic)
        return {'status': 1, 'message': '成功', 'bot':response}

def Dianfei_Task(user, datain):
    result = get_dianfei(user.getDianfeiPayload(), user.getBuptAcc(), user.getBuptPass())
    notification = {
        'urgent': 0,
        'title': "查电费结果",
        'content': result,
        'time': time.time(),
    }
    user.insertNotification(notification)
    return {'status': 1, 'message': '成功'}

def Homework_Task(user, datain):
    result = user.homework.get_all_undone()
    notification = {
        'urgent': 1,
        'title': "查作业结果",
        'content': result,
        'time': time.time(),
    }
    user.insertNotification(notification)
    return {'status': 1, 'message': '成功'}

def Homework_score_Task(user, datain):
    result = user.homework.get_all_assiscore()
    notification = {
        'urgent': 1,
        'title': "查作业成绩结果",
        'content': result,
        'time': time.time(),
    }
    user.insertNotification(notification)
    return {'status': 1, 'message': '成功'}

def AIBalance_Task(user, datain):
    result = ai.get_quota()
    notification = {
        'urgent': 1,
        'title': "查AI余额结果",
        'content': result,
        'time': time.time(),
    }
    user.insertNotification(notification)
    return {'status': 1, 'message': '成功'}

def getTodayClass_Task(user, datain):
    result = user.classnotify.get_today_class()
    notify = ""
    if len(result) == 0:
        notify = "今日无课"
    else:
        for course in result:
            title = course.get('courseName') + "\n"
            place = "地点：" + course.get('classroomName') + "\n"
            ctime = "时间：" + course.get('startTime') + "----" + course.get('endTIme') + "\n"
            teacher = "老师：" + course.get('teacherName') + "\n"
            notify += title + place + ctime + teacher + "\n"
    notification = {
        'urgent': 1,
        'title': "今日所有课程",
        'content': notify,
        'time': time.time(),
    }
    user.insertNotification(notification)
    return {'status': 1, 'message': '成功'}

def getUcloudFileTask(user, datain):
    if datain.get('fileid') is None:
        # 没有传入特定fileid，故作为请求所有文件
        if datain.get('refresh') or len(user.homework.get_updated_resources()) == 0:
            user.homework.update_all_resources()
        result = user.homework.get_updated_resources()
        return {'status': 1, 'message': '成功', 'cloudfiles': result}
    fileurl = user.homework.get_file_url(datain.get('fileid'))
    print(fileurl)
    return {'status': 1, 'message': '成功', 'fileurl': fileurl}
