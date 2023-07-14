//
//  Parser.swift
//
//
//  Created by Yoshino Kouichi on 2020/07/14.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation

fileprivate let nearLength: Int = 10
fileprivate let maxHoleCount = 5    ////////////////////

fileprivate let closeTagPattern = "</\\+[qsox][0-9]{0,2}>"

fileprivate let imgTagStart = "<+img "
fileprivate let imgTagEnd = "/>"

fileprivate let formatNoCloseTag = "…%@…: <+img に対応する /> がありません。"
fileprivate let formatTooFewParameter = "…%@…: +img のパラメータが不足しています。"
fileprivate let formatTooManyParameter = "…%@…: +img のパラメータが多すぎます。"
fileprivate let formatNoWidth = "…%@…: 幅の指定が正しくありません。"
fileprivate let formatInvalidFileName = "…%@…: ファイル名の指定が正しくありません。"
fileprivate let formatImgTag = "<img style='width: %@;' src='images/%@' alt='##fig: %@' />"
fileprivate let formatOuterTagOpen = "<+%@>"
fileprivate let formatOuterTagOpenStart = "<+%@"
fileprivate let formatTypeConflict = "正誤問題と選択問題が混在しています。"
fileprivate let formatInvalidTag = "…%@…: 不正なタグ %@ が検出されました。"
//  fileprivate let formatInvalidCharacter = "…%@…: 不正な文字 %@ が検出されました。"
fileprivate let formatNoCorresponding = "…%@…: %@ に対応する %@ がありません。"
fileprivate let formatDiscontinuousXTag = "…%@…: タグ <+x%d> の番号が連続していません。 "
fileprivate let formatChoiceCountInvalid = "…%@…: タグ <+x%d> の番号は、1～%d以外なので使用できません。"
fileprivate let formatOuterHoleInvalid = "…%@…: タグ <+%@%d> の番号は、1～%d以外なので使用できません。"
fileprivate let formatNoTagInQsTag = "…%@…: <+%@> と </+%@> の間に <+ で始まらない要素があります。"
fileprivate let formatTagInnerTag = "…%@…: <+%@> と </+%@> の間に %@ があります。"
fileprivate let formatEmptyQTag = "…%@…: <+q> と </+q> の間が空です。"
fileprivate let formatInvalidCloseTag = "…%@…: クローズタグに対応するオープンタグがありません。"
//fileprivate let formatEmptyOuterTag = "…%@…: <+s%d> と </+s%d> の間が空です。"
fileprivate let formatDuplicatedXTag = "…%@…: <+x%d> が重複しています。"
fileprivate let formatXTagOpen = "<+x%d>"
fileprivate let formatXTagClose = "</+x%d>"
fileprivate let autoXTagOpen = "<+x>"
fileprivate let autoXTagClose = "</+x>"
fileprivate let formatOuterTagNOpen = "<+%@%@>"
fileprivate let formatOuterTagClose = "</+%@%@>"
fileprivate let qTagClose = "</+q>"
fileprivate let oTagOpen = "<+o>"
fileprivate let oTagClose = "</+o>"
fileprivate let xTagOpenStart = "<+x"
fileprivate let openTagStart = "<+"
fileprivate let closeTagStart = "</+"
fileprivate let tagStart = "<+"
fileprivate let tagEnd = ">"

public class Token {
    public static let noChoice = -1
    public static let maxChoiceCount  = 19
    fileprivate(set) var type: TokenType
    public var hole: Int         // 選択問題のア、イ、ウ、･･･識別
    fileprivate(set) var text: String!
    fileprivate(set) var answer: String!
    fileprivate(set) var choices: [String?]
    fileprivate(set) var choiceCount: Int
    
    public convenience init(type: TokenType) {
        self.init(type: type, text: "")
    }//init(type: TokenType)
    
    public init(type: TokenType, text: String) {
        self.type = type
        self.text = text
        self.hole = 0
        self.choiceCount = 0
        self.choices = Array(repeating: nil, count: Token.maxChoiceCount)
    }//
    
    public func toString() -> String {
        var s = type.name + ", " + text
        if let t = answer {
            s += ", A: " + t
        }
        for i in 0..<choices.count {
            if let t = choices[i] {
                s += String(format: ", %d: %@", [i, t])
            }
        }
        return s
    }//toString()
    
