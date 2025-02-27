// GlobalManager.swift

import Foundation

struct GlobalConstant{
    static let URL_init = "/init"
    static let URL_get_notification = "/get_notification"
    static let URL_delete_notification = "/delete_notifications"
    static let URL_execute_task = "/execute_task"
}

class GlobalConfig : ObservableObject{
    static let shared = GlobalConfig()
    
    var userId: String {
        get {
            return UserDefaults.standard.string(forKey: "userId") ?? "USERID"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userId")
        }
    }
    
    var apiBaseURL: String {
        get {
            return UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://api.example.com"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "apiBaseURL")
        }
    }
    @Published var servername: String = ""
    private init() {}  // 防止外部初始化
}
var global_conversations: [ConversationMessage] {
    get {
        // 从 UserDefaults 获取数据
        if let data = UserDefaults.standard.data(forKey: "global_conversations"),
           let savedMessages = try? JSONDecoder().decode([ConversationMessage].self, from: data) {
            return savedMessages
        }
        return [] // 如果没有保存的消息，返回空数组
    }
    set {
        // 将数组编码为 Data，并保存到 UserDefaults
        if let encodedData = try? JSONEncoder().encode(newValue) {
            UserDefaults.standard.set(encodedData, forKey: "global_conversations")
        }
    }
}

let file1 = CloudFile(id: UUID(), fileName: "测试1", fileID: "12345", ClassName: "测试课程名称1",ChapterName: "测试章节名称1")
let file2 = CloudFile(id: UUID(), fileName: "测试2", fileID: "123456",ChapterName: "测试章节名称2")
let file3 = CloudFile(id: UUID(), fileName: "测试3", fileID: "123457", ClassName: "测试课程名称3",ChapterName: "测试章节名称3")
let file4 = CloudFile(id: UUID(), fileName: "测试4", fileID: "123458")

class GlobalData: ObservableObject {
    static let shared = GlobalData()
    @Published var imageUrl:String {
        didSet {
            // 当 imageUrl 改变时，将它存储到 UserDefaults
            UserDefaults.standard.set(imageUrl, forKey: "imageUrl")
        }
    }
    @Published var global_cloudfiles : [CloudFile] = []
    @Published var global_Functions: [RobotFunction] = []
    @Published var global_Notifications: [NotificationMessage] = []{
        didSet {
            // 当 global_Notifications 改变时，将它存储到 UserDefaults
            if let encoded = try? JSONEncoder().encode(global_Notifications) {
                UserDefaults.standard.set(encoded, forKey: "GNotification")
            }
        }
    }
    @Published var global_conversations: [ConversationMessage] = []{
        didSet {
            // 当 global_Notifications 改变时，将它存储到 UserDefaults
            if let encoded = try? JSONEncoder().encode(global_conversations) {
                UserDefaults.standard.set(encoded, forKey: "global_conversations")
            }
        }
    }
    private init() {
        // 初始化时，检查 UserDefaults 中是否已经保存了 global_Notifications
        if let savedData = UserDefaults.standard.data(forKey: "GNotification"),
           let decoded = try? JSONDecoder().decode([NotificationMessage].self, from: savedData) {
            global_Notifications = decoded
        }
        if let savedData = UserDefaults.standard.data(forKey: "global_conversations"),
           let decoded = try? JSONDecoder().decode([ConversationMessage].self, from: savedData) {
            global_conversations = decoded
        }
        if let savedImageUrl = UserDefaults.standard.string(forKey: "imageUrl") {
            imageUrl = savedImageUrl
        }else {
            imageUrl = "" // 默认值
        }
    }
}
