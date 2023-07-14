//
//  SettingViewController.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/08/15.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
import UIKit
import WebKit

public class SettingViewController: CustomViewController {
    public var darkModeGroup: DarkModeGroup!
    public var optionGroup: OptionGroup!
    public var questionCountGroup: QuestionCountGroup!
    public var fontSizeGroup: FontSizeGroup!
    
    override public func viewDidLoad() {
        _ = log(50, "SettingViewController#viewDidLoad:\(viewState)")
        super.viewDidLoad()
        do {
            darkModeGroup = DarkModeGroup(baseView: self, upperView: super.topMessage)
            try darkModeGroup.setup()
            
            var upperView: UIView = self.darkModeGroup.label
            if Repository.useOption() {
                optionGroup = OptionGroup(baseView: self, upperView: self.darkModeGroup.label)
                try optionGroup.setup()
                upperView = self.optionGroup.label
            }
            questionCountGroup = QuestionCountGroup(baseView: self, upperView: upperView)
            try questionCountGroup.setup()
            
            fontSizeGroup = FontSizeGroup(baseView: self, upperView: self.questionCountGroup.slider)
            try fontSizeGroup.setup()
            
            try setupButtonArea()
            try setupReturnButton()
            setupOrientationChangeListner(action: #selector(super.onOrientationChangeListner))
            try setupSwipeListener(action: #selector(onSwipeListener(sender: )))
        } catch let e {
            _ = log(10, "\(e)")
        }
    }//viewDidLoad()
    
    override public func returnToPreviousView(previousView: ViewType) throws {
        try darkModeGroup.apply()
        try super.returnToPreviousView(previousView: previousView)
    }//returnToPreviousView(previousView: ViewType)
    
    private func createScrollView() throws {
        scroll = UIScrollView()
        self.view.addSubview(scroll)
    }//createScrollView()
    
    @objc override public func onSwipeListener(sender: UISwipeGestureRecognizer) {
        _ = log(50, "MenuViewController#onSwipeListener: \(sender.direction.value)")
        do {
            if sender.direction == .up {     // up(↑)
                if Repository.checkMode {
                    var s = try listProperties()
                    s += "●フォントサンプルHTMLl\n" + fontSizeGroup.fontSampleHtml
                    try gotoMessageView(message: s, returnView: viewState)
                }
            } else {
                _ = log(90, "SettingViewController#onSwipeListener: undefined swipe")
            }
        } catch let e {
            _ = log(10, "SettingViewController#onSwipeListener:\(e)")
        }
    }//onSwipeListener(sender: UISwipeGestureRecognizer)
    
    ///// 回転処理 /////
    @objc override public func onOrientationChangeListner() {
        _ = log(10, "SettingViewController#onOrientationChangeListner(...)")
        do {
            try fontSizeGroup.updateFontSample()
        } catch let e {
            try! gotoMessageView(message: log(10, "SettingViewController#viewDidLayoutSubviews:\(e)"), returnView: viewState)
        }
    }//onOrientationChangeListner
    
    ///// レイアウト /////
    override public func viewDidLayoutSubviews() {
        _ = log(50, "SettingViewController#viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        //       if viewState == .setting {
        do {
            try layoutSettingView()
        } catch let e {
            _ = log(10, "ViewController#viewDidLayoutSubviews:\(e)")
        }
        //        }
    }//viewDidLayoutSubviews()
    
    public func layoutSettingView() throws {
        //let dividingLine = ExamDividingLine(baseView: self)
        let innerDividingLine = ExamDividingLine(baseView: self)
        try prepareScrollView(upperView: topMessage!)
        try darkModeGroup.layout(top: defaultMargin * 2)
        var upperView: UIView = self.darkModeGroup.label
        if Repository.useOption() {
            innerDividingLine.draw(upperView: darkModeGroup.label)
            try optionGroup.layout()
            upperView = optionGroup.buttons[0]
        }
        innerDividingLine.draw(upperView: upperView, margin: defaultMargin)
        try questionCountGroup.layout()
        innerDividingLine.draw(upperView: questionCountGroup.slider)
        try fontSizeGroup.layout()
        innerDividingLine.draw(upperView: fontSizeGroup.sample, margin: 4)
        try returnButton.layout()
        try layoutScrollView(upperView: mainTitle, bottomView: fontSizeGroup.sample, buttonView: returnButton)
        try layoutButtonArea(upperView: scroll!)
        //dividingLine.draw(upperView: scroll!, margin: ExamDividingLine.lineWidth)
        //dividingLine.apply(targetView: self.view)
        innerDividingLine.apply(targetView: self.scroll!)
    }//layoutSettingView()
    
}//class SettingViewController

public class DarkModeGroup {
    weak var baseView: SettingViewController!
    var upperView: UIView
    var onOffSwitch: UISwitch!
    var label: UILabel!
    var initialValue: ExamColor.Mode
    
    public init(baseView: SettingViewController, upperView: UIView) {
        self.baseView = baseView
        self.upperView = upperView
        initialValue = ExamColor.mode
    }//init(baseView: SettingViewController, upperView: UIView)
    

    public func setup() throws {
       _ = log(50, "DarkModeGroup#setup")
        try setupLabel()
        try setupOnOffSwitch()
    }//setupDarkModeGroup()
    
    private func setupLabel() throws {
        label = UILabel()
        label.text = "画面の配色を暗色系にする"
        label.textColor = ExamColor.normalText.uiColor
        //        darkModeLabel.layer.borderColor = UIColor.red.cgColor
        baseView.scroll.addSubview(label)
    }//setupLabel()
    
    private func setupOnOffSwitch() throws {
        onOffSwitch = UISwitch()
        onOffSwitch.onTintColor = ExamColor.tint.uiColor    /// ON背景
        onOffSwitch.tintColor = UIColor.darkGray    /// OFF縁取り
        label.layer.backgroundColor = UIColor.clear.cgColor   /// OFF背景
        onOffSwitch.addTarget(self, action: #selector(onOnOffSwitchChangeListener(_:)), for: .valueChanged)
        baseView.scroll.addSubview(onOffSwitch)
        onOffSwitch.isOn = (initialValue == .dark)
    }//setupOnOffSwitch
    
    @objc public func onOnOffSwitchChangeListener(_ sender: UISwitch) {
        update(darkMode: sender.isOn)
    }//onOnOffSwitchChangeListener(_ sender: UISwitch)
    
    public func update(darkMode: Bool) {
        _ = log(50, "DarkModeGroup#update")
        if darkMode {
            ExamColor.mode = .dark
        } else {
            ExamColor.mode = .bright
        }
    }//update()

    public func apply() throws {
        Repository.menu!.setupColor()
    }//apply()
    ///// レイアウト /////
    public func layout(top: CGFloat) throws {
        _ = log(50, "DarkModeGroup#layout")
        try layoutLabel(top: top)
        try layoutSwitch()
    }//layout()
    
    public func layoutLabel(top: CGFloat) throws {
        //let safe = getSafeArea(baseView: self.baseView!)
//        let x = self.baseView!.frameMinX + defaultMargin
//        let y = self.baseView!.scroll.frame.mn  + top
//        let w = self.baseView!.frameWidth - defaultMargin
//        let h = Repository.defaultFontSize * 2 + defaultMargin
        
        let upperRect = upperView.frame
        let x = self.baseView!.frameMinX + defaultMargin
        let y = upperRect.maxY  + defaultMargin
        let w = self.baseView!.frameWidth - defaultMargin
        let h = Repository.defaultFontSize * 2 + defaultMargin
    label.layer.borderColor = UIColor.red.cgColor
        _ = log(90, "DarkModeGroup#llayoutLabel:\t\(w) x \(h) at (\(x), \(y))")
        label.frame = CGRect.init(x: x, y: y, width: w, height: h)
        //        darkModeLabel.layer.borderColor = UIColor.red.cgColor
        //        darkModeLabel.layer.borderWidth = 1.0
    }//layoutLabel()
    
    let defaultSwitchWidth = Repository.defaultFontSize
    
    public func layoutSwitch() throws {
        //        let safe = getSafeArea(baseView: self.baseView!)
        onOffSwitch.isOn = (ExamColor.mode == .dark)
        
        let w = defaultSwitchWidth
        let x = label.frame.maxX - defaultMargin - w
        let y = label.frame.minY
        let h = label.frame.height
        onOffSwitch.frame = CGRect.init(x: x, y: y, width: w, height: h)
        //        darkModeSwitch.layer.borderColor = UIColor.red.cgColor
        //        darkModeSwitch.layer.borderWidth = 1.0
        
        let labelFrame = label.frame
        _ = log(100, "DarkModeGroup#layoutSwitch frame:\t\(labelFrame.size.width) x \(labelFrame.size.height) at (\(labelFrame.minX), \(labelFrame.minY))")
        let switchSize:CGSize = CGSize(width: 40, height: 20)
        _ = log(90, "DarkModeGroup#layoutSwitch size:\t\(switchSize.width) x \(switchSize.height)")
        let frame = onOffSwitch.frame
        _ = log(90, "DarkModeGroup#layoutSwitch frame:\t\(frame.size.width) x \(frame.size.height) at (\(frame.minX), \(frame.minY))")
        let newMinX = labelFrame.maxX - frame.size.width - CGFloat(defaultMargin)
        let newWidth = frame.size.width
        let newMinY = label.frame.minY + (labelFrame.size.height - frame.size.height) / 2
        let newHeight = frame.size.height
        onOffSwitch.frame = CGRect.init(x: newMinX, y: newMinY, width: newWidth, height: newHeight)
        let newFrame = onOffSwitch.frame
        _ = log(90, "DarkModeGroup#layoutSwitch frame:\t\(newFrame.size.width) x \(newFrame.size.height) at (\(newFrame.minX), \(newFrame.minY))")
    }//layoutSwitch()
    
}//class DarkModeGroup

public class OptionGroup: NSObject {
    weak var baseView: SettingViewController!
    var upperView: UIView
    var buttons: [OptionButton]
    var label: UILabel!

    public init(baseView: SettingViewController, upperView: UIView) {
        self.baseView = baseView
        self.upperView = upperView
        self.buttons = []
    }//init(baseView: SettingViewController, upperView: UIView)
    
    public func setup() throws {
        _ = log(50, "OptionGroup#setup")
        try setupLabel()
        try setupButtons()
    }//setup()
    
    private func setupLabel() throws {
        self.label = UILabel()
        self.label.text = "資格種別:"
        self.label.textColor = ExamColor.normalText.uiColor
        self.label.layer.borderColor = UIColor.red.cgColor
        self.baseView.scroll.addSubview(label)
    }//setupLabel()
    
    private func setupButtons() throws {
        for i in 0 ..< OptionButton.optionList.count {
            let option = OptionButton.optionList[i]
            var config = ExamButtonConfig()
            config.caption = option.name
            config.action = nil
//            config.action = #selector(onOptionButtonListener)
            config.width *= 0.8
            config.baseView = baseView
            config.targetView = self
            config.align = .center
            config.activeStates = [ .setting ]
            buttons.append(try OptionButton(config: config, optionType: option.type))
            buttons[i].tag = option.type.code
        }
    }//setupButtons()
//
//    @objc private func onOptionButtonListener(_ sender: UIButton) {
//        do {
//            let optionType = try OptionType.find(code: sender.tag)
//            if try Repository.changeOptionState(optionType: optionType) {
//                let button = sender as! OptionButton
//                button.updateColor()
//                _ = Repository.getSelectedOption()
//            }
//        } catch let e {
//            onError(log(10, "OptionGroup#onOptionButtonListener:\(e)"))
//        }
//    }//onOptionButtonListener(_ sender: UIButton)
//
    ///// レイアウト /////
    public func layout() throws {
        _ = log(50, "OptionGroup#layout")
        try layoutLabel()
        for b in buttons {
            try b.layout(label: self.label)
        }
    }//layout()
    
    private func layoutLabel() throws {
        let upperRect = upperView.frame
        let x = self.baseView!.frameMinX + defaultMargin
        let y = upperRect.maxY  + Repository.defaultFontSize
        let w = self.baseView!.frameWidth - defaultMargin
        let h = upperRect.height
        label.frame = CGRect.init(x: x, y: y, width: w, height: h)
        _ = log(90, "OptionGroup#layoutLabel label:\t\(w) x \(h) at (\(x), \(y))")
        _ = log(90, "OptionGroup#layoutLabel label:\t\(label.frame.width) x \(label.frame.height) at (\(label.frame.minX), \(label.frame.minY))")
    }//layoutLabel()

}//OptionGroup

class OptionButton: ExamButton {
    public var optionType: OptionType
    public static let optionList:
        [(type: OptionType, name: String)] = [
//        (OptionType.optionS, "総合種"),
//        (OptionType.optionD, "DD1種"),
//        (OptionType.optionA, "AI1種")
    ]

    public init(config: ExamButtonConfig, optionType: OptionType)  throws {
        self.optionType = optionType
        try super.init(config: config)
    }//init(...)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("OptionButton#init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)
    
    override public func setup(config: ExamButtonConfig) {
        _ = log(90, "OptionButton#setup:\(config.caption)")
        do {
            //        self.backgroundColor = ExamColor.normalButtonBase.uiColor  // ボタンの背景色を設定.
            self.layer.masksToBounds = true     // ボタンの枠を丸く
            self.layer.cornerRadius = 5.0      // コーナーの半径
            self.titleLabel!.font = UIFont.systemFont(ofSize: config.fontSize)
            self.setTitle(OptionButton.optionList[try getIndex()].name, for: .normal)
            self.layer.borderWidth = 3
            updateColor()
            let baseView = config.baseView as! SettingViewController
            baseView.scroll.addSubview(self)
            self.addTarget(self, action: #selector(onOptionButtonListener),
                           for: UIControl.Event.touchUpInside)
        } catch let e {
            onError(log(10, "OptionButton#setup:\(e)"))
        }
    }//setup(config: ExamButtonConfig)
    
    @objc private func onOptionButtonListener(_ sender: UIButton) {
        do {
            let optionType = try OptionType.find(code: sender.tag)
            if try Repository.changeOptionState(optionType: optionType) {
                let button = sender as! OptionButton
                button.updateColor()
                _ = Repository.getSelectedOption()
            }
        } catch let e {
            onError(log(10, "OptionButton#onOptionButtonListener:\(e)"))
        }
    }//onOptionButtonListener(_ sender: UIButton)
    
    public func updateColor() {
        self.setTitleColor(getButtonColor().fore, for: .normal)
        self.layer.borderColor = getButtonColor().fore.cgColor
        self.backgroundColor = getButtonColor().back
    }//upateColor(active: Bool)
    
    private func getButtonColor() -> (fore: UIColor, back: UIColor) {
        if Repository.getOptionState(optionType: self.optionType) ?? true {
            return (ExamColor.optionButtonActiveFore.uiColor,
                    ExamColor.optionButtonActiveBack.uiColor)
        } else {
            return (ExamColor.optionButtonInactiveFore.uiColor,
                    ExamColor.optionButtonInactiveBack.uiColor)
        }
    }//getButtonColor()
    
    public func layout(label: UILabel) throws {
        let w = config.width
//        let x = config.baseView.view.frame.maxX - (3.0 - CGFloat(try getIndex())) * (CGFloat(w) + defaultMargin)
        let x = label.frame.maxX - (3.0 - CGFloat(try getIndex())) * (CGFloat(w) + defaultMargin)
        let h = config.height
        let y = label.frame.minY + (label.frame.height - CGFloat(h)) / 2.0
        self.frame = CGRect.init(x: x, y: y, width: w, height: h)
        _ = log(90, "OptionButton##layout: [\(self.tag)]\t\(w) x \(h) at (\(x), \(y))")
        _ = log(90, "OptionButton##layout: \(label.text!)")
    }
    
    private func getIndex() throws -> Int {
        return try OptionButton.getIndex(optionType: self.optionType)
    }//getIndex()
    
    public static func getIndex(optionType: OptionType) throws -> Int {
        for i in 0 ..< OptionButton.optionList.count {
            if OptionButton.optionList[i].type == optionType {
                return i
            }
        }//for i in 0 ..< keys.count
        throw ExamError.runtime("OptionButton#getIndex: Invalid option type: \(optionType)")
    }//getIndex(optionType: optionType)

}//class OptionButton


public class QuestionCountGroup {
    weak var baseView: SettingViewController!
    var upperView: UIView!
    var slider: UISlider!
    var label: UILabel!
    
    public static let defaultQuestionCount: Float = 500
    public static let minLimit: Float = 3
    public static let maxLimit: Float = 10
    
    public init(baseView: SettingViewController, upperView: UIView) {
        self.baseView = baseView
        self.upperView = upperView
    }//init(baseView: SettingViewController, upperView: UIView)
    
    public func setup() throws {
        _ = log(50, "QuestionCountGroup#setup")
        try setupLabel()
        try setupSlider()
    }//setup()
    
    private func setupLabel() throws {
        label = UILabel()
        //        label.text = "出題画面のフォントサイズ"
        label.textColor = ExamColor.normalText.uiColor

        baseView.scroll.addSubview(label)
    }//setupLabel()
    
    private func setupSlider() throws {
        slider = UISlider()
        slider.minimumTrackTintColor = ExamColor.tint.uiColor
        slider.minimumValue = QuestionCountGroup.minLimit
        slider.maximumValue = QuestionCountGroup.maxLimit
        slider.value = Float(Repository.questionCount)
        slider.addTarget(self, action: #selector(self.onQuestionCountChangeListener(_:)), for: .valueChanged)
        baseView.scroll.addSubview(slider)
    }//setupSlider)
    
    @objc private func onQuestionCountChangeListener(_ sender: UISlider) {
        do {
            try update()
        } catch let e {
            _ = log(10, "\(e)")
        }
    }//onFontSizeChangeListener(_ sender: UIButton)
    
    public func layout() throws {
        _ = log(50, "QuestionCountGroup#layout")
        _ = log(100, "QuestionCountGroup#layout pcount=\(Repository.questionCount)")
        try update()
        try layoutLabel()
        try layoutSlider()
    }//layout()
    
    private func layoutLabel() throws {
        let upperRect = upperView!.frame
        let x = self.baseView!.frameMinX + defaultMargin
        let y = upperRect.maxY + defaultMargin
        let w = self.baseView!.frameWidth - defaultMargin
        let h = upperRect.height
        label.frame = CGRect.init(x: x, y: y, width: w, height: h)
        _ = log(100, "QuestionCountGroup#layoutLabel label:\t\(w) x \(h) at (\(x), \(y))")
        _ = log(100, "QuestionCountGroup#layoutLabel label:\t\(label.frame.width) x \(label.frame.height) at (\(label.frame.minX), \(label.frame.minY))")
        
    }//layoutLabel()
    
    private func update() throws {
        _ = log(50, "QuestionCountGroup#update")
        _ = log(100, String(format:"question count=%.2f", slider.value))
       slider.value = round(slider.value)
        _ = log(100, String(format:"question count=%.2f", slider.value))
        label.text = String(format: "出題数: %2.0f問", slider.value)
        Repository.questionCount = Int(slider.value)
        _ = log(100, "QuestionCountGroup#update count=\(Repository.questionCount)")
    }//update()
    
    private func layoutSlider() throws {
        let x = label.frame.minX + CGFloat(defaultMargin * 2)
        let y = label.frame.maxY 
        let w = label.frame.width - CGFloat(defaultMargin * 4)
        let h = label.frame.height
        slider.frame = CGRect.init(x: x, y: y, width: w, height: h)
        _ = log(100, "QuestionCountGroup#layoutSlider slider:\t\(w) x \(h) at (\(x), \(y))")
        _ = log(100, "QuestionCountGroup#layoutSlider slider:\t\(slider.frame.width) x \(slider.frame.height) at (\(slider.frame.minX), \(slider.frame.minY))")
    }//layoutSlider()
    
}//class QuestionCountGroup

public class FontSizeGroup {
    weak var baseView: SettingViewController!
    var upperView: UIView!
    var slider: UISlider!
    var label: UILabel!
    var sample: ExamWebView!
    var fontSampleHtml: String = ""
    
    // sliderは、px単位。labelの表示は、pt単位。
    // 16px == 12pt == 1em
    public static let px2pt: Float = 12.0 / 16.0
    public static let minLimit: Float = 5.0 / px2pt         // 5pt
    public static let maxLimit: Float = 50.0 / px2pt        // 50pt
    public static let addtitionalParagraph  = "<!-- aditional -->"
 
    private static let htmlBody = ""
        + "  <div class='exam_area'"
        + "   style='width: 4000px; margin: 0; padding: 0; text-indent: 0;'>\n"
        + "    <p>123abcdeいろはにほへとちりぬるを</p>\n"
        + "    <p>初春の令月にして気淑く風和ぎ</p>\n"
        + "    <p>梅は鏡前の粉を披き蘭は珮後の香を薫らす</p>\n"
        + "    <p>" + FontSizeGroup.addtitionalParagraph + "</p>\n"
        + "  </div>\n"

    public init(baseView: SettingViewController, upperView: UIView) {
        self.baseView = baseView
        self.upperView = upperView
    }//init(baseView: SettingViewController, upperView: UIView)
    
    public func setup() throws {
        _ = log(50, "FontSizeGroup#setup")
        try setupLabel()
        try setupSlider()
        try setupSample()
    }//setup()
    
    private func setupLabel() throws {
        label = UILabel()
        //        label.text = "出題画面のフォントサイズ"
        label.textColor = ExamColor.normalText.uiColor
        label.layer.borderColor = UIColor.red.cgColor
        baseView.scroll.addSubview(label)
    }//setupLabel()
    
    private func setupSlider() throws {
        slider = UISlider()
        slider.minimumTrackTintColor = ExamColor.tint.uiColor
        slider.minimumValue = FontSizeGroup.minLimit
        slider.maximumValue = FontSizeGroup.maxLimit
        slider.value = Repository.examFontSize
        slider.addTarget(self, action: #selector(self.onFontSizeChangeListener(_:)), for: .valueChanged)
        baseView.scroll.addSubview(slider)
    }//setupSlider()
    
    @objc private func onFontSizeChangeListener(_ sender: UISlider) {
        //        label.text = "\(sender.value)"
        do {
            _ = log(50, "FontSizeGroup#update: \(slider.value)")
            Repository.examFontSize = slider.value
            try updateLabel()
            try updateFontSample()
        } catch let e {
            _ = log(10, "\(e)")
        }
    }//onFontSizeChangeListener(_ sender: UISlider)

    private func setupSample() throws {
        sample = try ExamWebView(baseView: baseView)
//        sample.frame = CGRect.init(x: 150, y: 300, width: 100, height: 200)
        sample.frame = CGRect.zero
        baseView.scroll.addSubview(sample)
    }//setupSample()

    public func updateFontSample() throws {
        guard let v = sample else {
            throw ExamError.runtime("fontSampleView: nil")
        }
        DeviceOrientation.update(baseView: baseView, webView: sample)
        let fontMetricses = "slider=\((slider.value * FontSizeGroup.px2pt).d1)pt, font=\(slider.value.d1)px"
        let html = try HtmlPage.getInstance()
            .getPage(page: FontSizeGroup.htmlBody)
            .replace(before: "body oncopy",
                after: "body style='padding: 0; margin: 0;' oncopy")
//            .replace(before: FontSizeGroup.addtitionalParagraph, after: fontMetricses)
        _ = log(40, "FontSizeGroup#updateFontSample\n\(html)")
        _ = log(40, "FontSizeGroup#updateFontSample \(fontMetricses)")
        v.loadHTMLString(html, baseURL: nil)
        self.fontSampleHtml = html
    }//updateFontSample()
    
    
    public func layout() throws {
        _ = log(50, "FontSizeGroup#layout")
        try layoutLabel()
        try layoutSlider()
        try layoutSample()
    }//layout()
    
    private func layoutLabel() throws {
        try updateLabel()
        let upperRect = upperView!.frame
        let x = self.baseView!.frameMinX + defaultMargin
        let y = upperRect.maxY + defaultMargin
        let w = self.baseView!.frameWidth - defaultMargin
        let h = upperRect.height
        label.frame = CGRect.init(x: x, y: y, width: w, height: h)
        _ = log(100, "FontSizeGroup#layoutLabel label:\t\(w) x \(h) at (\(x), \(y))")
        _ = log(100, "FontSizeGroup#layoutLabel label:\t\(label.frame.width) x \(label.frame.height) at (\(label.frame.minX), \(label.frame.minY))")
        
    }//layoutLabel()
    
    private func updateLabel() throws {
        label.text = String(format: "出題画面のフォントサイズ: %4.1fポイント", slider.value * FontSizeGroup.px2pt)
    }//updateLabel()
    
    private func layoutSlider() throws {
        let x = label.frame.minX + CGFloat(defaultMargin * 2)
        let y = label.frame.maxY
        let w = label.frame.width - CGFloat(defaultMargin * 4)
        let h = label.frame.height
        slider.frame = CGRect.init(x: x, y: y, width: w, height: h)
        _ = log(100, "FontSizeGroup#layoutSlider slider:\t\(w) x \(h) at (\(x), \(y))")
        _ = log(100, "FontSizeGroup#layoutSlider slider:\t\(slider.frame.width) x \(slider.frame.height) at (\(slider.frame.minX), \(slider.frame.minY))")
    }//layoutSlider()
    
    private func layoutSample() throws {
        let x = slider.frame.minX + defaultMargin
        let y = slider.frame.maxY
        let w = slider.frame.width - defaultMargin * 2.0
        let h = slider.frame.height * 2.0
        //        sample.frame = CGRect.init(x: x, y: y, width: w, height: h)
        try sample.layout(x: x, y: y, width: w, height: h)
        DeviceOrientation.update(baseView: baseView, webView: sample)
        try updateFontSample()
        _ = log(100, "FontSizeGroup#layoutSample sample:\t\(w) x \(h) at (\(x), \(y))")
        _ = log(100, "FontSizeGroup#layoutSample sample:\t\(sample.frame.width) x \(sample.frame.height) at (\(sample.frame.minX), \(sample.frame.minY))")
    }//layoutSample()
}//class FontSizeGroup

/** End of File **/
