//
//  MessageViewController.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/08/02.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
import UIKit
<<<<<<< HEAD:ExamShugiDenKou/src/VIew/MessageViewController.swift
<<<<<<< HEAD:ExamShugiDenKou/src/VIew/MessageViewController.swift
import ExamLib_iOS1
=======
#if canImport(ExamLib)
import ExamLib
#endif
>>>>>>> develop8:ExamShugiDenKou/src/View/MessageViewController.swift
=======
#if canImport(ExamLib)
import ExamLib
#endif
>>>>>>> develop8:ExamShugiDenKou/src/View/MessageViewController.swift

public class MessageViewController: MessageViewBaseController {
    private var messageViewArea: ExamLabel!
    public var message: String = "."
    public var returnView: ViewType = .unknown
    
    override public func viewDidLoad() {
        viewState = .message
        log(50, ":\(viewState)")
        super.viewDidLoad()
        do {
            try setupMessageView()
            try setupReturnButton()
            returnButton.setTitle("戻る", for: .normal)
        } catch let e {
            log(10, ":\(e)")
        }
    }//viewDidLoad()
    
    private func setupMessageView() throws {
        messageViewArea = try ExamLabel(baseView: self, text: message, fontSize: Repository.defaultFontSize, under: mainTitle)
        messageViewArea.textColor = ExamColor.normalText.uiColor
        messageViewArea.backgroundColor = ExamColor.background.uiColor
        messageViewArea.layer.borderColor = ExamColor.frameTopLeft.cgColor
        messageViewArea.isScrollEnabled = true
        self.view.addSubview(messageViewArea)
    }//setupMessageView

    
    override public func returnToPreviousView(previousView: ViewType) throws {
        viewState = self.returnView
        self.dismiss(animated: false, completion: nil)
    }//returnToPreviousView()
    
    ///// レイアウト /////
    override public func viewDidLayoutSubviews() {
        log(50, ":\(viewState)")
        super.viewDidLayoutSubviews()
        do {
            try returnButton.layout()
            try layoutMessageViewArea()
        } catch let e {
            log(10, ":\(e)")
        }
    }//viewDidLayoutSubviews()

    public func layoutMessageViewArea() throws {
        log(50)
        let frame = self.view.frame
        let safe = getSafeArea(baseView: self)
        let x = safe.left + defaultMargin
        let bottonOfBaseView = mainTitle.frame.minY + mainTitle.frame.height + defaultMargin
        let y = bottonOfBaseView + defaultMargin
        let w = frame.width - safe.left - safe.right - defaultMargin * 2
        let h = returnButton.frame.minY  - bottonOfBaseView - defaultMargin * 2
        messageViewArea.frame = CGRect.init(x: x, y: y, width: w, height: h )
        log(50, "mainTitle: \(mainTitle.frame.size.width.d1), \(mainTitle.frame.size.height.d1) at (\(mainTitle.frame.minX.d1), \(mainTitle.frame.minY.d1))")
        log(50, "messageView: \(messageViewArea.frame.size.width.d1), \(messageViewArea.frame.size.height.d1) at (\(messageViewArea.frame.minX.d1), \(messageViewArea.frame.minY.d1))")
        log(50, "menuButton: \(returnButton.frame.size.width.d1), \(returnButton.frame.size.height.d1).d1) at (\(returnButton.frame.minX.d1), \(returnButton.frame.minY.d1)")
    }//layoutMessageViewArea)
}//class MessageViewController

/** End of File **/
