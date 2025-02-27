//
//  serverapi.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/15.
//
import SwiftUI

func init_serverInfo(errorMessage:Binding<String>, showErrorAlert:Binding<Bool>)->Void{
    /*获取服务器信息，包括功能(task)和服务器名称*/
    let postData: [String: Any] = [
        "userId": GlobalConfig.shared.userId
    ]
    postRequest(url: GlobalConfig.shared.apiBaseURL + GlobalConstant.URL_init, body: postData) { result in
        switch result {
        case .success(let response):
            NSLog("响应数据: \(response)")
            if response["status"] as? Int != 1{
                NSLog("服务器回复错误: \(String(describing: response["message"] as? String))")
                // 更新错误消息和弹窗状态
                errorMessage.wrappedValue = response["message"] as? String ?? ""
                showErrorAlert.wrappedValue = true
            }
            else{
                DispatchQueue.main.async {
                    GlobalConfig.shared.servername = response["servername"] as? String ?? "未命名服务器"
                }
                let functions_array = response["tasks"] as? NSArray ?? []
                var tmpFunctions : [RobotFunction] = []
                for item in functions_array {
                    if let task = item as? [String: Any] {
                        let url = task["url"] as? String ?? ""
                        let title = task["title"] as? String ?? ""
                        let content = task["content"] as? String ?? ""
                        let executable = task["executable"] as? Bool ?? false
                        let newFunction = RobotFunction(id: UUID(), executable: executable,title: title,content: content,method: url)
                        tmpFunctions.append(newFunction)
                    }
                }
                DispatchQueue.main.async {
                    GlobalData.shared.global_Functions = tmpFunctions
                }
            }
        case .failure(let error):
            NSLog("请求失败: \(error.localizedDescription)")
            // 更新错误消息和弹窗状态
            errorMessage.wrappedValue = error.localizedDescription
            showErrorAlert.wrappedValue = true
        }
    }
}

func get_notifications(errorMessage:Binding<String>, showErrorAlert:Binding<Bool>)->Void{
    /*获取服务器信息，包括功能(task)和服务器名称*/
    let postData: [String: Any] = [
        "userId": GlobalConfig.shared.userId
    ]
    postRequest(url: GlobalConfig.shared.apiBaseURL + GlobalConstant.URL_get_notification, body: postData) { result in
        switch result {
        case .success(let response):
            NSLog("响应数据: \(response)")
            if response["status"] as? Int != 1{
                NSLog("服务器回复错误: \(String(describing: response["message"] as? String))")
                // 更新错误消息和弹窗状态
                errorMessage.wrappedValue = response["message"] as? String ?? ""
                showErrorAlert.wrappedValue = true
            }
            else{
                NSLog(response["notifications"] as? String ?? "")
                let functions_array = response["notifications"] as? NSArray ?? []
                var tmpNotifications = GlobalData.shared.global_Notifications
                for item in functions_array {
                    if let noti = item as? [String: Any] {
                        let urgent = noti["urgent"] as? Int ?? 0
                        let title = noti["title"] as? String ?? ""
                        let content = noti["content"] as? String ?? ""
                        let time = noti["time"] as? Double
                        let Date_time = Date(timeIntervalSince1970: time ?? 0)
                        let newNotify = NotificationMessage(id: UUID(), urgent: urgent, title: title, content: content, genTime: Date_time)
                        tmpNotifications.append(newNotify)
                    }
                }
                DispatchQueue.main.async {
                    GlobalData.shared.global_Notifications = tmpNotifications
                }
                delete_notifications(errorMessage: errorMessage, showErrorAlert: showErrorAlert)
            }
        case .failure(let error):
            NSLog("请求失败: \(error.localizedDescription)")
            // 更新错误消息和弹窗状态
            errorMessage.wrappedValue = error.localizedDescription
            showErrorAlert.wrappedValue = true
        }
    }
}
func delete_notifications(errorMessage:Binding<String>, showErrorAlert:Binding<Bool>)->Void{
    /*获取服务器信息，包括功能(task)和服务器名称*/
    let postData: [String: Any] = [
        "userId": GlobalConfig.shared.userId
    ]
    postRequest(url: GlobalConfig.shared.apiBaseURL + GlobalConstant.URL_delete_notification, body: postData) { result in
        switch result {
        case .success(let response):
            NSLog("响应数据: \(response)")
            if response["status"] as? Int != 1{
                NSLog("服务器回复错误: \(String(describing: response["message"] as? String))")
                // 更新错误消息和弹窗状态
                errorMessage.wrappedValue = response["message"] as? String ?? ""
                showErrorAlert.wrappedValue = true
            }
            else{
                //删除成功
            }
        case .failure(let error):
            NSLog("请求失败: \(error.localizedDescription)")
            // 更新错误消息和弹窗状态
            errorMessage.wrappedValue = error.localizedDescription
            showErrorAlert.wrappedValue = true
        }
    }
}