    public func existsQuestion(index: Int) -> Bool {
        return getChoice(index: index) != nil
    }//existsQuestion(token: Token, index: Int)
    
    public func getChoice(index: Int) -> String? {
        Assert.isTrue(index < choices.count, "Invalid index=\(index)")
        return choices[index]
    }//getChoice(index: Int)
    
    public func setChoice(index: Int, _ s: String) {
        Assert.isTrue(index < choices.count,
            String(format: "Invalid index %d >= %d", [index, choices.count]))
        choices[index] = s
    }//setChoice(index: Int, _ s: String)
}//class Token

public class TokenSet {
    fileprivate(set) var list: [Token]
    fileprivate(set) var qaType: QaType
    
    public init() {
        list = []
        qaType = QaType.na
    }//init()
    
    public func add(token: Token) {
        list.append(token)
    }//add(token: Token)
}//class tokenSet

public class GenericParser {
    
    fileprivate var examSource: String!
    fileprivate var code: String!
    
    public init() {
        self.code = nil
        self.examSource = nil
    }//AbstractParser(ource: String)

    //    public init(examSource: String) {
//        self.code = nil
//        self.examSource = examSource.trim()
//    }//AbstractParser(ource: String)
    
    public init(code: String, source: String) {
        self.code = code
        self.examSource = source.trim()
    }//AbstractParser(code: String, examSource: String)
    
    public func getNear(position: Int) -> String {
        return self.examSource.substring(
            from: position - nearLength, to: position + nearLength)
    }//getNear(int position)
    
}//class GenericParser

public class TagPreprocessor: GenericParser {
    private var replaceTable : [String:String] = [:]
    private static var thisInstance: TagPreprocessor! = nil

    public static func getInstance(source: String) -> TagPreprocessor {
        if thisInstance == nil {
            thisInstance = TagPreprocessor()
            thisInstance.makeReplaceTable()
        }
        thisInstance.examSource = source
        return thisInstance
    }// getInstance()
    
//    override public init(examSource: String) {
//        super.init(examSource: examSource)
//    }//init(examSource: String)
    
    private func makeReplaceTable() {
        replaceTable["<+b/>"] = "‡"
        replaceTable["<+br/>"] = "</p>\n<p>"
        replaceTable["<+k>"] = "<span class='enhanced'>"
        replaceTable["</+k>"] = "</span>"
        replaceTable["<+n/>"] = "</p>\n<p>"
        replaceTable["<+t>"] = "<div class='examtable'><table><tbody>\n"
        replaceTable["</+t>"] = "</tbody></table></div>\n"
        replaceTable["<+u>"] = "<+u><+o>"
        replaceTable["</+u>"] = "</+o></+u>"
    }//makeReplaceTable()

    public func parse() throws -> String {
        var s = examSource
        for t in replaceTable {
            s = s!.replace(before: t.key, after: t.value)
        }
        s = try ImgTagPreprocessor.getInstance(source: s!).parse()
        return s!
    }//parse()
    
}//class TagPreprocessor

public class ImgTagPreprocessor: GenericParser {
    private static var thisInstance: ImgTagPreprocessor! = nil
    private var replaceTable : [String:String] = [:]
    
    private var width: String!
    private var fileName: String!
    private var position: Int
    private var positionInTag: Int

    override public init() {
        self.width = nil
        self.fileName = nil
        self.position = 0
        self.positionInTag = 0;
        super.init()
    }//init(code: String, examSource: String)
    
    public static func getInstance(source: String) -> ImgTagPreprocessor {
        if thisInstance == nil {
            thisInstance = ImgTagPreprocessor()
        }
        thisInstance.examSource = source
        return thisInstance
    }// getInstance()

