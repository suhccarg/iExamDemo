//
//  CustomViewController.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/21.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer


public let baseViewTag = 1000
public let scrollViewTag = 1001
public let mainTitleViewTag = 1002
public let preTitleViewTag = 1003
public let topMessageViewTag = 1004
public let messageAreaViewTag = 1005

public func getSafeArea(baseView: CustomViewController)
    ->  (top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
        if #available(iOS 11.0, *) {// iOS11以降
            let safe: UIEdgeInsets = baseView.view.safeAreaInsets
            return (top: safe.top, bottom: safe.bottom,
                    left: safe.left, right: safe.right)
        } else {// iOS10以前
            let height = UIApplication.shared.statusBarFrame.size.height
            return (top: height, bottom: 0.0, left: 0.0, right: 0.0)
        }
}//func getSafeArea()


public class CustomViewController: UIViewController {
    public var scroll: UIScrollView!
    public var preTitle: ExamTitle!
    public var mainTitle: ExamTitle!
    public var topMessage: ExamTopMessage!
    public var buttonArea: UILabel!
    public var returnButton: ExamButton!
    public var frameMinX: CGFloat!
    public var frameWidth: CGFloat!

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if ExamColor.mode == .bright || ExamColor.mode == .na {
            return UIStatusBarStyle.default
        } else {
            return UIStatusBarStyle.lightContent
        }
    }//var preferredStatusBarStyle

    override public var prefersStatusBarHidden: Bool { return false }
    
    override public func viewDidLoad() {
        _ = log(50, "CustomViewController#viewDidLoad:\(viewState)")
        super.viewDidLoad()
        clearError()

        currentViewController = self
        self.view.tag = baseViewTag
        //Repository.baseViewSize = self.view.frame.size
        do {
            try ExamColor.apply()
            self.view.backgroundColor = ExamColor.base.uiColor
            try createScrollView()
            try setupTitle()
            try setupTopMessage()
        } catch let e {
            _ = log(10, "CustomViewController#viewDidLoad:\(e)")
        }
    }//viewDidLoad()

    private func createScrollView() throws {
        if viewState == .menu || viewState == .setting {
            scroll = UIScrollView()
            scroll.tag = scrollViewTag
            self.view.addSubview(scroll)
            setupColorScrollView()
        }
    }//createScrollView()
    
    public func setupColor() throws {
        try ExamColor.apply()
        self.view.backgroundColor = ExamColor.base.uiColor
        setupColorScrollView()
        preTitle.setupColor()
        mainTitle.setupColor()
        topMessage.setupColor()
        setupColorButtonArea()
    }//setupColor()
    
    private func setupColorScrollView() {
        scroll.backgroundColor  = ExamColor.base.uiColor
//        scroll.backgroundColor  = ExamColor.lightgreen.uiColor
    }//setupScrollView()
    
    private func setupTitle() throws {
        _ = log(50, "CustomViewController#setupTitle")
        preTitle = try ExamTitle(baseView: self, text: Repository.applicationType.pretitle,
             fontSize: Repository.defaultFontSize)
        preTitle.tag = preTitleViewTag
        mainTitle = try ExamTitle(baseView: self, text: Repository.applicationType.title,
              fontSize: Repository.defaultFontSize * 5 / 4,
               foot: defaultMargin, under: preTitle)
        mainTitle.tag = mainTitleViewTag
    }//setupTitle()
    
    private func setupTopMessage() throws {
        _ = log(50, "CustomViewController#setupTopMessage")
        topMessage = try ExamTopMessage(baseView: self, under: mainTitle)
    }//setupTopMessage()
    
    public func setupButtonArea() throws {
        _ = log(50, "CustomViewController#setupButtonArea")
        self.buttonArea = UILabel()
        setupColorButtonArea()
        self.view.addSubview(self.buttonArea)
    }//setupButtonArea()
    
    private func setupColorButtonArea() {
        self.buttonArea!.backgroundColor = ExamColor.buttonArea.uiColor
    }//setupColorButtonArea()
    
    public func setupReturnButton() throws {
        self.returnButton  = nil
        var config = ExamButtonConfig()
        config.caption = "メニューへ"
        config.action = #selector(onReturnButtonListener(_: ))
        config.width *= 1.2
        config.baseView = self
        config.targetView = config.baseView
        config.align = .left
        config.activeStates = [ .review, .setting, .message ]
        self.returnButton  = try ExamButton(config: config)
        self.view.addSubview(returnButton)
    }//setupReturnButton()
    
    @objc public func onReturnButtonListener(_ sender: UIButton) {
        _ = log(90, "returnButton tapped.")
        try! returnToPreviousView(previousView: .menu)
    }//onReturnButtonListener(_ sender: UIButton)
    
    public func returnToPreviousView(previousView: ViewType) throws {
        viewState = previousView
        self.dismiss(animated: false, completion: nil)
    }//returnToPreviousView()
    
    public func setupExam() throws -> Bool {
        examManager = ExamManager()
        let category: ExamCategory = try ExamCategory.find(code: Repository.categoryCode)
        try examManager.generate(category: category,
                                 count: Repository.questionCount)
        return (examManager.examList.count > 0)
    }//setupExam()

    ///// 回転処理 /////
    public func setupOrientationChangeListner(action: Selector) {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self,
               selector: action,
               name:UIDevice.orientationDidChangeNotification, object:nil)
    }//setupOrientationChangeListner()
    
    @objc public func onOrientationChangeListner() {
        _ = log(10, "CustomViewController#onOrientationChangeListner")
        //Repository.baseViewSize = self.view.frame.size
        if debugLevel > 0 {
            let deviceOrientation = UIDevice.current.orientation
            if deviceOrientation.isLandscape {
                _ = log(90, "CustomViewController#Device orientation: Landscape")
            } else if deviceOrientation.isPortrait {
                _ = log(90, "CustomViewController#Device orientation: Portrait")
            } else {
                _ = log(90, "CustomViewController#Device orientation: Unknown")
            }
        }
    }//onOrientationChangeListner()
    

    ///// スワイプ処理 /////
    public func setupSwipeListener(action: Selector!) throws {
        for direction: UISwipeGestureRecognizer.Direction in [ .right, .left, .up, .down ] {
            let swipe = UISwipeGestureRecognizer(target: self, action: action)
            swipe.direction = direction
            view.addGestureRecognizer(swipe)
        }
    }//setupSwipeListener()
    
    @objc public func onSwipeListener(sender: UISwipeGestureRecognizer) {
            _ = log(50, "CustomViewController#onSwipeListener")
    }
   
    ////// viewDidLayoutSubviews#layout //////
    override public  func viewDidLayoutSubviews() {
        _ = log(50, "CustomViewController#viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        //printScreenMetrics()
        do {
            updateXScale()
            try layout()
        } catch let e {
            _ = log(10, "CustomViewController#viewDidLayoutSubviews:\(e)")
        }
    }//viewDidLayoutSubviews()
   
    public func layout() throws {
        try preTitle.layout()
        try mainTitle.layout()
        try topMessage!.layout(text: generateTopMessage())
        //DeviceOrientation.update(size: self.view.frame.size)
    }//layout()

    public func layoutButtonArea(upperView: UIView) throws {
        _ = log(90, "CustomViewController#layoutButtonArea")
        let frame = self.view.frame
        let safe = getSafeArea(baseView: self)
        let x = frame.minX + safe.right
        let w = frame.width - safe.right - safe.left
        let y = upperView.frame.maxY + 1
        let h = frame.maxY - safe.bottom - y
        self.buttonArea!.frame = CGRect.init(x: x, y: y, width: w, height: h)
    }//layoutButtonArea()
    
    private func updateXScale() {
        let safe = getSafeArea(baseView: self)
        self.frameMinX = self.view.frame.minX + safe.left + defaultMargin
        self.frameWidth = self.view.frame.width - safe.right - safe.left - defaultMargin * 2
    }//updateXScale()
    
    private func generateTopMessage() -> String {
        switch viewState {
        case .setting, .question, .answer, .message:
            return "     "
        case .menu:
            return "出題分野を選択してください。"
        case .review:
            return "出題は以上です。復習しましょう。"
        default:
            try! gotoMessageView(message: log(10, "CustomViewController#generateTopMessage() Invalid state: \(String(describing: viewState))"), returnView: viewState)
            return " "
        }///switch viewState
    }//generateTopMessage()
    
    public func printScreenMetrics() {
        let level = 50
        _ = log(level, "frame.origin.x = \(view.frame.origin.x)")
        _ = log(level, "frame.origin.y = \(view.frame.origin.y)")
        _ = log(level, "frame.width = \(view.frame.width)")
        _ = log(level, "frame.height = \(view.frame.height)")
        let safe = getSafeArea(baseView: self)
        _ = log(level, "safe.top = \(safe.top)")
        _ = log(level, "safe.bottom = \(safe.bottom)")
        _ = log(level, "safe.right = \(safe.right)")
        _ = log(level, "safe.left = \(safe.left)")
    }//printScreenMetrics()
    
    ////// スクロール /////
    public func prepareScrollView(upperView: UIView) throws {
        _ = log(90, "CustomViewController#prepareScrollView frame:\t\(self.view.frame))")
        _ = log(90, "CustomViewController#prepareScrollView safe:\t\(getSafeArea(baseView: self)))")
        try prepareScrollRect(upperView: upperView)
        try prepareContentsRect()
    }//prepareScrollView(baseView: CustomViewController, upperView: UIView)
    
    private func prepareScrollRect(upperView: UIView) throws {
        let x = self.view.frame.minX
        let w = self.view.frame.width
        let y = upperView.frame.maxY + defaultMargin / 2.0
        let h: CGFloat = 10000.0
        _ = log(90, "CustomViewController#prepareScrollRect Scroll:\t\(w) x \(h) at (\(x), \(y))")
        scroll.frame = CGRect.init(x: x, y: y, width: w, height: h)
        _ = log(90, "CustomViewController#prepareScrollRect safe:\t\(getSafeArea(baseView: self))")
    }//prepareScrollRect(baseView: CustomViewController, upperView: UIView)
    
    private func prepareContentsRect() throws {
        let w = Int(self.view.frame.width)
        let h = 10000
        _ = log(90, "CustomViewController#prepareContentsRect Contents:\t\(w) x \(h)")
        scroll.contentSize = CGSize(width: w, height: h)
    }//prepareContentsRect(baseView: CustomViewController, upperView: UIView)
    
    public func layoutScrollView(upperView: UIView, bottomView: UIView, buttonView: UIView) throws {
        _ = log(90, "CustomViewController#layoutScrollView frame:\t\(self.view.frame))")
        _ = log(90, "CustomViewController#layoutScrollView safe:\t\(getSafeArea(baseView: self))")
         if viewState == .menu || viewState == .setting {
            try updateScrollRect(upperView: nil, buttonView: buttonView)
            try updateContentsRect(upperView: nil, bottomView: bottomView)
        }
    }//layoutScrollView(upperView: UIView, bottomView: UIView, buttonView: UIView)
    
    private func updateScrollRect(upperView: UIView?, buttonView: UIView) throws {
        let x = self.view.frame.minX
        let w = self.view.frame.width
        var y: CGFloat
        if let v = upperView {
            y = v.frame.maxY + defaultMargin / 2.0
        } else {
            let safe = getSafeArea(baseView: self)
            y = self.view.frame.minY + safe.top
        }
        let h = buttonView.frame.minY - defaultMargin - y
        _ = log(90, "CustomViewController#updateScrollRect Scroll:\t\(w) x \(h) at (\(x), \(y))")
        scroll.frame = CGRect.init(x: x, y: y, width: w, height: h)
    }//updateScrollRect(upperView: UIView, buttonView: UIView)
    
    private func updateContentsRect(upperView: UIView?, bottomView: UIView) throws {
        let w = self.view.frame.width
//        let h = bottomView.frame.maxY
//            - upperView.frame.minY + defaultMargin * 10
        var h: CGFloat
        if let v = upperView {
            h = bottomView.frame.maxY
                - v.frame.minY + defaultMargin * 3
        } else {
            h = bottomView.frame.maxY + defaultMargin * 3
        }
        _ = log(90, "CustomViewController#updateContentsRect Contents:\t\(w) x \(h)")
        scroll.contentSize = CGSize(width: w, height: h)
    }//updateContentsRect(upperView: UIView, bottomView: UIView)
    

    ////// メッセージ表示 /////
    public func gotoMessageView(message: String, returnView: ViewType) throws {
        _ = log(50, "gotoMessageView")
        let storyboard: UIStoryboard = self.storyboard!
        let messageView = storyboard.instantiateViewController(withIdentifier: "MessageView") as! MessageViewController
        messageView.message = message
        messageView.returnView = returnView
        viewState = .message
        self.present(messageView, animated: false, completion: nil)
    }//gotoMessageView()
    
//    override public func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }//func didReceiveMemoryWarning()
    
}//class CustomViewController

