//
//  WebView.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/08/17.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
import UIKit
import WebKit

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
        _ = log(50, "ExamWebView - init(view: UIView...)")
    }//init(baseView: CustomViewController, under upperView: UIView, buttonAreaHeight bottom: CGFloat)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)
    
    public func layout(x: CGFloat , y: CGFloat , width w: CGFloat , height h: CGFloat)  throws {
        self.frame = CGRect.init(x: x, y: y, width: w, height: h )
        _ = log(90, "WebView: \(self.frame.size.width) x \(self.frame.size.height) at (\(self.frame.minX), \(self.frame.minY))")
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
        _ = log(50, "ExamWebView#setPage \n\(html)")
        //        _ = log(90, "ExamWebView#setPage fontRate=\(DeviceOrientation.fontRate), \(HtmlPage.getWebFontSize(fontSize: Repository.examFontSize))px")
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
        _ = log(90, "ExamWebView#setPage \n\(html)")
        //        _ = log(90, "ExamWebView#setPage fontRate=\(DeviceOrientation.fontRate), \(HtmlPage.getWebFontSize(fontSize: Repository.examFontSize))px")
        return html
    }//setPage(page: String)
    
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
        _ = log(50, "ExamFullWebView#layout")
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

public class ExamColor {
    public enum Mode { case bright, dark, na }

    public static var base: String = "#666666"
    public static var baseText: String = "#111111"
    public static var background: String = "#333333"
    public static var titleBar: String = "#dddddd"
    public static var titleText: String = "#555555"
    public static var normalText: String = "#333333"
    public static var enhancedText: String = "#999999"
    public static var tint: String = "#999999"
    public static var frameTopLeft: String = "#aaaaaa"
    public static var frameBottomRight: String = "#777777"
    public static var normalButtonBase: String = "#cccccc"
    public static var pushedButtonBase: String = "#666666"
    public static var normalButtonText: String = "#444444"
    public static var pushedButtonText: String = "#111111"
    public static var buttonArea: String = "#666666"
    public static var dividingLineTop: String = "#eeeeee"
    public static var dividingLineBottom: String = "#aaaaaa"
    public static var optionButtonActiveFore: String = "#aaaaaa"
    public static var optionButtonActiveBack: String = "#aaaaaa"
    public static var optionButtonInactiveFore: String = "#aaaaaa"
    public static var optionButtonInactiveBack: String = "#aaaaaa"
    
    public static var normalButtonBaseImage: UIImage!
    public static var pushedButtonBaseImage: UIImage!
    
    public static func apply() throws {
        switch ExamColor.mode {
        case .bright:
            mode = .bright
            changer.setBrightColor()
        case .dark:
            changer.setDarkColor()
        default:
            throw ExamError.runtime(log(10, "ExamColor - setMode(\(mode))"))
        }//switch mode
        normalButtonBaseImage = createImageFromUIColor(color:
            ExamColor.normalButtonBase.uiColor)
        pushedButtonBaseImage = createImageFromUIColor(color:
            ExamColor.pushedButtonBase.uiColor)
    }//apply()

    //public static var mode: Mode = .na
    public static var mode: Mode {
        get  {
            if Repository.darkMode {
                return .dark
            } else {
                return .bright
            }
        }//get
        set {
            Repository.darkMode = (newValue == .dark)
        }//set
    }//var mode
    
    private static let changer = { () -> ExamColorChanger in
        if Repository.isKoutan() {
            return ExamColorKoutanThemeChanger()
        } else if Repository.isShugi() {
            return ExamColorShugiThemeChanger()
        } else {
            return ExamColorBlueThemeChanger()
        }
    }()
    fileprivate static func createImageFromUIColor(color: UIColor) -> UIImage {
        // 1x1のbitmapを作成
        let rect = CGRect.init(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        // bitmapを塗りつぶし
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        // UIImageに変換
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }//createImageFromUIColor(color: UIColor)
}//class ExamColor

public class ExamColorChanger {
    
    fileprivate func setBrightColor() {}//setBrightColor()
    
    fileprivate func setDarkColor() {}//setDarkColor()
    
}//class ExamColorChanger

public class ExamColorKoutanThemeChanger: ExamColorChanger {