    public func parse() throws -> String {
        var source = self.examSource
        var destination = ""
        while (source!.count > 0) {
            // <+img ～< />などの外
            let openTag = source!.find(pattern: imgTagStart)
            if openTag == nil { // タグの開きがない
                // 残りの文字列を登録してループを抜ける。
//                destination.append(source!)
                destination += source!
                break
            } //if openTag < 0)
            // <+img あり → <+img の前までをそのままコピー
            if 1 <= openTag! {
                destination += source!.substring(to: openTag!)
            }
            // +img タグの中を処理
            let closeTag = openTag! + imgTagStart.count
                + source!.substring(from: openTag! + imgTagStart.count).find(pattern: imgTagEnd)! // #####
            if openTag! + imgTagStart.count >= closeTag {
                throw ExamError.runtime(
                    String(format: formatNoCloseTag, getNear(position: self.position + openTag!)))
            } //if openTag + imgTagStart.count >= closeTag)
            let textInimgTag = source!.substring(from: openTag! + imgTagStart.count, to: closeTag)
            let headPosition = self.position
            self.position = headPosition + openTag! + imgTagStart.count
            destination += try convertImgTag(source: textInimgTag)
            // ソース文字列を残り部分に更新
            self.position = headPosition + closeTag + imgTagEnd.count
            source = source!.substring(from: closeTag + imgTagEnd.count)
        } //while (examSource.count > 0)
        return destination
    }//parse()
    
    private func convertImgTag(source: String) throws -> String {
        try parseImgTag(trimmedSource: source)
        return generateImgTag()
    }//convertImgTag(source: String)
    
    private func parseImgTag(trimmedSource: String) throws {
        let trimmedSource = trimmedSource.trim()
        var positionInTag = 0
        if trimmedSource.find(pattern: imgTagStart) != nil {
            throw ExamError.runtime(
                String(format: formatNoCloseTag, getNear(position: self.position + positionInTag)))
        } //if trimmedSource.find(pattern: imgTagStart) != nil
        // 幅の取得
        var spacePosition = examSource.find(pattern: " ")
        if spacePosition == nil {
            throw ExamError.runtime(
                String(format: formatTooFewParameter, getNear(position: self.position + positionInTag)))
        } //if spacePosition < 0)
        let width = examSource.substring(to: spacePosition!)
        if width.find(pattern: "'") != nil {
            throw ExamError.runtime(
                String(format: formatNoWidth, getNear(position: self.position + positionInTag)))
        } // if width.find(pattern: "'") < 0)
        //    setWidth(width)
        self.width = adjustSize(parameter: width)
        // ソース文字列を残り部分に更新
        examSource = examSource.substring(from: spacePosition! + 1).trim()
        positionInTag += spacePosition! + 1
        // ファイル名の取得
        spacePosition = examSource.find(pattern: " ")
        if spacePosition != nil {
            throw ExamError.runtime(
                String(format: formatTooManyParameter, getNear(position: self.position + positionInTag)))
        } //if spacePosition > 0
        if examSource.substring(to: 1) != "'" ||
            examSource.substring(from: examSource.count - 1, to: examSource.count) != "'" {
            throw ExamError.runtime(String(format: formatInvalidFileName,
                                           getNear(position: self.position + positionInTag)))
        } // if !examSource.substring(to: 1) == "'") ...
        self.fileName = examSource.substring(from: 1, to: examSource.count - 1)
    }//parseImgTag(examSource: String)
    
    private func generateImgTag() -> String {
        return String(format: formatImgTag, [self.width,
                             self.fileName, self.fileName])
    }//generateImgTag()
    
    private func adjustSize(parameter: String) -> String {
        
        return ""
    }
    
}//class ImgTagPreprocessor


public class ExamSourceParser: GenericParser {
    public var tokenSet: TokenSet!
    private var position: Int
    private var positionInTag: Int
    private var autoXNumbered: Bool
    private var autoXNumber: Int
    private static var thisInstance: ExamSourceParser! = nil
    
    public static func getInstance(code: String, source: String) -> ExamSourceParser {
        if thisInstance == nil {
            thisInstance = ExamSourceParser(code: code, source: source)
        }
        thisInstance.examSource = source
        return thisInstance
    }// getInstance()

    override public init(code: String, source: String) {
        self.tokenSet = nil
        self.position = 0
        self.positionInTag = 0
        self.autoXNumbered = false
        self.autoXNumber = 0
        super.init(code: code, source: source)
    }//init(code: String, source: String)