public class ExamLabel: UITextView {
    weak public var baseView: CustomViewController!
    public var upperView: UIView!
    public var fontSize: CGFloat
    let heightMargin: CGFloat = 8
    let leftMargin: CGFloat = 8
//    // webview 内のテキスト選択禁止
//    static let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
//    // webview 内の⻑押しによるメニュー表示禁止
//    static let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
    
    init(baseView: CustomViewController, text: String, fontSize: CGFloat, under upperView: UIView?)  throws {
        self.baseView = baseView
        self.upperView = upperView
        self.fontSize = fontSize
        super.init(frame: CGRect.zero, textContainer: nil)
        self.isEditable = false
        self.isSelectable = false
        self.isScrollEnabled = false
        _ = log(50, "ExamLabel#init(view: UIView):\(text)")
        setup(text: text, fontSize: fontSize)
    }//init(baseView: CustomViewController, caption: String, upper: UIControl)
    
    convenience init(baseView: CustomViewController, text: String, fontSize: CGFloat)  throws {
        try self.init(baseView: baseView, text: text, fontSize: fontSize, under: nil)
    }//init(baseView: CustomViewController, caption: String)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)

   public func setup(text: String, fontSize: CGFloat) {
    _ = log(50, "ExamLabel#setup:\(text)")
        //self.font = self.font!.withSize(fontSize)
        self.fontSize = fontSize
        self.text = text
        if let scroll = self.baseView!.scroll {
            scroll.addSubview(self)
        } else {
            self.baseView!.view.addSubview(self)
        }
    }//setup(caption: String)
    
