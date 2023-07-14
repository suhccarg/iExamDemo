//
//  ExamManager.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/16.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//
//
import Foundation

public class ExamManager {
    private static let initCursor = -1
    public var cursor: Int
    public var count: Int
    public var holeBase: Int
    public var examList: [ExamUnit?]
    
    private static var thisInstance: ExamManager! = nil
    
    public static func getInstance(cursor :Int, count: Int) -> ExamManager {
        if thisInstance == nil {
            thisInstance = ExamManager(cursor: cursor, count: count)
        }
        thisInstance.holeBase = 0
        return thisInstance
    }// getInstance()
    
    public convenience init() {
        self.init(cursor: ExamManager.initCursor, count: 0)
    }//init()
    
    public init(cursor: Int, count: Int) {
        self.cursor = cursor
        self.count = count
        self.holeBase = 0
        self.examList = []
        
    }//init(cursor: Int, count: Int)
    
    public func rewind() {
        self.cursor = ExamManager.initCursor
    }// rewind()
    
    public func hasNext() -> Bool {
        return (self.cursor + 1 < self.count)
    }//hasNext()
    
    public func next() throws {
        self.cursor = self.cursor + 1
    }// next()
    
    public func getQuestionText() throws -> String {
        return try getQuestionParagraph(index: self.cursor)
    }//getQuestionText()
    
    public func getAnswerText() throws -> String {
        return try getAnswerParagraph(index: self.cursor)
    }// getAnswerText()
    
    public func getCommentText() throws -> String {
        return try getCommentParagraph(index: self.cursor)
    }//getCommentText()
    
    public func getQuestionParagraph() throws -> String {
        return try getQuestionParagraph(index: self.cursor)
    }//getQuestionParagraph()
    
