//
//  TypeCode.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/14.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation

protocol TypeCode {
    associatedtype T
    var code: Int {get}
    var name: String {get}
    
    func toString() -> String
    func equals(_ other: T) -> Bool
}//protocol TypeCode

public class GenericTypeCode: TypeCode {
    typealias T = GenericTypeCode
    
    public var code: Int
    public var name: String
    
    fileprivate init(_ code: Int, _ name: String) {
        self.code = code
        self.name = name
        assert(type(of: self) != GenericTypeCode.self, "Cannot create instance: GenericTypeCode")
    }//init(code: Int, name: String)
    
    func equals(_ other: GenericTypeCode) -> Bool {
        return (self.code == other.code)
    }
    
    public func toString() -> String {
        return "\(code) \(name)"
    }//toString()
    
    fileprivate func find(code: Int, list: [T]) throws -> T {
        for i in 0 ..< list.count {
            if list[i].code == code {
                return list[i]
            }//if
        }//for
        throw ExamError.runtime("Invalid type code: \(code)")
    }//find(code: Int, list: [T])
    
    fileprivate func find(codeString: String, list: [T]) throws -> T {
        if let code = Int(codeString) {
            return try find(code: code, list: list)
        }
        throw ExamError.runtime("Invalid type code: \(codeString)")
    }//find(codeString: String, list: [T])
    
    fileprivate func getCodeByName(name: String, list: [T]) throws -> Int {
        for i in 0..<list.count {
            if list[i].name == name {
                return list[i].code
            }//if
        }//for
        throw ExamError.runtime("Invalid type name: \(name)")
    }//find(codeString: String, list: [T])
    
    //    static public func ==(left: GenericTypeCode, right: GenericTypeCode) -> Bool {
    //        return left.code == right.code
    //    }// ==(left: GenericTypeCode, right: GenericTypeCode)
    //
    //    static public func !=(left: GenericTypeCode, right: GenericTypeCode) -> Bool {
    //        return left.code != right.code
    //    }// !=(left: GenericTypeCode, right: GenericTypeCode)
    
}//class GenericTypeCode


public class ApplicationType: GenericTypeCode  {
    public static let sample
        = ApplicationType(code: 1, name: "Sample", label: "Manifold学習アプリ",
                          pretitle: "サンプル版", title: "Manifold学習アプリ")
    private static let fuuBase = 2
    public static let fuuSample
        = ApplicationType(code: fuuBase + 1, name: "FuuSample", label: "ふぅ",
                          pretitle: "お父さんがつくった", title: "ふぅのためのお勉強アプリ")
    public static let fuuEnglish
        = ApplicationType(code: fuuBase + 2, name: "FuuEnglish", label: "ふぅ",
                          pretitle: "お父さんがつくった", title: "ふぅのためのお勉強アプリ【英語】")


    private static let denkiTsushinShugi = "電気通信主任技術者試験 受験対策"
    private static let shugiBase = 1000
    public static let shugiHouki
        = ApplicationType(code: shugiBase+1, name: "ShugiHouki", label: "法規",
                          pretitle: denkiTsushinShugi, title: "法規")
    public static let shugiDenKou
        = ApplicationType(code: shugiBase+2, name: "ShugiDenKou", label: "伝送交換設備 - 主任技術者",
                          pretitle: denkiTsushinShugi, title: "伝送交換設備")    
    private static let denkiTsushinKoutan = "電気通信の工事担任者試験 受験対策"
    private static let koutanBase = 1500
    public static let koutanHoukiSougou
        = ApplicationType(code: koutanBase+1, name: "KoutanHoukiSougou", label: "法規 - 工担",
                          pretitle: denkiTsushinKoutan, title: "法規")
    public static let koutanKisoSougou
        = ApplicationType(code: koutanBase+2, name: "KoutanKisoSougou", label: "基礎 - 工担",
                          pretitle: denkiTsushinKoutan, title: "基礎")
    public static let koutanGijutsuDigital1
        = ApplicationType(code: koutanBase+3, name: "KoutanGijutsuDd1", label: "技術(デジタル) - 工担",
                          pretitle: denkiTsushinKoutan, title: "技術(第１級デジタル通信)")
    public static let koutanGijutsuAnalog1
        = ApplicationType(code: koutanBase+4, name: "KoutanGijutsuAi1", label: "技術(アナログ) - 工担",
                          pretitle: denkiTsushinKoutan, title: "技術(第１級アナログ通信)")
    public static let koutanGijutsuSougou
        = ApplicationType(code: koutanBase+5, name: "KoutanGijutsuSougou", label: "技術(総合) - 工担",
                          pretitle: denkiTsushinKoutan, title: "技術(総合通信)")

