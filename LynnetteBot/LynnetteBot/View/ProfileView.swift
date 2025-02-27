//
//  ProfileView.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/15.
//

import SwiftUI

struct ProfileView: View {
    @State private var baseURLInput: String = GlobalConfig.shared.apiBaseURL
    @State private var UserID : String = GlobalConfig.shared.userId
        
        var body: some View {
            VStack (spacing: 0){
                HStack{
                    Text("服务器地址:")
                        .font(.headline)
                    
                    TextField("请输入服务器地址", text: $baseURLInput)  // 使用 @State 变量进行绑定
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())  // 设置文本框样式
                        .frame(width: 300)  // 设置文本框宽度
                        .onChange(of: baseURLInput, {
                            GlobalConfig.shared.apiBaseURL = baseURLInput
                        })
                }
                HStack{
                    Text("用户ID:")
                        .font(.headline)
                    
                    TextField("请输入用户ID", text: $UserID)  // 使用 @State 变量进行绑定
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())  // 设置文本框样式
                        .frame(width: 300)  // 设置文本框宽度
                        .onChange(of: UserID, {
                            GlobalConfig.shared.userId = UserID
                        })
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
