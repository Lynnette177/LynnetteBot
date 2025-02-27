//
//  ConversationPage.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/15.
//
import SwiftUI

struct ConversationView: View {
    
    @State private var aiMode:Int = 0
    @ObservedObject private var globalData = GlobalData.shared
    @StateObject private var globalConfig = GlobalConfig.shared
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isThinking: Bool = false
    
    let aiModeOptions = ["普通模式", "精准模式", "画图模式", "识图模式"]
    let aiModeIcons = ["message", "location.north.circle.fill", "paintbrush", "photo"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                HStack {
                    Text(globalConfig.servername)
                        .font(.system(size: 35, weight: .bold, design: .default)) // 设置大字体
                        .foregroundColor(Color.blue) // 字体颜色为蓝色
                        .shadow(color: .blue, radius: 10, x: 5, y: 5) // 添加阴影效果
                        .padding(10)
                    Spacer()
                    Picker("选择模式", selection: $aiMode) {
                        ForEach(0..<aiModeOptions.count, id: \.self) { index in
                            HStack{
                                Image(systemName: aiModeIcons[index]) // 图标
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text(aiModeOptions[index])
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // 可以选择不同样式
                    .cornerRadius(10)  // 设置按钮圆角
                    Button("清空内容"){
                        globalData.global_conversations.removeAll()
                    }
                    .frame(width: 80,height: 40)
                    .background(Color.red)  // 设置按钮背景颜色为黑色
                    .foregroundColor(.white)  // 设置按钮文字颜色为白色
                    .cornerRadius(10)  // 设置按钮圆角
                    .padding(.trailing)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // 让HStack的宽度最大并左对齐
                Divider()
                if aiMode == 0 || aiMode == 1{
                    aiAskView(globalData: globalData,geometry: geometry, isThinking:$isThinking, aiMode: $aiMode,showErrorAlert: $showErrorAlert,errorMessage: $errorMessage)
                }
                if aiMode == 2{
                    drawPictureView(globalData: globalData,geometry: geometry, isThinking:$isThinking, aiMode: $aiMode,showErrorAlert: $showErrorAlert,errorMessage: $errorMessage)
                }
                if aiMode == 3{
                    recognizePictureView(globalData: globalData, geometry: geometry, isThinking: $isThinking, aiMode: $aiMode, showErrorAlert: $showErrorAlert, errorMessage: $errorMessage)
                }
            }
        }
    }
}

struct aiAskView : View {
    @State private var ContentToSend = ""
    @State var containHeight: CGFloat = 0
    @ObservedObject var globalData:GlobalData
    var geometry: GeometryProxy
    @Binding var isThinking: Bool
    @Binding var aiMode : Int
    @Binding var showErrorAlert:Bool
    @Binding var errorMessage:String
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(globalData.global_conversations, id: \.id) { conversation in // 用唯一标识符来作为id
                    if conversation.user == 0 {
                        VStack(alignment: .leading, spacing: 0) {
                            TalkTail()
                                .fill(Color.blue)
                                .frame(width: 22, height: 12)
                                .padding(.leading, 22)
                            Text(conversation.content)
                                .padding(12)
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                                .cornerRadius(12, antialiased: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = conversation.content
                            }) {
                                Text("复制")
                                Image(systemName: "doc.on.clipboard")
                            }
                            Button(action: {
                                // 触发分享
                                shareContent(content:conversation.content)
                            }) {
                                Label("分享", systemImage: "square.and.arrow.up")
                            }
                        }
                    } else {
                        // 用户的消息，右侧气泡
                        VStack(alignment: .trailing, spacing: 0) {
                            TalkTail()
                                .fill(Color.green)
                                .frame(width: 22, height: 12)
                                .padding(.trailing, 22)
                            Text(conversation.content)
                                .padding(12)
                                .foregroundColor(Color.white)
                                .background(Color.green)
                                .cornerRadius(12, antialiased: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(10)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = conversation.content
                            }) {
                                Text("复制")
                                Image(systemName: "doc.on.clipboard")
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: geometry.size.height * 0.8)
            .onChange(of: globalData.global_conversations.count,{
                // 使用动画滚动到底部
                withAnimation {
                    if let lastConversation = globalData.global_conversations.last {
                        proxy.scrollTo(lastConversation.id, anchor: .bottom)
                    }
                }
            })
            .onAppear {
                // 初次加载时滚动到底部
                if let lastConversation = globalData.global_conversations.last {
                    proxy.scrollTo(lastConversation.id, anchor: .bottom)
                }
            }
        }
        Spacer()
        Divider()
        HStack{
            AutoSizingTF(hint: "对话内容", text: $ContentToSend, containerHeight: $containHeight, onEnd: {UIApplication
                .shared
                .sendAction(
                    #selector(
                        UIResponder.resignFirstResponder
                    ),
                    to: nil,
                    from: nil,
                    for: nil
                )}
            )
            .padding(.horizontal)
            .frame(width: 250, height: containHeight < 120 ? containHeight : 120)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 3)
            )
            .cornerRadius(10)
            .padding()
            Button(isThinking ? "思考中" : "发送") {
                if ContentToSend != "" && !isThinking {
                    postChat(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert, method: "chat", isThinking: $isThinking, history: $globalData.global_conversations, usermsg: ContentToSend,mode: aiMode)
                    ContentToSend = ""
                }
            }
            .frame(width: 100,height: 50)
            .background(isThinking ?  Color.gray : Color.black)  // 设置按钮背景颜色为黑色
            .foregroundColor(.white)  // 设置按钮文字颜色为白色
            .cornerRadius(10)  // 设置按钮圆角
            .padding(.leading)
        }
        .frame(maxWidth: .infinity)
        Divider()
            .padding(.bottom, 10)
    }
}


