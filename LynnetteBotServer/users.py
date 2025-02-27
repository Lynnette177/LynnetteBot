from pushover import Client
import datetime
from tasks import *
import homework
import jwglwx
import threading

lyn_id = ""
wyn_id = ""
servername = "LynnetteBot"
default_key = "PUSHOVERKEY"
default_apitoken = "PUSHOVERAPITOKEN"

def searchUserbyIDinList(userid):
    result = None
    for user in user_list:
        if user.getID() == userid:
            result = user
            break
    return result

def checkTaskinTaskList(taskin, task_list):
    result = None
    for task in task_list:
        if task.get('url') == taskin:
            result = task
            break
    return result


def getUrgentTypeStr(urg):
    if urg == 0:
        return "普通事件"
    elif urg == 1:
        return "中等事件"
    elif urg == 2:
        return "紧急事件"
    return "未知事件"

class user:
    def __init__(self, id, userkey, apitoken, device, buptacc, buptpass, dianfeipayload):
        self.id = id
        self.notificationList = []
        self.pushoverClient = Client(userkey, api_token=apitoken, device=device)
        self.buptacc = buptacc
        self.buptpass = buptpass
        self.dianfeipayload = dianfeipayload
        self.homework = homework.homework(buptacc, buptpass)
        self.classnotify = jwglwx.jwglwx(buptacc, buptpass)

    def getID(self):
        return self.id
    def getTask(self):
        #HARD CODED
        if self.id == lyn_id:
            return [ClassCheckTask,DianfeiTask,HomeworkTask, HomeworkGradeTask,DoorTask,AIBalanceTask, NasTask, RebootNasTask,RebootNasArozOSTask,ClassNotifyTask,GetUcloudFileTask,ChatTask,HomeworkNotifyTask,NotificationTask,GoodMorningNighTask]
        elif self.id == wyn_id:
            return [ClassCheckTask,DianfeiTask,HomeworkTask, HomeworkGradeTask,AIBalanceTask,ClassNotifyTask,GetUcloudFileTask,ChatTask,HomeworkNotifyTask,NotificationTask,GoodMorningNighTask]
        else:
            return []
    def send_to_pushover(self, content, title):
        self.pushoverClient.send_message(content, title=title)
    
    def insertNotification(self, notification):
        if notification.get('urgent') is not None and notification.get('time') and notification['title'] and notification.get('content'):
            self.notificationList.append(notification)
            dt_object = datetime.datetime.fromtimestamp(notification.get('time'))
            formatted_time = dt_object.strftime('%Y-%m-%d %H:%M:%S')
            content = notification['title'] + "\n" + getUrgentTypeStr(notification['urgent']) + formatted_time + "\n" + notification.get('content')
            pushthread = threading.Thread(target=self.send_to_pushover, args=(content, notification['title']))
            pushthread.start()
        
            
    def getNotificationList(self):
        return self.notificationList
    def clearNotificationList(self):
        self.notificationList = []
    def getDianfeiPayload(self):
        return self.dianfeipayload
    def getBuptAcc(self):
        return self.buptacc
    def getBuptPass(self):
        return self.buptpass

user_list = [user(lyn_id,default_key,default_apitoken,'iPhone13ProMax','acc','pass',{'partmentId': '沙河校区雁北园D2楼','floorId': '?层','dromNumber': 123345,'areaid': 2}),
             user(wyn_id,default_key,default_apitoken,'WYNiPhone','acc2','pass2',{'partmentId': '沙河校区雁南园S6楼','floorId': '?层','dromNumber': 12345,'areaid': 2})]