    private static let externalBase = 1000000
    private static let roumuBase = externalBase + 1000000
    public static let roumuSample
        = ApplicationType(code: roumuBase+1, name: "RoumuSample", label: "労務Q&A",
                          pretitle: "御園社労士事務所", title: "やさしく読める労務Q＆A")
    
    public static let sampleTrial
        = sample.createTrialVersion()
    public static let shugiHoukiTrial
        = shugiHouki.createTrialVersion()
    public static let shugiDenKouTrial
        = shugiDenKou.createTrialVersion()
    public static let koutanHoukiSougouTrial
        = koutanHoukiSougou.createTrialVersion()
    public static let koutanGijutsuSougouTrial
        = koutanGijutsuSougou.createTrialVersion()
    public static let koutanKisoSougouTrial
        = koutanKisoSougou.createTrialVersion()
    public static let koutanGijutsuDigital1Trial
        = koutanGijutsuDigital1.createTrialVersion()
    public static let koutanGijutsuAnalog1Trial
        = koutanGijutsuAnalog1.createTrialVersion()
    
    
    private static let types: [ApplicationType] = [
        shugiHouki, shugiHoukiTrial,
        shugiDenKou, shugiDenKouTrial,   
        koutanHoukiSougou, koutanHoukiSougouTrial,
        koutanKisoSougou, koutanKisoSougouTrial,
        koutanGijutsuSougou, koutanGijutsuSougouTrial,
        koutanGijutsuDigital1, koutanGijutsuDigital1Trial,
        koutanGijutsuAnalog1, koutanGijutsuAnalog1Trial,
        roumuSample, fuuSample, fuuEnglish,
        sample, sampleTrial
    ]
    //    private var code: Int
    //    private var name: String
    public var label: String // <manifest ...> ... <application ... android:label = の値
    public var pretitle: String
    public var title: String
    
    private init(code: Int, name: String, label: String, pretitle: String, title: String) {
        //        self.code = code
        //        self.name = name
        self.label = label
        self.pretitle = pretitle
        self.title = title
        super.init(code, name)
    }//init(...)
    
    public static func initialize() {
        _ = ApplicationType(code: 0, name: "", label: "", pretitle: "", title: "")
    }

    public static func check() throws {
      if debugLevel >= 50 {
        let s = checkUniqueArray( array: ApplicationType.types)
        if !(s == "") {
            throw ExamError.runtime(s);
        }
      }//if (debugLevel >= 50)
    }//checkArray()

    
    public static func  find(code: Int) throws -> ApplicationType {
        for i in 0..<types.count {
            if types[i].code == code {
                return types[i]
            }
        }//for i in 0..< types.count {
        throw ExamError.runtime("Invalid spplication type code: \(code)")
    }//find(int code)
    
    private func createTrialVersion() -> ApplicationType {
        return ApplicationType(code: -code, name: name, label: label, pretitle: pretitle, title: title)
    }//createTrialVersion(ApplicationType applicationType)
    
    public override func toString() -> String {
        return "\(code) \(name)"
    }
    
    public func equals(type: ApplicationType) -> Bool{
        return self.code == type.code
    }
    
    public func almostEquals(type: ApplicationType) ->Bool {
        return self.code == type.code || self.code == -type.code
    }
    
    public func isTrial() -> Bool {
        return (code < 0)
    }//isTrial()
    
    public func useOption() -> Bool {
        return self == ApplicationType.koutanHoukiSougou
            ||  self == ApplicationType.koutanHoukiSougouTrial
    }//useOption()
    
    
    public func isShugi() -> Bool {
        return self == ApplicationType.shugiHouki
            || self == ApplicationType.shugiHoukiTrial
            || self == ApplicationType.shugiDenKou
            || self == ApplicationType.shugiDenKouTrial
    }//isKoutan
    