    public func setup(text: String) {
        self.setup(text: text, fontSize: Repository.defaultFontSize)
    }//setup(text: String)

    public func layout() throws {
        _ = log(50, "ExamLabel#layout: \"\(self.text!)\"")
//        self.font = UIFont.boldSystemFont(ofSize: self.fontSize)
        self.font = UIFont.systemFont(ofSize: self.fontSize)
        self.frame = getDrawRect()
        _ = log(90, "ExamLabel#layout: \(self.frame.size.width) x \(self.frame.size.height) at (\(self.frame.minX), \(self.frame.minY))")
    }//layout()
    
    public func getDrawRect() -> CGRect {
        var x : CGFloat
        var y : CGFloat
        var w : CGFloat
        let h = self.fontSize * 4.0 / 3.0 + heightMargin
        let safe = getSafeArea(baseView: self.baseView!)
        if let v = self.upperView {
            x = v.frame.minX
            y = v.frame.maxY
            w = self.baseView!.view.frame.width - safe.right - safe.left - defaultMargin * 2.0
        } else {
            x = self.baseView!.view.frame.minX + safe.left + defaultMargin
            if self.baseView!.scroll != nil {
                y = self.baseView!.view.frame.minY
            } else {
                y = self.baseView!.view.frame.minY + safe.top
            }
            w = self.baseView!.view.frame.width - safe.right - safe.left - defaultMargin * 2.0
        }
        return CGRect.init(x: x, y: y, width: w, height: h)
    }//getDrawRect()
    
}//class ExamLabel: UILabel


