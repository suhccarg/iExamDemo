//
//  ExamUnit.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/14.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
 
public class ExamUnit {
    var code: String
    var qaType: QaType
    var option: String
    var correctnessChoice: Int
    var correctnessChoiceCount: Int
    var fillingIndexes: [Int]
    var fillingAnswer: Int
    var questionParagraph: String
    var selectionBox: String
    var sourceDivision: String
    var answerParagraph: String
    var commentParagraph: String
    var questionImage: String
    var answerImage: String
    var commentImage: String

    public init(code: String) {
        self.code = code
        self.qaType = QaType.na
        self.option = ""
        self.correctnessChoice = 0
        self.correctnessChoiceCount = 0
        self.fillingIndexes = []
        self.fillingAnswer = 0
        self.questionParagraph = ""
        self.selectionBox = ""
        self.sourceDivision = ""
        self.answerParagraph = ""
        self.commentParagraph = ""
        self.questionImage = ""
        self.answerImage = ""
        self.commentImage = ""
    }//init(code: String)

    public convenience init(dto: ExamSourceDto, qaType: QaType) throws  {
        self.init(code: dto.code)
        self.qaType = qaType
    } //init(dto: ExamSourceDto, qaType: QaType)
    
    func generateChoice(max: Int) -> Int {
        return Int.random(in: 0..<max)
    }//generateChoice(max: Int)
    
    let printLength = 20

    func toString() -> String {
         var  s = "code=\(code), choice=\(correctnessChoice)/\(correctnessChoiceCount)\n"
        s += "Q: \(questionParagraph.right(printLength))\n"
        s += "S: \(sourceDivision.right(printLength))\n"
        s += "A: \(answerParagraph.right(printLength))\n"
        s += "C: \(commentParagraph.right(printLength))\n"
        return s
    }///toString()
    
    func toString(_ index: Int) -> String {
        var  s = "code=\(code), choice=\(correctnessChoice)/\(correctnessChoiceCount)\n"
        s += "Q[\(index)]: \(questionParagraph.right(printLength))\n"
        s += "S[\(index)]: \(sourceDivision.right(printLength))\n"
        s += "A[\(index)]: \(answerParagraph.right(printLength))\n"
        s += "C[\(index)]: \(commentParagraph.right(printLength))\n"
        return s
    }///toString()
    
  
    public func genarateSourceDivision(source: String) {
        if source != "" {
            sourceDivision = HtmlPage.getInstance().generateSourceAreaDivsion(text: source)
        }
    }//genarateSourceDivision(sourceDivision)
    
    public func genarateQuestionImgTag(image: String) throws  {
        if image != "" {
            questionImage = try HtmlPage.getInstance().generateImgTag(imageFile: image)
        }
    }//genarateQuestionImgTag(image)
    
    public func genarateAnswerImgTag(image: String) throws {
        if image != "" {
            answerImage = try HtmlPage.getInstance().generateImgTag(imageFile: image)
        }
    }//genarateAnswerImgTag(image)
    
    public func genarateCommentImgTag(image: String) throws {
        if image != "" {
            commentImage = try HtmlPage.getInstance().generateImgTag(imageFile: image)
        }
    }//genarateCommentImgTag(image)
 
}//class ExamUnit

/** End of File **/
