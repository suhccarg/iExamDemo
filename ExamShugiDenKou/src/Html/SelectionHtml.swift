//
//  FillingHtml.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/17.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
  
public class SelectionHtml {
    private static let formatHole = " <span class='hole'>"
        + "&nbsp;&nbsp;&nbsp;&nbsp;%@&nbsp;&nbsp;&nbsp;&nbsp;</span> "
    
    fileprivate var index: Int
    public var qaType: QaType
    
    private init() {
        self.index = 0
        self.qaType = QaType.na
    }
    
    public init(qaType: QaType) {
        self.index = 0
        self.qaType = qaType
    }
    
    public func generate(tokenSet: TokenSet, phrases: [SelectionPhrases?]) throws -> String {
        var paragraph = ""
        //self.index = index
        prepare(tokenSet: tokenSet)
        for token in tokenSet.list {
            paragraph += try getTextFormToken(token: token, phrases: phrases)
        }///for
        return "<p>\n" + paragraph + "</p>\n"
    }//generate(ArrayList<Token> tokenSet, index: Int)
    
    public func prepare(tokenSet: TokenSet) {
        qaType = tokenSet.qaType
        
    }//prepare()

    public func getHoleString(number: Int) -> String {
        return String(format: SelectionHtml.formatHole, QaElements.getHoleString(index: number))
    }
    
    public func getEmptyHole() -> String {
        return String(format: SelectionHtml.formatHole, "")
    }
    
    public func getPrefix(index: Int) -> String {
        return ""
    }//getPrefix(index: Int)
    
    public func getTextFormToken(token: Token, phrases: [SelectionPhrases?]) throws -> String {
        return ""
    }
    
}//class SelectionHtml

public class SelectionQuestionHtml: SelectionHtml {
    
//    override public init() {}
    
    public func generate(tokenSet: TokenSet, fillingPhrases: [SelectionPhrases?]) throws -> String {
        return  try super.generate(tokenSet: tokenSet, phrases: fillingPhrases)
    }//generate(tokenSet: tokenSet, FillingPhrases[] phrases)
    
    override public func getTextFormToken(token: Token, phrases: [SelectionPhrases?]) throws -> String {
        if token.type == TokenType.plain || token.type == TokenType.tag {
            return token.text
        } else if token.type == TokenType.fillingQa {
            return getHoleString(number: token.hole)
        } else if token.type == TokenType.branchQa {
            return ""
        } else if token.type == TokenType.blankQa {
            return getEmptyHole()
        } else {
            throw ExamError.runtime("Invalid token type(4)9: "
                + token.type.toString())
        }
    }//getTextFormToken(token: Token)
}//class SelectionQuestionHtml

public class SelectionAnswerHtml: SelectionHtml {
    
//    override public init() {}
    
    override public func getTextFormToken(token: Token, phrases: [SelectionPhrases?]) throws -> String {
        if self.qaType == QaType.correctness || self.qaType == QaType.filling {
            if token.type == TokenType.plain || token.type == TokenType.tag {
                return token.text
            } else if token.type == TokenType.fillingQa || token.type == TokenType.branchQa {
                let phrase = phrases[token.hole]!
                let roundNumber = try getRoundNumber(phrase.answerIndex + 1)
                return HtmlPage.answerOpen
                    + roundNumber
                    + phrase.answerPhrase.replace(before: "-?.png", after: "%23-?.png") + HtmlPage.answerClose
            } else {
                throw ExamError.runtime("Invalid token type: \(token.type.name)")
            }
        } else if self.qaType == QaType.branch {
            if token.type == TokenType.branchQa {
                let phrase = phrases[token.hole]
                return try getRoundNumber(phrase!.answerIndex + 1)
                    + phrase!.answerPhrase.replace(before: "-?.png", after: "%23-?.png")
            } else {
                return ""
            }
        } else if self.qaType == QaType.blank {
            if token.type == TokenType.blankQa {
                let phrase = phrases[token.hole]
                return phrase!.answerPhrase.replace(before: "-?.png", after: "%23-?.png")
            } else {
                return ""
            }
        } else {
            throw ExamError.runtime("Invalid qaType: \(self.qaType.name)")
        }
    }//getTextFormToken(token: Token)
    
}//class SelectionAnswerHtml

