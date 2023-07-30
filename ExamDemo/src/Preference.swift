//
//  Preference.swift
//  ExamShugiDenKou
//
//  Created by suhccarg on 2023/07/20.
//00

import Foundation
#if canImport(ExamLib)
import ExamLib
#endif

let defaultMargin: CGFloat = 8.0
 let initialQuestionCount: Int = 5
//## var menu: MenuViewController!
 let hiddenCounterLimit =  3
 let defaultFontSize: CGFloat = 16.0

///// ExamAppError /////
enum ExamAppError: Error {
    case isNil(_: String)
    case runtime(_: String)
    case assert(_: String)
    case parse(_: String)
    case sql(_: String)
    case crypt(_: String)
}//enum ExamAppError

public class Preference {
    ///////////////////////////////////////////////////////////////////////////
    //    public static let applicationType = ApplicationType.shugiHouki
    //    private static let baseName = "Exam"
    //    public static let defaultOptionType: OptionType = .optionS
    // ///////////////
    //    public static let applicationType = ApplicationType.roumuSample
    //    //        public static let applicationType = ApplicationType.sample
    //    private static let baseName = "Exam"
    //    public static let defaultOptionType: OptionType = .optionT
    //    //    public static let defaultOptionType: OptionType = .optionD

///////////////////
    //    public static let applicationType = ApplicationType.koutanGijutsuDigital1
    //        private static let baseName = "Exam"
    //        public static let defaultOptionType: OptionType = .optionD
    //        public static let examCategories: //////////////
    public static var debugLevel: Int {
        get {
            return Repository.debugLevel
        }
        set {
            Repository.debugLevel = newValue
        }
    }
    public static var applicationType: ApplicationType {
        get {
            return Repository.applicationType
        }
        set {
            Repository.applicationType = newValue
        }
    }
    public static var defaultOptionType: OptionType {
        get {
            return Repository.defaultOptionType
        }
        set {
            Repository.defaultOptionType = newValue
            //            Preference.defaultOptionType              = Repository.defaultOptionType
        }
    }
    public static  let baseName = "Exam"
     ///////////////
    //    public static let examCategories: [ExamCategory] = [
    //        ExamCategory.sho01Jigyouhou ,
    //        ExamCategory.sho02JigyouyouSetsubi ,
    //        ExamCategory.sho03TanmatsuSetsubi ,
    //        ExamCategory.sho04YuusenTsuushin ,
    //        ExamCategory.sho09Other
    //    ]
    //    public static let initialCategoryCode = ExamCategory.sho01Jigyouhou
    // //////////////////
    //    public static let examCategories: [ExamCategory] = [
    //        ExamCategory.roumuSample1, ExamCategory.roumuSample2, ExamCategory.roumuSample3 ]
    //    public static let initialCategoryCode = ExamCategory.roumuSample1
    ////////////////////
    //        public static let examCategories: [ExamCategory] = [
    //            ExamCategory.kg1Terminal,
    //            ExamCategory.kg2Construction,
    //            ExamCategory.kg3Network,
    //            ExamCategory.kg4Security]
    //        public static let initialCategoryCode = ExamCategory.kg1Terminal
    ////////////////////
    public static let exemFontSize = Repository.examFontSize
    public static var menu :MenuViewController!
//    public static let examCategories: [ExamCategory] = [
//        ExamCategory.sdk21Setsubi,
//        ExamCategory.sdk22Shinraisei_System,
//        ExamCategory.sdk24Koukan_Musen,
//        ExamCategory.sdk25Densou,
//        ExamCategory.sdk27Network,
//        ExamCategory.sdk29Security,
//        ExamCategory.sdk31Denryoku ]
    public static let examCategories: [ExamCategory] = [
        ExamCategory.demo1,
        ExamCategory.demo2,
        ExamCategory.demo3 ]
    public static var categoryCode: Int {
        get {
            let code = UserDefaults.standard.integer(forKey: Repository.keyExamCategory)
            for category in Preference.examCategories {
                if category.code == code {
                    return code
                }
            }
            return Preference.initialCategoryCode.code
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Repository.keyExamCategory)
        }
    }//var examCategory
    
    public static let questionCountMinLimit: Int = 3
    public static let questionCountMaxLimit: Int = 10
    public static var questionCount: Int {
        get {
            let n = UserDefaults.standard.integer(forKey: Repository.keyQuestionCount)
            if n == 0 {
                return initialQuestionCount       // default
            }
            
            return min(max(n, questionCountMinLimit), questionCountMaxLimit)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Repository.keyQuestionCount)
        }
    }//var questionCount
    //##
    //
//    // sliderは、px単位。labelの表示は、pt単位。
//    // 16px == 12pt == 1em
//    public static let px2pt: Float = 12.0 / 16.0
//    public static let fontSizeMinLimit: Float = 5.0 / px2pt         // 5pt
//    public static let fontSizeMaxLimit: Float = 50.0 / px2pt        // 50pt
//    
//    public static var examFontSize: Float {
//        get {
//            let size = UserDefaults.standard.float(forKey: Repository.keyExamFontSize)
//            if size == 0 {
//                return initialExamFontSize
//            }
//            return min(max(size, fontSizeMinLimit), fontSizeMaxLimit)
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: Repository.keyExamFontSize)
//        }
//    }//var examFontSize
    private static var isPrepared = false
    
    public init() {
        if (!Preference.isPrepared) {
            Self.debugLevel = 60
            Self.applicationType = .demo
            Self.defaultOptionType = .optionA
        }
        Preference.isPrepared = true
    }
}
