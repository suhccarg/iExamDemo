//
//  HtmlPage.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/17.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
import WebKit

public class HtmlPage {
    public static let imageDirectory = "images"
    public static let answerOpen = "<span class='answer'>"
    public static let answerClose = "</span>"
    public static let boldOpen = "<span class='bold'>"
    public static let boldClose = "</span>"
    public static let messageCorrectAnswer
        = "問題文は、" + answerOpen + "正しい" + answerClose + "文章です。"
    //public static let formatColor = "#%06X"
    public static let selectionAreaOpen = "  <div class='brancharea'>\n"
    public static let selectionAreaClose = "  </div>\n"
    public static let formatFillingHeader = ""
        + "    <div class='branchtitle'>\n"
        + "      <p>《%@の語群》</p>\n"
        + "    </div>\n"
    public static let  formatSelectionHeader = ""
    public static let formatQuestionTitle = "【問題%@】"
    public static let formatAnswerTitle = "【解答%@】"
    public static let formatCommentTitle = "【補足%@】"
    public static let cssTextColor = "#textColor#"
    public static let cssEnhancedColor = "#enhancedColor#"
    public static let cssBackgroundColor = "#backgroundColor#"
    public static let cssFontSize = "#fontSize#"
    public static let cssFontSize80 = "#fontSize80%#"
    public static let commentPlace = "#comment#"
    public static let subtitlePlace = "#subtitle#"
    public static let headerOpen = ""
        + "<!DOCTYPE html>\n"
        + "<html lang='ja'>\n"
        + "<head>\n"
        + "<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>\n"
        + "<meta name='viewport' content='width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no'>"
        //+ "<meta name='viewport' content='width=device-width,initial-scale=1' />\n"
    public static let headerClose = "\n"
        + "</head>\n"
    public static let bodyOpen = ""
        + "<body oncopy='return false;' >\n"
        + "<div onCopy='return false;'>\n"
    public static let bodyClose = "\n  </div>\n</body>\n</html>"

