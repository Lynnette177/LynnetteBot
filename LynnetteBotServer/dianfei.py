import requests
import json
import requests
import re
import urllib3
urllib3.disable_warnings()

def extract_values(html_content):
    # 定义正则表达式模式
    # 使用正则表达式找到匹配项
    execution_value = re.search(r'<input\s+name="execution"\s+value="([^"]+)"', html_content)

    if execution_value:
        execution_value = execution_value.group(1)
#        print(execution_value)
    else:
        print("未找到execution的值")
    return execution_value

def get_and_print(url):
    try:
        response = requests.get(url, allow_redirects=False)
        #print("Initial URL:", response.url)
        while response.status_code == 302:  # 302状态码表示重定向
            redirected_url = response.headers['Location']
            #print("Redirected to:", redirected_url)
            response = requests.get(redirected_url, allow_redirects=False)
        if response.status_code == 200:
            cookies = response.cookies
#            print(cookies)
            return extract_values(response.text), cookies
        else:
            print("Failed to retrieve content. Status code:", response.status_code)
    except requests.exceptions.RequestException as e:
        print("Error:", e)

def get_login_cookies (username, password,exe,cookies):
    url = "https://auth.bupt.edu.cn/authserver/login"  # 替换为实际的登录URL
    data = {
        'username': username,
        'password': password,
        'submit': '登录',
        'type': 'username_password',
        'execution': exe,
        '_eventId': 'submit',
    }
#    print(data)
    try:
        #print(cookies)
        response = requests.post(url, data=data,allow_redirects=False,cookies=cookies)
        redirected_url = response.headers['Location']
        for cookie in response.cookies:
            #print(cookie)
            pass
        #print("重定向地址:", redirected_url)
        response = requests.post(redirected_url, data=data, allow_redirects=False, cookies=response.cookies)
        for cookie in response.cookies:
            #print(cookie)
            pass
        return response.cookies
    except requests.exceptions.RequestException as e:
        print("Error:", e)

def get_co_and_sa(acc,password):
    url1 = "https://app.bupt.edu.cn/buptdf/wap/default/chong"
    exe,cookies = get_and_print(url1)
    return get_login_cookies(acc, password,exe,cookies)


def get_dianfei(payload, acc, password):
# 定义要访问的网址
    url = 'https://app.bupt.edu.cn/buptdf/wap/default/chong'
    cookies = get_co_and_sa(acc, password)
    response = requests.get(url, cookies=cookies,verify=False,allow_redirects=False)
    if response.status_code == 200:
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        }
        response = requests.post('https://app.bupt.edu.cn/buptdf/wap/default/search', data=payload, headers=headers,cookies=cookies,verify=False)
        data = json.loads(response.text)
        info = {
            "楼层": data["d"]["data"]["floorName"],
            "更新时间": data["d"]["data"]["time"],
            "剩余金额": data["d"]["data"]["surplus"] + " 元",
            "剩余电量": "{:.2f}度".format(float(data["d"]["data"]["surplus"])/float(data["d"]["data"]["price"])),
            "总用电量": data["d"]["data"]["vTotal"] + " 度",
            "单价": data["d"]["data"]["price"] + " 元/度",
            "校区": data["d"]["data"]["parName"]
        }

        message = (
            f"楼层：{info['楼层']}\n"
            f"更新时间：{info['更新时间']}\n"
            f"剩余金额：{info['剩余金额']}\n"
#                f"剩余金额：19.1元\n"
            f"剩余电量：{info['剩余电量']}\n"
#                f"剩余电量：19.1\n"
            f"总用电量：{info['总用电量']}\n"
            f"单价：{info['单价']}\n"
            f"位置：{info['校区']}"
        )
        return message