public class ExamTitle: ExamLabel {
    fileprivate var edgeLabel: UILabel!
    fileprivate var foot: CGFloat!
    
    public init(baseView: CustomViewController, text: String, fontSize: CGFloat, foot: CGFloat, under upperView: UIView?)  throws {
        self.edgeLabel = UILabel()
        self.foot = foot
        try super.init(baseView: baseView, text: text,
                       fontSize: fontSize, under: upperView)
        _ = log(50, "ExamTitle#init(view: UIView):  \(text)")
    }//init(baseView: CustomViewController, ... upperView: UIView?)
    
    convenience public init(baseView: CustomViewController, text: String, fontSize: CGFloat)  throws {
        try self.init(baseView: baseView, text: text, fontSize: fontSize, foot: 0.0, under: nil)
    }//init(baseView: CustomViewController, caption: String)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("ExamTitle#init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)
    
    override public func setup(text: String, fontSize: CGFloat) {
        _ = log(50, "ExamTitle#setup: (\(text))")
        setupColor()
//        self.baseView!.view.addSubview(self.labelEdge)
        if let scroll = self.baseView!.scroll {
            scroll.addSubview(self.edgeLabel)
        } else {
            self.baseView!.view.addSubview(self.edgeLabel)
        }
        super.setup(text: text, fontSize: fontSize)
    }//setup(caption: String)
    
