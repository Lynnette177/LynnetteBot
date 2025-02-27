import Foundation
import SwiftUI

// 首页视图
struct HomepageView: View {
    @State private var isAlertPresented: [UUID: Bool] = [:]
    @State private var showErrorAlert = false
    @State private var isExecuting: [UUID: Bool] = [:]
    @State private var errorMessage = ""
    
    @StateObject private var globalData = GlobalData.shared
    @StateObject private var globalConfig = GlobalConfig.shared
    let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }

    var body: some View {
        VStack {
            // 通知部分
            NotificationSection(isAlertPresented: $isAlertPresented, globalData: globalData, globalConfig: globalConfig, dateFormatter: dateFormatter)

            Divider()

            // 功能部分
            FunctionSection(globalData: globalData, isExecuting: $isExecuting, errorMessage: $errorMessage, showErrorAlert: $showErrorAlert)
        }
    }
}

// 通知部分视图
struct NotificationSection: View {
    @Binding var isAlertPresented: [UUID: Bool]
    @ObservedObject var globalData: GlobalData
    @ObservedObject var globalConfig: GlobalConfig
    var dateFormatter: DateFormatter

    var body: some View {
        VStack {
            HStack {
                Text(globalConfig.servername + "通知中心")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(Color.blue)
                    .shadow(color: .blue, radius: 10, x: 5, y: 5)
                    .padding(10)
                Spacer()
                Button("清空通知") {
                    globalData.global_Notifications.removeAll()
                    isAlertPresented = [:]
                }
                .frame(width: 80, height: 40)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.trailing)
            }

            ScrollView {
                ForEach(globalData.global_Notifications.reversed(), id: \.id) { notificate in
                    NotificationRow(notificate: notificate, isAlertPresented: $isAlertPresented, dateFormatter: dateFormatter, globalData: globalData)
                }

                if globalData.global_Notifications.isEmpty {
                    EmptyNotificationView(serverName: globalConfig.servername)
                }
            }
            .frame(height: 300)
        }
    }
}

// 单个通知行视图
struct NotificationRow: View {
    var notificate: NotificationMessage
    @Binding var isAlertPresented: [UUID: Bool]
    var dateFormatter: DateFormatter
    @ObservedObject var globalData: GlobalData

    var body: some View {
        HStack {
            Image(systemName: icon(for: notificate.urgent))
                .resizable()
                .frame(width: 50, height: 50)
                .padding()

            VStack(alignment: .leading) {
                Text(notificate.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(notificate.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                let dateString = dateFormatter.string(from: notificate.genTime)
                Text("时间：" + dateString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(width: 300, height: 80, alignment: .leading)
            .alert(isPresented: Binding(
                get: { isAlertPresented[notificate.id] ?? false },
                set: { isAlertPresented[notificate.id] = $0 }
            )) {
                var alert_content = ""
                alert_content += geturgentstr(for: notificate.urgent) + "\n"
                let dateString = dateFormatter.string(from: notificate.genTime)
                alert_content += dateString + "\n"
                alert_content += notificate.content
                return Alert(title: Text(notificate.title),
                             message: Text(alert_content),
                             primaryButton: .default(Text("确认")),
                             secondaryButton: .destructive(Text("删除")) {
                    if let index = globalData.global_Notifications.firstIndex(where: { $0.id == notificate.id }) {
                        globalData.global_Notifications.remove(at: index)
                    }
                })
            }
        }
        .onTapGesture {
            isAlertPresented[notificate.id] = true
        }
        .background(backgroundColor(for: notificate.urgent))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: 400, height: 60, alignment: .center)
        .padding(15)
    }

    func backgroundColor(for urgent: Int) -> Color {
        switch urgent {
        case 0: return Color.blue
        case 1: return Color.yellow
        case 2: return Color.red
        default: return Color.gray
        }
    }

    func icon(for urgent: Int) -> String {
        switch urgent {
        case 0: return "checkmark.circle"
        case 1: return "exclamationmark.circle"
        case 2: return "exclamationmark.triangle"
        default: return "questionmark.circle"
        }
    }

    func geturgentstr(for urgent: Int) -> String {
        switch urgent {
        case 0: return "低优先级"
        case 1: return "中优先级"
        case 2: return "紧迫事件"
        default: return "未知事件"
        }
    }
}

// 空通知视图
struct EmptyNotificationView: View {
    var serverName: String

    var body: some View {
        VStack {
            Text("没有来自" + serverName + "的通知了")
                .font(.system(size: 25, weight: .bold, design: .default))
                .foregroundColor(Color.black)
                .frame(alignment: .center)
        }
        .frame(height: 300)
    }
}

// 功能部分视图
struct FunctionSection: View {
    @StateObject private var globalConfig = GlobalConfig.shared
    @ObservedObject var globalData: GlobalData
    @Binding var isExecuting: [UUID: Bool]
    @Binding var errorMessage: String
    @Binding var showErrorAlert: Bool

    var body: some View {
        VStack {
            HStack {
                Text(globalConfig.servername + "功能中心")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(Color.blue)
                    .shadow(color: .blue, radius: 10, x: 5, y: 5)
                    .padding(10)
                Spacer()
            }

            ScrollView {
                ForEach(0..<globalData.global_Functions.count / 2 + globalData.global_Functions.count % 2, id: \.self) { index in
                    HStack {
                        ForEach(0..<2) { offset in
                            let i = index * 2 + offset
                            if i < globalData.global_Functions.count {
                                let singleFunction = globalData.global_Functions[i]
                                FunctionRow(singleFunction: singleFunction, isExecuting: $isExecuting, errorMessage: $errorMessage, showErrorAlert: $showErrorAlert)
                            }
                        }
                    }
                }
            }
            .frame(height: 330)
        }
    }
}

// 单个功能行视图
struct FunctionRow: View {
    var singleFunction: RobotFunction
    @Binding var isExecuting: [UUID: Bool]
    @Binding var errorMessage: String
    @Binding var showErrorAlert: Bool

    var body: some View {
        HStack {
            if singleFunction.executable {
                Image(systemName: (isExecuting[singleFunction.id] ?? false) ? "hourglass" : "play.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.blue))
            } else {
                Image(systemName: "info.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.blue))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(singleFunction.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(singleFunction.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.green)
        .cornerRadius(15)
        .shadow(radius: 5)
        .frame(width: 200, height: 80)
        .onTapGesture {
            if singleFunction.executable{
                isExecuting[singleFunction.id] = true
                executeTask(uuid:singleFunction.id,errorMessage: $errorMessage, showErrorAlert: $showErrorAlert, method: singleFunction.method,isExecuting: $isExecuting)
            }
        }
        .contextMenu {
            Text(singleFunction.content)
        }
    }
}
