import requests
import json
import re
import tongyirenzheng
import mimetypes
class homework():
    def __init__(self, account, password):
        self.maxhomeworkSize = 13
        self.account = account
        self.password = password
        self.undone_id = 0
        self.assid_list = []
        self.classid_list = []
        self.resourcelist = []
        """
        resourcelist格式是列表，单项是
        {'chapter': '第一章到第十二章', 'res_name': '第十一章 专项技术攻防及治理.pdf', 'id': '1869305750272692226', 'classname': '网络空间安全治理'}
        只有每一课的第一个资源有课程名、只有每一章的第一个资源有章节名
        """
        self.rtoken = ''
        self.url = "https://apiucloud.bupt.edu.cn/ykt-basics/api/inform/news/list?newsCopyPersonId="
        self.headers = {
            "Accept": "application/json, text/plain, */*",
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
            "Authorization": "",
            "Blade-Auth": "",
            "Content-Length": "0",
            "Identity": "",
            "Origin": "https://ucloud.bupt.edu.cn",
            "Referer": "https://ucloud.bupt.edu.cn/",
            "Sec-Ch-Ua": "\"Chromium\";v=\"122\", \"Not(A:Brand\";v=\"24\", \"Microsoft Edge\";v=\"122\"",
            "Sec-Ch-Ua-Mobile": "?0",
            "Sec-Ch-Ua-Platform": "\"Windows\"",
            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Mode": "cors",
            "Sec-Fetch-Site": "same-site",
            "Tenant-Id": "",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 Edg/122.0.0.0"
        }
        self.data = {
                "siteId": '',
                "userId": '',
                "keyword": "",
                "current": 1,
                "size": self.maxhomeworkSize,
                "studentAssignmentStatus": None,
                "status": 0,
                "sortColumn": "",
                "sortType": None
        }
        self.params = {
                "userId": '',
                "size": str(self.maxhomeworkSize),
                "current": "1"
        }

    def get_ucloud_notify(self):
        try:
            if self.headers["Blade-Auth"] == "":
                listofblade = tongyirenzheng.get_co_and_sa(self.account,self.password)
                self.headers["Tenant-Id"] = listofblade[0]
                self.headers["Authorization"] = listofblade[1]
                self.headers["Blade-Auth"] = listofblade[2]
                self.headers["identity"] = listofblade[4]
                self.data['userId'] = listofblade[3]
                self.params['userId'] = listofblade[3]
                self.rtoken = listofblade[5]

            else:
                listofblade = tongyirenzheng.post_refresh(self.rtoken,self.headers["Tenant-Id"],self.headers["Authorization"],self.account,self.password)
                self.headers["Tenant-Id"] = listofblade[0]
                self.headers["Authorization"] = listofblade[1]
                self.headers["Blade-Auth"] = listofblade[2]
                self.headers["identity"] = listofblade[4]
                self.data['userId'] = listofblade[3]
                self.params['userId'] = listofblade[3]
            news_url = self.url + self.data['userId'] + '&current=1&size=5'
            response = requests.post(news_url, headers=self.headers)
            #print(response.status_code)
    #        print(response.json())  # 如果响应是 JSON 格式，你可以使用 .json() 方法获取响应内容
            response_data = json.loads(response.text)
            records = response_data['data']['records']
            record_texts = []
            readid_str = ''
            result = ''
            for record in records:
                if record['isRead'] == 0:
                    news_title = record['newsTitle']
                    newsCopyTime = record['newsCopyTime']
                    news_info = re.sub(r'<span>(.*?)</span>', '', record['newsInfo'])
                    span_content = re.findall(r'<span>(.*?)</span>', record['newsInfo'])
                    readid_str += record['id'] + ','
                    if span_content:
                        news_info += '《'+' '.join(span_content) + '》'
                    record_texts.append(f"{news_title}：{news_info} {newsCopyTime}")
                    result = '\n'.join(record_texts)
            if (readid_str != ''):
                readdata = {
                    "ids" : readid_str,
                }
                response = requests.post("https://apiucloud.bupt.edu.cn/ykt-basics/api/inform/news/readNews?", headers=self.headers,data=readdata)
                print(response.json())
            return result
        except Exception as e:
            print("An error occurred:", e)
            return ''

    def check_assignment(self,siteid):
        self.data['siteId']=siteid
        url_assi = "https://apiucloud.bupt.edu.cn/ykt-site/work/student/list"
        response = requests.post(url_assi, headers=self.headers, json=self.data)
        if response.status_code == 200:
            all_assignments = response.json().get('data', {}).get('records', [])
            assi_list = []
            submitted_list = []
            for assi in all_assignments:
                if assi.get('status') == 2 and assi.get('assignmentStatus') == 99:
                    assi_list.append(assi)
                elif assi.get('status') == 2 and assi.get('assignmentStatus') != 99:
                    submitted_list.append(assi)
            #print([assi_list,submitted_list])
            return [assi_list,submitted_list]

        else:
            return None

    def check_assignment_scored(self, siteid):
        self.data['siteId']=siteid
        data_new = self.data
        data_new['size'] = 50
        url_assi = "https://apiucloud.bupt.edu.cn/ykt-site/work/student/list"
        response = requests.post(url_assi, headers=self.headers, json=data_new)
        if response.status_code == 200:
            all_assignments = response.json().get('data', {}).get('records', [])
            assi_list = []
            for assi in all_assignments:
                if assi.get('status') == 3 and assi.get('assignmentStatus') == 1:
                    assi_list.append(assi)
            return assi_list

        else:
            return None

    def get_class_id(self):
        urlclass = "https://apiucloud.bupt.edu.cn/ykt-site/site/list/student/history"
        self.get_ucloud_notify()
        response = requests.get(urlclass, params=self.params, headers=self.headers)
        idi = 1
        class_str = ''
        if response.status_code == 200:
            resdata = response.json()
            self.classid_list = []
            records = resdata.get('data', {}).get('records', [])
            for record in records:
                cname = record.get('siteName')
                class_str += '序号：' + str(idi) + ' 课程：' + cname + '\n'
                self.classid_list.append([cname, record.get('id')])
                idi += 1
        return class_str

    def get_class_res_url(self, res_num,full_res = False):
        if not self.class_res_list:
            return []
        if (res_num <= 0 or (res_num - 1) >= len(self.class_res_list)) and not full_res:
            return []
        if full_res:
            res_url_list = []
            for single_res in self.class_res_list:
                res_url_list.append([single_res[0], self.get_file_url(single_res[1])])
            return res_url_list
        return [self.class_res_list[res_num-1][0], self.get_file_url(self.class_res_list[res_num-1][1])]

    def get_all_assiscore(self):
        result = ""
        if not self.classid_list:
            self.get_class_id()
            """        if num <= 0 or (num - 1) >= len(self.classid_list):
            return '输入的数字不合法或者超出了序号。'"""
        for num in range(len(self.classid_list)):
            cid = self.classid_list[num-1][1]
            cname = self.classid_list[num-1][0]
            score_str = cname+'的所有作业得分：\n'
            scored_list = self.check_assignment_scored(cid)
            total_score = 0
            count = 0
            for single_socored_assi in scored_list:
                title = single_socored_assi.get('assignmentTitle')
                score = self.get_score_detail(single_socored_assi.get('id'))
                score_str += title + ' ' + str(score) + '分\n'
                total_score += score
                count+=1
            if count != 0:
                score_str += '平均分：' + str(f"{total_score/count:.2f}\n")
                result += score_str
            else:
                result += cname + '还没有已打分的作业噢\n'
        return result

    def update_all_resources(self):
        if not self.classid_list:
            self.get_class_id()
        #if num <= 0 or (num - 1) >= len(self.classid_list):
        #    return '输入的数字不合法或者超出了序号。'
        result = []
        for num in range(len(self.classid_list)):
            resurl = 'https://apiucloud.bupt.edu.cn/ykt-site/site-resource/tree/student'
            resparam = {
                'siteId' : self.classid_list[num-1][1],
                'userId' : self.data['userId']
            }
            class_res_response = requests.post(resurl,headers = self.headers, params= resparam)
            chapter_list = class_res_response.json().get('data')
            #self.class_res_list = []
            idi = 1
            res_str = ''
            for chapter in chapter_list:
                charpter_name = chapter.get('resourceName')
                res_str += charpter_name + '：\n'
                charpter_res_list = chapter.get('attachmentVOs')
                resi = 1
                for single_res in charpter_res_list:
                    res_name = single_res.get('resource').get('name')
                    res_dict = {
                        'res_name' : res_name,
                        'id': single_res.get('resource').get('id')
                    }
                    if idi == 1:
                        res_dict['classname'] = self.classid_list[num-1][0]
                    if resi == 1:
                        res_dict['chapter'] = charpter_name
                    result.append(res_dict)
                    #res_str += '序号：' + str(idi) + ' 资源名：' + ' ' + res_name +'\n'
                    #self.class_res_list.append([res_name,single_res.get('resource').get('id')])
                    idi += 1
                    resi+=1
            #return self.classid_list[num-1][0]+(' 这门课程还没发布过任何教学资源' if res_str == '' else '\n' + res_str)
        self.resourcelist = result
    def get_updated_resources(self):
        return self.resourcelist
    
    def get_all_undone(self):
        urlundone = "https://apiucloud.bupt.edu.cn/ykt-site/site/list/student/history"
        self.get_ucloud_notify()
        response = requests.get(urlundone, params=self.params, headers=self.headers)
        data = response.json()
        #print(data)
        assignments_str = ''
        submitted_str = ''
        You_Meizuo = False
        You_Meijiezhi = False
        if response.status_code == 200:
            self.assid_list = []
            self.classid_list = []
            records = data.get('data', {}).get('records', [])
            idi = 1
            for record in records:
                #print("ID:", record.get('id'))
                print("Site Name:", record.get('siteName'))
                self.classid_list.append([record.get('siteName'), record.get('id')])
                assi_list = self.check_assignment(record.get('id'))
                if assi_list[0]:
                    You_Meizuo = True
                    assignments_str += '🔮' + record.get('siteName') + ' 的作业：\n'
                    for assi in assi_list[0]:
                        self.assid_list.append([record.get('siteName'),assi.get('id')])
                        assignments_str += f"序号{idi} 章节：{assi.get('chapterName')} {assi.get('assignmentTitle')} 截止日期：{assi.get('assignmentEndTime')}\n"
                        idi += 1
            self.undone_id = idi-1
            for record in records:
                assi_list = self.check_assignment(record.get('id'))
                if assi_list[1]:
                    You_Meijiezhi = True
                    submitted_str += '🪄' + record.get('siteName') + ' 的作业：\n'
                    for assi in assi_list[1]:
                        self.assid_list.append([record.get('siteName'),assi.get('id')])
                        submitted_str +=f"序号{idi} 章节：{assi.get('chapterName')} {assi.get('assignmentTitle')} 截止日期：{assi.get('assignmentEndTime')}\n"
                        idi += 1
            if not You_Meizuo and not You_Meijiezhi:
                return '没有没做的作业，也没有交了但没截止的作业了'
            elif not You_Meizuo and You_Meijiezhi:
                return '作业都交了\n💕💕有已经提交但是还没截止的作业：\n' + submitted_str
            elif not You_Meijiezhi and You_Meizuo:
                return '🚩🚩有没做的作业：\n' + assignments_str + '交了的全都截止了'
            return '🚩🚩有没做的作业：\n' + assignments_str + '💕💕有已经提交但是还没截止的作业：\n' + submitted_str

    def remove_html_tag(self, str1):
        pattern = r"<.*?>"  # 匹配任意内容在<>内的正则表达式
        result = re.sub(pattern, "", str1)  # 使用sub函数替换匹配到的内容为空字符串
        return result

    def get_submit_detail(self,assid):
        submitcheck_url = 'https://apiucloud.bupt.edu.cn/ykt-site/work/submit-view?'
        submitcheck_p = {
            "assignmentId": assid
        }
        scheck_response = requests.get(submitcheck_url, headers=self.headers, params=submitcheck_p)
        att_list = scheck_response.json().get('data').get('attachmentIds')
        comment = scheck_response.json().get('data').get('assignmentComment')
        content = scheck_response.json().get('data').get('assignmentContent')
        att_name_url = 'https://apiucloud.bupt.edu.cn/blade-source/resource/list/byId?'
        all_att_name_list = []
        rpara = {
            "resourceIds": ','.join(att_list)
        }
        attresponse = requests.get(att_name_url, headers=self.headers, params=rpara)
        att_datalist = attresponse.json().get('data')
        for single_att_in_l in att_datalist:
            all_att_name_list.append(single_att_in_l.get('name'))
        att_url_list=[]
        for satt in att_list:
            att_url_list.append(get_file_url(satt))
        return [comment,content,all_att_name_list,att_url_list]

    def get_score_detail(self, assid):
        submitcheck_url = 'https://apiucloud.bupt.edu.cn/ykt-site/work/submit-view?'
        submitcheck_p = {
            "assignmentId": assid
        }
        scheck_response = requests.get(submitcheck_url, headers=self.headers, params=submitcheck_p)
        score = scheck_response.json().get('data').get('assignmentScore')

        return score

    def get_file_url(self, resource_id):
        check_resource_url = "https://apiucloud.bupt.edu.cn/blade-source/resource/filePath"
        resource_params = {
            "resourceId":resource_id
        }
        re_response = requests.get(check_resource_url, headers=self.headers, params=resource_params)
        return re_response.json().get('data')

    def get_a_detail(self,idn):
        self.get_ucloud_notify()
        if (idn - 1) >= len(self.assid_list) or (idn - 1) < 0:
            print("不存在")
            none_list = ["没有这个序号的作业噢 发送 作业 给我重新看一下吧"]
            return none_list
        assid = self.assid_list[idn-1]
        #print(assid)
        d_url = "https://apiucloud.bupt.edu.cn/ykt-site/work/detail"
        d_params = {
            "assignmentId": assid[1]
        }
        d_response = requests.get(d_url, headers=self.headers, params=d_params)
        #print(d_response.json())
        d_json = d_response.json().get('data')
        if d_response.status_code == 200:
            detail = assid[0] +'：'+ d_json.get('assignmentTitle') + '\n详细信息：' + remove_html_tag(d_json.get('assignmentContent'))
            resources = d_json.get('assignmentResource')
            return_list = [detail]
            resources_up_list = []
            for sigle_resource in resources:
                resource_list = []
                resource_id = sigle_resource.get('resourceId')
                resource_name = sigle_resource.get('resourceName')
                resource_url = get_file_url(resource_id)
                resource_list = [resource_id,resource_name,resource_url]
                resources_up_list.append(resource_list)
            return_list.append(resources_up_list)
            if idn > self.undone_id:
                detail = '这是一个已经提交的作业\n'+detail
                att_name_list = get_submit_detail(assid[1])
                if att_name_list[0] != '':
                    detail += '\n作业评语：' + att_name_list[0]
                if att_name_list[1] != '':
                    detail += '\n作业内容：' + att_name_list[1]
                detail += '\n您已上传的附件列表：\n'
                for single_att_name in att_name_list[2]:
                    detail += single_att_name + '\n'
                return_list[0] = detail
                return_list.append(att_name_list[2])
                return_list.append(att_name_list[3])
            return return_list
        return None

    def upload_file(self,idn,comment,filenames,binaryarrs):
        self.get_ucloud_notify()
        if (idn - 1) >= len(self.assid_list):
            print("不存在")
            none_list = ["没有这个序号的作业噢 发送 作业 给我重新看一下吧"]
            return none_list
        assid = self.assid_list[idn-1][1]
        url_upload = 'https://apiucloud.bupt.edu.cn/blade-source/resource/upload/biz'
        i=0
        attach_ids = []
        for filename in filenames:
            binaryarr=binaryarrs[i]
            files = {
                'file': (filename, binaryarr, mimetypes.guess_type(filename)),
                'userId': (None, self.data['userId']),
                'bizType': (None, '3')
            }
            i+=1
            f_response = requests.post(url_upload, headers=self.headers, files=files)
            #print(f_response.json())
            attach_ids.append(f_response.json().get('data'))
        submit_data = {
            "assignmentContent": comment,
            "assignmentId": assid,
            "assignmentType": 0,
            "attachmentIds": attach_ids,
            "commitId": "",
            "groupId": "",
            "userId": self.data['userId']
        }
        #print(submit_data)
        sub_response = requests.post('https://apiucloud.bupt.edu.cn/ykt-site/work/submit', headers=self.headers , json=submit_data)
        #print(sub_response.json())

"""
myHomework = homework(account='', password='')
print(myHomework.get_all_resources())
print(myHomework.get_ucloud_notify())
print(myHomework.get_all_undone())
print(myHomework.assid_list)
print(myHomework.classid_list)
print(myHomework.class_res_list)
"""