struct drawPictureView: View {
    @State private var ContentToSend = ""
    @State private var SentContent = ""
    @State var containHeight: CGFloat = 0
    @ObservedObject var globalData:GlobalData
    var geometry: GeometryProxy
    @Binding var isThinking: Bool
    @Binding var aiMode : Int
    @Binding var showErrorAlert:Bool
    @Binding var errorMessage:String
    var body: some View {
        Spacer()
        Group {
            if URL(string: globalData.imageUrl) != nil {
                // 使用自定义的 UIImageViewRepresentable
                URLImageView(url: URL(string: globalData.imageUrl)!, size: CGSize(width: 300, height: 300))
                            .cornerRadius(5)
                            .overlay{
                                Rectangle().stroke(Color.gray, lineWidth: 2)
                                    .cornerRadius(5)
                            }
                            .padding()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.4)) // 占位符的背景颜色
                    .frame(width: 300, height: 300)
                    .overlay(
                        VStack{
                            if isThinking{
                                ProgressView()
                                Text("画图中...")
                                    .foregroundColor(.black)
                            }
                            else {
                                Text("画好的图将在此处显示")
                                    .foregroundColor(.black)
                            }
                        }
                    )
                    .clipShape(Rectangle()) // 保证是方形的
                    .cornerRadius(5)
                    .overlay(
                        Rectangle().stroke(Color.gray, lineWidth: 2)
                            .cornerRadius(5)
                    )
            }
            Text(SentContent)
        }
        Spacer()
        HStack{
            AutoSizingTF(hint: "对话内容", text: $ContentToSend, containerHeight: $containHeight, onEnd: {UIApplication
                .shared
                .sendAction(
                    #selector(
                        UIResponder.resignFirstResponder
                    ),
                    to: nil,
                    from: nil,
                    for: nil
                )}
            )
            .padding(.horizontal)
            .frame(width: 250, height: containHeight < 120 ? containHeight : 120)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 3)
            )
            .cornerRadius(10)
            .padding()
            Button(isThinking ? "画图中" : "发送") {
                if ContentToSend != "" && !isThinking {
                    globalData.imageUrl = ""
                    postforImage(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert, imageUrl: $globalData.imageUrl, method: "chat", isThinking: $isThinking,  usermsg: ContentToSend,mode: aiMode)
                    SentContent = ContentToSend
                    ContentToSend = ""
                }
            }
            .frame(width: 90,height: 50)
            .background(isThinking ?  Color.gray : Color.black)  // 设置按钮背景颜色为黑色
            .foregroundColor(.white)  // 设置按钮文字颜色为白色
            .cornerRadius(10)  // 设置按钮圆角
            .padding(.leading)
        }
    }
}

