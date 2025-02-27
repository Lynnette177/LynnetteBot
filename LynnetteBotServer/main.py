from flask import Flask, request, jsonify
import json
import scheduleTask
from users import *
import time
import threading

appSecret = "asigbsaiodugbjkscbgkjsdg"
app = Flask(__name__)

@app.route('/init', methods=['POST'])
def init():
    # 获取请求的JSON数据
    data = request.get_json()

    userId = data.get('userId')
    user = searchUserbyIDinList(userId)
    if userId is None or user is None:
        response = {
            'status': 0,
            'message': '用户不存在'
        }
    else:
        response = {
            'status': 1,
            'message': '成功',
            'servername': servername,
            'tasks': user.getTask()
        }

    # 返回JSON响应
    return jsonify(response)

@app.route("/get_notification", methods=['POST'])
def get_notification():
    data = request.get_json()
    userId = data.get('userId')
    user = searchUserbyIDinList(userId)
    if userId is None or user is None:
        response = {
            'status': 0,
            'message': '用户不存在'
        }
    else:
        task_list = user.getTask()
        if not checkTaskinTaskList("get_notification", task_list):
            response = {
                'status': 0,
                'message': '不支持该任务',
            }
        else:
            response = {
                'status': 1,
                'message': '成功',
                'notifications' : user.getNotificationList()
            }

    # 返回JSON响应
    print(response)
    return jsonify(response)

@app.route('/delete_notifications', methods=['POST'])
def delete_notification():
    data = request.get_json()
    userId = data.get('userId')
    user = searchUserbyIDinList(userId)
    if userId is None or user is None:
        response = {
            'status': 0,
            'message': '用户不存在'
        }
    else:
        task_list = user.getTask()
        if not checkTaskinTaskList("get_notification", task_list):
            response = {
                'status': 0,
                'message': '不支持该任务',
            }
        else:
            user.clearNotificationList()
            response = {
                'status': 1,
                'message': '成功'
            }

    return jsonify(response)


@app.route('/execute_task', methods=['POST'])
def execute_task():
    file = None
    if request.is_json:
        data = request.get_json()
    else:
        data = json.loads(request.form.get('json'))
        file = request.files.get('file')
    userId = data.get('userId')
    method = data.get('method')
    user = searchUserbyIDinList(userId)
    if userId is None or user is None:
        response = {
            'status': 0,
             'message': '用户不存在'
        }
    else:
        task_list = user.getTask()
        if not checkTaskinTaskList(method, task_list):
            response = {
                'status': 0,
                'message': '不支持该任务',
            }
        else:
            response = launch_task(user, method,data, file)
    return jsonify(response)




@app.route('/insert_notify', methods=['POST'])
def insert_notify():
    data = request.get_json()
    userId = data.get('userId')
    secret = data.get('secret')
    notify = data.get('notify')
    if secret != appSecret:
        response = {
            'status': 0,
            'message': '不合法的密钥'
        }
        return jsonify(response)
    user = searchUserbyIDinList(userId)
    if userId is None or user is None:
        response = {
            'status': 0,
             'message': '用户不存在'
        }
    else:
        user.insertNotification(notify)
        response = {
            'status': 1,
            'message': '成功'
        }
    return jsonify(response)


if __name__ == '__main__':
    thread = threading.Thread(target=scheduleTask.scheduleMain)
    thread.start()
    app.run(host='0.0.0.0', port=3001)
    thread.join()