func executeTask(uuid: UUID,errorMessage:Binding<String>, showErrorAlert:Binding<Bool>, method: String,isExecuting: Binding<[UUID: Bool]>)->Void{
    /*获取服务器信息，包括功能(task)和服务器名称*/
    let postData: [String: Any] = [
        "userId": GlobalConfig.shared.userId,
        "method": method
    ]
    postRequest(url: GlobalConfig.shared.apiBaseURL + GlobalConstant.URL_execute_task, body: postData,timeout: 100) { result in
        switch result {
        case .success(let response):
            NSLog("响应数据: \(response)")
            if response["status"] as? Int != 1{
                NSLog("服务器回复错误: \(String(describing: response["message"] as? String))")
                // 更新错误消息和弹窗状态
                errorMessage.wrappedValue = response["message"] as? String ?? ""
                showErrorAlert.wrappedValue = true
            }
            else{
                //请求成功
                get_notifications(errorMessage: errorMessage, showErrorAlert: showErrorAlert)
            }
        case .failure(let error):
            NSLog("请求失败: \(error.localizedDescription)")
            // 更新错误消息和弹窗状态
            errorMessage.wrappedValue = error.localizedDescription
            showErrorAlert.wrappedValue = true
        }
        isExecuting.wrappedValue[uuid] = false
    }
}


func postChat(errorMessage:Binding<String>, showErrorAlert:Binding<Bool>, method: String,isThinking: Binding<Bool>,history:Binding<[ConversationMessage]>, usermsg:String, mode:Int)->Void{
    /*获取服务器信息，包括功能(task)和服务器名称*/
    isThinking.wrappedValue = true
    let historyArray = history.wrappedValue.map { message -> [String: Any] in
        return [
            "id": message.id.uuidString, // 将 UUID 转换为字符串
            "user": message.user,
            "content": message.content
        ]
    }
    
    let postData: [String: Any] = [
        "userId": GlobalConfig.shared.userId,
        "method": method,
        "history": historyArray,
        "mode":mode,
        "usermsg": usermsg
    ]
    history.wrappedValue.append(ConversationMessage(id: UUID(),user: 1, content: usermsg))
    postRequest(url: GlobalConfig.shared.apiBaseURL + GlobalConstant.URL_execute_task, body: postData,timeout: 100) { result in
        switch result {
        case .success(let response):
            NSLog("响应数据: \(response)")
            if response["status"] as? Int != 1{
                NSLog("服务器回复错误: \(String(describing: response["message"] as? String))")
                // 更新错误消息和弹窗状态
                errorMessage.wrappedValue = response["message"] as? String ?? ""
                showErrorAlert.wrappedValue = true
            }
            else{
                if let repStr = response["Bot"] as? String {
                    DispatchQueue.main.async {
                        history.wrappedValue.append(ConversationMessage(id:UUID(),user: 0, content: repStr))
                    }
                }
            }
        case .failure(let error):
            NSLog("请求失败: \(error.localizedDescription)")
            // 更新错误消息和弹窗状态
            errorMessage.wrappedValue = error.localizedDescription
            showErrorAlert.wrappedValue = true
        }
        isThinking.wrappedValue = false
    }
}

func postforImage(errorMessage:Binding<String>, showErrorAlert:Binding<Bool>, imageUrl:Binding<String>,method: String,isThinking: Binding<Bool>,usermsg:String, mode:Int)->Void{
    /*获取服务器信息，包括功能(task)和服务器名称*/
    isThinking.wrappedValue = true
    
    let postData: [String: Any] = [
        "userId": GlobalConfig.shared.userId,
        "method": method,
        "mode":mode,
        "usermsg": usermsg
    ]
    postRequest(url: GlobalConfig.shared.apiBaseURL + GlobalConstant.URL_execute_task, body: postData,timeout: 100) { result in
        switch result {
        case .success(let response):
            NSLog("响应数据: \(response)")
            if response["status"] as? Int != 1{
                NSLog("服务器回复错误: \(String(describing: response["message"] as? String))")
                // 更新错误消息和弹窗状态
                errorMessage.wrappedValue = response["message"] as? String ?? ""
                showErrorAlert.wrappedValue = true
            }
            else{
                if let repStr = response["imageUrl"] as? String {
                    DispatchQueue.main.async {
                        imageUrl.wrappedValue = repStr
                    }
                }
            }
        case .failure(let error):
            NSLog("请求失败: \(error.localizedDescription)")
            // 更新错误消息和弹窗状态
            errorMessage.wrappedValue = error.localizedDescription
            showErrorAlert.wrappedValue = true
        }
        isThinking.wrappedValue = false
    }
}

