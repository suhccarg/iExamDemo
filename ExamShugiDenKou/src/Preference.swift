//
//  Preference.swift
//  ExamShugiDenKou
//
//  Created by suhccarg on 2023/07/20.
//

import Foundation
#if canImport(ExamLib_iOS1)
import ExamLib_iOS1
#endif

let defaultMargin: CGFloat = 8.0
 let initialQuestionCount: Int = 5
 let initialExamFontSize: Float = 16.0     // 16px = 12pt
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
    public static var menu :MenuViewController!
    public static let examCategories: [ExamCategory] = [
        ExamCategory.sdk21Setsubi,
        ExamCategory.sdk22Shinraisei_System,
        ExamCategory.sdk24Koukan_Musen,
        ExamCategory.sdk25Densou,
        ExamCategory.sdk27Network,
        ExamCategory.sdk29Security,
        ExamCategory.sdk31Denryoku ]
    public static let initialCategoryCode = ExamCategory.sdk21Setsubi

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
    // sliderは、px単位。labelの表示は、pt単位。
    // 16px == 12pt == 1em
    public static let px2pt: Float = 12.0 / 16.0
    public static let fontSizeMinLimit: Float = 5.0 / px2pt         // 5pt
    public static let fontSizeMaxLimit: Float = 50.0 / px2pt        // 50pt
    
    public static var examFontSize: Float {
        get {
            let size = UserDefaults.standard.float(forKey: Repository.keyExamFontSize)
            if size == 0 {
                return initialExamFontSize
            }
            return min(max(size, fontSizeMinLimit), fontSizeMaxLimit)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Repository.keyExamFontSize)
        }
    }//var examFontSize

}
