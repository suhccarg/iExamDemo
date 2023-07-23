//
//  WebView.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/08/17.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
////

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import WebKit
#if canImport(ExamLib_iOS1)
import ExamLib_iOS1
#endif
// webview 内のテキスト選択禁止
let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
// webview 内の⻑押しによるメニュー表示禁止
let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"

public class ExamWebView: WKWebView {
    weak public var baseView: CustomViewController!
    private var topLeftFrameLayer: CAShapeLayer!
    private var bottomRightFrameLayer: CAShapeLayer!
    
    public init(baseView: CustomViewController) throws {
        self.baseView = baseView
        self.topLeftFrameLayer = nil
        self.bottomRightFrameLayer = nil
        let disableSelectionScript = WKUserScript(source: disableSelectionScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let disableCalloutScript = WKUserScript(source: disableCalloutScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let controller = WKUserContentController()
        controller.addUserScript(disableSelectionScript)
        controller.addUserScript(disableCalloutScript)
        
        // コンフィグ作成
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = controller //上記の操作禁止を反映
        if #available(iOS 10.0, *) {// iOS10以降
            webConfig.ignoresViewportScaleLimits = true // ピンチインによるズーム禁止を解除
        }
        // 上記のコンフィグを反映して WKWebView 作成
        super.init(frame: self.baseView!.view.frame, configuration: webConfig)
        self.backgroundColor = ExamColor.background.uiColor
        // 回転時にフォントサイズが変更されるのを防ぐ
        //self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        baseView.view.addSubview(self)
        log(50, "ExamWebView - init(view: UIView...)")
    }//init(baseView: CustomViewController, under upperView: UIView, buttonAreaHeight bottom: CGFloat)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)
    
    public func layout(x: CGFloat , y: CGFloat , width w: CGFloat , height h: CGFloat)  throws {
        self.frame = CGRect.init(x: x, y: y, width: w, height: h )
        log(90, "WebView: \(self.frame.size.width) x \(self.frame.size.height) at (\(self.frame.minX), \(self.frame.minY))")
        drawFrame(size: CGSize(width: w, height: h), lineWidth: 2.0)
    }//layout()
    
    private func drawFrame(size: CGSize, lineWidth: CGFloat) {
        let minX: CGFloat = 0.0
        let maxX: CGFloat = size.width
        let minY: CGFloat = 0.0
        let maxY: CGFloat = size.height
        
        let topLeftPath = UIBezierPath()
        topLeftPath.move(to: CGPoint(x: minX, y: maxY))
        topLeftPath.addLine(to: CGPoint(x: minX, y: minY))
        topLeftPath.addLine(to: CGPoint(x: maxX, y: minY))
        if topLeftFrameLayer != nil {
            topLeftFrameLayer.removeFromSuperlayer()
            topLeftFrameLayer = nil
        }
        topLeftFrameLayer = CAShapeLayer()
        topLeftFrameLayer.path = topLeftPath.cgPath
        topLeftFrameLayer.strokeColor = ExamColor.frameTopLeft.cgColor
        topLeftFrameLayer.fillColor = UIColor.clear.cgColor
        topLeftFrameLayer.lineWidth = lineWidth
        self.layer.addSublayer(topLeftFrameLayer)
        
        let bottomRightPath = UIBezierPath()
        bottomRightPath.move(to: CGPoint(x: maxX, y: minY))
        bottomRightPath.addLine(to: CGPoint(x: maxX, y: maxY))
        bottomRightPath.addLine(to: CGPoint(x: minX, y: maxY))
        if bottomRightFrameLayer != nil {
            bottomRightFrameLayer.removeFromSuperlayer()
            bottomRightFrameLayer = nil
        }
        bottomRightFrameLayer = CAShapeLayer()
        bottomRightFrameLayer.path = bottomRightPath.cgPath
        bottomRightFrameLayer.strokeColor = ExamColor.frameBottomRight.cgColor
        bottomRightFrameLayer.fillColor = UIColor.clear.cgColor
        bottomRightFrameLayer.lineWidth = lineWidth
        self.layer.addSublayer(bottomRightFrameLayer)
    }//drawFrame(rect: CGRect, width: CGFloat)
    
    public func setPage(page: String) throws -> String {
        return try setPage(page: page, comment: "")
    }//setPage(page: String)
    
    public func setPage(page: String, comment: String) throws -> String {
        HtmlPage.getInstance().commentHtml = comment
        let html = try HtmlPage.getInstance().getPage(page: page)
        // self.loadHTMLString(html, baseURL: nil)
        self.loadHTMLString(html,
            baseURL: URL(fileURLWithPath: Bundle.main.path(forResource: nil, ofType: "png")!))
        log(50, "ExamWebView#setPage \n\(html)")
        //        log(90, "ExamWebView#setPage fontRate=\(DeviceOrientation.fontRate), \(HtmlPage.getWebFontSize(fontSize: Repository.examFontSize))px")
        return html
    }//setPage(page: String, comment: String)
    
    public func setPage(paragraphs: [String]) throws -> String {
        return try setPage(paragraphs: paragraphs, comment: "")
    }//setPage(page: String)
    
    public func setPage(paragraphs: [String], comment: String) throws -> String {
        HtmlPage.getInstance().commentHtml = comment
        let html = try HtmlPage.getInstance().getPage(paragraphs: paragraphs)
        // self.loadHTMLString(html, baseURL: nil)
        self.loadHTMLString(html,
                            baseURL: URL(fileURLWithPath: Bundle.main.path(forResource: nil, ofType: "png")!))
        log(90, "ExamWebView#setPage \n\(html)")
        //        log(90, "ExamWebView#setPage fontRate=\(DeviceOrientation.fontRate), \(HtmlPage.getWebFontSize(fontSize: Repository.examFontSize))px")
        return html
    }//setPage(page: String)
    
    public static func apply() throws {
        switch ExamColor.mode {
        case .bright:
            mode = .bright
            changer.setBrightColor()
        case .dark:
            changer.setDarkColor()
        default:
            throw ExamAppError.runtime(slog(10, "ExamColor - setMode(\(mode))"))
        }//switch mode
        normalButtonBaseImage = createImageFromUIColor(color:
            ExamColor.normalButtonBase.uiColor)
        pushedButtonBaseImage = createImageFromUIColor(color:
            ExamColor.pushedButtonBase.uiColor)
    }//apply()
}//class ExamWebView


public class ExamFullWebView: ExamWebView {
    private var upperView: UIView!
    
