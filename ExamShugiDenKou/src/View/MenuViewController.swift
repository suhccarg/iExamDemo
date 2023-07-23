//
//  MenuViewController.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/08/07.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import UIKit
public enum TouchedView { case base, title, other }
#if canImport(ExamLib_iOS1)
import ExamLib_iOS1
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
}//struct ExamRadioConfig


public class MenuViewController: CustomViewController {
    open var radioGroup: ExamRadioGroup!

    override public func viewDidLoad() {
        log(50, "MenuViewGenericController#viewDidLoad:\(viewState)")
        super.viewDidLoad()
        setupOrientationChangeListner(action: #selector(onOrientationChangeListner))
    }
    open  override func setupRadioGroup() throws {
        self.radioGroup = nil
        var config = ExamRadioConfig()
        config.baseView = self
        config.targetView = config.baseView
        config.upperView = topMessage
        config.isSelected = false
        config.action = #selector(radioButtonListner(_:))
        self.radioGroup  = ExamRadioGroup(config: config,
                                          categories: Repository.examCategories,
                                          selectedCode: Preference.categoryCode)
        self.radioGroup.setup()
    }//setupExamRadioBGroup()
    
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
    
    open override func setupRadioGroup() throws {
        self.radioGroup = nil
        var config = ExamRadioConfig()
        config.baseView = self
        config.targetView = config.baseView
        config.upperView = topMessage
        config.isSelected = false
        config.action = #selector(radioButtonListner(_:))
        self.radioGroup  = ExamRadioGroup(defaultConfig: config,
                                          categories: Repository.examCategories,
                                          selectedCode: Preference.categoryCode)
        self.radioGroup.setup()
    }//setupExamRadioButton()
    
    private func startExam() throws {
        log(50, "MenuViewGenericController#startExam")
        let selectedCategory = radioGroup.getSelected()
        if selectedCategory ==  nil {
            throw ExamAppError.runtime(slog(10, "radioGroup.getSelected() == nil"))
        }
        super.startExam()
    }//startExam()

    
    @objc open  func onStartButtonListener(_ sender: UIButton) {
        log(90, "MenuViewGenericController#startButton tapped.")
        do {
            _ = logPrecisely(90, "MenuViewGenericController: try startExam")
            try startExam()
        } catch let e {
            fatalError(slog(10, "MenuViewGenericController#onStartButtonListener:\(e)"))
            // try! gotoMessageView(message: log(10,
            //"MenuViewGenericController#onStartButtonListener:\(e)"), returnView: viewState)
        }
    }//onStartButtonListener(_ sender: UIButton)
    
    
    
    @objc open override func radioButtonListner(_ sender: UIButton) {
        log(10, "ExamViewController#radioButtonClicked(\(sender.titleLabel!.text!))")
        super.radioButtonListner(sender)
    }//radioButtonListner(_ sender: UIButton)
    
    
    
    @objc open  func onshowAllkButtonListener(_ sender: UIButton) {
        log(90, "MenuViewGenericController#hiddenButton tapped.")
        do {
            _ = logPrecisely(90, "MenuViewGenericController: try startExam")
            try startExam()
        } catch let e {
            log(10, "MenuViewGenericController#onshowAllkButtonListener:\(e)")
        }
    }//onshowAllkButtonListener(_ sender: UIButton)
    
    @objc open  func onSelfCheckButtonListener(_ sender: UIButton) {
        log(90, "MenuViewGenericController#hiddenButton tapped.")
        do {
            _ = logPrecisely(90, "MenuViewGenericController: try startExam")
            try startExam()
        } catch let e {
            log(10, "MenuViewGenericController#onSelfCheckButtonListener:\(e)")
        }
    }//onSelfCheckButtonListener(_ sender: UIButton)
    
    @objc open  func onSettingButtonListener(_ sender: UIButton) {
        log(50, "MenuViewGenericController#onSettingButtonListener")
        let storyboard: UIStoryboard = self.storyboard!
        let settingView = storyboard.instantiateViewController(withIdentifier: "SettingView") as! SettingViewGenericController
        viewState = .setting
        self.present(settingView, animated: false, completion: nil)
        log(50, "MenuViewGenericController#onSettingButtonListener:\(viewState)")
    }//onSettingButtonListener
    
    @objc override public func onSwipeListener(sender: UISwipeGestureRecognizer) {
        log(50, "MenuViewGenericController#onSwipeListener: \(sender.direction.value)")
        do {
            if sender.direction == .left {     // forward(->)
                log(90, "MenuViewGenericController#onSwipeListener: startExam")
                try startExam()
           } else if sender.direction == .up {     // up(↑)
                if Repository.checkMode {
                    try gotoMessageView(message: getSelfCheck(), returnView: viewState)
                }
            } else {
                log(90, "MenuViewGenericController#onSwipeListener: undefined swipe")
            }
        } catch let e {
            log(10, "MenuViewGenericController#onSwipeListener:\(e)")
        }
    }//onSwipeListener(sender: UISwipeGestureRecognizer)

/// 画面操作 /////
    ///
    /// ///// 回転処理 /////
    @objc open override func onOrientationChangeListner() {
        log(10, "MenuViewController#onOrientationChangeListner")
        super.onOrientationChangeListner()
    }//onOrientationChangeListner()
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        log(100, "MenuViewGenericController#touchesEnded")
        var location: CGPoint = CGPoint.zero
        for touch in touches {
            location = touch.location(in: self.view)
            log(90, "MenuViewGenericController#touchesEnded() location: \(location)")
        }
        if checkHiddenMode(location: location) {
            log(50, "MenuViewGenericController#touchesEnded: HiddenModeCounter=\(HiddenModeCounter.counter)")
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
                    log(10, "MenuViewGenericController#touchesEnded:\(e)")
                }
            }
            return
        }
        return
    }//touchesEnded
    
    private func getTouchedPoint(touches: Set<UITouch>) -> CGPoint {
        for touch in touches {
            let location = touch.location(in: self.view)
            log(90, "MenuViewGenericController#touchesEnded() location: \(location)")
            return location
        }
        return CGPoint.zero
    }//getTouchedPoint(touches: Set<UITouch>)
    
    
    ////// viewDidLayoutSubviews#layout //////
    override public func viewDidLayoutSubviews() {
        log(50, "MenuViewGenericController#viewDidLayoutSubviews")
       if isError() {
            try! gotoMessageView(message: getError(), returnView: viewState)
            return
        }
        super.viewDidLayoutSubviews()
        do {
            try layoutMenuView()
        } catch let e {
            log(10, "MenuViewGenericController#viewDidLayoutSubviews:\(e)")
        }
    }//viewDidLayoutSubviews()
 
    ////// viewDidLayoutSubviews#layout //////
    
}