    override fileprivate func setBrightColor() {
        ExamColor.base = "#FFFFCC"
        ExamColor.baseText = "#000000"
        ExamColor.background = "#FFFFFF"                //
        ExamColor.titleBar = "#006600"
        ExamColor.titleText = "#FFFFFF"
        ExamColor.normalText = "#000000"
        ExamColor.enhancedText = "#990000"
        ExamColor.tint = "#00CC00"                      // "#0000CC"
        ExamColor.frameTopLeft = "#999999"
        ExamColor.frameBottomRight = "#CCCCCC"
        ExamColor.normalButtonBase = "#FF9900"
        ExamColor.pushedButtonBase = "#CC6600"
        ExamColor.normalButtonText = "#000000"
        ExamColor.pushedButtonText = "#000000"
        ExamColor.dividingLineTop =  "#DDDD99"
        ExamColor.dividingLineBottom = "#FFFFEE"
        ExamColor.buttonArea = "#EEEEBB"
        ExamColor.optionButtonActiveFore = "#00CC00"    // "#0000CC"
        ExamColor.optionButtonActiveBack = "#FFFFFF"    //
        ExamColor.optionButtonInactiveFore = "#666666"
        ExamColor.optionButtonInactiveBack = "#DDDDDD"
    }//setBrightColor()
    
    override fileprivate func setDarkColor() {
        ExamColor.base = "#333333"
        ExamColor.baseText = "#CCCCCC"
        ExamColor.background = "#003300"                // "#000022"
        ExamColor.titleBar = "#003300"
        ExamColor.titleText = "#CCCCCC"
        ExamColor.normalText = "#CCCCCC"
        ExamColor.enhancedText = "#CC7A7A"
        ExamColor.tint = "#009900"                      // "#000099"
        ExamColor.frameTopLeft = "#222222"
        ExamColor.frameBottomRight = "#555555"
        ExamColor.normalButtonBase = "#663333"
        ExamColor.pushedButtonBase = "#442222"
        ExamColor.normalButtonText = "#CCCCCC"
        ExamColor.pushedButtonText = "#EEEEEE"
        ExamColor.dividingLineTop = "#222222"
        ExamColor.dividingLineBottom = "#555555"
        ExamColor.buttonArea = "#444444"              
        ExamColor.optionButtonActiveFore = "#CCCCCC"    //
        ExamColor.optionButtonActiveBack = "#009900"    // "#000099"
        ExamColor.optionButtonInactiveFore = "#999999"
        ExamColor.optionButtonInactiveBack = "#333333"
    }//setDarkColor()
    
}//class ExamColorKoutanThemeChanger

public class ExamColorShugiThemeChanger: ExamColorKoutanThemeChanger {
    
    override fileprivate func setBrightColor() {
        super.setBrightColor()
        ExamColor.titleBar = "#000066"
        ExamColor.titleText = "#FFFFFF"
        
        ExamColor.tint = "#0000CC"
        ExamColor.optionButtonActiveFore = "#0000CC"
        ExamColor.optionButtonActiveBack = "#FFFFFF"
    }//setBrightColor()
    
    override fileprivate func setDarkColor() {
        super.setDarkColor()
        ExamColor.titleBar = "#000033"
        ExamColor.titleText = "#CCCCCC"
        
        ExamColor.background = "#000022"                // "#003300"
        ExamColor.tint = "#000099"
        ExamColor.optionButtonActiveFore = "#CCCCCC"
        ExamColor.optionButtonActiveBack = "#000099"
    }//setDarkColor()
    
}//class ExamColorShugiThemeChanger

public class ExamColorBlueThemeChanger: ExamColorChanger  {
    
    override fileprivate func setBrightColor() {
        ExamColor.base = "#EEEEEE"
        ExamColor.baseText = "#000000"
        ExamColor.background = "#FFFFFF"
        ExamColor.titleBar = "#000066"
        ExamColor.titleText = "#FFFFFF"
        ExamColor.normalText = "#000000"
        ExamColor.enhancedText = "#990000"
        ExamColor.tint = "#0000CC"
        ExamColor.frameTopLeft = "#999999"
        ExamColor.frameBottomRight = "#CCCCCC"
        ExamColor.normalButtonBase = "#CCFFFF"
        ExamColor.pushedButtonBase = "#99CCCC"
        ExamColor.normalButtonText = "#000000"
        ExamColor.pushedButtonText = "#000000"
        ExamColor.dividingLineTop = "#9999DD"
        ExamColor.dividingLineBottom = "#FFFFEE"
        ExamColor.buttonArea = "#DDDDDD"
        ExamColor.optionButtonActiveFore = "#0000CC"
        ExamColor.optionButtonActiveBack = "#FFFFFF"
        ExamColor.optionButtonInactiveFore = "#666666"
        ExamColor.optionButtonInactiveBack = "#DDDDDD"
    }//setBrightColor()
    
