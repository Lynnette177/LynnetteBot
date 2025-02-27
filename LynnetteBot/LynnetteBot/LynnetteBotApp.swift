//
//  LynnetteBotApp.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/15.
//

import SwiftUI

@main
struct LynnetteBotApp: App {
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.scenePhase) private var scenePhase
    @State private var SelectedTab = 0
    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $SelectedTab)
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("请求失败"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("确定"))
                    )
                }
            
                .onAppear(){
                    init_serverInfo(errorMessage:$errorMessage, showErrorAlert:$showErrorAlert)
                    get_notifications(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert)
                }
                .refreshable {
                    // 下拉刷新时触发相同的函数
                    init_serverInfo(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert)
                    get_notifications(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert)
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .active{
                        init_serverInfo(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert)
                        get_notifications(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert)
                    }
                }
                .onChange(of: SelectedTab) {
                    if SelectedTab == 0{
                        init_serverInfo(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert)
                        get_notifications(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert)
                    }
                }
        }
    }
    
    init() {
    }
    
}

