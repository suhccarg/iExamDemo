//
//  Button.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/08/16.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import WebKit
#if canImport(ExamPackage)
import ExamPackage
#endif


public enum ButtonAlign { case left, center, right, unknown }
   
let defaultButtonHeight: CGFloat = 30
let defaultButtonWidth: CGFloat = 70
let defaultButtonFontSize: CGFloat = 12.0

public struct ExamButtonConfig {
    var caption: String = ""
    var action: Selector! = nil
    var width: CGFloat = defaultButtonWidth
    var height: CGFloat = defaultButtonHeight
    var fontSize: CGFloat = defaultButtonFontSize
    weak var baseView: CustomViewController! = nil
    weak var targetView: NSObject! = nil
    var upperView: UIView? = nil
    var align: ButtonAlign = .unknown
    var activeStates: [ViewType] = []
}//struct ExamButtonConfig

//public class Hoge: Util {
//
//
//}
//
//public class Moge: ExamWebView {
//
//}
public class ExamButton: UIButton {
    private let buttonMargin : CGFloat = defaultMargin
    public var config: ExamButtonConfig!
    
    let heightMargin: CGFloat = defaultMargin
    let leftMargin: CGFloat = defaultMargin
    
    public init(config: ExamButtonConfig)  throws {
        self.config = config
        super.init(frame: CGRect.zero)
        if let action = config.action {
            self.addTarget(config.baseView, action: action, for: UIControl.Event.touchUpInside)
        }
        log(90, "hoge")
        log(90, "(...) :\(config.caption)")
        setup(config: config)
    }//init(...)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)
    
    public func setup(config: ExamButtonConfig) {
        log(90, ":\(config.caption)")
        setupColor()
        self.layer.masksToBounds = true     // ボタンの枠を丸く
        self.layer.cornerRadius = 5.0      // コーナーの半径
        self.titleLabel!.font = UIFont.systemFont(ofSize: config.fontSize)
        self.setTitle(config.caption, for: .normal)
        config.baseView!.view.addSubview(self)
    }//setup(config: ExamButtonConfig)
    
    public func setupColor() {
        self.setBackgroundImage(ExamColor.normalButtonBaseImage, for: .normal)
        self.setBackgroundImage(ExamColor.pushedButtonBaseImage, for: .highlighted)
        self.setTitleColor(ExamColor.normalButtonText.uiColor, for: .normal)
        self.setTitleColor(ExamColor.pushedButtonText.uiColor, for: .highlighted)
    }//setupColor()

    ///// レイアウト /////
    public func layout() throws {
        log(90, ": \(config!.caption)")
        guard let c = self.config else {
            throw ExamAppError.runtime("ExamButton#layout: config=nil")
        }
        if c.activeStates.contains(viewState)
            || c.activeStates.contains(.always) {
            let w = Int(config!.width)
            let h = Int(config!.height)
            let rect: CGRect = CGRect.init(x: try getX(), y: try getY(), width: w, height: h)
            self.frame = rect
            log(90, "() [\(self.tag)]: \(self.frame.size.width) x \(self.frame.size.height) at (\(self.frame.minX), \(self.frame.minY))")
            self.isHidden = false
        } else {
            log(90, "() [\(self.tag)]: hidden -> true")
            self.isHidden = true
        }//if c.hiddenStates.contains(viewState) ... else
    }//layout()
    
    private func getX() throws -> Int {
        guard let c = self.config else {
            throw ExamAppError.runtime("ExamButton#layout: config: nil")
        }
        let safe = getSafeArea(baseView: c.baseView!)
        
        switch c.align {
        case .left:
            if let v = config!.upperView {
                let baseX = v.frame.minX
                let baseW = v.frame.width
                return Int(baseX + baseW + buttonMargin)
            } else {
                return Int(safe.left + buttonMargin)
            }
        case .center:
            let v = c.baseView!.view
            return Int((v!.frame.width  - safe.right - safe.left
                - c.width) / 2)
        case .right:
            if let v = config!.upperView {
                let baseX = v.frame.minX
                let width = c.width
                return Int(baseX - buttonMargin - width)
            } else {
                return Int(c.baseView!.view.frame.width - buttonMargin
                    - safe.right - safe.left - c.width)
            }
        default:
            throw ExamAppError.runtime("ExamButton#getX: Invalid origin \(String(describing: c.align))")
        }
    }//getX()
    
    private func getY() throws -> Int {
        guard let c = self.config else {
            throw ExamAppError.runtime("ExamButton#getY: config: nil")
        }
        let safe = getSafeArea(baseView: c.baseView!)
        if let v = config!.upperView {
            return Int(v.frame.minY)
        } else {
            return Int(c.baseView!.view.frame.height  - safe.bottom - buttonMargin - c.height)
        }
    }//getY()
    
}//class ExamButton


