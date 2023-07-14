//
//  ExamViewController.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/06/28.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import UIKit
import WebKit
import SQLite3

 
class ExamViewController: CustomViewController {
    private var webView: ExamFullWebView!
    private var gotoAnswerButton: ExamButton!
    private var gotoBackButton: ExamButton!         // 問題へ戻る
    private var gotoNextButton: ExamButton!         // 次の問題 or レビュー
    private var gotoNewExamButton: ExamButton!      // 次の出題セット
    private var breakButton: ExamButton!         //
    private var htmlInView: String!
    
    
    override func viewDidLoad() {
        _ = log(50, "ExamViewController#viewDidLoad:\(viewState)")
        super.viewDidLoad()
        do {
            try setupGotoAnswerButton()
            try setupGotoBackButton()
            try setupGotoNextButton()
            try setupGotoNewExamButton()
            try setupReturnButton()
            try setupBreakButton()
            try setupWebView()
            setupOrientationChangeListner(action: #selector(onOrientationChangeListner))
            try setupSwipeListener(action: #selector(onSwipeListener(sender: )))
            try startExam()
        } catch let e {
            onError(log(10, "ExamViewController#viewDidLoad:\(e)"))
//            try! gotoMessageView(message: log(10, "ExamViewController#viewDidLoad:\(e)"))
        }
    }//viewDidLoad()
    
    ///// UI初期化 /////
   private func setupGotoAnswerButton() throws {
        var config = ExamButtonConfig()
        config.caption = "解答を見る"
        config.action = #selector(onGotoAnswerButtonListener(_: ))
        config.width *= 1.2
        config.baseView = self
        config.targetView = config.baseView
        config.align = .right
        config.activeStates = [ .question ]
        gotoAnswerButton  = try ExamButton(config: config)
    }//setupGotoAnswerButton()
    
    private func setupGotoBackButton() throws {
        var config = ExamButtonConfig()
        config.caption = "問題へ戻る"
        config.action = #selector(onGotoBackButtonListener(_: ))
        config.width *= 1.2
        config.baseView = self
        config.targetView = config.baseView
        config.align = .center
        config.activeStates = [ .answer ]
        gotoBackButton  = try ExamButton(config: config)
    }//setupBackButton()
    
    private func setupGotoNextButton() throws {
        var config = ExamButtonConfig()
        config.caption = "次へ進む"
        config.action = #selector(onGotoNextButtonListener(_: ))
        config.width *= 1.2
        config.baseView = self
        config.targetView = config.baseView
       config.align = .right
        config.activeStates = [ .answer ]
        gotoNextButton  = try ExamButton(config: config)
    }//setupNextButton()
    
    private func setupGotoNewExamButton() throws {
        var config = ExamButtonConfig()
        config.caption = "次の出題へ"
        config.action = #selector(onGotoNewExamButtonListener(_: ))
        config.width *= 1.5
        config.baseView = self
        config.targetView = config.baseView
        config.align = .center
        config.activeStates = [ .review ]
        gotoNewExamButton  = try ExamButton(config: config)
    }//setupGotoNewExamButton()

    private func setupBreakButton() throws {
        var config = ExamButtonConfig()
        config.caption = "中断"
        config.action = #selector(onReturnButtonListener(_: ))
        config.baseView = self
        config.targetView = config.baseView
        config.align = .left
        config.activeStates = [ .question, .answer ]
        breakButton  = try ExamButton(config: config)
    }//setupGotoQuestionButton()

    
   private func setupWebView() throws {
        self.webView = try ExamFullWebView(baseView: self,
                      under: topMessage)
  }//setupWebView()
   
    ///// イベント処理 /////
    @objc private func onGotoAnswerButtonListener(_ sender: UIButton) {
        _ = log(90, "gotoAnswerButton tapped.")
        try! gotoAnswer()
        //self.performSegue(withIdentifier: "gotoSubSegue", sender: nil)
    }//onGotoAnswerButtonListener(_ sender: UIButton)
    
    @objc private func onGotoQuestionButtonListener(_ sender: UIButton) {
        _ = log(90, "gotoQuestionButton tapped.")
        try! gotoQuestion()
    }//onGotoQuestionButtonListener(_ sender: UIButton)
    
    @objc private func onGotoBackButtonListener(_ sender: UIButton)  {
        _ = log(90, "gotoBackButton tapped.")
        do {
            try gotoQuestion()
        } catch let e {
//            fatalError(log(10, "ExamViewController#onGotoBackButtonListener:\(e)"))
            try! gotoMessageView(message: log(10, "ExamViewController#onGotoBackButtonListener:\(e)"), returnView: viewState)
        } // do ... catch let e
    }//onGotoBackButtonListener(_ sender: UIButton)
    
    @objc private func onGotoNextButtonListener(_ sender: UIButton)  {
        _ = log(90, "gotoNextButton tapped.")
        do {
            try gotoNext()
        } catch let e {
//            fatalError(log(10, "ExamViewController#onGotoNextButtonListener:\(e)"))
            try! gotoMessageView(message: log(10, "ExamViewController#onGotoNextButtonListener:\(e)"), returnView: viewState)
        } // do ... catch let e
    }//onGotoNextButtonListener(_ sender: UIButton)
    
    @objc private func onGotoNewExamButtonListener(_ sender: UIButton) {
        _ = log(90, "gotoNewExamButton tapped.")
        _ = try! setupExam()
        try! startExam()
        try! gotoQuestion()
    }//onGotoNewExamButtonListener(_ sender: UIButton)
 
    ///// 遷移処理 /////
    private func startExam() throws {
        try examManager.next()
    }//startExam()

    private func gotoNext() throws {
        if examManager.hasNext() {
            try examManager!.next()
            try gotoQuestion()
        } else {
            try gotoReview()
        }//if (ExamManager.hasNext()) ... else
    }//gotoNext()
    
    private func gotoQuestion() throws {
        viewState = .question
       _ = log(50, "ExamViewController#gotoQuestion:\(viewState)")
        try layout()
    }//gotoQuestion()

    private func gotoAnswer() throws {
        viewState = .answer
        _ = log(50, "ExamViewController#gotoAnswer:\(viewState)")
        try layout()
    }//gotoAnswer()
    
    private func gotoReview() throws {
        viewState = .review
        _ = log(50, "ExamViewController#gotoReview:\(viewState)")
        try layout()
    }//gotoReview()

    ///// レイアウト /////
    override func viewDidLayoutSubviews() {
        _ = log(50, "ExamViewController#viewDidLayoutSubviews:\(viewState)")
        super.viewDidLayoutSubviews()
        do {
             try layout()
        } catch let e {
//            fatalError(log(10, "ExamViewController#viewDidLayoutSubviews:\(e)"))
            try! gotoMessageView(message: log(10, "ExamViewController#viewDidLayoutSubviews:\(e)"), returnView: viewState)
        }
    }//viewDidLayoutSubviews()

    override public func layout() throws {
         try super.layout()
         try layoutExamView()
    }//layout()
    
    private func layoutExamView() throws {
//        if viewState != .question && viewState != .answer &&  viewState != .review {
//            return
//        }
        try super.layout()
        for button in [gotoAnswerButton, gotoBackButton, breakButton,
                  gotoNextButton, gotoNewExamButton, returnButton] where button != nil {
            try button!.layout()
        }
//        _ = logPrecisely(40, "ExamViewController#layoutExamView: try printToWebView")
        self.htmlInView = try printToWebView()
        _ = logPrecisely(40, "ExamViewController#layoutExamView: try webView!.layout")
        try self.webView!.layout()
        _ = logPrecisely(40, "ExamViewController#layoutExamView")
    }//layoutExamView()
    
   private func printToWebView() throws -> String {
        DeviceOrientation.update(baseView: self, webView: webView)
        let comment = ""
        switch viewState {
        case .question:
            let index = examManager.cursor
            var page = try getQuestionHeader(index: index).inDiv(className: "exam_area")
//            page += "<hr/>"
            page += try generateQuestionHtml(index: index)
            return try self.webView.setPage(page: page, comment: comment)
        case .answer:
            let index = examManager.cursor
            var page: String = getAnswerHeader(index: index).inDiv(className: "exam_area")
            page += try generateAnswerHtml(index: index)
            page += getCommentHeader(index: index).inDiv(className: "exam_area")
            page += try generateCommentHtml(index: index)
            return try self.webView.setPage(page: page, comment: comment)
        case .review:
            examManager.rewind()
            var reviews: [String] = []
            for index in 0 ..<  examManager.count {
                try examManager.next()
                var page: String = try getQuestionHeader(index: index).inH4().inDiv(className: "exam_area")
                page += try generateQuestionHtml(index: index)
                page += getAnswerHeader(index: index).inH4().inDiv(className: "exam_area")
                page += try generateAnswerHtml(index: index)
                page += getCommentHeader(index: index).inH4().inDiv(className: "exam_area")
                page += try generateCommentHtml(index: index)
                reviews.append(page)
            }//for (int i = 0 i < reviews.length i++)
            return try self.webView.setPage(paragraphs: reviews, comment: comment)
        default:
//            throw ExamError.runtime(log(10, "ExamViewController#printToWebView() - Invalid state: \(String(describing: viewState))"))
            return log(10, "ExamViewController#printToWebView() - Invalid state: \(String(describing: viewState))")
        }///switch viewState
    }//printToWebView()
    
    private func getQuestionHeader(index: Int) throws -> String {
        var header = HtmlPage.getQuestionHeader(
                    code: String(index + 1)).inBold()
        if Repository.allCheck {
            header += " " + (try examManager.getCode())
                    + "(" + (try examManager.getOption()) + ")"
        }
        if try examManager!.getQaType() == QaType.filling {
            return header.inH4() + "空欄に最も適切な語句を語群から選べ。".inH5()
        } else if try examManager!.getQaType() == QaType.branch {
            return header.inH4() + "最も適切なものを選択肢から選べ。".inH5()
        } else if try examManager!.getQaType() == QaType.blank {
            return header.inH4() + "空欄を埋めよ。".inH5()
        } else {
            return header.inH4() + "誤りがあれば訂正せよ。".inH5()
        }
    }//getQuestionHeader(index: Int)
    
    private func getAnswerHeader(index: Int) -> String {
        return HtmlPage.getAnswerHeader(
            code: String(index + 1)).inBold().inH4()
    }//getAnswerHeader(index: Int)
    
    private func getCommentHeader(index: Int) -> String {
        return HtmlPage.getCommentHeader(
            code: String(index + 1)).inBold().inH4()
    }//getCommentHeader(index: Int)
    
    private func generateQuestionHtml(index: Int) throws -> String {
        var html = ""
        html += try examManager.getQuestionParagraph(index: index).inDiv(className: "exam_area")
        html += try examManager.getBranchArea()
        html += try examManager.getQuestionImage(index: index)
        html += try examManager.getSourceDivision(index: index)
        return html  + "\n"
    }//generateQuestionHtml(index: Int, heading format: String)
    
    private func generateAnswerHtml(index: Int) throws -> String {
        var html = ""
        html += try examManager.getAnswerParagraph(index: index).inDiv(className: "exam_area")
        html += try examManager.getAnswerImage(index: index)
        return try TagPreprocessor.getInstance(source: html).parse()  + "\n"
    }//generateAnswerHtml(int index, int headingFormatId)
    
    private func generateCommentHtml(index: Int) throws -> String {
        var html = ""
        html += try examManager.getCommentParagraph(index: index).inDiv(className: "exam_area")
        html += try examManager.getCommentImage(index: index)
        return try TagPreprocessor.getInstance(source: html).parse()  + "\n"
    }//generateAnswerHtml(int index, int headingFormatId)

    ///// 回転処理 /////
    @objc override public func onOrientationChangeListner() {
        _ = log(10, "ExamViewController#onOrientationChangeListner")
        if debugLevel > 0 {
            let deviceOrientation = UIDevice.current.orientation
            if deviceOrientation.isLandscape {
                _ = log(90, "ExamViewController#Device orientation: Landscape")
            } else if deviceOrientation.isPortrait {
                _ = log(90, "ExamViewController#Device orientation: Portrait")
            } else {
                _ = log(90, "ExamViewController#Device orientation: Unknown")
            }
        }
//        //_ = self.webView.reload()
//        do {
//            _ = try printToWebView()
//        } catch let e {
////            fatalError(log(10, "ExamViewController#viewDidLayoutSubviews:\(e)"))
//            try! gotoMessageView(message: log(10, "ExamViewController#viewDidLayoutSubviews:\(e)"), returnView: viewState)
//        }
        //        self.loadView()
        //        self.viewDidLoad()
    }//onOrientationChangeListner
    
    ///// スワイプ関連 /////
    @objc override public func onSwipeListener(sender: UISwipeGestureRecognizer) {
        _ = log(50, "ExamViewController#onSwipeListener: \(sender.direction.value)")
        do {
            if sender.direction == .left {     // forward(->)
                switch viewState {
                case .question:
                    try! gotoAnswer()
                case .answer:
                    try! gotoNext()
                case .review:
                    try! startExam()
                default:
                    break
                }///switch viewState
            } else if sender.direction == .right {  // backward(<-)
                switch viewState {
                case .question:
                    break
                case .answer:
                    try! gotoQuestion()
                case .review:
                    break
                default:
                    break
                }///switch viewState
            } else if sender.direction == .up {     // up(↑)
                 if Repository.checkMode {
                    try gotoMessageView(message: htmlInView, returnView: viewState)
                }
            } else {
                _ = log(90, "ExamViewController#onSwipeListener: undefined swipe")
            }
        } catch let e {
            _ = log(10, "ExamViewController#onSwipeListener:\(e)")
        }
    }//onSwipeListener(sender: UISwipeGestureRecognizer)

}//class ExamViewController

/** End of File **/