public class SelectionBoxHtml: SelectionHtml {
    fileprivate static let selectionAreaOpen = HtmlPage.selectionAreaOpen
    fileprivate static let selectionAreaClose = HtmlPage.selectionAreaClose
    private static let selectionListDivOpen = "\n  <div class='branchlist'>\n"
    private static let pOpen = "    <p>\n         "
    private static let pClose = "\n    </p>\n"
    private static let selectionListDivClose = "  </div>\n"
//    private static let formatBranchHeader = ""
//        + "    <div class='branchtitle'>\n"
//        + "      <p>《%@の語群》</p>\n"
//        + "    </div>\n"
    private static let formatFillingHeader = HtmlPage.formatFillingHeader
    private static let formatSelectionHeader = HtmlPage.formatSelectionHeader

//    override public init() {}
    
    public func generate(tokenSet: TokenSet, selectionPhrase: [SelectionPhrases?]) throws -> String {
        var html = ""
        for i in 0 ..< selectionPhrase.count {
            html += try generateBranchArea(selectionPhrases: selectionPhrase[i])
        }
        return html
    }//generate(tokenSet: tokenSet, FillingPhrases[] phrases)

    public func generateBranchArea(selectionPhrases: SelectionPhrases?) throws -> String {
        if selectionPhrases == nil {
            return ""
        }
        var html = ""
        if qaType == QaType.blank {
            return html;
        }
        html += SelectionBoxHtml.selectionAreaOpen
        if qaType == QaType.filling {
            html += String(format: SelectionBoxHtml.formatFillingHeader, QaElements.getHoleString(index: selectionPhrases!.hole))
        } else if qaType == QaType.branch {
            html += String(format: SelectionBoxHtml.formatSelectionHeader,
                           QaElements.getHoleString(index: selectionPhrases!.hole))
        } else {
            throw ExamError.assert(String(format:"Invalid QaType: [%d] %@",
                                                   [qaType.code, qaType.name] ))
        }
        html += SelectionBoxHtml.selectionListDivOpen
        for i in 0 ..< selectionPhrases!.choices.count {
            html += SelectionBoxHtml.pOpen
            html += try getRoundNumber(i + 1)
            html +=  " " + selectionPhrases!.choices[i]
            html +=  SelectionBoxHtml.pClose
        } //for i in 0 ..< branchPhrases!.choices.count
        html += SelectionBoxHtml.selectionListDivClose
        html += SelectionBoxHtml.selectionAreaClose
        return html
    }//generateBranchArea(String heading)

    override public func getTextFormToken(token: Token, phrases: [SelectionPhrases?]) throws -> String {
        if token.type == TokenType.plain || token.type == TokenType.tag {
            return token.text
        } else if token.type == TokenType.fillingQa {
            return getHoleString(number: token.hole)
            //  } else if token.type == TokenType.correctnessQa) {
        } else if token.type == TokenType.branchQa || token.type == TokenType.blankQa {
            return ""
        } else {
            throw ExamError.runtime("Invalid token type(6): "
                + token.type.toString())
        }
    }//getTextFormToken(token: Token)
    
}//class SelectionBoxHtml

public class SelectionListHtml: CorrectnessHtml {
    private static let formatSelectionHeader = "  <div class='no-indent'><p>"
        + "《<span style='font-weight: bold; text-decoration: underline;'>%@</span>の語群》<p></div>\n"
    
    override public init() {
        super.init()
    }//init()
    
    override public func generate(tokenSet: TokenSet, index: Int) -> String {
        var hole = 0
        var paragraph = ""
        self.index = index
        for token in tokenSet.list {
            let html = getTextFormToken(token: token)
            if html != "" {
                paragraph += String(format: SelectionListHtml.formatSelectionHeader, QaElements.getHoleString(index: hole))
                hole += 1
                paragraph += html
            }
        }///while
        return "<p>\n" + paragraph + "</p>\n"
    }//ggenerate(tokenSet: tokenSet, index: Int)
    
    override public func getTextFormToken(token: Token) -> String {
        let html = ""
        if token.type == TokenType.fillingQa {
            //
        }
        return html
    }//getTextFormToken(token: Token)
    
}//class class SelectionListHtml
/** End of File **/