    public func setupColor() {
        self.backgroundColor = ExamColor.titleBar.uiColor
        self.textColor = ExamColor.titleText.uiColor
        self.edgeLabel.backgroundColor = self.backgroundColor
    }//setupColor()
    
    override public func layout() throws {
        try super.layout()
        try layoutLabelEdge()
    }//layout()
    
    private func layoutLabelEdge() throws {
        let x = baseView!.view.frame.minX
        let y = self.frame.maxY + self.foot - 1.0
        let w = baseView!.view.frame.maxX - baseView!.view.frame.minX
        let h = -(self.frame.height + self.foot + 1.0)
        edgeLabel.frame = CGRect.init(x: x, y: y, width: w, height: h)
        if debugLevel > 100 {
            edgeLabel.layer.borderColor = UIColor.red.cgColor
            edgeLabel.layer.borderWidth = 1.0
            edgeLabel.backgroundColor = UIColor.green
        }
    }//layoutLabelEdge()
    
}//class ExamTitle: ExamLabel

public class ExamTopMessage: ExamLabel {
    private var origin: CGPoint
    
    public init(baseView: CustomViewController, fontSize: CGFloat, under upperView: UIView?)  throws {
        self.origin = CGPoint(x: 0.0, y: 0.0)
        try super.init(baseView: baseView, text: " ",
                       fontSize: fontSize, under: upperView)
        _ = log(50, "ExamTopMessage#init")
    }//init(baseView: CustomViewController, fontSize: CGFloat, under upperView: UIView?)
    
    convenience public init(baseView: CustomViewController)  throws {
        try self.init(baseView: baseView,  fontSize: Repository.defaultFontSize, under: nil)
    }//init(baseView: CustomViewController)
    
    convenience public init(baseView: CustomViewController, under upperView: UIView?)  throws {
        try self.init(baseView: baseView,  fontSize: Repository.defaultFontSize, under: upperView)
    }//init(baseView: CustomViewController, under upperView: UIView?)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }//init?(coder aDecoder: NSCoder)
    
    override public func setup(text: String, fontSize: CGFloat) {
        super.setup(text: text, fontSize: fontSize)
        _ = log(50, "ExamTopMessage#setup")
        setupColor()
    }//setup(text: String, fontSize: CGFloat)
    
    public func setupColor() {
        self.backgroundColor = UIColor.clear
        self.textColor = ExamColor.normalText.uiColor
    }//setupColor()

    override public func setup(text: String) {
        self.setup(text: text, fontSize: Repository.defaultFontSize)
    }//setup(text: String)
    
    public func setOrigin(x: CGFloat, y: CGFloat) {
        self.origin = CGPoint(x: x, y: y)
    }//setOrigin(x: CGFloat, y: CGFloat)
    
    ///// レイアウト /////
    public func layout(text: String) throws {
        _ = log(50, "ExamTopMessage#layout(\"\(text)\")")
        self.text = text
        // self.font = UIFont.boldSystemFont(ofSize: super.fontSize)
        try super.layout()
        let x = self.frame.minX
        let w = self.frame.width
        var y = self.frame.minY
        var h = self.frame.height
        switch viewState {
        case .menu, .review:
            self.textColor = ExamColor.normalText.uiColor
            y += defaultMargin * 2.0
            h = Repository.defaultFontSize * 2.5
        case .setting, .question,  .answer, .message:
            self.textColor = self.backgroundColor
            h = Repository.defaultFontSize * 0.5
        default:
//            throw ExamError.runtime(log(10, "Invalid state: \(String(describing: viewState))"))
            _ = log(10, "ExamTopMessage#layout(\(viewState.value()): Invalid state)")
        }//switch viewState
//        self.backgroundColor = ExamColor.cyan.uiColor
        self.frame = CGRect.init(x: x, y: y, width: w, height: h)
        _ = log(90, "ExamTopMessage#layout: \(self.frame.size.width) x \(self.frame.size.height) at (\(self.frame.minX), \(self.frame.minY))")
    }//layout()
 
}//class ExamTopMessage