    public static func getQaType(tokenArray: [Token]) throws -> QaType {
        var qaType: QaType = QaType.na
        for token in tokenArray {
            if token.type == TokenType.correctnessQa {
                if qaType != QaType.na && qaType != QaType.correctness {
                    throw ExamError.parse(formatTypeConflict)
                }
                qaType = QaType.correctness
            } else if token.type == TokenType.fillingQa {
                if qaType != QaType.na && qaType != QaType.filling {
                    throw ExamError.parse(formatTypeConflict)
                }
                qaType = QaType.filling
            } else if token.type == TokenType.branchQa {
                if qaType != QaType.na && qaType != QaType.branch {
                    throw ExamError.parse(formatTypeConflict)
                }
                qaType = QaType.branch
            }//if type == ...
        }//for token in tokenArray
        if qaType == QaType.na {
            qaType = QaType.correctness
        }
        return qaType
    }//getQaType(tokenArray: [Token])
    
    public func parse() throws -> TokenSet {
        self.tokenSet = TokenSet()
        self.tokenSet.qaType = QaType.na
        var source = try TagPreprocessor.getInstance(source: self.examSource).parse()
         //    String source = getSource()
        _ = log(60, "ExamSourceParser#parse: \(source)")
        self.examSource = source
        clearPosition()
        while source.count > 0 {
            // <+外>～</+外>などの外
            let openTag: Int? = try getOpenTagStart(source: source)
            if openTag == nil { // タグの開きがない
                // 残りの文字列を登録してループを抜ける。
                tokenSet.add(token: Token(type: TokenType.plain, text: source))
                break
            }
            //次の開きタグまでをプレーンテキストとして登録
            if 0 < openTag! {
            // openTag==0は、</+q>と<+q>などの間の空文字列なので除外する
                let  s = source.substring(to: openTag!)
                tokenSet.add(token: Token(type: TokenType.plain, text: s))
            }
            let tagType = getQuestionType(source: source, openTag: openTag!)

            // 外タグの処理
            let tokenType = selectTokenType(tagType: tagType)
            try setQaType(qaType: selectQaType(tagType: tagType))
            if tokenType == nil {
                if tagType.count <= 0 {
                    throw ExamError.runtime(String(format: formatInvalidTag,getNear(position: self.position), openTagStart))
                } else {
                    throw ExamError.runtime(String(format: formatInvalidTag, getNear(position: self.position), openTagStart + tagType + tagEnd))
                }
            }//if (tokenType == null) {
            // <+外N>の数値部分の切り出し
            let outerTagIndexString = try getTagIndex(source: source, tagType: tagType, openTag: openTag!)
            let gain = openTag! + getOpenOuterTagString(tagType: tagType, sn: outerTagIndexString).count
            addPosition(gain: gain)
            source = source.substring(from: gain)
            
            // <+外N>～</+外N>の内
            //let beforeSPosition = self.position
            let closeOuterTagStart = try getCloseOuterTagStart(source: source, tagType: tagType, sn: outerTagIndexString)
            let tokenSString = try getOuterTagTokenString(source: source,
                                                      tagType: tagType,openTag: openTag!, sn: outerTagIndexString)
            let outerToken = Token(type: tokenType!, text: tokenSString)
            outerToken.hole = try getHoleValue(tagType: tagType, tagNumber: outerTagIndexString)
            tokenSet.add(token: try parseInnerTag(token: outerToken, tagSource: tokenSString, outTag: tagType + outerTagIndexString))
            let outerCloseGain = closeOuterTagStart + getCloseOuterTagString(tagType: tagType, sn: outerTagIndexString).count
            addPosition(gain: outerCloseGain)
            source = source.substring(from: outerCloseGain)
        } //while examSource.count > 0
        if tokenSet.qaType == QaType.correctness { // xタグの連続性確認
            try checkChoiceContinuity()
        }
        if tokenSet.qaType == QaType.na { // .タグなしは、正誤問題
            tokenSet.qaType = QaType.correctness
        }
        _ = log(60, "ExamSourceParser#parse: completed.")
        return tokenSet
    }//parse()
    
    private func selectQaType(tagType: String) -> QaType! {
        switch (tagType) {
        case "q":
            return QaType.correctness
        case "r":
            return QaType.branch
        case "s":
            return QaType.filling
        case "u":
            return QaType.blank
        default:
            return nil;
        }//switch (tagType)
    }//selectQaType(String tagType)
    
