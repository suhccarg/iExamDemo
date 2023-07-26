//
//  MenuViewController.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/08/07.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import UIKit
public enum TouchedView { case base, title, other }
#if canImport(ExamPackage)
import ExamPackage
#endif


open class ExamRadioConfig {
    var category: ExamCategory!
    weak var baseView: CustomViewController! = nil
    weak var targetView: NSObject! = nil
    var upperView: UIView? = nil
    var tag: Int  = 0
    var isSelected: Bool = false
    var action: Selector! = nil
    var baseColor: UIColor = ExamColor.base.uiColor
    
    public init() {}
    public func deepCopy(from source: ExamRadioConfig) {
        self.baseView = source.baseView
        self.targetView = source.targetView
        self.upperView = source.upperView
        self.tag = source.tag
        self.isSelected = source.isSelected
        self.action = source.action
        self.baseColor = source.baseColor
    }
    
}//struct ExamRadioConfig


public class MenuViewController: CustomViewController {
    public var radioGroup: ExamRadioGroup!
    public var messageArea: UILabel!
    public var startButton: ExamButton!
    public var showAllButton: ExamButton!
    public var selfCheckButton: ExamButton!
    public var settingButton: SettingButton!
    
    override public func viewDidLoad() {
        log(50, ":\(viewState)")
        super.viewDidLoad()
        Repository.debugLevel = 50
        Preference.menu = self
        do {
            try ExamSourceDao.prepare(bundledDbFile: Repository.getDbFileName())
            try setupRadioGroup()
            try setupMessageArea()
            try setupButtonArea()
            try setupStartButton()
            try setupHiddenButton()
            try setupSettingButton()
            setupOrientationChangeListner(action: #selector(onOrientationChangeListner))
            try setupSwipeListener(action: #selector(onSwipeListener(sender: )))
            HiddenModeCounter.clear()
            Repository.allCheck = false
            Repository.checkMode = false
        } catch let e {
            try! gotoMessageView(message: ":\(e)", returnView: viewState)
            //            onError(slog(10, ":\(e)"))
        }
    }//viewDidLoad()
    
    override public func setupColor() {
        do {
            try super.setupColor()
            self.radioGroup.setupColor()
            setupColorMessageArea()
            startButton.setupColor()
            showAllButton.setupColor()
            selfCheckButton.setupColor()
            settingButton.setupColor()
        } catch let e {
            onError(slog(10, ":\(e)"))
        }
    }//setupColor()
    //    private func setupRadioGroup() throws {
    //        self.radioGroup = nil
    //        var config = ExamRadioConfig()
    //        config.baseView = self
    //        config.targetView = config.baseView
    //        config.upperView = topMessage
    //        config.isSelected = false
    //        config.action = #selector(radioButtonListner(_:))
    //        self.radioGroup  = ExamRadioGroup(defaultConfig: config,
    //                                          categories: Preference.examCategories,
    //                                          selectedCode: Preference.categoryCode)
    //        self.radioGroup.setup()
    //    }//setupExamRadioButton()
    public func setupRadioGroup() throws {
        self.radioGroup = nil
        var config = ExamRadioConfig()
        config.baseView = self
        config.targetView = config.baseView
        config.upperView = topMessage
        config.isSelected = false
        config.action = #selector(radioButtonListner(_:))
        self.radioGroup  = ExamRadioGroup(defaultConfig: config,
                                          categories: Preference.examCategories,
                                          selectedCode: Preference.categoryCode)
        self.radioGroup.setup()
    }//setupExamRadioButton()
    

    private func setupMessageArea() throws {
        self.messageArea = UILabel()
        self.messageArea.numberOfLines = 0
        setupColorMessageArea()
        self.messageArea.tag = messageAreaViewTag
        scroll.addSubview(self.messageArea)
    }//setupMessageArea
    
    private func setupColorMessageArea() {
        self.messageArea.textColor  = ExamColor.enhancedText.uiColor
        //        self.messageArea.backgroundColor = ExamColor.mistyrose.uiColor
        self.messageArea.backgroundColor = ExamColor.base.uiColor
    }//setupColorMessageArea()
    
    public func setupStartButton() throws {
        self.startButton  = nil
        var config = ExamButtonConfig()
        config.caption = "開始"
        config.action = #selector(onStartButtonListener(_: ))
        config.baseView = self
        config.targetView = config.baseView
        config.align = ButtonAlign.center
        config.activeStates = [ .always ]
        self.startButton  = try ExamButton(config: config)
    }//setupStartButton()
    
    public func setupHiddenButton() throws {
        self.showAllButton  = nil
        self.selfCheckButton = nil
        var configShowAll = ExamButtonConfig()
        configShowAll.caption = "All"
        configShowAll.action = #selector(onshowAllkButtonListener(_: ))
        configShowAll.baseView = self
        configShowAll.targetView = configShowAll.baseView
        configShowAll.align = ButtonAlign.left
        configShowAll.activeStates = [ ]
        self.showAllButton  = try ExamButton(config: configShowAll)
        var configSelfCheck = ExamButtonConfig()
        configSelfCheck.caption = "Check"
        configSelfCheck.action = #selector(onSelfCheckButtonListener(_: ))
        configSelfCheck.baseView = self
        configSelfCheck.targetView = configSelfCheck.baseView
        configSelfCheck.align = .center
        configSelfCheck.activeStates = [ ]
        self.selfCheckButton  = try ExamButton(config: configSelfCheck)
        
        self.showAllButton.isHidden = true
        self.selfCheckButton.isHidden = true
    }//setupHiddenButton)
    
    private func setupSettingButton() throws {
        self.settingButton  = try SettingButton(baseView: self,
                                                action: #selector(onSettingButtonListener))
    }//setupSettingButton)
    
    //    private func setupSettingButton() throws {
    //        self.settingButton  = try SettingButton(baseView: self,
    //            action: #selector(onSettingButtonListener))
    //    }//setupSettingButton)
    //}
    //}//onStartButtonListener(_ sender: UIButton)
    
    private func startExam() throws {
        log(50)
        let selectedCategory = radioGroup.getSelected()
        if selectedCategory ==  nil {
            throw ExamAppError.runtime(slog(10, "radioGroup.getSelected() == nil"))
        }
        Preference.categoryCode = selectedCategory!.code
        if !(try setupExam()) {
            self.messageArea.text = "該当する問題がありません。"
            return
        }
        let storyboard: UIStoryboard = self.storyboard!
        let examView = storyboard.instantiateViewController(withIdentifier: "ExamView") as! ExamViewController
        viewState = .question
        examView.modalPresentationStyle = .fullScreen
        self.present(examView, animated:  true, completion: nil)
    }//startExam()
    
    
    @objc private func onStartButtonListener(_ sender: UIButton) {
        log(90, " tapped.")
        do {
            logPrecisely(90, "MenuViewController: try startExam")
            try startExam()
        } catch let e {
            fatalError(slog(10, ":\(e)"))
            // try! gotoMessageView(message: log(10,
            //":\(e)"), returnView: viewState)
        }
    }//onStartButtonListener(_ sender: UIButton)
    
    
    
//    @objc private func radioButtonListner(_ sender: UIButton) {
//        log(10, "(\(sender.titleLabel!.text!))")
//        super.radioButtonListner(sender)
//    }//radioButtonListner(_ sender: UIButton)

    @objc public func radioButtonListner(_ sender: UIButton) {
        log(10, "(\(sender.titleLabel!.text!))")
        self.radioGroup.select(sender: sender)
        self.messageArea.text = ""
    }//radioButtonListner(_ sender: UIButton)
    
    
    
    @objc private  func onshowAllkButtonListener(_ sender: UIButton) {
        log(90, " tapped.")
        do {
            logPrecisely(90, "MenuViewController: try startExam")
            try startExam()
        } catch let e {
            log(10, ":\(e)")
        }
    }//onshowAllkButtonListener(_ sender: UIButton)
    
    @objc private  func onSelfCheckButtonListener(_ sender: UIButton) {
        log(90, " tapped.")
        do {
            logPrecisely(90, "MenuViewController: try startExam")
            try startExam()
        } catch let e {
            log(10, ":\(e)")
        }
    }//onSelfCheckButtonListener(_ sender: UIButton)
    
    @objc private  func onSettingButtonListener(_ sender: UIButton) {
        log(50)
        let storyboard: UIStoryboard = self.storyboard!
        let settingView = storyboard.instantiateViewController(withIdentifier: "SettingView") as! SettingViewController
        viewState = .setting
        self.present(settingView, animated: false, completion: nil)
        log(50, ":\(viewState)")
    }//onSettingButtonListener
    
    @objc override public func onSwipeListener(sender: UISwipeGestureRecognizer) {
        log(50, ": \(sender.direction.value)")
        do {
            if sender.direction == .left {     // forward(->)
                log(90, ": startExam")
                try startExam()
            } else if sender.direction == .up {     // up(↑)
                if Repository.checkMode {
                    try gotoMessageView(message: getSelfCheck(), returnView: viewState)
                }
            } else {
                log(90, ": undefined swipe")
            }
        } catch let e {
            log(10, ":\(e)")
        }
    }//onSwipeListener(sender: UISwipeGestureRecognizer)
    
    /// 画面操作 /////
    ///
    /// ///// 回転処理 /////
    override public  func onOrientationChangeListner() {
        log(10)
        super.onOrientationChangeListner()
    }//onOrientationChangeListner()
    
    @objc override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        log(100)
        var location: CGPoint = CGPoint.zero
        for touch in touches {
            location = touch.location(in: self.view)
            log(90, "() location: \(location)")
        }
        if checkHiddenMode(location: location) {
            log(50, ": HiddenModeCounter=\(HiddenModeCounter.counter)")
            if HiddenModeCounter.check() {
                if showAllButton.isHidden {
                    showAllButton.isHidden = false
                    showAllButton.config.activeStates = [ .always ]
                    selfCheckButton.isHidden = false
                    selfCheckButton.config.activeStates = [ .always ]
                    Repository.allCheck = true
                    Repository.checkMode = true
                } else {
                    showAllButton.isHidden = true
                    showAllButton.config.activeStates = [  ]
                    selfCheckButton.isHidden = true
                    selfCheckButton.config.activeStates = [  ]
                    Repository.allCheck = false
                    Repository.checkMode = false
                }
                HiddenModeCounter.clear()
                do {
                    try showAllButton!.layout()
                    try selfCheckButton!.layout()
                } catch let e {
                    log(10, ":\(e)")
                }
            }
            return
        }
        return
    }//touchesEnded
    
    private func getTouchedPoint(touches: Set<UITouch>) -> CGPoint {
        for touch in touches {
            let location = touch.location(in: self.view)
            log(90, "() location: \(location)")
            return location
        }
        return CGPoint.zero
    }//getTouchedPoint(touches: Set<UITouch>)
    
    private func checkHiddenMode(location: CGPoint) -> Bool {
        return HiddenModeCounter.update(baseView: self, location: location)
    }//checkHiddenMode(location: CGPoint)
    
    ///// 回転処理 /////
    override public func setupOrientationChangeListner(action: Selector) {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: action,
                                               name:UIDevice.orientationDidChangeNotification, object:nil)
    }//setupOrientationChangeListner()
    

    
    ////// viewDidLayoutSubviews#layout //////
    override public func viewDidLayoutSubviews() {
        log(50)
        if isError() {
            try! gotoMessageView(message: getError(), returnView: viewState)
            return
        }
        super.viewDidLayoutSubviews()
        do {
            try layoutMenuView()
        } catch let e {
            log(10, ":\(e)")
        }
    }//viewDidLayoutSubviews()
    
    ////// viewDidLayoutSubviews#layout //////
    
    public func layoutMenuView() throws {
        //let dividingLine = ExamDividingLine(baseView: self)
        //ry topMessage!.layout()
        try prepareScrollView(upperView: topMessage!)
        try radioGroup.layout()
        try layoutMessageArea(upperView: radioGroup.getBottomButton())
        //        try messageArea.layout()
        try startButton!.layout()
        try showAllButton!.layout()
        try selfCheckButton!.layout()
        try settingButton!.layout(top: startButton.frame.minY)
        try layoutScrollView(upperView: topMessage, bottomView: messageArea, buttonView: startButton!)
        try layoutButtonArea(upperView: scroll!)
        //dividingLine.draw(upperView: scroll!, margin: ExamDividingLine.lineWidth)
        //dividingLine.apply(targetView: self.view)
        
    }//layoutMenuView()
    
    private func layoutMessageArea(upperView: UIView) throws {
        messageArea.text = ""
        let safe = getSafeArea(baseView: self)
        let x = self.view.frame.minX + safe.left + defaultMargin * 2
        let w = self.view.frame.width -  defaultMargin * 4 - safe.right - safe.left
        let y = upperView.frame.maxY + defaultMargin * 2.0
        let h = Repository.defaultFontSize * 3.0
        messageArea.frame = CGRect.init(x: x, y: y, width: w, height: h)
        log(90, ":\t\(w) x \(h) at (\(x), \(y))")
        log(90, ":\t\(messageArea.frame.width) x \(messageArea.frame.height) at (\(messageArea.frame.minX), \(messageArea.frame.minY))")
        
    }//layoutMessageArea(upperView: UIView)
}//class MenuViewController

public class HiddenModeCounter {
    public static var counter: Int = 0
    //    public static var previouseView : TouchedView = .other
    //    public static var thresholdX: CGFloat
    