    public func isKoutan() -> Bool {
        return self == ApplicationType.koutanHoukiSougou
            || self == ApplicationType.koutanHoukiSougouTrial
            || self == ApplicationType.koutanKisoSougou
            || self == ApplicationType.koutanKisoSougouTrial
            || self == ApplicationType.koutanGijutsuSougou
            || self == ApplicationType.koutanGijutsuSougouTrial
            || self == ApplicationType.koutanGijutsuDigital1
            || self == ApplicationType.koutanGijutsuDigital1Trial
            || self == ApplicationType.koutanGijutsuAnalog1
            || self == ApplicationType.koutanGijutsuAnalog1Trial
    }//isKoutan

    public func isBlueTheme() -> Bool {
        return self == ApplicationType.roumuSample
            || self == ApplicationType.fuuSample
            || self == ApplicationType.fuuEnglish
    }//isBlueTheme()
    
    static public func ==(left: ApplicationType, right: ApplicationType) -> Bool {
        return left.code == right.code
    }// ==(left: ApplicationType, right: ApplicationType)
    
    static public func !=(left: ApplicationType, right: ApplicationType) -> Bool {
        return left.code != right.code
    }// !=(left: ApplicationType, right: ApplicationType)
}//class ApplicationType

public class OptionType: GenericTypeCode, Hashable {
    typealias T = OptionType
    
    private static let base = 0x40
    public static let na = OptionType(base, "-")
    public static let optionA = OptionType(base + 1, "A")
    public static let optionB = OptionType(base + 2, "B")
    public static let optionC = OptionType(base + 3, "C")
    public static let optionD = OptionType(base + 4, "D")
    public static let optionE = OptionType(base + 5, "E")
    public static let optionF = OptionType(base + 6, "F")
    public static let optionG = OptionType(base + 7, "G")
    public static let optionH = OptionType(base + 8, "H")
    public static let optionI = OptionType(base + 9, "I")
    public static let optionJ = OptionType(base + 10, "J")
    public static let optionK = OptionType(base + 11, "K")
    public static let optionL = OptionType(base + 12, "L")
    public static let optionM = OptionType(base + 13, "M")
    public static let optionN = OptionType(base + 14, "N")
    public static let optionO = OptionType(base + 15, "O")
    public static let optionP = OptionType(base + 16, "P")
    public static let optionQ = OptionType(base + 17, "Q")
    public static let optionR = OptionType(base + 18, "R")
    public static let optionS = OptionType(base + 19, "S")
    public static let optionT = OptionType(base + 20, "T")
    public static let optionU = OptionType(base + 21, "U")
    public static let optionV = OptionType(base + 22, "V")
    public static let optionW = OptionType(base + 23, "W")
    public static let optionX = OptionType(base + 24, "X")
    public static let optionY = OptionType(base + 25, "Y")
    public static let optionZ = OptionType(base + 26, "Z")
    public static let baseInstance = optionA
    
    private static let options: [OptionType] = [
        optionA, optionB, optionC, optionD, optionE,
        optionF, optionG, optionH, optionI, optionJ,
        optionK, optionL, optionM, optionN, optionO,
        optionP, optionQ, optionR, optionS, optionT,
        optionU, optionV, optionW, optionX, optionY, optionZ
    ]
    
    override fileprivate init(_ code: Int, _ name: String) {
        super.init(code, name)
    }//init(code: Int, name: String)
    
    func getTypeList() -> [OptionType] {
        return OptionType.options
    }//getTypeList()
    
    public static func find(code: Int) throws -> OptionType {
        return try baseInstance.find(code: code, list: options) as! OptionType
    }//find(code: Int)
    
    public static func find(codeString: String) throws -> OptionType {
        return try baseInstance.find(codeString: codeString, list: options) as! OptionType
    }//find(codeString: String)
    
    
    static public func ==(left: OptionType, right: OptionType) -> Bool {
        return left.code == right.code
    }// ==(left: OptionType, right: OptionType)
    
    static public func !=(left: OptionType, right: OptionType) -> Bool {
        return left.code != right.code
    }// !=(left: OptionType, right: OptionType)
    
    public func hash(into hasher: inout Hasher) {
        code.hash(into: &hasher)
    }//hash(into hasher: inout Hasher)
}//class OptionType


public class ExamCategory: GenericTypeCode, Hashable  {
    typealias T = ExamCategory
    
    public var description: String
    