    private func selectTokenType(tagType: String) -> TokenType! {
        switch (tagType) {
        case "q":
            return TokenType.correctnessQa
        case "r":
            return TokenType.branchQa
        case "s":
            return TokenType.fillingQa
        case "u":
            return TokenType.blankQa
        default:
            return nil;
        }//switch (tagType)
    }//selelctTokenType(String tagType)
    
    private func parseInnerTag(token: Token, tagSource: String, outTag: String) throws -> Token {
        clearAutoXNumber()
        //    tagSource = tagSource.trim()
        var tagSource = tagSource.replace(before: "\r", after: "").replace(before: "\n", after: "")
        while tagSource.trim().count > 0 {
            tagSource = try getTagSource(tagSource: tagSource, outTag: outTag)
            
            let tag = try getOpenInnerTag(tagSource: tagSource, outTag: outTag)
            switch tag.substring(to: 1) {
            case "o": 
                try checkOTag(tag: tag)
                let otagString = tagSource.substring(from: oTagOpen.count, to: try getCloseOTagStart(tagSource: tagSource))
                try checkInnerTagString(tagString: otagString, inTag: "o")
                token.answer = otagString.trim()
                let oGain = try getCloseOTagStart(tagSource: tagSource) + oTagClose.count
                addPositionInTag(gain: oGain)
                tagSource = tagSource.substring(from: oGain)
                break
            case "x": 
                // 数値部分の切り出し
                let xtagIndex = try getXTagIndex(token: token, tagSource: tagSource)
                let closeXTagStart = try getCloseXTagStart(tagSource: tagSource, index: xtagIndex)
                let xtagString = tagSource.substring(from: getOpenXTagString(index: xtagIndex).count, to: closeXTagStart)
                try checkInnerTagString(tagString: xtagString, inTag: "x" + getXTagIndexString(index: xtagIndex+1))
                token.choices[xtagIndex] = xtagString.trim()
                token.choiceCount = max(xtagIndex + 1, token.choiceCount)
                let xGain = closeXTagStart + getCloseXTagString(index: xtagIndex).count
                addPosition(gain: xGain)
                tagSource = tagSource.substring(from: xGain)
                break
            default: 
                throw ExamError.runtime(String(format: formatInvalidTag,
                       getNear(position: self.position + self.positionInTag), openTagStart + tag + tagEnd))
            }//switch tag.substring(to: 1)
        } //while tagSource.trim().count > 0
        if token.type == TokenType.fillingQa {
            try checkArrayIndexContinuity(array: token.choices)
        }
        return token
    }//parseInnerTag
    
    private func getOpenTagStart(source: String) throws -> Int? {
        let openTag = source.find(pattern: openTagStart)
        if openTag == nil {
            if  try source.find(regex: closeTagPattern) {
                // "<+"がないのにタグの閉じがあった
                throw ExamError.runtime(String(format: formatInvalidCloseTag,
                       getNear(position: self.position )))
            } else {
                return nil
            }
        } //if openTag == nil ...
        let closeTag = source.find(pattern: closeTagStart)
        if closeTag != nil {
            if closeTag! < openTag! {
                // 開きタグの前に閉じタグがある
                throw ExamError.runtime(String(format: formatInvalidCloseTag,
                        getNear(position: self.position + closeTag!)))
            }
        }//if closeTag != nil)
        return openTag!
    }//getOpenTagStart(source: String)
    
    private func getQuestionType(source: String, openTag: Int) -> String {
        return source.substring(from: openTag + openTagStart.count, to: openTag + openTagStart.count + 1)
   }//getQuestionType(
    
//    private func checkQTag(source: String, openTag: Int) throws {
//        if source.count <= openTag + qTagOpen.count {
//            throw ExamError.runtime(String(format: formatInvalidTag,
//                getNear(position: self.position), source.substring(from: openTag)))
//        }
//    }//checkQTag
    
//    private func getCloseTag(source: String, tagClose: String) throws -> Int {
//        let closeTag = source.find(pattern: qTagClose)
//        if closeTag == nil {
//            throw ExamError.runtime(String(format: formatNoCorresponding,
//                       getNear(position: self.position), qTagOpen, qTagClose))
//       }
//        if closeTag == 0 {
//            throw ExamError.runtime(String(format: formatEmptyQTag, getNear(position: self.position)))
//        }
//        return closeTag!
//    }//getCloseTag(examSource: String, tagClose: String)
    
