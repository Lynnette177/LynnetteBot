//
//  AutoSizeTF.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/15.
//

import SwiftUI

//封装自适应文本框组件AutoSizingTF
struct AutoSizingTF: UIViewRepresentable {
    //参数列表
    var hint: String //Placeholder占位
    @Binding var text: String //文本
    @Binding var containerHeight: CGFloat //文本框高度
    var onEnd : () -> () //尾随闭包函数
    
    func makeCoordinator() -> Coordinator {
        return AutoSizingTF.Coordinator(parent:  self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView() //实例化文本框组件
        //原生组件样式控制
        textView.text = hint
        textView.textColor = .gray
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 20)
        textView.delegate = context.coordinator
        //定义输入框附件toolbar(工具栏)并使用默认样式
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolBar.barStyle = .default
        //使用另一个spacer作为间隔来使得done完成按钮布局在右侧
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //定义done完成按钮
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(context.coordinator.closeKeyBoard))
        
        toolBar.items = [spacer, doneButton]
        toolBar.sizeToFit()
        textView.inputAccessoryView = toolBar
        //返回这个UIViewRepresentable组件
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        //自适应文本高度函数
        DispatchQueue.main.async {
            if containerHeight == 0 {
                //将内容文本的高度赋值给弹性文本框的高度变量
                containerHeight = uiView.contentSize.height
            }
        }
        uiView.text = text
    }
    
    
    class Coordinator: NSObject, UITextViewDelegate {
        //读取所有的父属性
        var  parent: AutoSizingTF
        init(parent: AutoSizingTF) {
            self.parent = parent
        }
        //键盘关闭时
        @objc func closeKeyBoard() {
            parent.onEnd()
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.hint {
                textView.text = ""
                textView.textColor = UIColor(Color.primary)
            }
        }
        
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.containerHeight = textView.contentSize.height
        }
        
        //检查文本框是否内容为空，如果为空则用hint的值覆盖
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                //覆盖组件
                textView.text = parent.hint
                textView.textColor = .gray
            }
        }
        
    }
}