struct recognizePictureView: View {
    @State private var ContentToSend = ""
    @State private var SentContent = ""
    @State private var botmsg = ""
    @State var containHeight: CGFloat = 0
    @ObservedObject var globalData:GlobalData
    var geometry: GeometryProxy
    @Binding var isThinking: Bool
    @Binding var aiMode : Int
    @Binding var showErrorAlert:Bool
    @Binding var errorMessage:String
    
    @State private var isImagePickerPresented = false
    @State private var isActionSheetPresented = false
    @State private var selectedImage: UIImage? = nil
    @State private var isCameraSelected = false // 用来控制是拍照还是从相册选择
    
    var body: some View {
        Spacer()
        VStack {
            // 显示拍摄的图片
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("请先拍一张照片")
                    .font(.headline)
                    .frame(width: 300, height: 300, alignment: .center)
            }
            
            HStack{
                Button("选择图片") {
                    if !isThinking{
                        isActionSheetPresented = true
                        SentContent = ""
                    }
                }
                .padding()
                .actionSheet(isPresented: $isActionSheetPresented) {
                    ActionSheet(
                        title: Text("选择来源"),
                        buttons: [
                            .default(Text("拍照")) {
                                isCameraSelected = true
                                isImagePickerPresented = true
                            },
                            .default(Text("从相册选择")) {
                                isCameraSelected = false
                                isImagePickerPresented = true
                            },
                            .cancel(Text("取消"))
                        ]
                    )
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(isImagePickerPresented: $isImagePickerPresented, selectedImage: $selectedImage,isCamera: isCameraSelected)
                }
                .frame(width: 100,height: 30)
                .background(isThinking ? Color.gray : Color.blue)  // 设置按钮背景颜色为黑色
                .foregroundColor(.white)  // 设置按钮文字颜色为白色
                .cornerRadius(10)  // 设置按钮圆角
                .padding(.leading)
                Button("清空已拍"){
                    if !isThinking{
                        selectedImage = nil
                        SentContent = ""
                    }
                }
                .padding()
                .frame(width: 100,height: 30)
                .background(isThinking ?  Color.gray : Color.blue)  // 设置按钮背景颜色为黑色
                .foregroundColor(.white)  // 设置按钮文字颜色为白色
                .cornerRadius(10)  // 设置按钮圆角
                .padding(.leading)
            }
        }
        ScrollView {
                Text(SentContent)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.top)
            if isThinking{
                ProgressView()
            }
            else{
                Text(botmsg)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = botmsg
                        }) {
                            Text("复制")
                            Image(systemName: "doc.on.clipboard")
                        }
                        Button(action: {
                            // 触发分享
                            shareContent(content:botmsg)
                        }) {
                            Label("分享", systemImage: "square.and.arrow.up")
                        }
                    }
            }
        }

        Spacer()
        HStack{
            AutoSizingTF(hint: "询问内容", text: $ContentToSend, containerHeight: $containHeight, onEnd: {UIApplication
                .shared
                .sendAction(
                    #selector(
                        UIResponder.resignFirstResponder
                    ),
                    to: nil,
                    from: nil,
                    for: nil
                )}
            )
            .padding(.horizontal)
            .frame(width: 250, height: containHeight < 120 ? containHeight : 120)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 3)
            )
            .cornerRadius(10)
            .padding()
            Button(isThinking ? "思考中" : "发送") {
                if ContentToSend != "" && !isThinking && selectedImage != nil{
                    if let imageData = selectedImage?.jpegData(compressionQuality: 0.8) {
                        postforRecognizeImage(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert, method: "chat", isThinking: $isThinking,  usermsg: ContentToSend,mode: aiMode,imageData: imageData, botmsg: $botmsg)
                        SentContent = ContentToSend
                        ContentToSend = ""
                    }
                }
            }
            .frame(width: 90,height: 50)
            .background(isThinking ?  Color.gray : Color.black)  // 设置按钮背景颜色为黑色
            .foregroundColor(.white)  // 设置按钮文字颜色为白色
            .cornerRadius(10)  // 设置按钮圆角
            .padding(.leading)
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView()
    }
}
