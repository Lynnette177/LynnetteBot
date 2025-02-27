import Foundation
struct ConversationMessage: Codable{
    var id : UUID
    var user : Int = 0 //0表示用户的消息
    var content : String = ""
}

struct NotificationMessage : Codable{
    var id : UUID
    var urgent : Int      //紧迫等级 0 1 2
    var title : String = "" // 标题
    var content : String = "" //内容
    var genTime : Date
}

struct RobotFunction: Codable{
    var id : UUID
    var executable : Bool
    var title : String = ""     //功能标题
    var content : String = ""   //功能描述
    var method : String = ""    //POST API的时候需要的字段
}

struct CloudFile:Codable{
    var id: UUID
    var fileName: String
    var fileID: String
    var ClassName: String = ""
    var ChapterName: String = ""
}