    public init(baseView: CustomViewController, under upperView: UIView) throws {
        self.upperView = upperView
        try super.init(baseView: baseView)
    }//init(baseView: CustomViewController, under upperView: UIView, buttonAreaHeight bottom: CGFloat)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)
    
    public func layout() throws {
        log(50, "ExamFullWebView#layout")
        let rect = ExamFullWebView.getRect(baseView: self.baseView, upperView: self.upperView)
        try layout(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)
        //        let frame = baseView.view.frame
        //        let safe = getSafeArea(baseView: baseView!)
        //        let buttonAreaHeight = defaultButtonHeight + 3 * defaultMargin
        //        let x = safe.left + defaultMargin
        //        let y = upperView.frame.maxY + defaultMargin
        //        let w = frame.width - safe.left - safe.right - defaultMargin * 2
        //        let h = frame.height - y -   safe.bottom - buttonAreaHeight
        //        try layout(x: x, y: y, width: w, height: h )
    }//layout()
    
    public static func getRect(baseView: CustomViewController, upperView: UIView) -> CGRect {
        let frame = baseView.view.frame
        let safe = getSafeArea(baseView: baseView)
        let buttonAreaHeight = defaultButtonHeight + defaultMargin * 2.0
        let x = safe.left + defaultMargin
        let y = upperView.frame.maxY + defaultMargin
        let w = getWidth(baseView: baseView)
        let h = frame.height - y -   safe.bottom - buttonAreaHeight
        return CGRect.init(x: x, y: y, width: w, height: h )
    }//getRect()
    
    public static func getWidth(baseView: CustomViewController) -> CGFloat {
        let frame = baseView.view.frame
        let safe = getSafeArea(baseView: baseView)
        return frame.width - safe.left - safe.right - defaultMargin * 2
    }//getWidth(baseView)
    
}//class ExamFullWebView

