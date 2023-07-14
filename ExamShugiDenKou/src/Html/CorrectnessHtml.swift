//
//  CorrectnessHtml.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/17.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation

public class CorrectnessHtml {
    
    public  var index: Int
    
    init() {
        self.index = 0
    }
    
    public func generate(tokenSet: TokenSet, index: Int) throws -> String {
        var paragraph = ""
        self.index = index
        for token in tokenSet.list {
            paragraph += try getTextFormToken(token: token)
        }///while
        return "<p>\n" + getPrefix(index: self.index) + paragraph + "</p>\n"
    }//generate(ArrayList<Token> tokenSet, index: Int)
    
    public func generate(tokenSet: TokenSet) throws -> String {
        return try generate(tokenSet: tokenSet, index: 0)
    }//generate(ArrayList<Token> tokenSet)
    
    public func getPrefix(index: Int) -> String {
        return ""
    }//getPrefix(index: Int)
    
    public func getTextFormToken(token: Token) throws -> String {
        return ""
    }
}//class CorrectnessHtml

public class CorrectnessQuestionHtml: CorrectnessHtml {
    override public init() {
        super.init()
    }
    
    override public func getTextFormToken(token: Token) throws -> String {
        if token.type == TokenType.plain || token.type == TokenType.tag {
            return token.text
        } else if token.type == TokenType.blankQa {
            return token.answer
        } else if token.type == TokenType.correctnessQa {
            if token.existsQuestion(index: self.index) {
                return token.choices[self.index]!
            } else {
                return token.answer
            }
            //} else if token.type == TokenType.fillingQa)) {
        } else {
            throw ExamError.runtime("Invalid token type(2): "
                + token.type.toString())
        }
    }//getTextFormToken(token: Token)
}//class CorrectnessQuestionHtml

public class CorrectnessAnswerHtml: CorrectnessHtml {

    override public init() {
        super.init()
    }

    override public func getTextFormToken(token: Token) throws -> String {
        if token.type ==  TokenType.plain || token.type == TokenType.tag {
            return token.text
        } else if token.type == TokenType.blankQa {
            return HtmlPage.answerOpen + token.answer + HtmlPage.answerClose
        } else if token.type == TokenType.correctnessQa {
            if token.existsQuestion(index: self.index)
                && token.choices[self.index] != token.answer {
                return HtmlPage.answerOpen + token.answer + HtmlPage.answerClose
            } else {
                return token.answer
            }
        } else {
            throw ExamError.runtime("Invalid token type(3): "
                + token.type.toString())
        }
    }//getTextFormToken(token: Token)
}//class CorrectnessAnswerHtml
/** End of File **/
