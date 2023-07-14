//
//  Repository.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/21.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
import UIKit

public let debugLevel = 0

public var examManager: ExamManager!

let defaultMargin: CGFloat = 8.0

public enum ViewType {
    case menu, setting, question, answer, review, message
    case always, unknown
    
    public func value() -> String {
        return "\(String(describing: self))"
    }
}//enum ViewType

public var viewState: ViewType = .menu

public class Repository {
    ///////////////////////////////////////////////////////////////////////////
//    public static let applicationType = ApplicationType.shugiHouki
//    private static let baseName = "Exam"
//    public static let defaultOptionType: OptionType = .optionS
//
//    public static let examCategories: [ExamCategory] = [
//        ExamCategory.sho01Jigyouhou ,
//        ExamCategory.sho02JigyouyouSetsubi ,
//        ExamCategory.sho03TanmatsuSetsubi ,
//        ExamCategory.sho04YuusenTsuushin ,
//        ExamCategory.sho09Other
//    ]
//    public static let initialCategoryCode = ExamCategory.sho01Jigyouhou
    ///////////////////////////////////////////////////////////////////////////@@
    public static let applicationType = ApplicationType.shugiDenKou
    private static let baseName = "Exam"
    public static let defaultOptionType: OptionType = .optionS

    public static let examCategories: [ExamCategory] = [
        ExamCategory.sdk21Setsubi,
        ExamCategory.sdk22Shinraisei_System,
        ExamCategory.sdk24Koukan_Musen,
        ExamCategory.sdk25Densou,
        ExamCategory.sdk27Network,
        ExamCategory.sdk29Security,
        ExamCategory.sdk31Denryoku ]
    public static let initialCategoryCode = ExamCategory.sdk21Setsubi
    ///
    /////////////////////////////////////////////////////////////////////////////////
//    public static let applicationType = ApplicationType.roumuSample
//    //        public static let applicationType = ApplicationType.sample
//    private static let baseName = "Exam"
//    public static let defaultOptionType: OptionType = .optionT
//    //    public static let defaultOptionType: OptionType = .optionD
//
//
//    public static let examCategories: [ExamCategory] = [
//        ExamCategory.roumuSample1, ExamCategory.roumuSample2, ExamCategory.roumuSample3 ]
//    public static let initialCategoryCode = ExamCategory.roumuSample1
/////////////////////////////////////////////////////////////////////////////////
//    public static let applicationType = ApplicationType.koutanGijutsuDigital1
//        private static let baseName = "Exam"
//        public static let defaultOptionType: OptionType = .optionD
//        public static let examCategories: [ExamCategory] = [
//            ExamCategory.kg1Terminal,
//            ExamCategory.kg2Construction,
//            ExamCategory.kg3Network,
//            ExamCategory.kg4Security]
//        public static let initialCategoryCode = ExamCategory.kg1Terminal
    ////////////////////
    public static let initialQuestionCount: Int = 5
    public static let initialExamFontSize: Float = 16.0     // 16px = 12pt

    public static let hiddenCounterLimit =  3
    public static let defaultFontSize: CGFloat = 16.0
    public static var allCheck = false
    public static var checkMode = false

    public static var menu: MenuViewController!
    //public static var categoryCode: Int = ExamCategory.unknown.code

    private static let keyExamCategory = "ExamCategory"
    private static let keyDarkMode = "DarkMode"
    private static let keyOptionState = "OptionState"
    private static let keyQuestionCount = "QuestionCount"
    private static let keyExamFontSize = "ExamFontSize"
    public static var defaultOptionList = [
        OptionType.optionS: true,
        OptionType.optionD: false,
        OptionType.optionA: false
    ]
    private static var thisInstance: Repository! = nil

    public static func getInstance() -> Repository {
        if thisInstance == nil {
            thisInstance = Repository()
            do {
                ExamCategory.initialize();
                ApplicationType.initialize();
                try ExamCategory.check();
                try ApplicationType.check();
            } catch let e {
                onError(log(10, "Repository#getInstance:\(e)"))
            }
        }
        return thisInstance
    }// getInstance()

    public static func getDbFileName() -> String  {
    return "\(baseName)\(getInstance().getFileNamePrefix()).db";
    }//getDbFileName()
    
