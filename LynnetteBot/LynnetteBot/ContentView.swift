//
//  ContentView.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/15.
//

import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Int
    var body: some View {
        TabView (selection: $selectedTab){
            // Home Tab
            HomepageView()
                .tabItem {
                    Label("通知与功能", systemImage: "house.fill")
                }
                .tag(0)

            ConversationView()
                .tabItem {
                    Label("对话", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            ColoudFileView()
                .tabItem {
                    Label("云端文件", systemImage: "folder")
                }
                .tag(2)
            ProfileView()
                .tabItem {
                    Label("个人设置", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .background(Color.gray)
    }
}