    private static let sampleBase = 0
    public static let unknown = ExamCategory(sampleBase , "Unknown", "Unknown")
    public static let sample1 = ExamCategory(sampleBase + 1, "Sample1", "Sample1")
    public static let sample2 = ExamCategory(sampleBase + 2, "Sample2", "Sample2")
    public static let sample3 = ExamCategory(sampleBase + 3, "Sample3", "Sample3")
    // 主技 10 法規 01  分野 1-99
    private static let shoBase = 100100;
    public static let sho01Jigyouhou = ExamCategory(shoBase + 1,  "主法規:電気通信事業法", "電気通信事業法")
    public static let sho02JigyouyouSetsubi = ExamCategory(shoBase + 2,  "主法規:事業用電気通信設備規則", "事業用電気通信設備規則")
    public static let sho03TanmatsuSetsubi = ExamCategory(shoBase + 3,  "主法規:端末設備等規則", "端末設備等規則")
    public static let sho04YuusenTsuushin = ExamCategory(shoBase + 4,  "主法規:有線電気通信法、有線電気通信設備令", "有線電気通信法、有線電気通信設備令")
    public static let sho09Other = ExamCategory(shoBase + 9,  "主法規:その他", "その他")

    // 主技 10 伝送交換設備 02  分野 1-99
    private static let sdkBase = 100200;
    public static let sdk01Setsubi = ExamCategory(sdkBase + 1, "主伝交:設備管理", "設備管理")
    public static let sdk02Shinraisei = ExamCategory(sdkBase + 2, "主伝交:信頼性技術", "信頼性技術")
    public static let sdk05DensouKoukan = ExamCategory(sdkBase + 5, "主伝交:伝送技術、交換技術", "伝送技術、交換技術")
    public static let sdk07Network = ExamCategory(sdkBase + 7, "主伝交:ネットワーク技術", "ネットワーク技術")
    public static let sdk09Security = ExamCategory(sdkBase + 9, "主伝交:情報セキュリティ", "情報セキュリティ")
    public static let sdk11Denryoku = ExamCategory(sdkBase + 11, "主伝交:通信電力", "通信電力")
    
    public static let sdk21Setsubi = ExamCategory(sdkBase + 21, "主伝交:設備管理", "設備管理")
    public static let sdk22Shinraisei_System = ExamCategory(sdkBase + 22, "主伝交:信頼性技術、システム", "信頼性技術、システム")
    public static let sdk24Koukan_Musen = ExamCategory(sdkBase + 24, "主伝交:交換技術、無線技術", "交換技術、無線技術")
    public static let sdk25Densou = ExamCategory(sdkBase + 25, "主伝交:伝送技術", "伝送技術")
    public static let sdk27Network = ExamCategory(sdkBase + 27, "主伝交:ネットワーク技術", "ネットワーク技術")
    public static let sdk29Security = ExamCategory(sdkBase + 29, "主伝交:情報セキュリティ", "情報セキュリティ")
    public static let sdk31Denryoku = ExamCategory(sdkBase + 31, "主伝交:通信電力", "通信電力")
    // 工担 15 法規 01 分野 1-99
    private static let khBase = 150100
    public static let khQ1 = ExamCategory(khBase + 1, "工担法規:電気通信事業法",
                                          "電気通信事業法および施行規則（問1）")
    public static let khQ2 = ExamCategory(khBase + 2, "工担法規:工事担任者、技術基準適合、有線電気通信法",
                                          "工事担任者規則、端末機器の技術基準適合認定等に関する規則、有線電気通信法（問2）")
    public static let khQ3Q4 = ExamCategory(khBase + 7, "工担法規:端末設備等規則", "端末設備等規則（問3～問4）")
    public static let khQ5 = ExamCategory(khBase + 5, "工担法規:有線電気通信設備令、不正アクセス、電子署名",
                                          "有線電気通信設備令および施行規則、不正アクセス禁止法、電子署名法（問5）")
    // 工担 15 基礎 03 分野 1-6
    private static let kkBase = 150200
    public static let kk1Electric = ExamCategory(kkBase + 1, "工担基礎:電気回路", "電気回路")
    public static let kk2Electronic = ExamCategory(kkBase + 2, "工担基礎:電子回路", "電子回路")
    public static let kk3Logic = ExamCategory(kkBase + 3, "工担基礎:論理回路", "論理回路")
    public static let kk4Transmission = ExamCategory(kkBase + 4, "工担基礎:伝送理論", "伝送理論")
    public static let kk5Technology = ExamCategory(kkBase + 5, "工担基礎:伝送技術", "伝送技術")
    // 工担 15 技術 03 分野 1-6
    private static let kgBase = 150300
    public static let kg1Terminal = ExamCategory(kgBase + 1, "工担技術:端末設備の技術", "端末設備の技術")
    public static let kg2Construction = ExamCategory(kgBase + 2, "工担技術:接続工事の技術", "接続工事の技術")
    public static let kg3Network = ExamCategory(kgBase + 3, "工担技術:ネットワークの技術", "ネットワークの技術")
    public static let kg4Security = ExamCategory(kgBase + 4, "工担技術:情報セキュリティの技術", "情報セキュリティの技術")
    public static let kg5Isdn = ExamCategory(kgBase + 5, "工担技術:ISDNの技術", "ISDNの技術")
    public static let kg6Traffic = ExamCategory(kgBase + 6, "工担技術:トラヒック理論", "トラヒック理論")
    
