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
    private static let demoBase = 10
     public static  let demo1 = ExamCategory(demoBase + 1, "Sample1", "正誤問題")
     public static  let demo2 = ExamCategory(demoBase + 2, "Sample2", "語句選択問題")
     public static  let demo3 = ExamCategory(demoBase + 3, "Sample3", "語句穴埋問題")
    public static let examCategories: [ExamCategory] = [
        demo1,
        demo2,
        demo3 ]
    public static let initialCategoryCode = demo1
    
 //    // 主技 10 法規 01  分野 1-99
 //    private static let shoBase = 100100;
 //    public static  let sho01Jigyouhou = ExamCategory(shoBase + 1,  "主法規:電気通信事業法", "電気通信事業法")
 //    public static  let sho02JigyouyouSetsubi = ExamCategory(shoBase + 2,  "主法規:事業用電気通信設備規則", "事業用電気通信設備規則")
 //    public static  let sho03TanmatsuSetsubi = ExamCategory(shoBase + 3,  "主法規:端末設備等規則", "端末設備等規則")
 //    public static  let sho04YuusenTsuushin = ExamCategory(shoBase + 4,  "主法規:有線電気通信法、有線電気通信設備令", "有線電気通信法、有線電気通信設備令")
 //    public static  let sho09Other = ExamCategory(shoBase + 9,  "主法規:その他", "その他")
 //
 //    // 主技 10 伝送交換設備 02  分野 1-99
 //    private static let sdkBase = 100200;
 //    public static  let sdk01Setsubi = ExamCategory(sdkBase + 1, "主伝交:設備管理", "設備管理")
 //    public static  let sdk02Shinraisei = ExamCategory(sdkBase + 2, "主伝交:信頼性技術", "信頼性技術")
 //    public static  let sdk05DensouKoukan = ExamCategory(sdkBase + 5, "主伝交:伝送技術、交換技術", "伝送技術、交換技術")
 //    public static  let sdk07Network = ExamCategory(sdkBase + 7, "主伝交:ネットワーク技術", "ネットワーク技術")
 //    public static  let sdk09Security = ExamCategory(sdkBase + 9, "主伝交:情報セキュリティ", "情報セキュリティ")
 //    public static  let sdk11Denryoku = ExamCategory(sdkBase + 11, "主伝交:通信電力", "通信電力")
 //
 //    public static  let sdk21Setsubi = ExamCategory(sdkBase + 21, "主伝交:設備管理", "設備管理")
 //    public static  let sdk22Shinraisei_System = ExamCategory(sdkBase + 22, "主伝交:信頼性技術、システム", "信頼性技術、システム")
 //    public static  let sdk24Koukan_Musen = ExamCategory(sdkBase + 24, "主伝交:交換技術、無線技術", "交換技術、無線技術")
 //    public static  let sdk25Densou = ExamCategory(sdkBase + 25, "主伝交:伝送技術", "伝送技術")
 //    public static  let sdk27Network = ExamCategory(sdkBase + 27, "主伝交:ネットワーク技術", "ネットワーク技術")
 //    public static  let sdk29Security = ExamCategory(sdkBase + 29, "主伝交:情報セキュリティ", "情報セキュリティ")
 //    public static  let sdk31Denryoku = ExamCategory(sdkBase + 31, "主伝交:通信電力", "通信電力")
 //    // 工担 15 法規 01 分野 1-99
 //    private static let khBase = 150100
 //    public static  let khQ1 = ExamCategory(khBase + 1, "工担法規:電気通信事業法",
 //                                          "電気通信事業法および施行規則（問1）")
 //    public static  let khQ2 = ExamCategory(khBase + 2, "工担法規:工事担任者、技術基準適合、有線電気通信法",
 //                                          "工事担任者規則、端末機器の技術基準適合認定等に関する規則、有線電気通信法（問2）")
 //    public static  let khQ3Q4 = ExamCategory(khBase + 7, "工担法規:端末設備等規則", "端末設備等規則（問3～問4）")
 //    public static  let khQ5 = ExamCategory(khBase + 5, "工担法規:有線電気通信設備令、不正アクセス、電子署名",
 //                                          "有線電気通信設備令および施行規則、不正アクセス禁止法、電子署名法（問5）")
 //    // 工担 15 基礎 03 分野 1-6
 //    private static let kkBase = 150200
 //    public static  let kk1Electric = ExamCategory(kkBase + 1, "工担基礎:電気回路", "電気回路")
 //    public static  let kk2Electronic = ExamCategory(kkBase + 2, "工担基礎:電子回路", "電子回路")
 //    public static  let kk3Logic = ExamCategory(kkBase + 3, "工担基礎:論理回路", "論理回路")
 //    public static  let kk4Transmission = ExamCategory(kkBase + 4, "工担基礎:伝送理論", "伝送理論")
 //    public static  let kk5Technology = ExamCategory(kkBase + 5, "工担基礎:伝送技術", "伝送技術")
 //    // 工担 15 技術 03 分野 1-6
 //    private static let kgBase = 150300
 //    public static  let kg1Terminal = ExamCategory(kgBase + 1, "工担技術:端末設備の技術", "端末設備の技術")
 //    public static  let kg2Construction = ExamCategory(kgBase + 2, "工担技術:接続工事の技術", "接続工事の技術")
 //    public static  let kg3Network = ExamCategory(kgBase + 3, "工担技術:ネットワークの技術", "ネットワークの技術")
 //    public static  let kg4Security = ExamCategory(kgBase + 4, "工担技術:情報セキュリティの技術", "情報セキュリティの技術")
 //    public static  let kg5Isdn = ExamCategory(kgBase + 5, "工担技術:ISDNの技術", "ISDNの技術")
 //    public static  let kg6Traffic = ExamCategory(kgBase + 6, "工担技術:トラヒック理論", "トラヒック理論")
 //
 //    public static  let externalBase = 10000000
 //    public static  let fuuBase = externalBase
 //    public static  let fuuEnglishSample1 = ExamCategory(fuuBase + 1, "英単語の和訳", "日本語にしよう")
 //    public static  let fuuEnglishSample2 = ExamCategory(fuuBase + 2, "英単語への英訳", "英語読にしよう")
 //    public static  let fuuEnglishSample3 = ExamCategory(fuuBase + 3, "ー", "ー")
 //    public static  let roumuBase = externalBase  + 100000
 //    public static  let roumuSample1 = ExamCategory(roumuBase + 1, "労務Q&A:賃金", "賃金の話")
 //    public static  let roumuSample2 = ExamCategory(roumuBase + 2, "労務Q&A:休暇や労働時間", "休暇や労働時間の話")
 //    public static  let roumuSample3 = ExamCategory(roumuBase + 3, "労務Q&A:その他", "その他の話")
 //
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
            ExamCategory.categories = Preference.examCategories
        }
        Preference.isPrepared = true
    }
}
