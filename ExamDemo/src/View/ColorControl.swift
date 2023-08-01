//
//  ColorControl.swift
//  ExamDemo
//
//  Created by suhccarg on 2023/08/01.
//

import Foundation
#if canImport(ExamLib)
import ExamLib
#endif
open class  ExamColorKoutanThemeChanger: ExamColorChanger {
    public override init() {
        super.init()
    }
    
    override open func setBrightColor() {
        ExamColor.base = "#FFFFCC"
        ExamColor.baseText = "#000000"
        ExamColor.background = "#FFFFFF"                //
        ExamColor.titleBar = "#006600"
        ExamColor.titleText = "#FFFFFF"
        ExamColor.normalText = "#000000"
        ExamColor.enhancedText = "#990000"
        ExamColor.tint = "#00CC00"                      // "#0000CC"
        ExamColor.frameTopLeft = "#999999"
        ExamColor.frameBottomRight = "#CCCCCC"
        ExamColor.normalButtonBase = "#FF9900"
        ExamColor.pushedButtonBase = "#CC6600"
        ExamColor.normalButtonText = "#000000"
        ExamColor.pushedButtonText = "#000000"
        ExamColor.dividingLineTop =  "#DDDD99"
        ExamColor.dividingLineBottom = "#FFFFEE"
        ExamColor.buttonArea = "#EEEEBB"
        ExamColor.optionButtonActiveFore = "#00CC00"    // "#0000CC"
        ExamColor.optionButtonActiveBack = "#FFFFFF"    //
        ExamColor.optionButtonInactiveFore = "#666666"
        ExamColor.optionButtonInactiveBack = "#DDDDDD"
    }//setBrightColor()
    
    override open  func setDarkColor() {
        ExamColor.base = "#333333"
        ExamColor.baseText = "#CCCCCC"
        ExamColor.background = "#002200"                // "#000022"
        ExamColor.titleBar = "#003300"
        ExamColor.titleText = "#CCCCCC"
        ExamColor.normalText = "#CCCCCC"
        ExamColor.enhancedText = "#CC7A7A"
        ExamColor.tint = "#009900"                      // "#000099"
        ExamColor.frameTopLeft = "#222222"
        ExamColor.frameBottomRight = "#555555"
        ExamColor.normalButtonBase = "#663333"
        ExamColor.pushedButtonBase = "#442222"
        ExamColor.normalButtonText = "#CCCCCC"
        ExamColor.pushedButtonText = "#EEEEEE"
        ExamColor.dividingLineTop = "#222222"
        ExamColor.dividingLineBottom = "#555555"
        ExamColor.buttonArea = "#444444"
        ExamColor.optionButtonActiveFore = "#CCCCCC"    //
        ExamColor.optionButtonActiveBack = "#009900"    // "#000099"
        ExamColor.optionButtonInactiveFore = "#999999"
        ExamColor.optionButtonInactiveBack = "#333333"
    }//setDarkColor()
    
}//class ExamColorKoutanThemeChanger

open  class  ExamColorShugiThemeChanger: ExamColorKoutanThemeChanger {
    
    override open  func setBrightColor() {
        super.setBrightColor()
        ExamColor.titleBar = "#000066"
        ExamColor.titleText = "#FFFFFF"
        
        ExamColor.tint = "#0000CC"
        ExamColor.optionButtonActiveFore = "#0000CC"
        ExamColor.optionButtonActiveBack = "#FFFFFF"
    }//setBrightColor()
    
    override open  func setDarkColor() {
        super.setDarkColor()
        ExamColor.titleBar = "#000033"
        ExamColor.titleText = "#CCCCCC"
        
        ExamColor.background = "#000022"                // "#003300"
        ExamColor.tint = "#000099"
        ExamColor.optionButtonActiveFore = "#CCCCCC"
        ExamColor.optionButtonActiveBack = "#000099"
    }//setDarkColor()
    
}//class ExamColorShugiThemeChanger

open  class  ExamColorBlueThemeChanger: ExamColorChanger  {
    
    override open  func setBrightColor() {
        ExamColor.base = "#EEEEEE"
        ExamColor.baseText = "#000000"
        ExamColor.background = "#FFFFFF"
        ExamColor.titleBar = "#000066"
        ExamColor.titleText = "#FFFFFF"
        ExamColor.normalText = "#000000"
        ExamColor.enhancedText = "#990000"
        ExamColor.tint = "#0000CC"
        ExamColor.frameTopLeft = "#999999"
        ExamColor.frameBottomRight = "#CCCCCC"
        ExamColor.normalButtonBase = "#CCFFFF"
        ExamColor.pushedButtonBase = "#99CCCC"
        ExamColor.normalButtonText = "#000000"
        ExamColor.pushedButtonText = "#000000"
        ExamColor.dividingLineTop = "#9999DD"
        ExamColor.dividingLineBottom = "#FFFFEE"
        ExamColor.buttonArea = "#DDDDDD"
        ExamColor.optionButtonActiveFore = "#0000CC"
        ExamColor.optionButtonActiveBack = "#FFFFFF"
        ExamColor.optionButtonInactiveFore = "#666666"
        ExamColor.optionButtonInactiveBack = "#DDDDDD"
    }//setBrightColor()
    
    override open  func setDarkColor() {
        ExamColor.base = "#333333"
        ExamColor.baseText = "#CCCCCC"
        ExamColor.background = "#000033"
        ExamColor.titleBar = "#000044"
        ExamColor.titleText = "#CCCCCC"
        ExamColor.normalText = "#CCCCCC"
        ExamColor.enhancedText = "#CC7A7A"
        ExamColor.tint = "#000099"
        ExamColor.frameTopLeft = "#222222"
        ExamColor.frameBottomRight = "#555555"
        ExamColor.normalButtonBase = "#000066"
        ExamColor.pushedButtonBase = "#000099"
        ExamColor.normalButtonText = "#CCCCCC"
        ExamColor.pushedButtonText = "#EEEEEE"
        ExamColor.buttonArea = "#444444"
        ExamColor.dividingLineTop = "#222222"
        ExamColor.dividingLineBottom = "#555555"
        ExamColor.optionButtonActiveFore = "#CCCCCC"
        ExamColor.optionButtonActiveBack = "#000099"
        ExamColor.optionButtonInactiveFore = "#999999"
        ExamColor.optionButtonInactiveBack = "#333333"
    }//setDarkColor()
}//class ExamColorBlueThemeChanger

