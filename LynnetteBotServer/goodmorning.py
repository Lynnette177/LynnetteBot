
import time
import json
from time import localtime
from requests import get, post
from datetime import datetime, date
import random

apiKey = ""

def get_stroy():
    headers = {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                      'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36'
    }
    random_id = random.randint(1, 8)
    while random_id == 6 or random_id == 5:
        random_id = random.randint(1, 8)
    random_page = random.randint(1, 30)
    txUrl = "https://apis.tianapi.com/fairytales/fylist?num=30&key="
    key = apiKey
    while True:
        try:
            txUrl_id = txUrl + key + '&typeid=' + str(random_id) + '&page=' + str(random_page)
            r = post(txUrl_id, headers=headers)
            story_list = r.json()["result"]["list"]
            break
        except:
            random_page = random.randint(1, 30)
            time.sleep(1)
    random_story_list = random.choice(story_list)
    random_story_id = random_story_list['id']
    story_title = random_story_list['title']
    txUrl = 'https://apis.tianapi.com/fairytales/index?key='
    txUrl_story = txUrl + key + '&id=' + random_story_id
    r = post(txUrl_story, headers=headers)
    story_content = r.json()['result']['content']
    return story_title + '\n' + story_content.replace('&lsquo;', '"').replace('&rsquo;', '"').replace('&quot;', '"')


def get_GoodNight():
    week_list = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]
    story = get_stroy()
    year = localtime().tm_year
    month = localtime().tm_mon
    day = localtime().tm_mday
    today = datetime.date(datetime(year=year, month=month, day=day))
    week = week_list[(today.weekday() + 1) % 7]
    msgtosend = "夜深了，晚安🌙：\n今天的故事是：" + story + "\n🎆\n" + f"明天是{week}"
    return msgtosend