    enum TappedSide  { case left, right, none}
    private static var previousSide: TappedSide = .none
    
    private init() {}
    
    public static func clear() {
        HiddenModeCounter.counter = 0
        //HiddenModeCounter.previouseView = .other
    }//clear()
    
    public static func update(baseView: CustomViewController, location: CGPoint) -> Bool {
        let thresholdX = baseView.view.frame.maxX / 3.0
        switch previousSide {
        case .left:
            if thresholdX * 2.0 < location.x {
                previousSide = .right
                HiddenModeCounter.counter += 1
                log(90, ": \(HiddenModeCounter.counter)")
                return true
            } else {
                previousSide = .left
                HiddenModeCounter.counter = 0
            }
        case .right:
            if  location.x < thresholdX * 1.0 {
                previousSide = .left
                HiddenModeCounter.counter += 1
                log(90, ": \(HiddenModeCounter.counter)")
                return true
            } else {
                previousSide = .right
                HiddenModeCounter.counter = 0
            }
        default:
            if thresholdX < location.x {
                previousSide = .right
            } else {
                previousSide = .left
            }
            HiddenModeCounter.counter = 0
        }
        log(90, ": \(HiddenModeCounter.counter)")
        return false
    }//update(baseView: CustomViewController, location: CGPoint)
    
