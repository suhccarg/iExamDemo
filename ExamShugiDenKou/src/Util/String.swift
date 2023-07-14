//
//  String.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/21.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func right(_ to: Int) -> String {
        return substring(to: to)
    }//right(_ to: Int)
    
    func substring(to: Int) -> String {
        let last = min(to, self.count)
        return String(self[self.startIndex..<self.index(self.startIndex, offsetBy: last)])
    }//func substring(to: Int)
    
    func substring(from: Int) -> String {
        let first = max(0, from)
        return String(self[self.index(self.startIndex, offsetBy: first)..<self.endIndex])
    }//substring(from: Int)
    
    func substring(from: Int, to: Int) -> String {
        let first = max(0, from)
        let last = min(to, self.count)
        return String(self[self.index(self.startIndex,
                                      offsetBy: first)..<self.index(self.startIndex, offsetBy: last)])
    }//substring(from: Int, to: Int)
    
    func replace(before: String, after: String) -> String {
        return self.replacingOccurrences(of: before, with: after)
    }//replace(before: String, after: String)
    
    func find(regex pattern: String) throws -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        guard regex != nil else {
            throw ExamError.runtime("Invalid regular expression: \(pattern)")
        }
        return regex!.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, self.count)) != nil
    }//func find(regex pattern: String)
    
    func find(pattern: String) -> Int? {
        if self.count < pattern.count {
            return nil
        }
        for i in 0 ... self.count - pattern.count {
            if self.getc(at: i) == String(pattern.first!) {
                if self.substring(from: i, to: i + pattern.count) == pattern {
                    return i
                }
            }
        }//for i in 0 ...
        return nil
    }//find(pattern: String)
    
    func getc(at position: Int) -> String {
        let index = self.index(self.startIndex, offsetBy: position)
        return String(self[index...index])
    }//getc(at position: Int)
    
    func isSpace() -> Bool {
        return self == " " || self == "\t" || self == "\n" || self == "\r"
    }//isSpace()
    
    func ltrim() -> String {
        for index in 0..<self.count {
            if !self.getc(at: index).isSpace() {
                return self.substring(from: index)
            }
        }//for
        return ""
    }//ltrim()
    
    func rtrim() -> String {
        for index in (0..<self.count).reversed() {
            if !self.getc(at: index).isSpace() {
                return self.substring(to: index + 1)
            }
        }//for
        return ""
    }//rtrim()
    func trim() -> String {
        return self.ltrim().rtrim()
    }//trim()
    
    func inH4() -> String {
        return "<h4>\(self)</h4>\n"
    }
    func inH5() -> String {
        return "<h5>\(self)</h5>\n"
    }
    func inBold() -> String {
        return HtmlPage.boldOpen + "\(self)" + HtmlPage.boldClose
    }
    func inDiv(className: String) -> String {
        return "<div class=\'\(className)\'>\n"
            + "  \(self)\n</div>\n"
    }
    
    ///// Color /////
    public var uiColor: UIColor {
        return self.toUIColor()
    }
    public var cgColor: CGColor {
        return self.toUIColor().cgColor
    }
    
    func toUIColor() -> UIColor {
        if self == "" {
            return UIColor.clear
        }
        do {
            let rgb = try self.parseRgb()
            let r: CGFloat = round(CGFloat(rgb.red) / 25.5) / 10.0
            let g: CGFloat = round(CGFloat(rgb.green) / 25.5) / 10.0
            let b: CGFloat = round(CGFloat(rgb.blue) / 25.5) / 10.0
            return UIColor.init(red: r, green: g, blue: b, alpha: 1.0)
        } catch let e {
            _ = log(0, "ExamColor - toUIColor(\"\(self)\"): \(e)")
            return UIColor.white
        }
    }//toUIColor(color: String)
    
    
    private func parseRgb() throws -> (red: Int, green: Int, blue: Int) {
        Assert.isTrue(self.count == 7, "Invalid color string: \(self)")
        do {
            let red = try self.substring(from: 1, to:3).parseHex()
            let green = try self.substring(from: 3, to:5).parseHex()
            let blue = try self.substring(from: 5, to:7).parseHex()
            return (red: red, green: green, blue: blue)
        } catch let e {
            throw ExamError.runtime("parseRgb(\"\(self)\": \(e)")
        }
    }//parseRgb(color: String)
    
    private func parseHex() throws -> Int {
        if let n = Int(self, radix: 16) {
            if 0 <= n && n < 0x100 {
                //print("\(self) -> \(n)")
                return n
            }
        }
        throw ExamError.runtime("Invalid hexadecimal string: \(self)")
    }//parseHex(hex: String)

}//extension String
/** End of File **/