public class ExamDividingLine {
    weak var baseView: CustomViewController!
    private var paths: [UIBezierPath]
    private var lineLayers: [CAShapeLayer?]
    private var lineColors: [UIColor] {
        return  [
            ExamColor.dividingLineTop.uiColor,
            ExamColor.dividingLineBottom.uiColor
        ]
    }//lineColors
    public static let lineWidth: CGFloat = 4.0
    
    public init(baseView: CustomViewController) {
        self.baseView = baseView
        self.paths = []
        self.paths.append(UIBezierPath())
        self.paths.append(UIBezierPath())
        self.lineLayers = [nil, nil]
        clear()
    }//init(baseView: SettingViewController)
    
    public func clear() {
        for i in 0 ..< self.lineLayers.count {
            if self.lineLayers[i] != nil {
                self.lineLayers[i]!.removeFromSuperlayer()
                self.lineLayers[i] = nil
            }
        }
    }//clear()
    
    public func draw(upperView: UIView) {
        draw(minY: upperView.frame.maxY, margin: 0)
    }//draw(upperView: UIView)
 
    public func draw(upperView: UIView, margin: CGFloat) {
        _ = log(90, "ExamDividingLine#draw upperView = \(upperView.frame.values)")
        let minY = upperView.frame.maxY
            + defaultMargin / 2.0 - ExamDividingLine.lineWidth / 2.0 + margin
        _ = log(90, "ExamDividingLine#draw:\ttopY \(minY) = upperMaxY \(upperView.frame.maxY) + \(defaultMargin / 2.0 - ExamDividingLine.lineWidth / 2.0 + margin)")
        draw(minY: minY, margin: margin)
    }//draw(upperView: UIView, margin: CGFloat)
    
    public func draw(lowerView: UIView, margin: CGFloat) {
        _ = log(90, "ExamDividingLine#draw lowerView = \(lowerView.frame.values)")
        let minY = lowerView.frame.minY
            - defaultMargin / 2.0 - ExamDividingLine.lineWidth / 2.0 - margin
        _ = log(90, "ExamDividingLine#draw:\ttopY \(minY) = lowerMinY \(lowerView.frame.minY) + \(defaultMargin / 2.0 - ExamDividingLine.lineWidth / 2.0 - margin)")
        draw(minY: minY, margin: margin)
    }//draw(lowerView: UIView, margin: CGFloat)
    
    public func draw(minY: CGFloat, margin: CGFloat) {
        let safe = getSafeArea(baseView: baseView)
        let minX: CGFloat = 0.0
        let maxX = baseView.view.frame.maxX + safe.right
        let topY = minY
        let bottomY = topY + ExamDividingLine.lineWidth / 2.0
        
        self.paths[0].move(to: CGPoint(x: minX, y: topY))
        self.paths[0].addLine(to: CGPoint(x: maxX, y: topY))
        
        self.paths[1].move(to: CGPoint(x: minX, y: bottomY))
        self.paths[1].addLine(to: CGPoint(x: maxX, y: bottomY))
        _ = log(90, "ExamDividingLine#draw:\t\(topY),\(bottomY) \(minX)->\(maxX)")
    }//draw(upperView: UIView, margin: Int)
    
    public func apply(targetView: UIView) {
        for i in 0 ..< 2 {
            lineLayers[i] = CAShapeLayer()
            lineLayers[i]!.path = paths[i].cgPath
            lineLayers[i]!.strokeColor = lineColors[i].cgColor
            lineLayers[i]!.fillColor = UIColor.clear.cgColor
            lineLayers[i]!.lineWidth = ExamDividingLine.lineWidth / 2.0
            //            self.baseView.scroll.layer.addSublayer(lineLayers[i]!)
            targetView.layer.addSublayer(lineLayers[i]!)
        }//for i in 0 ..< 2
    }//apply()
}//class ExamDividingLine

/** End of File **/