    public static let formatCss = ""
        + ".exam_area p {\n"
        + "  font-size: " + cssFontSize + "px;\n"
        + "  line-height: 1.4em;\n"
        + "  margin: 0 0 0.2em 0.1em;\n"
        + "  padding: 0 0 0 0;\n"
        + "  text-indent: 1em;\n"
        + "  line-height: 1.4em;\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".exam_area h4 {\n"
        + "  font-size: " + cssFontSize + "px;\n"
        + "  line-height: 1.4em;\n"
        + "  text-indent: 0em;\n"
        + "  font-weight: normal;\n"
        + "  margin: 1em 0 0.5em 0;\n"
        + "  padding: 0 0 0 0;\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".exam_area h5 {\n"           ///////
        + "  font-size: " + cssFontSize + "px;\n"
        + "  line-height: 1.4em;\n"
        + "  text-indent: 1em;\n"
        + "  font-weight: normal;\n"
        + "  margin: 0 0 0.5em 0;\n"
        + "  padding: 0 0 0 0;\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".exam_area img {\n"
        + "  height: auto;\n"
        + "  vertical-align: middle;\n"
        + "  font-weight: bold;\n"
        + "}\n"
        + "span.answer {\n"
        + "  font-weight: bold;\n"
        + "  color: " + cssEnhancedColor + ";\n"
        + "}\n"
        + "span.enhanced {\n"
        + "  font-weight: bold;\n"
        + "  color: " + cssEnhancedColor + ";\n"
        + "}\n"
        + ".exam_area ul {\n"
        + "  margin: 0 0 0 1em;\n"
        + "  padding: 0 0 0 0;\n"
        + "  line-height: 1.4em;\n"
        + "}\n"
        + ".exam_area ol {\n"
        + "  margin: 0 0 0 1em;\n"
        + "  padding: 0 0 0 0;\n"
        + "  line-height: 1.4em;\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".exam_area li {\n"
        + "  font-size: " + cssFontSize + "px;\n"
        + "  line-height: 1.4em;\n"
        + "  margin: 0.5em 0 0 0;\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".brancharea {\n"
        + "  padding: 0.2em 0.7em 0.2em 0.2em;\n"
        + "  margin: 0.4em 0.2em 0.2em 0.2em;\n"
        + "  border: dashed thin " + cssTextColor + ";\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".branchtitle p {\n"
        + "  font-size: " + cssFontSize + "px;\n"
        + "  line-height: 1.4em;\n"
        + "  padding: 0 0 0 0;\n"
        + "  margin: 0 0 0 0.5em;\n"
        + "  text-indent: -1em;\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".branchlist p {\n"
        + "  font-size: " + cssFontSize + "px;\n"
        + "  line-height: 1.4em;\n"
        + "  padding: 0 0 0 0;\n"
        + "  margin: 0 0 0 1.5em;\n"
        + "  text-indent: -1em;\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".examtable td {\n"
        + "  border-collapse: collapse;\n"
        + "  border: solid 1px " + cssTextColor + ";\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".examtable table {\n"
        + "  border-collapse: collapse;\n"
        + "  color: " + cssTextColor + ";\n"
       + "}\n"
        + ".examtable th, td {\n"
        + "  border: solid 1px " + cssTextColor + ";\n"
        + "}\n"
        + "td.w20, th.w20 {\n"
        + "  color: " + cssTextColor + ";\n"
        + "  width: 20%;\n"
        + "}\n"
        + "td.center  {\n"
        + "  color: " + cssTextColor + ";\n"
        + "   text-align: center;\n"
        + "   width: 20%;\n"
        + "}\n"
        + "td.w30, th.w30 {\n"
        + "  color: " + cssTextColor + ";\n"
        + "  width: 30%;\n"
        + "}\n"
        + "td.w40, th.w40 {\n"
        + "  color: " + cssTextColor + ";\n"
        + "  width: 40%;\n"
        + "}\n"
        + "td.w50, th.w50 {\n"
        + "  color: " + cssTextColor + ";\n"
        + "  width: 50%;\n"
        + "}\n"
        + "td.w60, th.w60 {\n"
        + "  color: " + cssTextColor + ";\n"
        + "  width: 60%;\n"
        + "}\n"
        + ".sourcearea p {\n"
        + "  font-size: " + cssFontSize80 + "px;\n"
        + "  line-height: 1.4em;\n"
        + "  margin: 0.5em 1em 0 1em;\n"
        + "  text-indent: 0;\n"
        + "  color: " + cssTextColor + ";\n"
        + "}\n"
        + ".no-indent p {\n"
        + "  font-size: " + cssFontSize + "px;\n"
        + "  line-height: 1.4em;\n"
        + "  margin: 0.5em 1em 0 0;\n"
        + "  text-indent: -1em;\n"
        + "}\n"
        + "span.hole {\n"
        + "  font-weight: bold;\n"
        //          + "  text-decoration: underline;\n"
        + "   border: 2px solid;\n"
        + "}\n"
        + "img.figure {\n"
        + "  max-width: 100%;\n"
        + "  height: auto;\n"
        + "}\n"
        + "span.bold {\n"           ////////////
        + "  font-weight: bold;\n"
        + "}\n"
        + "body {\n"
        + "  background: " + cssBackgroundColor + ";\n"
        + "  font-family: sans-serif;\n"
        + "  -webkit-text-size-adjust: 100%;\n"
        + "  padding: 0em 0.5em 0em 0.5em;\n"
        + "}\n"
    public static let formatEmptyHtml = ""
        + "<!DOCTYPE html>\n"
        + "<html lang='ja'>\n"
        + "<head>\n"
        + "<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>\n"
        + "<title>Exam</title>\n"
        + "</head>\n"
        + "<body style='background: " + cssBackgroundColor + ";' >\n"
        + "</body>\n"
        + "</html>\n"
    private var header: String
    public var commentHtml: String
    private var imageDirectory: String
    private static var thisInstance: HtmlPage! = nil

    public static func getInstance() -> HtmlPage {
        if thisInstance == nil {
            thisInstance = HtmlPage()
        }
        return thisInstance
    }// getInstance()
    
    private init() {
        self.header = HtmlPage.generateHeaderTemplate()
        self.imageDirectory = ""
        self.commentHtml = ""
        self.imageDirectory = generateImageDirectory()
    }//init()
   
    public static func generateHeaderTemplate() -> String {
        return "<title>Exam - " + HtmlPage.subtitlePlace + "</title>\n"
            + HtmlPage.commentPlace
            + "<style>\n" + HtmlPage.formatCss + "</style>"
        
    }//generateHeaderTemplate()


    private func getCommentHtml() -> String {
        if self.commentHtml == "" {
            return ""
        } else {
            return "<!-- \n" + self.commentHtml + "\n-->\n"
        }
    }//getCommentHtml()
    
    private func normalizeImageName(html: String) throws -> String {
//        if Daark
//        return fileName.replace(before: "-?.", after: "-A.")    ExamColor.mode colorScheme;
//        do {
//        let colorScheme = SettingDao().readColorScheme();
//        } catch ExamError.sql {
//        let colorScheme = ExamColor.Mode.bright;
//        }
        if (ExamColor.mode == ExamColor.Mode.bright) {
            return html.replace(before: "-?.png", after: "-A.png")
        } else if (ExamColor.mode == ExamColor.Mode.dark) {
            return html.replace(before: "-?.png", after: "-K.png")
        } else {
            throw ExamError.runtime("Invalid Color Mode: \(ExamColor.mode)");
        }
    }//normalizeImageName(html: String)
    
    private func generateImageDirectory() -> String {
        return "images/"
    }
    
    private func convertImgSrc(html: String) -> String {
        return html
    }//convertImgSrc(html: String)
    
    private func generateHeader() -> String {
        return generateHeader(fontSize: Repository.examFontSize)
    }//generateHeader()
    
    private func generateHeader(fontSize: Float) -> String {
//        _ = log(40, "HtmlPage#generateHeader fontSize=\(fontSize.d1), fontRate=\(DeviceOrientation.fontRate.d1), webFontSize=\(HtmlPage.getWebFontSize(fontSize: fontSize).d1)")
        return self.header
            .replace(before: HtmlPage.subtitlePlace, after: "\(viewState.value())")
            .replace(before: HtmlPage.commentPlace, after: getCommentHtml())
            .replace(before: HtmlPage.cssTextColor, after: ExamColor.normalText)
            .replace(before: HtmlPage.cssEnhancedColor, after: ExamColor.enhancedText)
            .replace(before: HtmlPage.cssBackgroundColor, after: ExamColor.background)
//            .replace(before: HtmlPage.cssFontSize, after: HtmlPage.getWebFontSize(fontSize: fontSize).d1)
            .replace(before: HtmlPage.cssFontSize, after: fontSize.d1)
            .replace(before: HtmlPage.cssFontSize80, after: (fontSize * 0.8).d1)
    } //generateHeader(fontSize: Float)
  
    public func getPage(page: String) throws -> String {
        let html = HtmlPage.headerOpen + generateHeader() + HtmlPage.headerClose
                + HtmlPage.bodyOpen + page + HtmlPage.bodyClose
        _ = log(50, "HtmlPage#getPage()  \n\(html)")
        return try convertHtml(html: html)
    }//getPage(String page)
    
    public func getPage(paragraphs: [String]) throws -> String {
        var html: String! = nil
        for paragraph in paragraphs {
            if html == nil {
                html = HtmlPage.headerOpen + generateHeader() + HtmlPage.headerClose + HtmlPage.bodyOpen
            } else {
                html += "<hr/>\n"
            }
            html += paragraph + "\n"
        } //for (String s : paragraphs)
            html += HtmlPage.bodyClose
            _ = log(50, "HtmlPage#getPage  \n\(html!)")
            return try convertHtml(html: html)
    }//getPage(String[] paragraphs)
    
    public func getPage(examUnit: ExamUnit, top: String, bottom: String) throws -> String {
        var html = HtmlPage.headerOpen + generateHeader() + HtmlPage.headerClose + HtmlPage.bodyOpen
        html += top //【問題
        html += HtmlPage.getQuestionHeader(code: " " + examUnit.code).inBold().inH4()
        html += examUnit.questionParagraph
        html += examUnit.questionImage
        html += examUnit.selectionBox
        html += HtmlPage.getAnswerHeader(code: " " + examUnit.code).inBold().inH4()
        let answer = examUnit.answerParagraph
        html += try TagPreprocessor.getInstance(source: answer).parse()
        html += examUnit.answerImage
        html += HtmlPage.getCommentHeader(code: " " + examUnit.code).inBold().inH4()
        let comment = examUnit.commentParagraph
        html += try TagPreprocessor.getInstance(source: comment).parse()
        html += examUnit.commentImage
        html += bottom
        html += HtmlPage.bodyClose
        _ = log(50, "HtmlPage#getPage \n\(html)")
        return try convertHtml(html: html)
    }//getPage(examUnit: ExamUnit, String addition)
    
    public static func getQuestionHeader(code: String) -> String {
        return String(format: HtmlPage.formatQuestionTitle, code)
    }//getQuestionHeader(index: Int)
    
    public static func getAnswerHeader(code: String) -> String {
        return String(format: HtmlPage.formatAnswerTitle, code)
    }//getAnswerHeader(index: Int)
    
    public static func getCommentHeader(code: String) -> String {
        return String(format: HtmlPage.formatCommentTitle, code)
    }//getCommentHeader(index: Int)
    
    private func convertHtml(html: String) throws -> String {
        return try normalizeImageName(html: convertImgSrc(html: html)).replace(before: "‡", after: " ")
    }//convertHtml(html: String)
    
//    abstract fileprivate func convertImgSrc(html: String)
    
    public func getPage(examUnit: ExamUnit) throws -> String {
        return try getPage(examUnit: examUnit, top: "", bottom: "")
    }//getPage(examUnit: ExamUnit)
    
    public func generateHeading(heading: String) -> String {
        return heading.inH4()
    }//generateHeading(String heading)
    
    public func generateSourceDivsion(source: String, code: String) -> String {
        return generateSourceAreaDivsion(text: "<p>" + source + "</p>\n")
    }//generateSourceDivsion(String source)
    
    public func generateSourceDivsion(dto: ExamSourceDto) throws -> String {
        return generateSourceDivsion(source: try dto.encryptedSource!.decrypt().trim(), code: dto.code)
    }//generateSourceDivsion(dto: ExamSourceDto)
    
//    public func generateSourceDivsion(dto: PlainExamDto) throws -> String  {
//        return generateSourceDivsion(dto.getPlainSource.trim(), dto.getCode)
//    }//generateSourceDivsion(dto: PlainExamDto)
    
    public func generateCommentParagraph(comment: String, examUnit: ExamUnit) -> String {
        var commentParagraph = "<p>" + comment + "</p>\n"
        let questionParagraph = examUnit.questionParagraph
        let answerParagraph = examUnit.answerParagraph
        if examUnit.qaType == QaType.correctness {
            if questionParagraph == answerParagraph {
                commentParagraph = "<p>" + HtmlPage.messageCorrectAnswer + "</p>" + commentParagraph
            } //if questionParagraph == answerParagraph
        } //if qaType == QaType.correctness))
        return commentParagraph
    }//generateCommentParagraph(String comment, ...
    
    public func generateCommentParagraph(dto: ExamSourceDto, examUnit: ExamUnit) throws -> String  {
        return generateCommentParagraph(comment: try dto.encryptedComment!.decrypt().trim(), examUnit: examUnit)
    }//generateCommentParagraph(dto: ExamSourceDto, examUnit: ExamUnit)
    
    public func generateSourceAreaDivsion(text: String) -> String {
        //    return "<div class='no-indent'>\n" + s + "\n</div>\n"
        return "<div class='sourcearea'>\n" + text + "\n</div>\n"
    }//generateSourceAreaDivsion(String s)
    
    public func generateImgTag(imageFile: String) throws -> String {
        let imageFile = try normalizeImageName(html: imageFile)
        //    return "<img style='max-width: 100% height: auto' "
        //            + "src='file: //" + getImageDirectory()
        //            + imageFile + "' alt='Fig: " + imageFile + "' />\n"
        return "<img class='figure' "
            + "src='\(imageFile)' alt='\(imageFile)' />\n"
 
    }//
//
//    public func setImageDirectory(imageDirectory: String) {
//        self.imageDirectory = imageDirectory.replace(before: "\\\\", after: "/")
//    }
}//class HtmlPage

/** End of File **/