    //    public static func update(touched: TouchedView) -> Bool {
    //        switch touched {
    //        case .base:
    //            if HiddenModeCounter.previouseView == .base {
    //                //clear()
    //            } else {
    //                HiddenModeCounter.counter += 1
    //                HiddenModeCounter.previouseView = .base
    //            }
    //            return true
    //        case .title:
    //            if HiddenModeCounter.previouseView == .title {
    //                //clear()
    //            } else {
    //                HiddenModeCounter.counter += 1
    //                HiddenModeCounter.previouseView = .title
    //            }
    //            return true
    //        default:
    //            clear()
    //        }
    //        return false
    //    }//update(touched: TouchedView)
    
    public static func check() -> Bool {
        return HiddenModeCounter.counter > hiddenCounterLimit
    }//check()
}//class HiddenModeCounter

public class SettingButton: UIButton {
    weak private var baseView: CustomViewController!
    let buttonMargin :CGFloat = defaultMargin
    let heightMargin: CGFloat = defaultMargin
    let leftMargin: CGFloat = defaultMargin
    
    init(baseView: CustomViewController, action: Selector)  throws {
        self.baseView = baseView
        super.init(frame: CGRect.zero)
        log(50)
        setup(action: action)
    }//init()
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError(slog(0,"init(coder:) has not been implemented"))
    }//init?(coder aDecoder: NSCoder)
    
