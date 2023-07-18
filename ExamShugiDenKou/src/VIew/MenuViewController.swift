//
//  MenuViewController.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/08/07.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import UIKit
import ExamLib_iOS1

public enum TouchedView { case base, title, other }

public class MenuViewController: MenuViewBaseController {
    public var radioGroup: ExamRadioGroup!
    public var messageArea: UILabel!
    public var startButton: ExamButton!
    public var showAllButton: ExamButton!
    public var selfCheckButton: ExamButton!
    public var settingButton: SettingButton!

    override public func viewDidLoad() {
        _ = log(50, "MenuViewController#viewDidLoad:\(viewState)")
        super.viewDidLoad()
        Repository.menu = self
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
            try! gotoMessageView(message: "## MenuViewController#viewDidLoad:\(e)", returnView: viewState)
//            onError(log(10, "MenuViewController#viewDidLoad:\(e)"))
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
            onError(log(10, "MenuViewController#viewDidLoad:\(e)"))
        }
    }//setupColor()
    
    private func setupRadioGroup() throws {
        self.radioGroup = nil
        var config = ExamRadioConfig()
        config.baseView = self
        config.targetView = config.baseView
        config.upperView = topMessage
        config.isSelected = false
        config.action = #selector(radioButtonListner(_:))
        self.radioGroup  = ExamRadioGroup(defaultConfig: config,
                                          categories: Repository.examCategories,
                                          selectedCode: Repository.categoryCode)
        self.radioGroup.setup()
    }//setupExamRadioButton()
    
    @objc public func radioButtonListner(_ sender: UIButton) {
        _ = log(10, "ExamViewController#radioButtonClicked(\(sender.titleLabel!.text!))")
        self.radioGroup.select(sender: sender)
        self.messageArea.text = ""
    }//radioButtonListner(_ sender: UIButton)
    
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
    
    private func setupStartButton() throws {
        self.startButton  = nil
        var config = ExamButtonConfig()
        config.caption = "開始"
        config.action = #selector(onStartButtonListener(_: ))
        config.baseView = self
        config.targetView = config.baseView
        config.align = .center
        config.activeStates = [ .always ]
        self.startButton  = try ExamButton(config: config)
    }//setupStartButton()
    
    private func setupHiddenButton() throws {
        self.showAllButton  = nil
        self.selfCheckButton = nil
        var configShowAll = ExamButtonConfig()
        configShowAll.caption = "All"
        configShowAll.action = #selector(onshowAllkButtonListener(_: ))
        configShowAll.baseView = self
        configShowAll.targetView = configShowAll.baseView
        configShowAll.align = .left
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
    
    @objc private func onStartButtonListener(_ sender: UIButton) {
        _ = log(90, "MenuViewController#startButton tapped.")
        do {
            _ = logPrecisely(90, "MenuViewController: try startExam")
            try startExam()
        } catch let e {
            fatalError(log(10, "MenuViewController#onStartButtonListener:\(e)"))
//            try! gotoMessageView(message: log(10, "MenuViewController#onStartButtonListener:\(e)"), returnView: viewState)
        }
    }//onStartButtonListener(_ sender: UIButton)
    
    private func startExam() throws {
        _ = log(50, "MenuViewController#startExam")
        let selectedCategory = radioGroup.getSelected()
        if selectedCategory ==  nil {
            throw ExamError.runtime(log(10, "radioGroup.getSelected() == nil"))
        }
        Repository.categoryCode = selectedCategory!.code
        if !(try setupExam()) {
            self.messageArea.text = "該当する問題がありません。"
            return
        }
        let storyboard: UIStoryboard = self.storyboard!
        let examView = storyboard.instantiateViewController(withIdentifier: "ExamView") as! ExamViewController
        viewState = .question
        self.present(examView, animated: false, completion: nil)
    }//startExam()
    
    @objc private func onshowAllkButtonListener(_ sender: UIButton) {
        _ = log(90, "MenuViewController#hiddenButton tapped.")
        do {
            _ = logPrecisely(90, "MenuViewController: try startExam")
            try startExam()
        } catch let e {
            _ = log(10, "MenuViewController#onshowAllkButtonListener:\(e)")
        }
    }//onshowAllkButtonListener(_ sender: UIButton)
    
    @objc private func onSelfCheckButtonListener(_ sender: UIButton) {
        _ = log(90, "MenuViewController#hiddenButton tapped.")
        do {
            _ = logPrecisely(90, "MenuViewController: try startExam")
            try startExam()
        } catch let e {
            _ = log(10, "MenuViewController#onSelfCheckButtonListener:\(e)")
        }
    }//onSelfCheckButtonListener(_ sender: UIButton)
    
    @objc private func onSettingButtonListener(_ sender: UIButton) {
        _ = log(50, "MenuViewController#onSettingButtonListener")
        let storyboard: UIStoryboard = self.storyboard!
        let settingView = storyboard.instantiateViewController(withIdentifier: "SettingView") as! SettingViewController
        viewState = .setting
        self.present(settingView, animated: false, completion: nil)
        _ = log(50, "MenuViewController#onSettingButtonListener:\(viewState)")
    }//onSettingButtonListener
    
    @objc override public func onSwipeListener(sender: UISwipeGestureRecognizer) {
        _ = log(50, "MenuViewController#onSwipeListener: \(sender.direction.value)")
        do {
            if sender.direction == .left {     // forward(->)
                _ = log(90, "MenuViewController#onSwipeListener: startExam")
                try startExam()
           } else if sender.direction == .up {     // up(↑)
                if Repository.checkMode {
                    try gotoMessageView(message: getSelfCheck(), returnView: viewState)
                }
            } else {
                _ = log(90, "MenuViewController#onSwipeListener: undefined swipe")
            }
        } catch let e {
            _ = log(10, "MenuViewController#onSwipeListener:\(e)")
        }
    }//onSwipeListener(sender: UISwipeGestureRecognizer)
    
    ///// 画面操作 /////
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _ = log(100, "MenuViewController#touchesEnded")
        var location: CGPoint = CGPoint.zero
        for touch in touches {
            location = touch.location(in: self.view)
            _ = log(90, "MenuViewController#touchesEnded() location: \(location)")
        }
        if checkHiddenMode(location: location) {
            _ = log(50, "MenuViewController#touchesEnded: HiddenModeCounter=\(HiddenModeCounter.counter)")
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
                    _ = log(10, "MenuViewController#touchesEnded:\(e)")
                }
            }
            return
        }
        return
    }//touchesEnded
    
    private func getTouchedPoint(touches: Set<UITouch>) -> CGPoint {
        for touch in touches {
            let location = touch.location(in: self.view)
            _ = log(90, "MenuViewController#touchesEnded() location: \(location)")
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
    
    @objc override public func onOrientationChangeListner() {
        _ = log(10, "MenuViewController#onOrientationChangeListner")
        super.onOrientationChangeListner()
        //        radioGroup.redrawLabel()
        do {
            try layout()
        } catch let e {
            _ = log(10, "MenuViewController#onOrientationChangeListner:\(e)")
        }        //        self.loadView()
        //        self.viewDidLoad()
    }//onOrientationChangeListner()
    
    ////// viewDidLayoutSubviews#layout //////
    override public func viewDidLayoutSubviews() {
        _ = log(50, "MenuViewController#viewDidLayoutSubviews")
       if isError() {
            try! gotoMessageView(message: getError(), returnView: viewState)
            return
        }
        super.viewDidLayoutSubviews()
        do {
            try layoutMenuView()
        } catch let e {
            _ = log(10, "MenuViewController#viewDidLayoutSubviews:\(e)")
        }
    }//viewDidLayoutSubviews()
    
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
        _ = log(90, "MenuViewController#layoutMessageArea:\t\(w) x \(h) at (\(x), \(y))")
        _ = log(90, "MenuViewController#layoutMessageArea:\t\(messageArea.frame.width) x \(messageArea.frame.height) at (\(messageArea.frame.minX), \(messageArea.frame.minY))")

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
                _ = log(90, "HiddenModeCounter#update: \(HiddenModeCounter.counter)")
                return true
            } else {
                previousSide = .left
                HiddenModeCounter.counter = 0
            }
        case .right:
            if  location.x < thresholdX * 1.0 {
                previousSide = .left
                HiddenModeCounter.counter += 1
                _ = log(90, "HiddenModeCounter#update: \(HiddenModeCounter.counter)")
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
        _ = log(90, "HiddenModeCounter#update: \(HiddenModeCounter.counter)")
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
        return HiddenModeCounter.counter > Repository.hiddenCounterLimit
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
        _ = log(50, "SettingButton#init")
        setup(action: action)
    }//init()
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("SettingButton#init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)
    
    private func setup(action: Selector) {
        _ = log(50, "SettingButton#setup(caption: String)")
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
        _ = log(50, "SettingButton:#layout")
        let safe =  getSafeArea(baseView: baseView)
        let w = Int(defaultButtonHeight)
        let h = Int(defaultButtonHeight)
        let x = Int(baseView.view.frame.maxX - defaultMargin - safe.right) - w
        let y = Int(top)
        let rect: CGRect = CGRect.init(x: x, y: y, width: w, height: h)
        self.frame = rect
        _ = log(90, "Setting: \(self.frame.size.width) x \(self.frame.size.height) at (\(self.frame.minX), \(self.frame.minY))")
        
    }//layout()

}//SettingButton

/** End of File **/