    private func setQaType(qaType: QaType) throws {
        if tokenSet.qaType == QaType.na {
            tokenSet.qaType = qaType
        } //if tokenSet.qaType == QaType.na
        if tokenSet.qaType != qaType {
            throw ExamError.runtime(formatTypeConflict)
        } //if !tokenSet.qaType == qaType)
        return
    }//setQaType(QaType qaTpe)
    
    private func getTagIndex(source: String, tagType: String, openTag: Int) throws -> String {
        let tagIndexAndClose = source.substring(from: openTag + openTagStart.count)
        let tagEndString = tagIndexAndClose.find(pattern: tagEnd)
        if tagEndString == nil {
            throw ExamError.runtime(String(format: formatInvalidTag,
                getNear(position: self.position),
                source.substring(from: openTag, to: min(openTag + 2, source.count))))
        } //if tagEndString == nil
//        let stagIndexString = tagIndexAndClose.substring(from: 1, to: tagEndString!)
//        if examSource.count < openTag + getOpenOuterTagString(sn: stagIndexString).count + tagEnd.count {
//        throw ExamError.runtime(String(format: formatInvalidTag,
//            getNear(position: self.position), openTagStart + examSource.substring(from: openTag) + tagEnd))
//        } // if examSource.count <  ...
//        return stagIndexString
        let tagIndexString = tagIndexAndClose.substring(from: 1, to: tagEndString!)
        
        let openTagLength = getOpenOuterTagString(tagType: tagType, sn: tagIndexString).count
        if source.count < openTag + openTagLength + tagEnd.count {
            throw ExamError.runtime(String(format: formatInvalidTag,
                                           getNear(position: self.position),  openTagStart + source.substring(to: openTag) + tagEnd))
        } // if (examSource.length() <  ...
        return tagIndexString
    }//getTagIndex(examSource: String, tagType: String, openTag: Int)
    
    private func getHoleValue(tagType: String, tagNumber: String) throws -> Int {
    var hole = 0
    if tagNumber != "" {
        if let n = Int(tagNumber) {
            hole = n - 1
        } else {
            let outerTagOpenStart = String(format: formatOuterTagOpenStart, tagType);
            throw ExamError.runtime(String(format: formatInvalidTag,
                getNear(position: self.position), outerTagOpenStart + tagNumber + tagEnd))
        } //
    } // if !sn == ""))
    if hole < 0 || maxHoleCount <= hole {
        throw ExamError.runtime(
            String(format: formatOuterHoleInvalid,
                   getNear(position: self.position), tagType, hole + 1, maxHoleCount))
    }
    return hole
    }//getHoleVale(sn: String)
    
    private func getOpenOuterTagString(tagType: String, sn: String) -> String {
        return String(format: formatOuterTagNOpen, tagType, sn)
    }//getOpenOuterTagString(sn: String)
    
    private func getCloseOuterTagString(tagType: String, sn: String) -> String {
        return String(format: formatOuterTagClose, tagType, sn)
    }//getColseOuterTagString(sn: String)
    
    private func getOuterTagTokenString(source: String, tagType: String, openTag: Int, sn: String) throws -> String {
        //addPosition(gain: openTag + getOpenOuterTagString(sn: sn).count)
        let closeOuterTagStart = try getCloseOuterTagStart(source: source, tagType: tagType, sn: sn)
        var tokenString: String
        if closeOuterTagStart == 0 {
            tokenString = ""
        } else {
            tokenString = source.substring(to: closeOuterTagStart)
        }
        return tokenString
    }//getOuterTagTokenString(source: String, openTag: Int, sn: String)