    private func getFileNamePrefix() -> String {
        var prefix = Repository.applicationType.name
    if isTrial() {
            prefix += "Trial"
        }
    return prefix
    }// getFileNamePrefix()
    
    public func isTrial() -> Bool {
        return Repository.applicationType.isTrial()
    }
    public static func useOption() -> Bool {
        return Repository.applicationType.useOption()
    }
    public static func isKoutan() -> Bool {
        return Repository.applicationType.isKoutan()
    }
    public static func isShugi() -> Bool {
        return Repository.applicationType.isShugi()
    }
    public static func isBlueTheme() -> Bool {
        return Repository.applicationType.isBlueTheme()
    }
    public static var categoryCode: Int {
        get {
            let code = UserDefaults.standard.integer(forKey: Repository.keyExamCategory)
            for category in Repository.examCategories {
                if category.code == code {
                    return code
                }
            }
            return Repository.initialCategoryCode.code
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Repository.keyExamCategory)
        }
    }//var examCategory
    public static var darkMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Repository.keyDarkMode)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Repository.keyDarkMode)
        }
    }//var darkMode
    public static var optionList: [OptionType: Bool] {
        get {
            if Repository.useOption() == false {
                return [Repository.defaultOptionType: true]
            }
            let records = UserDefaults.standard.dictionary(forKey: Repository.keyOptionState)
                as? [String: Bool]
            if records == nil {
                return defaultOptionList
            }
            var list: [OptionType: Bool] = [:]
            for r in records! {
                list[try! OptionType.find(codeString: r.key)] = r.value
            }
            return list
        }//get
        set {
            var records: [String: Bool] = [:]
            for optionState in newValue {
                records[String(optionState.key.code)] = optionState.value
            }
            UserDefaults.standard.set(records , forKey: Repository.keyOptionState)
        }//set
    }//var optionList
    public static var questionCount: Int {
        get {
            let n = UserDefaults.standard.integer(forKey: Repository.keyQuestionCount)
            if n == 0 {
                return Repository.initialQuestionCount       // default
            }
            let minLimit = Int(QuestionCountGroup.minLimit)
            let maxLimit = Int(QuestionCountGroup.maxLimit)
            return min(max(n, minLimit), maxLimit)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Repository.keyQuestionCount)
        }
    }//var questionCount
    public static var examFontSize: Float {
        get {
            let size = UserDefaults.standard.float(forKey: Repository.keyExamFontSize)
            if size == 0 {
                return Repository.initialExamFontSize
            }
            return min(max(size, FontSizeGroup.minLimit), FontSizeGroup.maxLimit)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Repository.keyExamFontSize)
        }
    }//var examFontSize

    public static func getOptionState(optionType: OptionType) -> Bool? {
        return Repository.optionList[optionType]
    }//getOptionState(otionType: OptionType)
    
    public static func getSelectedOption() -> [OptionType] {
        var list: [OptionType] = []
        for opt in Repository.optionList.keys  {
            if Repository.getOptionState(optionType: opt)! {
                list.append(opt)
            }
        }//for opt in Repository.optionList.keys
        if debugLevel > 0 {
            var s = "Active options:"
            var count = 0
            for opt in list {
                if Repository.optionList[opt]! {
                    s += " \(opt.name)"
                    count += 1
                }
            }
            s += ",\t\(count) option(s) selected."
            _ = log(90, s)
        }//if debugLevel > 0
        return list
    }//getSelectedOption()
    
    public static func changeOptionState(optionType: OptionType) throws -> Bool {
        // 値の変更の有無を返す。
        guard let state = getOptionState(optionType: optionType) else {
            throw ExamError.runtime("Repository - changeOptionState() Invalid option type: \(optionType)")
        }
        if state == false {
            Repository.optionList[optionType] = true
            return true
        }
        // 他のオプションが全てfalseのときは、trueを維持する
        for opt in Repository.optionList.keys where opt != optionType {
            if getOptionState(optionType: opt) == true {
                Repository.optionList[optionType] = false
                return true
            }
        }//for opt in Repository.optionList
        return false
    }//changeOptionState(otionType: OptionType)

    
}//class Repository
/** End of File **/
