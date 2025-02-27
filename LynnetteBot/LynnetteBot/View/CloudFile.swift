//
//  CloudFile.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/15.
//

import SwiftUI

struct ColoudFileView: View {
    @ObservedObject private var globalData = GlobalData.shared
    @StateObject private var globalConfig = GlobalConfig.shared
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    var body: some View {
        VStack {
            Text(globalConfig.servername + " CloudFile")
                .font(.system(size: 32, weight: .bold, design: .default)) // 设置大字体
                .foregroundColor(Color.blue) // 字体颜色为蓝色
                .shadow(color: .blue, radius: 10, x: 5, y: 5) // 添加阴影效果
                .padding(10)
            VStack {
                // 按 ClassName 进行分组
                TabView {
                    ForEach(groupedCloudFiles(), id: \.id) { pageData in
                        ScrollView{
                            ForEach(pageData.1, id: \.id) { cloudFile in
                                if cloudFile.ClassName != "" {
                                    // 显示 ClassName
                                    HStack {
                                        Text(cloudFile.ClassName)
                                            .font(.system(size: 18, weight: .bold, design: .default))
                                            .foregroundColor(Color.black)
                                            .padding(10)
                                        Spacer()
                                    }
                                }
                                // 显示 ChapterName，如果不为空
                                if cloudFile.ChapterName != "" {
                                    HStack {
                                        Text(cloudFile.ChapterName)
                                            .font(.system(size: 17, weight: .bold, design: .default))
                                            .foregroundColor(Color.red)
                                        Spacer()
                                    }
                                    .padding(10)
                                }
                                
                                // 显示文件信息
                                HStack {
                                    if cloudFile.fileName.hasSuffix(".pptx") || cloudFile.fileName.hasSuffix(".ppt"){
                                        Image(systemName: "note.text")
                                    }
                                    else if cloudFile.fileName.hasSuffix(".docx") || cloudFile.fileName.hasSuffix(".doc"){
                                        Image(systemName: "text.document")
                                    }
                                    else if cloudFile.fileName.hasSuffix(".pdf"){
                                        Image(systemName: "list.bullet.clipboard.fill")
                                    }
                                    else{
                                        Image(systemName: "archivebox")
                                    }
                                    Spacer()
                                    VStack {
                                        Text(cloudFile.fileName)
                                            .foregroundColor(Color.white)
                                            .font(.system(size: 18, weight: .bold, design: .default))
                                        Text(cloudFile.fileID)
                                            .foregroundColor(Color.gray)
                                    }
                                    Spacer()
                                }
                                .onTapGesture{
                                    post_getfileurl_openin_safari(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert, method: "ucloudFile",fileid: cloudFile.fileID)
                                }
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 4)
                                        .cornerRadius(10)
                                )
                                .shadow(radius: 5)
                                .frame(maxWidth: 300, maxHeight: 75)
                            }
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(maxWidth: 350,maxHeight: 700)
            .overlay(
                RoundedRectangle(cornerRadius: 10)  // 添加一个带圆角的边框
                    .stroke(Color.gray, lineWidth: 3)  // 设置边框颜色和宽度
                    .cornerRadius(10)
            )
            .onAppear(){
                postget_all_files(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert, method: "ucloudFile",refresh:false)
            }
            .refreshable(action:{
                postget_all_files(errorMessage: $errorMessage, showErrorAlert: $showErrorAlert, method: "ucloudFile",refresh:true)
            })
        }
    }
    func groupedCloudFiles() -> [(id:UUID,[CloudFile])] {
        var pages: [(id:UUID,[CloudFile])] = []
        var currentPage: [CloudFile] = []
        for cloudFile in globalData.global_cloudfiles {
            if cloudFile.ClassName != "" {
                // 如果 ClassName 不为空，开始一个新的页面
                if !currentPage.isEmpty {
                    pages.append((UUID(),currentPage))
                }
                currentPage = [cloudFile] // 开始新的一页
            } else {
                // 如果 ClassName 为空，继续添加到当前页面
                currentPage.append(cloudFile)
            }
        }
        
        // 添加最后一页
        if !currentPage.isEmpty {
            pages.append((UUID(),currentPage))
        }
        return pages
    }
}
struct ColoudFileView_Previews: PreviewProvider {
    static var previews: some View {
        ColoudFileView()
    }
}