    private func setup(action: Selector) {
        log(50, "action: Selector")
        setupColor()
        self.addTarget(baseView, action: action, for: UIControl.Event.touchUpInside)
        baseView.view.addSubview(self)
    }//setup(action: Selector)
    
    public func setupColor() {
        self.backgroundColor = UIColor.clear  // ボタンの背景色
        if ExamColor.mode == .bright {
            self.setImage(UIImage(named:"gearBlack256.png")!, for: .normal)
            if Repository.isKoutan() {
                self.setImage(UIImage(named:"gearGreen256.png")!, for: .highlighted)
            } else {
                self.setImage(UIImage(named:"gearBlue256.png")!, for: .highlighted)
                //self.setImage(UIImage(named:"gearGreen256.png")!, for: .highlighted)
            }
        } else {
            self.setImage(UIImage(named:"gearLightGray256.png")!, for: .normal)
            if Repository.isKoutan() {
                self.setImage(UIImage(named:"gearLightGreen256.png")!, for: .highlighted)
            } else {
                self.setImage(UIImage(named:"gearLightBlue256.png")!, for: .highlighted)
                //self.setImage(UIImage(named:"gearLightGreen256.png")!, for: .highlighted)
            }
        }
    }//setupColor()
    
    public func layout(top: CGFloat) throws {
        log(50, "SettingButton:#layout")
        let safe =  getSafeArea(baseView: baseView)
        let w = Int(defaultButtonHeight)
        let h = Int(defaultButtonHeight)
        let x = Int(baseView.view.frame.maxX - defaultMargin - safe.right) - w
        let y = Int(top)
        let rect: CGRect = CGRect.init(x: x, y: y, width: w, height: h)
        self.frame = rect
        log(90, "Setting: \(self.frame.size.width) x \(self.frame.size.height) at (\(self.frame.minX), \(self.frame.minY))")
        
    }//layout()
    
}//SettingButton

/** End of File **/
