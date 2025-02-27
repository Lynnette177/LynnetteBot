//
//  ShareComponent.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/16.
//
import SwiftUI

// 分享文字内容
func shareContent(content: String) {
    let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)
    
    // 获取当前的视图控制器并展示分享视图
    if let currentVC = getTopViewController() {
        currentVC.present(activityVC, animated: true, completion: nil)
    }
}

// 分享图片内容
func shareImage(image: UIImage) {
    let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
    
    // 获取当前的视图控制器并展示分享视图
    if let currentVC = getTopViewController() {
        currentVC.present(activityVC, animated: true, completion: nil)
    }
}

// 获取当前顶层的视图控制器
func getTopViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first(where: { $0.isKeyWindow }),
          let rootVC = window.rootViewController else {
        return nil
    }
    
    var topVC = rootVC
    while let presentedVC = topVC.presentedViewController {
        topVC = presentedVC
    }
    return topVC
}
