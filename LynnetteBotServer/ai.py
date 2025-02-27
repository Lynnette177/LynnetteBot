from openai import OpenAI
import httpx
import json
import requests
import base64
api_key=""
client = OpenAI(
    base_url="https://api.xty.app/v1",
    api_key="",
)

def askai(history, usermsg, mode):
    chat_history = [{"role": "system", "content": "你是一个有用的AI助理，用中文给出简短且精确的回答。"}]
    for h in history:
        if h.get('user') == 1:
            chat_history.append({"role": "user", "content": h.get('content')})
        else:
            chat_history.append({"role": "assistant", "content": h.get('content')})
    chat_history.append({"role": "user", "content": usermsg})
    completion = client.chat.completions.create(
      model = "gpt-4o" if mode else "gpt-4o-mini",
      messages=chat_history
    )
    data = json.loads(completion.model_dump_json())
    message = data['choices'][0]['message']['content'] + "\nUsage:" + str(data['usage']['completion_tokens']) + "/" + str(data['usage']['total_tokens'])
    return message



def draw_pic(msg):
    response = client.images.generate(
      model="dall-e-3",
      prompt=msg,
      size="1024x1024",
      quality="standard",
      n=1,
    )
    image_url = response.data[0].url
    return image_url

def vision_pic(btarr):
    base64_image = base64.b64encode(btarr).decode('utf-8')
    headers = {
      "Content-Type": "application/json",
      "Authorization": f"Bearer {api_key}"
    }
    payload = {
      "model": "gpt-4o",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "用中文告诉我，这张图片的内容是什么？"
            },
            {
              "type": "image_url",
              "image_url": {
                "url": f"data:image/jpeg;base64,{base64_image}"
              }
            }
          ]
        }
      ],
      "max_tokens": 300
    }
    response = requests.post("https://oneapi.xty.app/v1/chat/completions", headers=headers, json=payload)
    return response.json().get('choices')[0].get('message').get('content')


def get_quota():
    quota_url = 'https://cxapi.xty.app/log/getBalance'
    params = {
        "rows": 10,
        "page": 1,
        "apiKey": ''
    }
    res = requests.get(quota_url, params = params)
    res_j = res.json()
    content = res_j.get('content')
    user_quota = content.get('used_quota')
    remain_quota = content.get('remain_quota')
    balance_re = remain_quota * 2 /1000000
    balance_used = user_quota * 2 /1000000
    total_ba = balance_used + balance_re
    return '总金额：$' + str(total_ba) + '\n已经使用：$' + str(balance_used) + '\n剩余金额：$' + str(balance_re)