    private func getCloseOuterTagStart(source: String, tagType: String, sn: String) throws -> Int {
        let closeOuterTagStart = source.find(pattern: getCloseOuterTagString(tagType: tagType, sn: sn))
        if closeOuterTagStart == nil {
            throw ExamError.runtime(String(format: formatNoCorresponding,
                                           getNear(position: self.position), getOpenOuterTagString(tagType: tagType,sn: sn), getCloseOuterTagString(tagType: tagType,sn: sn)))
            //                  "<x" + index + ">", "</x" + index + ">"))
        }
        return closeOuterTagStart!
    }//getCloseOuterTagStart(source: String sn: String)

//    private func getOpenRTagString(rn: String) -> String {
//        return String(format: formatRTagOpen, rn)
//    }//getOpenRTagString(rn: String)
//
//    private func getCloseRTagString(rn: String) -> String {
//        return String(format: formatRTagClose, rn)
//    }//getColseRSTagString(rn: String)
//
//    private func geRTagTokenString(source: String, openTag: Int, rn: String) throws -> String {
//        addPosition(gain: openTag + getOpenRTagString(rn: rn).count)
//        let closeRTagStart = try getCloseRTagStart(source: source, rn: rn)
//        var tokenString: String
//        if closeRTagStart == 0 {
//            tokenString = ""
//        } else {
//            tokenString = source.substring(to: closeRTagStart)
//        }
//        return tokenString
//    }//getRTagTokenString(source: String, openTag: Int, rn: String)
//
//    private func getCloseRTagStart(source: String, rn: String) throws -> Int {
//        let closeRTagStart = source.find(pattern: getCloseRTagString(rn: rn))
//        if closeRTagStart == nil {
//            throw ExamError.runtime(String(format: formatNoCorresponding,
//                   getNear(position: self.position), getOpenRTagString(rn: rn), getCloseRTagString(rn: rn)))
//            //                  "<x" + index + ">", "</x" + index + ">"))
//        }
//        return closeRTagStart!
//    }//getCloseRTagStart(source: String rn: String)
//
    private func getTagSource(tagSource: String, outTag: String) throws -> String {
        let tagSource = tagSource.trim()
        if tagSource.count < openTagStart.count {
            throw ExamError.runtime(String(format: formatNoTagInQsTag,
            getNear(position: self.position), outTag, outTag))
        }
        if tagSource.substring(to: openTagStart.count) != openTagStart { // タグの開きががない
            throw ExamError.runtime(String(format: formatNoTagInQsTag,
            getNear(position: self.position), outTag, outTag))
        }
        return tagSource
    }//getTagSource(tagSource: String, outTag: String)
    
    private func getOpenInnerTagEnd(tagSource: String) throws -> Int {
        let openTagEnd = tagSource.find(pattern: tagEnd)
        if openTagEnd == nil { // タグの開きはあるが閉じがない
            throw ExamError.runtime(
                String(format: formatNoCorresponding, getNear(position: self.position), "<", tagEnd))
        }
        return openTagEnd!
    }//getOpenInnerTagEnd
    
    private func getOpenInnerTag(tagSource: String, outTag: String) throws  -> String {
        let tag = tagSource.substring(from: openTagStart.count, to: try getOpenInnerTagEnd(tagSource: tagSource))
        if tag.count <= 0 {
        throw ExamError.runtime(String(format: formatNoTagInQsTag,
           getNear(position: self.position), outTag, outTag))
        } //if tag.count <= 0)
        return tag
    }//getOpenInnerTagEnd
    
    private func checkOTag(tag: String) throws {
        if tag.count != oTagOpen.count - 3 {
        throw ExamError.runtime(
            String(format: formatInvalidTag, getNear(position: self.position), openTagStart + tag))
        }
    }//checkOTag(String tag)
    
    private func getCloseOTagStart(tagSource: String) throws -> Int {
        let closeOTagStart = tagSource.find(pattern: oTagClose)
        if closeOTagStart  == nil {
            throw ExamError.runtime(
            String(format: formatNoCorresponding, getNear(position: self.position), oTagOpen, oTagClose))
        }
        return closeOTagStart!
    }//getCcloseOTagStart(String tagSource)
    
    private func getXTagIndexString(index: Int)  -> String {
        if self.autoXNumbered {
            return ""
        } else {
            return "" + String(index)
        }
    }//getXTagIndex(index: Int, Boolean autoNumbered)
    