public class ExamRadioGroup {
    private var buttons: [ExamRadioButton]
    private var selected: ExamCategory!
    
    public init(defaultConfig: ExamRadioConfig, categories: [ExamCategory], selectedCode: Int?) {
        var config = ExamRadioConfig()
        config.deepCopy(from: defaultConfig)
        self.buttons = []
//        var previousView = config.upperView
        var previousView: UIView = config.baseView.topMessage
        for i in 0 ..< categories.count {
            config.category = categories[i]
            config.upperView = previousView
            config.isSelected = false
            let newButton = ExamRadioButton(config: config, radioGroup: self)
            self.buttons.append(newButton)
            previousView = newButton
            config = ExamRadioConfig()
            config.deepCopy(from: defaultConfig)
        }//for i in 0 ..< labels.count
        select(tag: selectedCode!)
    }//init(defaultConfig: ExamRadioConfig, labels: [String], selected: Int?)
    
    public func setup() {
        for b in buttons {
            b.setup()
        }
    }//setup()
    
    public func setupColor() {
        for b in buttons {
            b.setupColor()
            b.redraw()
        }
    }//setupColor()
    
    public func layout() throws {
        for b in buttons {
            try b.layout()
        }
    }//layout()
    
    public func getSelected() -> ExamCategory? {
        return self.selected
    }//getSelected()
    
    public func select(sender: UIButton) {
        select(tag: sender.tag)
    }//select(sender: UIButton)
    
    public func select(tag: Int) {
        var checkExists = false
        do {
            self.selected = try ExamCategory.find(code: tag)
            for b in buttons {
                if b.tag == tag && !b.isSelected {
                    b.check(selected: true)
                    checkExists = true
                } else if b.tag != tag && b.isSelected {
                    b.check(selected: false)
                }
            }//for b in buttons
            if !checkExists {
                buttons[0].check(selected: true)
                self.selected = try ExamCategory.find(code: buttons[0].tag)
            }
        } catch let e {
            log(10, "(\(tag)):\(e)")
        }
    }//select(sender: UIButton)
    
    public func getLabels() -> [UILabel] {
        var labels: [UILabel] = []
        for b in buttons {
            labels.append(b.label)
        }
        return labels
    }//getLabels()
    
    public func getBottomButton() -> ExamRadioButton {
        return self.buttons[buttons.count - 1]
    }//getBottomButton()
    
    public func getBottomLabel() -> ExamRadioButton {
        return self.buttons[buttons.count - 1]
    }//getBottomButton()
    
}//class ExamRadioGroup


public class ExamRadioButton: UIButton {
    private var config: ExamRadioConfig!
    public var label: UILabel!
    private var frameShapeLayer:CAShapeLayer!
    private var checkShapeLayer:CAShapeLayer!
    
    private static let lineWidth:CGFloat = 2
    private static let buttonSize = Repository.defaultFontSize * 2.5
    
    init(config: ExamRadioConfig, radioGroup: ExamRadioGroup)  {
        self.config = config
        self.label = nil
        //        self.label = ExamRadioLabel(config: config)
        super.init(frame: CGRect.zero)
        self.setTitle(String(config.category.code), for: .normal)
        if let target = config.targetView {
            self.addTarget(target,
                           action: config.action!,
                           for: UIControl.Event.touchUpInside)
        }
        log(90, "(...): \(self.tag)")
        setup()
    }//init(...)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)
    
    @objc public func radioButtonClicked(_ sender: UIButton) {
        log(90, "(...): \(self.tag)")
        isSelected = !isSelected
        check(selected: isSelected)
    }
    
    public func setup() {
        setupButton()
        setupLabel()
    }//setup()
    
    public func setupButton() {
        self.setTitleColor(UIColor.clear, for: .normal)
        self.setTitleColor(UIColor.clear, for: .highlighted)
        self.backgroundColor = UIColor.clear
        self.tag = config.category.code
        log(90, ":\(self.tag)")
//        let base = config.baseView as! MenuViewController
//        base.scroll.addSubview(self)
        config.baseView.scroll.addSubview(self)
    }//setupButton()
    
    public func setupLabel() {
        label = UILabel()
        label.numberOfLines = 0
        label.tag = tag
        setupLabelColor()
        label.text = config.category.description
        label.font = UIFont.systemFont(ofSize: Repository.defaultFontSize)
        log(90, ": \(label.tag)")
        if Repository.debugLevel > 100 {
            label.layer.borderColor = UIColor.red.cgColor
            label.layer.borderWidth = 1.0
        }
        config.baseView.scroll.addSubview(label)
    }//setupLabel()
    
    public func setupColor() {
        setupLabelColor()
    }//setupColor()
    
    private func setupLabelColor() {
        label.backgroundColor = ExamColor.base.uiColor
        label.textColor = ExamColor.normalText.uiColor
    }//setupLabelColor()
    