    public func getBranchArea() throws -> String {
        guard self.cursor < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getBranchArea: out of range, cursor=\(self.cursor), list size=\(self.examList.count)")
        }
        return examList[self.cursor]!.selectionBox
    }//getBranchArea(index: Int)
    
    public func getQuestionImage() throws -> String {
        return try getQuestionImage(index: self.cursor)
    }//getQuestionImage()
    
    public func getSourceDivision() throws -> String {
        return try getSourceDivision(index: self.cursor)
    }//getSourceDivision(index: Int)
    
    public func getAnswerParagraph() throws -> String {
        return try getAnswerParagraph(index: self.cursor)
    }//getAnswerParagraph()
    
    public func getAnswerImage() throws -> String {
        return try getAnswerImage(index: self.cursor)
    }//getAnswerImage()
    
    public func getCommentParagraph() throws -> String {
        return try getCommentParagraph(index: self.cursor)
    }//getCommentParagraph()
    
    public func getCommentImage() throws -> String {
        return try getCommentImage(index: self.cursor)
    }//getCommentImage()
    
    public func reset(count: Int) throws {
        self.count = count
        rewind()
    }//reset()
    
    public func generate(category: ExamCategory, count: Int)
        throws {
            try reset(count: count)
            let dao = try ExamSourceDao()
            //        let idList: [Int] = try dao.getIdList(category: category, optionType: optionType)
            let idList: [Int] = try dao.getIdList(category: category, optionList: Repository.getSelectedOption())
            if debugLevel >= 50 {
                self.count = idList.count
            }
            if (Repository.allCheck || Repository.checkMode) {
                let indexes: [Int] = Array<Int>(0 ..<  idList.count)
                self.count = idList.count
                try generateExam(idList: idList, indexes: indexes)
            } else {
                if idList.count < self.count {
                    self.count = idList.count
                }
                let indexes: [Int] = selectIndexes(upperLimit: idList.count, count: self.count)
                try generateExam(idList: idList, indexes: indexes)
            }
    }//generate(category: ExamCategory, optionType: OptionType, count: Int)
    
    public func generateExam(idList: [Int], indexes: [Int])
        throws {
            let dao = try ExamSourceDao()
            self.examList = []
            for n in 0 ..< indexes.count {/////////////////////
                if let dto = try dao.getById(id: idList[indexes[n]]) {
                    self.examList.append(try getExamUnit(dto: dto))
                }
            } //for (int n = 0 n < self.count n++)
    }//generateExam(
    
    private func getExamUnit(dto: ExamSourceDto) throws -> ExamUnit? {
        guard let examSource = dto.encryptedExam else {
            return nil
        }
        let parser = ExamSourceParser(code: dto.code, source: try examSource.decrypt().trim())
        var tokenSet: TokenSet
        tokenSet = try parser.parse()
        //        do {
        //            tokenSet = try parser.parse()
        //        } catch ExamError.runtime(let reason) {
        //            alert(message: "\(reason)")
        //            fatalError("\(log(0, "\(reason)"))")
        //        }
        shiftHole(tokenSet: tokenSet)
        if debugLevel >= 50 {
            self.holeBase = 0
        }
        let qaElements = try QaElements(tokenSet: tokenSet)
        let  examUnit = try ExamUnit(dto: dto, qaType: tokenSet.qaType)
        examUnit.option = dto.option
        examUnit.questionParagraph = try qaElements.getQuestion()
        examUnit.selectionBox = try qaElements.getBranchArea()
        examUnit.answerParagraph = try qaElements.getAnswer()
        let source = try dto.encryptedSource!.decrypt().trim()
        
        examUnit.sourceDivision = HtmlPage.getInstance().generateSourceDivsion(source: source, code: dto.code)
        examUnit.commentParagraph =  HtmlPage.getInstance().generateCommentParagraph(comment: try dto.encryptedComment.decrypt().trim(), examUnit: examUnit)
        try examUnit.genarateQuestionImgTag(image: dto.questionImage.trim())
        try examUnit.genarateAnswerImgTag(image: dto.answerImage.trim())
        try examUnit.genarateCommentImgTag(image: dto.commentImage)
        return examUnit
    }//getExamUnit(dto: ExamSourceDto)
    
    private func shiftHole(tokenSet: TokenSet) {
        if tokenSet.qaType == QaType.filling {
            var maxHole = 0
            for token in tokenSet.list {
                if token.type == TokenType.fillingQa {
                    let hole = token.hole
                    token.hole = hole + self.holeBase
                    if maxHole < hole {
                        maxHole = hole
                    }
                }//if token.type == TokenType.fillingQa
            }//for
            self.holeBase += maxHole + 1
        }//if tokenSet.qaType == QaType.filling
    }//shiftHoleBase(tokenSet: tokenSet)
    
    public func toString() -> String {
        var s = String(format: "cursor=%d, count=%d  ", [cursor, count])
        for i in 0 ..< self.count {
            s += "\n" + self.examList[i]!.toString(i)
        }
        return s
    }//toString()
    
    public func selectIndexes(upperLimit: Int, count: Int) -> [Int]{
        Assert.isTrue(count <= upperLimit)
        if Repository.checkMode {
            return Array<Int>(0 ..< count)
        }
        var indexes: [Int] = Array<Int>(repeating: -1, count: count)
        if debugLevel < 50 {
            for i in 0 ..< count {
                while true {
                    let n = randomInt(upperLimit: upperLimit)
                    var found = false
                    for j in 0 ..< i {
                        if indexes[j] == n {
                            found = true
                            break
                        }
                    } // for i in 0 ..< i
                    if found == false {
                        indexes[i] = n
                        break
                    } //if found == false
                } //while true
            } // for i in 0 ... count
        }else {//if debugLevel < 50 else
            for i in 0 ..<  count {
                indexes[i] = i
            } // for i in 0 ... count
        }//if debugLevel < 50 else
        return indexes
    }//selectIndexes(int max, count: Int)
    
    public func getExam(index: Int) -> ExamUnit {
        return examList[index]!
    }//getExam(index: Int)
    
    public func getCode() throws  -> String {
        guard self.cursor < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getCode: out of range, cursor=\(self.cursor), list size=\(self.examList.count)")
        }
        return self.examList[self.cursor]!.code
    }//getCode()
    
    private func getCode(index: Int) throws -> String {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getCode(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.code
    }//getCode(index: Int)
    
    public func getOption() throws  -> String {
        guard self.cursor < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getOption: out of range, cursor=\(self.cursor), list size=\(self.examList.count)")
        }
        return self.examList[self.cursor]!.option
    }//getOption()
    
    
    public func getQaType() throws -> QaType {
        guard self.cursor < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getQaType: out of range, cursor=\(self.cursor), list size=\(self.examList.count)")
        }
        return try getQaType(index: self.cursor)
    }//
    
    public func getQaType(index: Int) throws -> QaType {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getQaType(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.qaType
    }//getQaType(index: Int)
    
    public func getQuestionParagraph(index: Int) throws -> String {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getQuestionParagraph(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.questionParagraph
    }//getQestion(index: Int)
    
    public func getBranchArea(index: Int) throws -> String {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getBranchArea(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.selectionBox
    }//getBranchArea(index: Int)
    
    public func getQuestionImage(index: Int) throws -> String {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getQuestionImage(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.questionImage
    }//getQestionImage(index: Int)
    
    public func getSourceDivision(index: Int) throws -> String {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getSourceDivision(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.sourceDivision
    }//getSourceDivision(index: Int)
    
    public func getAnswerParagraph(index: Int) throws -> String {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getAnswerParagraph(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.answerParagraph
    }//getAnswerParagraph(index: Int)
    
    public func getAnswerImage(index: Int) throws -> String {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getAnswerImage(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.answerImage
    }//getAnswerImage(index: Int)
    
    public func getCommentParagraph(index: Int) throws -> String {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getCommentParagraph(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.commentParagraph
    }//getCommentParagraph(index: Int)
    
    public func getCommentImage(index: Int) throws -> String {
        guard index < self.examList.count && 0 < self.examList.count else {
            throw ExamError.runtime("ExamManager#getCommentImage(\(index)): out of range, list size=\(self.examList.count)")
        }
        return examList[index]!.commentImage
    }//getCommentImage(index: Int)
    
}//class ExamManager

public class QaElements {
    private static let holeStrings: [String] = [
        "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ",
        "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト",
        "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ",
        "マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ",
        "ラ", "リ", "ル", "レ", "ロ", "ワ", "ヲ"
    ]
    public static let maxHoleCount = holeStrings.count
    public var tokenSet: TokenSet
    public var correctnessQa: CorrectnessQaElements?
    public var selectionQa: SelectionQaElements?
    
    public init(tokenSet: TokenSet) throws {
        self.tokenSet = tokenSet
        if tokenSet.qaType == QaType.correctness {
            self.correctnessQa = try CorrectnessQaElements(tokenSet: tokenSet)
            self.selectionQa = nil
        } else if tokenSet.qaType == QaType.filling || tokenSet.qaType == QaType.branch {
            self.correctnessQa = nil
            self.selectionQa = try SelectionQaElements(tokenSet: tokenSet)
        } else if tokenSet.qaType == QaType.blank {
            self.correctnessQa = try CorrectnessQaElements(tokenSet: tokenSet)
            self.selectionQa = try SelectionQaElements(tokenSet: tokenSet)
        } else {
            throw ExamError.assert("Invalid QA type: " + tokenSet.qaType.name)
        } ///if qaType == (QaType....
    }//init(tokenSet: tokenSet)
    
    public static func getHoleString(index: Int) -> String {
        return  holeStrings[index % holeStrings.count]
    }//getHoleString(index: Int)
    
    public func toString() -> String {
        var s = ""
        if self.correctnessQa != nil {
            s += self.correctnessQa!.toString()
        }
        if selectionQa != nil {
            s += self.selectionQa!.toString()
        }
        return s
    }//toString()
    
    public func getQuestion() throws -> String {
        if tokenSet.qaType == QaType.correctness {
            let index = correctnessQa!.choice
            return correctnessQa!.phrases[index].question
        } else if tokenSet.qaType == QaType.filling ||  tokenSet.qaType == QaType.branch  ||  tokenSet.qaType == QaType.blank {
            return selectionQa!.question
        } else {
            throw ExamError.parse("Invalid QA type: " + tokenSet.qaType.name)
        } ///if qaType == (QaType....
    }//getQuestion()
    
    public func getBranchArea() throws -> String {
        if tokenSet.qaType == QaType.correctness ||  tokenSet.qaType == QaType.blank {
            return ""
        } else if tokenSet.qaType == QaType.filling || tokenSet.qaType == QaType.branch {
            return selectionQa!.selectionArea
        } else {
            throw ExamError.parse("Invalid QA type: " + tokenSet.qaType.name)
        } ///if qaType == (QaType....  }
    }//getQuestion()s
    
    public func getAnswer() throws -> String {
        if tokenSet.qaType == QaType.correctness ||  tokenSet.qaType == QaType.blank  {
            let index = correctnessQa!.choice
            return correctnessQa!.phrases[index].answer
        } else if tokenSet.qaType == QaType.filling || tokenSet.qaType == QaType.branch {
            return selectionQa!.answer
        } else {
            throw ExamError.parse("Invalid QA type: " + tokenSet.qaType.name)
        } ///if qaType == QaType....
    }//getQuestion()
    
}//class QaElements

public class CorrectnessQaElements {
    public var choice: Int
    public var phrases: [CorrectnessPhrases]
    public var choiceCount: Int
    
    public init() {
        self.choice = 0
        self.phrases = []
        self.choiceCount = 0
    }//init()
    
    public convenience init(tokenSet: TokenSet) throws {
        self.init()
        self.choiceCount = generateChoiceCount(tokenSet: tokenSet)
        if debugLevel < 50 {
            self.choice = randomInt(upperLimit: self.choiceCount + 1)
        } else {
            self.choice = 0
        }// if debugLevel < 50
        self.phrases = Array(repeating: CorrectnessPhrases(), count: self.choiceCount + 1)// [choiceCount]には正答形が入る。
        let questionHtml = CorrectnessQuestionHtml()
        let answerHtml = CorrectnessAnswerHtml()
        for i in 0 ..< self.choiceCount + 1 {
            let correctness = CorrectnessPhrases()
            correctness.question = try questionHtml.generate(tokenSet: tokenSet, index: i)
            correctness.answer = try answerHtml.generate(tokenSet: tokenSet, index: i)
            phrases[i] = correctness
        } //for ...
    }//init(tokenSet: tokenSet)
    
    private func generateChoiceCount(tokenSet: TokenSet) -> Int {
        var maxChoice: Int = 0
        for token in tokenSet.list {
            if token.type == TokenType.correctnessQa {
                maxChoice = max(maxChoice, token.choiceCount)
            }
        } //for
        return maxChoice
    }// generateChoiceCount()
    
    public func toString() -> String {
        var s = ""
        s += "choice: \(choice)\n"
        for p in phrases { s += p.toString() + "\n" }
        s += "choiceCount: \(choiceCount)\n"
        return s
    }//toString()
    
    
    public func getQuestion() -> String {
        return getQuestion(index: self.choice)
    }//getQuestion()
    
    public func getAnswer() -> String {
        return getAnswer(index: self.choice)
    }//getQuestion()
    
    public func getQuestion(index: Int) -> String {
        return self.phrases[index].question
    }
    public func setQuestion(index: Int, text: String) {
        self.phrases[index].question = text
    }
    
    public func getAnswer(index: Int) -> String {
        return self.phrases[index].answer
    }
    
    public func setAnswer(index: Int, text: String) {
        self.phrases[index].answer = text
    }
    
}//class CorrectnessQaElements

public class CorrectnessPhrases {
    public var question: String
    public var answer: String
    
    public init() {
        self.question = ""
        self.answer = ""
    }
    
    public func toString() -> String {
        var s = ""
        s += "question: \(question)\n"
        s += "answer: \(answer)\n"
        return s
    }//toString()
}///class CorrectnessPhrases

public class SelectionQaElements {
    public var question: String
    public var selectionArea: String
    public var answer: String
    public var phrases: [SelectionPhrases?]  // <+s>～</+s>でHTML形式のリストひとつ
    
    public init() {
        self.question = ""
        self.selectionArea = ""
        self.answer = ""
        self.phrases = []  // <+s>～</+s>でHTML形式のリストひとつ
    }
    
    public convenience init(tokenSet: TokenSet) throws {
        self.init()
        generateChoiceList(tokenSet: tokenSet)
        let selectionQuestionHtml = SelectionQuestionHtml(qaType: tokenSet.qaType)
        self.question = try selectionQuestionHtml.generate(tokenSet: tokenSet, phrases: self.phrases)
        let selectionBoxHtml = SelectionBoxHtml(qaType: tokenSet.qaType)
        self.selectionArea = try selectionBoxHtml.generate(tokenSet: tokenSet, selectionPhrase: self.phrases)
        if tokenSet.qaType == QaType.blank {
            let answerParagraph = CorrectnessAnswerHtml()
            self.answer = try answerParagraph.generate(tokenSet: tokenSet)
        } else {
            let answerParagraph = SelectionAnswerHtml(qaType: tokenSet.qaType)
            self.answer = try answerParagraph.generate(tokenSet: tokenSet, phrases: self.phrases)
        }
        //    ChoiceAnswerParagraph answerParagraph = ChoiceAnswerParagraph(tokenSet, phrases)
    }///init(tokenSet: tokenSet)
    
    private func generateChoiceList(tokenSet: TokenSet) {
        self.phrases = Array(repeating: nil, count: QaElements.maxHoleCount) // hole値は連続しているとは限らない
        for token in tokenSet.list {
            if token.type == TokenType.fillingQa || token.type == TokenType.branchQa  || token.type == TokenType.blankQa {
                if self.phrases[token.hole] == nil {
                    self.phrases[token.hole] = SelectionPhrases(token: token)
                }//if getPhrase(token.hole) == nil)
            }//if token.type == (TokenType.fillingQa))
        } //for
    }//generateChoiceList(tokenSet: tokenSet)
    
    public func toString() -> String {
        var s = ""
        s += "question: \(question)\n"
        s += "selectionArea: \(selectionArea)\n"
        s += "answer: \(answer)\n"
        for p in phrases { s += p!.toString() + "\n" }
        return s
    }//toString()
}//class SelectionQaElements

public class SelectionPhrases {
    public var html: String
    public var answerIndex: Int
    public var answerPhrase: String
    public var choices: [String]
    public var hole: Int
    
    public init() {
        self.html = ""
        self.answerIndex = 0
        self.answerPhrase = ""
        self.choices = []
        self.hole = 0
    }
    
    public convenience init(token: Token) {
        self.init()
        Assert.isTrue(token.type == TokenType.fillingQa || token.type == TokenType.branchQa || token.type == TokenType.blankQa ,
                      "Invalid token type(1): " + token.type.name)
        self.hole = token.hole
        let indexes = generateIndexes(size: token.choiceCount + 1) //[choiceCount()]は正答のぶん
        choices = Array(repeating: "", count: token.choiceCount + 1)
        for i in 0 ..< token.choiceCount + 1 {
            if indexes[i] == token.choiceCount {// 正解の番号
                self.choices[i] =  token.answer
                self.answerIndex = i
                self.answerPhrase = token.answer
            } else {
                self.choices[i] = token.choices[indexes[i]]!
            }
        } //for (int i = 0 i <= token.getChoiceCount() i++)
    }//init(token: Token)
    
    private func  generateIndexes(size: Int) -> [Int] {
        let indexes: [Int] = Array(0 ..< size)
        if debugLevel >= 50 {
            return indexes
        }
        return indexes.shuffled()
    }//generateIndexes(int size)
    
    public func toString() -> String {
        var s = ""
        s += "html: \(html)\n"
        s += "answerIndex: \(answerIndex)\n"
        s += "answerPhrase: \(answerPhrase)\n"
        for c in choices { s += c + "\n" }
        s += "hole: \(hole)\n"
        return s
    }//toString()
}//class SelectionPhrases
/** End of File **/