    private func getXTagIndex(token: Token, tagSource: String) throws -> Int {
        let xtagEnd = tagSource.find(pattern: tagEnd)
        guard xtagEnd != nil else {
            throw ExamError.runtime(String(format: formatInvalidTag,
                           getNear(position: self.position), tagSource))
        }
        let xn = tagSource.substring(from: openTagStart.count + 1, to: xtagEnd!)
        var index: Int? = nil
        if xn == "" {
            index = self.autoXNumber
            incrementAutoXNumber()
            self.autoXNumbered = true
        } else {
            index = Int(xn)
            if index == nil {
                throw ExamError.runtime(String(format: formatInvalidTag,
                    getNear(position: self.position), xTagOpenStart + xn + tagEnd))
            }
            index! -= 1
        } // if xn == "")) ... else
        if index == nil || Token.maxChoiceCount <= index! {
            throw ExamError.runtime(
                String(format: formatChoiceCountInvalid, getNear(position: self.position), index! + 1,
            Token.maxChoiceCount))
        }
        if token.choices[index!] != nil {
            throw ExamError.runtime(
            String(format: formatDuplicatedXTag, getNear(position: self.position), index! + 1))
        }
        return index!
    }//getXTagIndex
    
    private func getOpenXTagString(index: Int) -> String {
        if self.autoXNumbered {
            return autoXTagOpen
        } else {
            return String(format: formatXTagOpen, index + 1)
        }
    }//getOpenXTagString(index: Int)
    
    private func getCloseXTagString(index: Int)  -> String  {
        if self.autoXNumbered {
            return autoXTagClose
        } else {
            return String(format: formatXTagClose, index + 1)
        }
    }//getCloseXTagString(index: Int)
    
    private func getCloseXTagStart(tagSource: String, index: Int) throws -> Int {
        let closeXTagStart = tagSource.find(pattern: getCloseXTagString(index: index))
        if closeXTagStart == nil {
            throw ExamError.runtime(
                String(format: formatNoCorresponding, getNear(position: self.position),
                       getOpenXTagString(index: index), getCloseXTagString(index: index)))
        }
        return closeXTagStart!
    }//getCloseXTagStart
    
    private func checkInnerTagString(tagString: String, inTag: String) throws {
        let postion = tagString.find(pattern: tagStart)
        if postion != nil {
            throw ExamError.runtime(String(format: formatTagInnerTag,
                   getNear(position: postion!), inTag, inTag, tagStart))
        }
    }//checkInnetTagString(String tagString, String inTag)
    
    private func checkChoiceContinuity() throws {
        Assert.isNotNil(object: self.examSource, "source == nil")
        var i: Int = 1
        while i <= Token.maxChoiceCount {
            if !self.examSource.contains("<+x\(i)>") {
                break
            }
            i += 1
        } //  while i <= ...
        while i <= Token.maxChoiceCount {
            let s = self.examSource.find(pattern: "<+x\(i)>")
            if s != nil {
                throw ExamError.runtime(String(format: formatDiscontinuousXTag, getNear(position: s!), i))
            }
            i += 1
        } //  while i <= ...
    }//checkChoiceContinuity()
    
    private func checkArrayIndexContinuity(array: [String?]) throws {
        var i: Int = 0
        while i < array.count {
            if array[i] == nil {
                break
            }
            i += 1
        } //  while i <= ...
        while i < array.count {
            if array[i] != nil {
                let tagPostion = self.examSource.find(pattern: "<+x\(i)>")
                let message = String(format: formatDiscontinuousXTag,
                                     getNear(position: tagPostion ?? 0), i)  ///////////////
                throw ExamError.runtime(message)
            }
            i += 1
        } //  while i <= ...
    }//checkChoiceContinuity()
    
    private func clearPosition() {
        self.position = 0
        self.positionInTag = 0;
    }//addPosition(int gain)
    
    private func addPosition(gain: Int) {
        self.position += gain
        self.positionInTag = 0;
    }//addPosition(int gain)
    
    private func addPositionInTag(gain: Int) {
        self.positionInTag += gain
    }//addPosition(gain: Int)
    
    private func clearAutoXNumber() {
        autoXNumbered = false
        autoXNumber = 0
    }//clearAutoNumber()
    
    private func incrementAutoXNumber() {
        autoXNumber += 1
    }//incrementAutoXNumber()
}//ExamSourceParser

/** End of File **/