func postforRecognizeImage(errorMessage:Binding<String>, showErrorAlert:Binding<Bool>, method: String,isThinking: Binding<Bool>,usermsg:String, mode:Int,imageData:Data, botmsg:Binding<String>)->Void{
    /*获取服务器信息，包括功能(task)和服务器名称*/
    isThinking.wrappedValue = true
    
    let postData: [String: Any] = [
        "userId": GlobalConfig.shared.userId,
        "method": method,
        "mode":mode,
        "usermsg": usermsg
    ]
    postRequestWithJSONAndFile(url: GlobalConfig.shared.apiBaseURL + GlobalConstant.URL_execute_task, jsonBody: postData,fileData:imageData, fileName: "pic.jpg", timeout: 100) { result in
        switch result {
        case .success(let response):
            NSLog("响应数据: \(response)")
            if response["status"] as? Int != 1{
                NSLog("服务器回复错误: \(String(describing: response["message"] as? String))")
                // 更新错误消息和弹窗状态
                errorMessage.wrappedValue = response["message"] as? String ?? ""
                showErrorAlert.wrappedValue = true
            }
            else{
                if let repStr = response["bot"] as? String {
                    DispatchQueue.main.async {
                        botmsg.wrappedValue = repStr
                    }
                }
            }
        case .failure(let error):
            NSLog("请求失败: \(error.localizedDescription)")
            // 更新错误消息和弹窗状态
            errorMessage.wrappedValue = error.localizedDescription
            showErrorAlert.wrappedValue = true
        }
        isThinking.wrappedValue = false
    }
}



func postget_all_files(errorMessage:Binding<String>, showErrorAlert:Binding<Bool>, method: String,refresh: Bool)->Void{
    /*获取服务器信息，包括功能(task)和服务器名称*/
    let postData: [String: Any] = [
        "userId": GlobalConfig.shared.userId,
        "method": method,
        "refresh": refresh
    ]
    postRequest(url: GlobalConfig.shared.apiBaseURL + GlobalConstant.URL_execute_task, body: postData) { result in
        switch result {
        case .success(let response):
            NSLog("响应数据: \(response)")
            if response["status"] as? Int != 1{
                NSLog("服务器回复错误: \(String(describing: response["message"] as? String))")
                // 更新错误消息和弹窗状态
                errorMessage.wrappedValue = response["message"] as? String ?? ""
                showErrorAlert.wrappedValue = true
            }
            else{
                let cloudfile_array = response["cloudfiles"] as? NSArray ?? []
                var tmp_gfiles : [CloudFile] = []
                for item in cloudfile_array {
                    if let noti = item as? [String: Any] {
                        let filename = noti["res_name"] as? String ?? ""
                        let fileID = noti["id"] as? String ?? ""
                        let classname = noti["classname"] as? String ?? ""
                        let chaptername = noti["chapter"] as? String ?? ""
                        let newFile = CloudFile(id:UUID(),fileName: filename, fileID: fileID,ClassName: classname,ChapterName: chaptername)
                        tmp_gfiles.append(newFile)
                    }
                }
                DispatchQueue.main.async {
                    GlobalData.shared.global_cloudfiles = tmp_gfiles
                }
            }
        case .failure(let error):
            NSLog("请求失败: \(error.localizedDescription)")
            // 更新错误消息和弹窗状态
            errorMessage.wrappedValue = error.localizedDescription
            showErrorAlert.wrappedValue = true
        }
    }
}


func post_getfileurl_openin_safari(errorMessage:Binding<String>, showErrorAlert:Binding<Bool>, method: String,fileid:String)->Void{
    /*获取服务器信息，包括功能(task)和服务器名称*/
    let postData: [String: Any] = [
        "userId": GlobalConfig.shared.userId,
        "method": method,
        "fileid": fileid
    ]
    postRequest(url: GlobalConfig.shared.apiBaseURL + GlobalConstant.URL_execute_task, body: postData) { result in
        switch result {
        case .success(let response):
            NSLog("响应数据: \(response)")
            if response["status"] as? Int != 1{
                NSLog("服务器回复错误: \(String(describing: response["message"] as? String))")
                // 更新错误消息和弹窗状态
                errorMessage.wrappedValue = response["message"] as? String ?? ""
                showErrorAlert.wrappedValue = true
            }
            else{
                if let fileurl = response["fileurl"] as? String {
                    if let url = URL(string: fileurl) {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } 
                    }
                }
            }
        case .failure(let error):
            NSLog("请求失败: \(error.localizedDescription)")
            // 更新错误消息和弹窗状态
            errorMessage.wrappedValue = error.localizedDescription
            showErrorAlert.wrappedValue = true
        }
    }
}
