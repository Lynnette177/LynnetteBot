import requests
import json
import time


def parse_tips(data):
    results = []
    # 定义需要的指标名
    indicators = [
        'lk', 'cl', 'gj', 'pl', 'co', 'pj', 'hc', 'gl', 'uv',
        'wc', 'ct', 'pk', 'ac', 'dy', 'ls', 'gm', 'xc', 'tr',
        'nl', 'xq', 'yh', 'yd', 'ag', 'mf', 'ys', 'fs', 'pp',
        'zs', 'jt', 'gz'
    ]
    for ind in indicators:
        name = f"{ind}_name"
        hint = f"{ind}_hint"
        des_s = f"{ind}_des_s"
        if name in data:
            result = f"{data[name]}：{data[hint]}\n    {data[des_s].strip('。')}"
            results.append(result + '\n')
    output = ''.join(results)
    return output


def get_weather(province_id_in = '10112', area_id_in = '05', county_id_in = '05'):
    try:
        weather_out = ""
        weather = ""
        timestamp = int(time.time())
        url = "http://d1.weather.com.cn/dingzhi/"
        url_realtime_weather = "http://d1.weather.com.cn/sk_2d/"
        url_tips = "https://d1.weather.com.cn/weather_index/"
        city_id = province_id_in + county_id_in + area_id_in
        # Connect order should be province_id + county_id + area_id
        url += city_id + ".html?_=" + str(timestamp * 1000 - 28800000)
        url_realtime_weather += city_id + ".html?_=" + str(timestamp * 1000 - 28800000)
        url_tips += city_id + ".html?_=" + str(timestamp * 1000 - 28800000)

        refer_url = "http://www.weather.com.cn" # /weather1d/" + city_id + ".shtml"
        #headers = {"Referer": refer_url}
        #print(headers)
        #print(url)
        headers={
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate, br',
            'Accept-Language': 'zh-CN,zh-Hans;q=0.9',
            'Connection': 'keep-alive',
            'Host': 'd1.weather.com.cn',
            'Referer': 'http://m.weather.com.cn/',
            'Sec-Fetch-Dest': 'script',
            'Sec-Fetch-Mode': 'no-cors',
            'Sec-Fetch-Site': 'cross-site',
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15',
        }
        response = requests.get(url, headers=headers)
        response.encoding = 'utf-8'
        response_realtime = requests.get(url_realtime_weather, headers=headers)
        response_realtime.encoding = 'utf-8'
        response_tip = requests.get(url_tips, headers=headers)
        response_tip.encoding = 'utf-8'

        if response.status_code == 200 and response_realtime.status_code == 200 and response_tip.status_code == 200:
            responseBody = response.text
            #print(responseBody)
            startIndex = responseBody.find('{')
            endIndex = responseBody.find("};", startIndex)
            weatherJson = responseBody[startIndex:endIndex + 1]
            doc_realtime = json.loads(weatherJson)

            max_temperature = doc_realtime["weatherinfo"]["temp"]
            lowest_temperature = doc_realtime["weatherinfo"]["tempn"]
            the_weather = doc_realtime["weatherinfo"]["weather"]
            cityname_str = doc_realtime["weatherinfo"]["cityname"]

            responseBody_realtime = response_realtime.text
            startIndex_realtime = responseBody_realtime.find('{')
            endIndex_realtime = responseBody_realtime.find('}')
            realTimeJson = responseBody_realtime[startIndex_realtime:endIndex_realtime + 1]
            doc_realtime = json.loads(realTimeJson)

            responseBody_tip = response_tip.text
            startIndex_tip = responseBody_tip.find('var dataZS ={')
            endIndex_tip = responseBody_tip.find('};',startIndex_tip)
            TipJson = responseBody_tip[startIndex_tip+12:endIndex_tip + 1]
            doc_tip = json.loads(TipJson)
            all_tip = doc_tip.get('zs')
            tips_str = parse_tips(all_tip)


            now_temperature = doc_realtime["temp"] + "℃"
            now_weather = doc_realtime["weather"]
            wind = doc_realtime["WD"]
            wind_speed = doc_realtime["wse"]
            wind_level = doc_realtime["WS"]
            wind_speed = wind_speed.split('\\')[0] + "(" + wind_level + ")"
            update_time = doc_realtime["time"]
            rain_possibility = doc_realtime["rain"]
            rain_in_24hour = doc_realtime["rain24h"]
            aqi = doc_realtime["aqi"]
            aqipm25 = doc_realtime["aqi_pm25"]
            limit_number = doc_realtime.get("limitnumber", "")
            humidity = doc_realtime["SD"]
            visibility = doc_realtime["njd"]
            atmospheric_pressure = doc_realtime["qy"]

            if limit_number:
                weather = "今日限行" + limit_number + "\n"
            weather = cityname_str + ":\n" + weather
            weather += "今日天气" + the_weather
            weather += "\n当前：" + now_weather
            weather += "\n当前温度" + now_temperature
            weather += "\n今日最高" + max_temperature
            weather += "\n今日最低" + lowest_temperature
            weather += "\n降雨概率：" + rain_possibility + "%\n24小时降雨概率：" + rain_in_24hour + "%"
            weather += "\n空气质量：" + aqi + "\nPM2.5：" + aqipm25
            weather += "\n湿度：" + humidity
            weather += "\n能见度：" + visibility
            weather += "\n风向：" + wind
            weather += "\n风速：" + wind_speed

            weather += tips_str

            weather += "\n更新时间：" + update_time

            weather_out = weather
            return True, weather_out
        else:
            return False, weather_out
    except Exception as e:
        return False, f"{e}"