    public static let externalBase = 10000000
    public static let fuuBase = externalBase
    public static let fuuEnglishSample1 = ExamCategory(fuuBase + 1, "英単語の和訳", "日本語にしよう")
    public static let fuuEnglishSample2 = ExamCategory(fuuBase + 2, "英単語への英訳", "英語読にしよう")
    public static let fuuEnglishSample3 = ExamCategory(fuuBase + 3, "ー", "ー")
    public static let roumuBase = externalBase  + 100000
    public static let roumuSample1 = ExamCategory(roumuBase + 1, "労務Q&A:賃金", "賃金の話")
    public static let roumuSample2 = ExamCategory(roumuBase + 2, "労務Q&A:休暇や労働時間", "休暇や労働時間の話")
    public static let roumuSample3 = ExamCategory(roumuBase + 3, "労務Q&A:その他", "その他の話")
    
    
    public static let baseInstance = unknown
    private static let categories: [ExamCategory] = [
        sho01Jigyouhou,   sho02JigyouyouSetsubi,
        sho03TanmatsuSetsubi ,    sho04YuusenTsuushin,
        sho09Other,
//        sdk01Setsubi,        sdk02Shinraisei,
//        sdk05DensouKoukan,   sdk07Network,
//        sdk09Security,        sdk11Denryoku,
        sdk21Setsubi, sdk22Shinraisei_System ,
        sdk24Koukan_Musen, sdk25Densou,   sdk27Network,
        sdk29Security,        sdk31Denryoku,
        khQ1, khQ2, khQ3Q4, khQ5,
        kk1Electric, kk2Electronic,
        kk3Logic, kk4Transmission, kk5Technology,
        kg1Terminal, kg2Construction, kg3Network,
        kg4Security, kg5Isdn, kg6Traffic,
        fuuEnglishSample1, fuuEnglishSample2, fuuEnglishSample3,
        roumuSample1, roumuSample2, roumuSample3,
        unknown, sample1, sample2, sample3,
        ]
    
    fileprivate init(_ code: Int, _ name: String, _ description: String) {
        self.description = description
        super.init(code, name)
    }//init(_ code: Int, _ name: String, _ description: String)
    
    
    public static func initialize() {
        _ = ExamCategory(0, "", "")
    }

    public static func check() throws {
      if debugLevel >= 50 {
        let s = checkUniqueArray( array: ExamCategory.categories)
        if !(s == "") {
            throw ExamError.runtime(s);
        }
      }//if (debugLevel >= 50)
    }//checkArray()


    public static func find(code: Int) throws -> ExamCategory {
        return try baseInstance.find(code: code, list: categories) as! ExamCategory
    }//find(code: Int)
    
    public static func find(codeString: String) throws -> ExamCategory {
        return try baseInstance.find(codeString: codeString, list: categories) as! ExamCategory
    }//find(codeString: String)
    
    public override func toString() -> String {
//        return "\(code) \(name)"
        return String(format:"%d %@",code, name)
    }
    
    public static func getCodeByName(name: String) throws -> Int {
        return try baseInstance.getCodeByName(name: name, list: categories)
    }//find(code: Int)
    
    static public func ==(left: ExamCategory, right: ExamCategory) -> Bool {
        return left.code == right.code
    }// ==(left: ExamCategory, right: ExamCategory)
    
    static public func !=(left: ExamCategory, right: ExamCategory) -> Bool {
        return left.code != right.code
    }// !=(left: ExamCategory, right: ExamCategory)
    
    public func hash(into hasher: inout Hasher) {
        code.hash(into: &hasher)
    }//hash(into hasher: inout Hasher)
}//class ExamCategory

public class QaType: GenericTypeCode {
    typealias T = QaType
    