    override fileprivate func setDarkColor() {
        ExamColor.base = "#333333"
        ExamColor.baseText = "#CCCCCC"
        ExamColor.background = "#000033"
        ExamColor.titleBar = "#000044"
        ExamColor.titleText = "#CCCCCC"
        ExamColor.normalText = "#CCCCCC"
        ExamColor.enhancedText = "#CC7A7A"
        ExamColor.tint = "#000099"
        ExamColor.frameTopLeft = "#222222"
        ExamColor.frameBottomRight = "#555555"
        ExamColor.normalButtonBase = "#000066"
        ExamColor.pushedButtonBase = "#000099"
        ExamColor.normalButtonText = "#CCCCCC"
        ExamColor.pushedButtonText = "#EEEEEE"
        ExamColor.buttonArea = "#444444"
        ExamColor.dividingLineTop = "#222222"
        ExamColor.dividingLineBottom = "#555555"
        ExamColor.optionButtonActiveFore = "#CCCCCC"
        ExamColor.optionButtonActiveBack = "#000099"
        ExamColor.optionButtonInactiveFore = "#999999"
        ExamColor.optionButtonInactiveBack = "#333333"
    }//setDarkColor()
}//class ExamColorBlueThemeChanger

class ColorName {
    
    // http://www.htmq.com/color/colorname.shtml
    public static var white: String = "#FFFFFF"
    public static var whitesmoke: String = "#F5F5F5"
    public static var ghostwhite: String = "#F8F8FF"
    public static var aliceblue: String = "#F0F8FF"
    public static var lavender: String = "#E6E6FA"
    public static var azure: String = "#F0FFFF"
    public static var lightcyan: String = "#E0FFFF"
    public static var mintcream: String = "#F5FFFA"
    public static var honeydew: String = "#F0FFF0"
    public static var ivory: String = "#FFFFF0"
    public static var beige: String = "#F5F5DC"
    public static var lightyellow: String = "#FFFFE0"
    public static var lightgoldenrodyellow: String = "#FAFAD2"
    public static var lemonchiffon: String = "#FFFACD"
    public static var floralwhite: String = "#FFFAF0"
    public static var oldlace: String = "#FDF5E6"
    public static var cornsilk: String = "#FFF8DC"
    public static var papayawhite: String = "#FFEFD5"
    public static var blanchedalmond: String = "#FFEBCD"
    public static var bisque: String = "#FFE4C4"
    public static var snow: String = "#FFFAFA"
    public static var linen: String = "#FAF0E6"
    public static var antiquewhite: String = "#FAEBD7"
    public static var seashell: String = "#FFF5EE"
    public static var lavenderblush: String = "#FFF0F5"
    public static var mistyrose: String = "#FFE4E1"
    public static var gainsboro: String = "#DCDCDC"
    public static var lightgray: String = "#D3D3D3"
    public static var lightsteelblue: String = "#B0C4DE"
    public static var lightblue: String = "#ADD8E6"
    public static var lightskyblue: String = "#87CEFA"
    public static var powderblue: String = "#B0E0E6"
    public static var paleturquoise: String = "#AFEEEE"
    public static var skyblue: String = "#87CEEB"
    public static var mediumaquamarine: String = "#66CDAA"
    public static var aquamarine: String = "#7FFFD4"
    public static var palegreen: String = "#98FB98"
    public static var lightgreen: String = "#90EE90"
    public static var khaki: String = "#F0E68C"
    public static var palegoldenrod: String = "#EEE8AA"
    public static var moccasin: String = "#FFE4B5"
    public static var navajowhite: String = "#FFDEAD"
    public static var peachpuff: String = "#FFDAB9"
    public static var wheat: String = "#F5DEB3"
    public static var pink: String = "#FFC0CB"
    public static var lightpink: String = "#FFB6C1"
    public static var thistle: String = "#D8BFD8"
    public static var plum: String = "#DDA0DD"
    public static var silver: String = "#C0C0C0"
    public static var darkgray: String = "#A9A9A9"
    public static var lightslategray: String = "#778899"
    public static var slategray: String = "#708090"
    public static var slateblue: String = "#6A5ACD"
    public static var steelblue: String = "#4682B4"
    public static var mediumslateblue: String = "#7B68EE"
    public static var royalblue: String = "#4169E1"
    public static var blue: String = "#0000FF"
    public static var dodgerblue: String = "#1E90FF"
    public static var cornflowerblue: String = "#6495ED"
    public static var deepskyblue: String = "#00BFFF"
    public static var cyan: String = "#00FFFF"
    public static var aqua: String = "#00FFFF"
    public static var turquoise: String = "#40E0D0"
    public static var mediumturquoise: String = "#48D1CC"
    public static var darkturquoise: String = "#00CED1"
    public static var lightseagreen: String = "#20B2AA"
    public static var mediumspringgreen: String = "#00FA9A"
    public static var springgreen: String = "#00FF7F"
    public static var lime: String = "#00FF00"
    public static var limegreen: String = "#32CD32"
    public static var yellowgreen: String = "#9ACD32"
    public static var lawngreen: String = "#7CFC00"
    public static var chartreuse: String = "#7FFF00"
    public static var greenyellow: String = "#ADFF2F"
    public static var yellow: String = "#FFFF00"
    public static var gold: String = "#FFD700"
    public static var orange: String = "#FFA500"
    public static var darkorange: String = "#FF8C00"
    public static var goldenrod: String = "#DAA520"
    public static var burlywood: String = "#DEB887"
    public static var tan: String = "#D2B48C"
    public static var sandybrown: String = "#F4A460"
    public static var darksalmon: String = "#E9967A"
    public static var lightcoral: String = "#F08080"
    public static var salmon: String = "#FA8072"
    public static var lightsalmon: String = "#FFA07A"
    public static var coral: String = "#FF7F50"
    public static var tomato: String = "#FF6347"
    public static var orangered: String = "#FF4500"
    public static var red: String = "#FF0000"
    public static var deeppink: String = "#FF1493"
    public static var hotpink: String = "#FF69B4"
    public static var palevioletred: String = "#DB7093"
    public static var violet: String = "#EE82EE"
    public static var orchid: String = "#DA70D6"
    public static var magenta: String = "#FF00FF"
    public static var fuchsia: String = "#FF00FF"
    public static var mediumorchid: String = "#BA55D3"
    public static var darkorchid: String = "#9932CC"
    public static var darkviolet: String = "#9400D3"
    public static var blueviolet: String = "#8A2BE2"
    public static var mediumpurple: String = "#9370DB"
    public static var gray: String = "#808080"
    public static var mediumblue: String = "#0000CD"
    public static var darkcyan: String = "#008B8B"
    public static var cadetblue: String = "#5F9EA0"
    public static var darkseagreen: String = "#8FBC8F"
    public static var mediumseagreen: String = "#3CB371"
    public static var teal: String = "#008080"
    public static var forestgreen: String = "#228B22"
    public static var seagreen: String = "#2E8B57"
    public static var darkkhaki: String = "#BDB76B"
    public static var peru: String = "#CD853F"
    public static var crimson: String = "#DC143C"
    public static var indianred: String = "#CD5C5C"
    public static var rosybrown: String = "#BC8F8F"
    public static var mediumvioletred: String = "#C71585"
    public static var dimgray: String = "#696969"
    public static var black: String = "#000000"
    public static var midnightblue: String = "#191970"
    public static var darkslateblue: String = "#483D8B"
    public static var darkblue: String = "#00008B"
    public static var navy: String = "#000080"
    public static var darkslategray: String = "#2F4F4F"
    public static var green: String = "#008000"
    public static var darkgreen: String = "#006400"
    public static var darkolivegreen: String = "#556B2F"
    public static var olivedrab: String = "#6B8E23"
    public static var olive: String = "#808000"
    public static var darkgoldenrod: String = "#B8860B"
    public static var chocolate: String = "#D2691E"
    public static var sienna: String = "#A0522D"
    public static var saddlebrown: String = "#8B4513"
    public static var firebrick: String = "#B22222"
    public static var brown: String = "#A52A2A"
    public static var maroon: String = "#800000"
    public static var darkred: String = "#8B0000"
    public static var darkmagenta: String = "#8B008B"
    public static var purple: String = "#800080"
    public static var indigo: String = "#4B0082"
    
}//class ColorName
/** End of File **/