    override public func draw(_ rect: CGRect) {
        log(90, ":\(self.tag)  \(rect.width) x \(rect.height) at (\(rect.minX), \(rect.minY))")
        super.draw(rect)
        drawFrame()
        drawCheck()
    }//draw(_ rect: CGRect)
    
    public func redraw() {
        drawFrame()
        drawCheck()
    }//redraw()
    
    private func drawFrame() {
        let framePath = UIBezierPath()
        let center = CGPoint(x:ExamRadioButton.buttonSize / 2,
                             y:ExamRadioButton.buttonSize / 2 + defaultMargin / 2)
        framePath.addArc(withCenter: center,
                         radius: ExamRadioButton.buttonSize / 4,
                         startAngle: 0,
                         endAngle: CGFloat.pi * 2,
                         clockwise: true)
//        framePath.stroke()
        framePath.fill(with: CGBlendMode.clear, alpha: 0)
        if frameShapeLayer != nil {
            frameShapeLayer.removeFromSuperlayer()
            frameShapeLayer = nil
        }
        frameShapeLayer = CAShapeLayer()
        frameShapeLayer.path = framePath.cgPath
        frameShapeLayer.strokeColor = ExamColor.normalText.cgColor
        frameShapeLayer.fillColor = UIColor.clear.cgColor
        frameShapeLayer.lineWidth = ExamRadioButton.lineWidth
        self.layer.addSublayer(frameShapeLayer)
    }//drawFrame()
    
    private func drawCheck() {
        let checkPath = UIBezierPath()
        let center = CGPoint(x:ExamRadioButton.buttonSize / 2,
                             y:ExamRadioButton.buttonSize / 2 + defaultMargin / 2)
        checkPath.addArc(withCenter: center,
                         radius: ExamRadioButton.buttonSize / 12,
                         startAngle: 0,
                         endAngle: CGFloat.pi * 2,
                         clockwise: true)
        checkPath.fill(with: CGBlendMode.clear, alpha: 0)
        if checkShapeLayer != nil {
            checkShapeLayer.removeFromSuperlayer()
            checkShapeLayer = nil
        }
        checkShapeLayer = CAShapeLayer()
        checkShapeLayer.strokeColor = ExamColor.normalText.cgColor
        checkShapeLayer.path = checkPath.cgPath
        if isSelected {
            checkShapeLayer.fillColor = ExamColor.normalText.cgColor
        } else {
            checkShapeLayer.fillColor = UIColor.clear.cgColor
        }
        checkShapeLayer.lineWidth = ExamRadioButton.lineWidth
        self.layer.addSublayer(checkShapeLayer)
    }//drawCheck()
    
    public func check(selected: Bool) {
        //setNeedsDisplay()
        log(90, "(\(selected)): \(self.tag)")
        self.isSelected = selected
        return
    }//check(selected: Bool)
    
    public func layout() throws {
        log(90, ": \(self.tag)")
        if self.label != nil {
            self.label.removeFromSuperview()
        }
        self.label = UILabel()
        self.label.text = config.category.description
        resetLabel(tag: self.tag)

        let scrollFrame = config.baseView.scroll.frame
        let safe = getSafeArea(baseView: self.config.baseView!)
//        let buttonSize = ExamRadioButton.defaultButtonSize
        let buttonX = scrollFrame.minX + safe.left + defaultMargin
        let labelX = buttonX + ExamRadioButton.buttonSize
        var y: CGFloat = 0.0
        if config.upperView != nil {
            y = config.upperView!.frame.maxY
        }
        let buttonW = scrollFrame.width - defaultMargin * 2.0 - safe.left - safe.right
        let labelW = buttonW - ExamRadioButton.buttonSize
        let h = ExamRadioButton.buttonSize + defaultMargin
        if Repository.debugLevel > 100 {
            self.layer.borderColor = UIColor.red.cgColor
            self.layer.borderWidth = 1.5
            label.layer.borderColor = UIColor.blue.cgColor
            label.layer.borderWidth = 3.0
            label.backgroundColor = UIColor.cyan
        }
        self.frame = CGRect.init(x: buttonX, y: y, width: buttonW, height: h )
        log(90, ":\(self.tag) \(self.frame.size.width) x \(self.frame.size.height) at (\(self.frame.minX), \(self.frame.minY)) ")

        label.frame = CGRect.init(x: labelX, y: y, width: labelW, height: h )
        log(90, ":\(label.tag) \(label.frame.size.width) x \(label.frame.size.height) at (\(label.frame.minX), \(label.frame.minY)) ")
//        drawFrame()
//        drawCheck()
    }//layoutLabel()
    
    public func resetLabel(tag: Int) {
        label.tag = tag
        setupLabel()
        //config.baseView.scroll.sendSubviewToBack(label)
    }//setup(tag: Int)
    
 
}//ExamRadioButton


/** End of File **/