    public static let na = QaType(1, "NA")
    public static let correctness = QaType(3, "Correctness")
    public static let filling = QaType(4, "Filling")
    public static let branch = QaType(5, "Branch")
    public static let blank = QaType(6, "Blank")
    public static let baseInstance = na
    private static let qaTypes: [QaType] = [
        na, correctness, filling, branch, blank
    ]
    
    override fileprivate init(_ code: Int, _ name: String) {
        super.init(code, name)
    }//init(code: Int, name: String)
    
    public static func find(code: Int) throws -> QaType {
        return try baseInstance.find(code: code, list: qaTypes) as! QaType
    }//find(code: Int)
    
    public static func find(codeString: String) throws -> QaType {
        return try baseInstance.find(codeString: codeString, list: qaTypes) as! QaType
    }//find(codeString: String)
    
    static public func ==(left: QaType, right: QaType) -> Bool {
        return left.code == right.code
    }// ==(left: QaType, right: QaType)
    
    static public func !=(left: QaType, right: QaType) -> Bool {
        return left.code != right.code
    }// !=(left: QaType, right: QaType)
}//class QaType


public class TokenType: GenericTypeCode {
    typealias T = TokenType
    
    public static let  unknown = TokenType(0, "Unknown")
    public static let  plain = TokenType(1, "Plain")
    public static let  tag = TokenType(2, "Tag")
    public static let  correctnessQa = TokenType(3, "Correctness")
    public static let  fillingQa = TokenType(4, "Filling")
    public static let  branchQa = TokenType(5, "Branch")
    public static let  blankQa = TokenType(6, "Blank")
    public static let baseInstance = unknown
    private static let qaTypes: [TokenType] = [
        plain, tag, correctnessQa, fillingQa, branchQa, blankQa, unknown
    ]
    
    override fileprivate init(_ code: Int, _ name: String) {
        super.init(code, name)
    }//init(code: Int, name: String)
    
    public static func find(code: Int) throws -> TokenType {
        return try baseInstance.find(code: code, list: qaTypes) as! TokenType
    }//find(code: Int)
    
    public static func find(codeString: String) throws -> TokenType {
        return try baseInstance.find(codeString: codeString, list: qaTypes) as! TokenType
    }//find(codeString: String)
    
    static public func ==(left: TokenType, right: TokenType) -> Bool {
        return left.code == right.code
    }// ==(left: TokenType, right: TokenType)
    
    static public func !=(left: TokenType, right: TokenType) -> Bool {
        return left.code != right.code
    }// !=(left: TokenType, right: TokenType)
}//class TokenType

public class SettingItem: GenericTypeCode {
    typealias T = SettingItem
    
    public static let unknown = SettingItem(0, "Unknown")
    public static let colorScheme = SettingItem(1, "ColorScheme")
    public static let questionCount = SettingItem(2, "QuestionCount")
    public static let version = SettingItem(3, "Version")
    public static let optionType = SettingItem(5, "OptionType")
    public static let swipeDirection = SettingItem(11, "Swipe Direction")
    public static let swipeMetric = SettingItem(12, "Swipe Metric")
    public static let swipeVelocity = SettingItem(13, "Swipe Velocity")
    public static let delayTime = SettingItem(14, "Delay Time")
    public static let dbTimeStamp = SettingItem(20, "DB TimeStamp")
    public static let baseInstance =  unknown
    private static let types: [SettingItem]  = [
        colorScheme, questionCount, version, optionType,
        swipeDirection, swipeMetric, swipeVelocity,
        delayTime,dbTimeStamp,
        unknown]
    
    override fileprivate init(_ code: Int, _ name: String) {
        super.init(code, name)
    }//init(code: Int, name: String)
    
    public static func find(code: Int) throws -> TokenType {
        return try baseInstance.find(code: code, list: types) as! TokenType
    }//find(code: Int)
    
    public static func find(codeString: String) throws -> TokenType {
        return try baseInstance.find(codeString: codeString, list: types) as! TokenType
    }//find(codeString: String)
    
    static public func ==(left: SettingItem, right: SettingItem) -> Bool {
        return left.code == right.code
    }// ==(left: SettingItem, right: SettingItem)
    
    static public func !=(left: SettingItem, right: SettingItem) -> Bool {
        return left.code != right.code
    }// !=(left: SettingItem, right: SettingItem)

}//class SettingItem

/** End of File **/

