//
//  Util.swift
//  exam
//
//  Created by Yoshino Kouichi on 2020/07/21.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
import UIKit
 
public var currentViewController: UIViewController!
// webview 内のテキスト選択禁止
let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
// webview 内の⻑押しによるメニュー表示禁止
let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"

///// エラー処理 /////
private var internalError: String?

public func onError(_ message:String) {
    internalError = message
}//onError(_ message:String)

public func clearError() {
    internalError = nil
}//clearError()

public func isError() -> Bool {
    return internalError != nil
}//isError()
      
public func getError() -> String {
    return internalError ?? ""
}//isError()

///// ExamError /////
enum ExamError: Error {
    case isNil(_: String)
    case runtime(_: String)
    case assert(_: String)
    case parse(_: String)
    case sql(_: String)
    case crypt(_: String)
}//enum ExamError

///// log /////
public func log(_ level: Int, _ message: String) -> String{
    if level <= debugLevel {
        print("  \(getCurrentDateTime()) \(message)")
    }
    return message
}//log(_ level: Int, _ message: String)

public func getCurrentDateTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMddHHmmss", options: 0, locale: Locale(identifier: "ja_JP"))
    return dateFormatter.string(from: Date())
}//getCurrentDateTime()

public func logPrecisely(_ level: Int, _ message: String) -> String{
    if level <= debugLevel {
        print("  \(getCurrentDateTimePrecisely()) \(message)")
    }
    return message
}//logPrecisely(_ level: Int, _ message: String)

public func getCurrentDateTimePrecisely() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMddHHmmssSSS", options: 0, locale: Locale(identifier: "ja_JP"))
    return dateFormatter.string(from: Date())
}//getCurrentDateTimePrecisely()

public func getBuildTimeStamp() -> String {
    let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
    var dateTime = Date()
    if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
        let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
        let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date {
        dateTime = infoDate
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYYMMddHHmmss", options: 0, locale: Locale(identifier: "ja_JP"))
    return dateFormatter.string(from: dateTime)
}//getBuildTimeStamp()

public func getDbTimeStamp() throws -> String {
//    let manager = FileManager()
//    let attributes = try manager.attributesOfItem(atPath: ExamSourceDao.dbFile)
//    let dateTime = attributes[.modificationDate]!
//
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYYMMddHHmmss", options: 0, locale: Locale(identifier: "ja_JP"))
//    return dateFormatter.string(from: dateTime as! Date)
    let dto = try SettingDao().getByItem(settingItem: SettingItem.dbTimeStamp)
    return dto!.value
}//getDbTimeStamp()

///// 自己診断メッセージ /////
public func getSelfCheck() -> String {
    var s = ""
    s += String(format: "%@\n", Repository.applicationType.name )
    s += String(format: "%@\n", Bundle.main.bundleIdentifier! )
    s += String(format: "DebugLevel: %d\n", debugLevel )
    do {
        s += try getTimeStamp()
        s += try listCountByCategory()
        s += try listProperties()
    //    s += listLackImageFile()
    } catch let e {
        s += "\n\n●内部エラー: \(e)"
    }
    return s
}//getSelfCheck()

private func getTimeStamp() throws -> String {
    var   s = "●ビルド日時\n"
    s += "App:\(getBuildTimeStamp())\n"
    if let dto = try SettingDao().getByItem(settingItem: SettingItem.dbTimeStamp) {
        s += String(format: "DB :%@ %@\n", dto.value, Repository.getDbFileName())
    }
    return s
}

private func listCountByCategory() throws -> String {
    let dao: ExamSourceDao = try ExamSourceDao()
    
    let list = try dao.getCountByCategory()
    let keys = [ExamCategory](list.keys).sorted(
        by: { lCategory, rCategory -> Bool in
            return lCategory.code < rCategory.code})
    var s = "●分野別問題数\n"
    for category in keys {
//        s += String(format: " %-20s %3d\n", category.name, list[category]!)
        s += String(format: " %4d %@\n", list[category]!, category.name)
    }
    return s
}//listCountByCategory()

public func listProperties() throws -> String {
    var s = "●設定値\n"
    s += " 選択分野: \(try ExamCategory.find(code: Repository.categoryCode).toString())\n"
    s += " 暗色モード: \(Repository.darkMode)\n"
    for opt in Repository.optionList {
        s += " Option \(opt.key.name): \(opt.value)\n"
    }
    s += " 出題数: \(Repository.questionCount)\n"
    s += " フォントサイズ: \(Repository.examFontSize.d1)\n"
    return s
}
///// ファイル操作 /////
public func checkFileExists(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
}//checkFileExists(path: String)

public func removeFileIfExists(path: String) throws {
    if checkFileExists(path: path) {
        try FileManager.default.removeItem(atPath: path)
    }
}//removeFileIfExists(path: String)

public func copyFile(from source: String, to destination: String) throws {
    try FileManager.default.copyItem(atPath: source, toPath: destination)
}//copyFile(from source: String, to destination: String)

public func getFolder(path: String) -> String {
    let tokens = path.components(separatedBy: "/")
    if tokens.count <= 1 {
        return ""
    }
    var folder = ""
    for i in 0 ..< tokens.count - 1 {
        folder += tokens[i] + "/"
    }//for i in ...
    return folder
}//getFolder(path: String)

///// 汎用 /////
public func getOrientation() -> UIDeviceOrientation {
    return UIDevice.current.orientation
}//getOrientation()

public func dumpToHex(uint8Array: [UInt8]) -> String {
    var s = "\n"
    for i in 0 ..< uint8Array.count  {
        s += String(format: "%02x ", uint8Array[i])
        if i % 16 == 7 {
            s += " "
        } else if i % 16 == 15 {
            s += "\n"
        }
    }
    return s
}
public func dumpToHex(string str: String) -> String {
    let a: [UInt8] = Array(str.utf8)
    return dumpToHex(uint8Array: a)
}
public func alert(message:String) {
    //alert(title: "異常終了",  message: message)
}//alert(message:String)

public func alert (title:String, message:String){
    let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertController.Style.alert)
    
    let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
        (action: UIAlertAction!) -> Void in
        print("OK")
    })
    alert.addAction(defaultAction)
    currentViewController.present(alert, animated: false, completion: nil)
}
public func alert1(title:String, message:String) {
    var alertController: UIAlertController!
    alertController = UIAlertController(title: title,
        message: message,preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK",
        style: .default, handler: nil))
    currentViewController.present(alertController, animated: false)
}//alert(title:String, message:String)

public func randomInt(upperLimit: Int) -> Int {
    if upperLimit == 0 {
        return 0
    } else {
        return Int.random(in: 0 ..< upperLimit)
    }
}//random(max: Int)

public func checkUniqueArray(array: [GenericTypeCode]) -> String {
    var error = "";
    for i in 0..<array.count {
        for j in i+1..<array.count {
            if i != j && array[i].equals(array[j]) {
                if error == "" {
                    error += String(format:" Conflict: %d:%@ == %d:%@",
                        i, array[i].toString(), j, array[j].toString());
                } else {
                    error += String(format:", %d:%@ == %d:%@",
                        i, array[i].toString(), j, array[j].toString());
                }
            } //if i != j && array[i].equals(array[j])
        } // for j in i+1..<array.count
    } // for i in 0..<array.count
    return error;
}//checkUniqueArray(array: [GenericTypeCode])

public func getBundlePath(baseName: String?, typeName: String) -> String {
    return Bundle.main.path(forResource: baseName, ofType: typeName) ?? "##Unknown##"
}//getBundlePath(baseName: String?, typeName: String?)

public func getBundlePath() -> String {
    return getBundlePath(baseName: nil, typeName: "db")
}//getBundlePath()

public func getBundlePath(fileName: String?) -> String {
    if fileName == nil {
        return "##nil##"
    }
    let parts =  splitToBaseAndExtensoin(fileName: fileName!)
    return getBundlePath(baseName: parts.base, typeName: parts.ext)
}//getBundlePath(fileName: String?)

private let roundNumberBase = 9311
public func getRoundNumber(_ n: Int) throws -> String {
    if n <= 0 || 20 < n {
        throw ExamError.runtime("Round number - out of range: \(n)")
    }
    return String(format: "&#%04d;", roundNumberBase + n)
}//getRoundNumber(_ n: Int)

public func splitToBaseAndExtensoin(fileName: String) -> (base: String, ext: String) {
    let tokens = fileName.components(separatedBy: ".")
    if tokens.count <= 1 {
        return (fileName, "")
    }
    var basename = ""
    for i in 0 ..< tokens.count - 2 {
        basename += tokens[i] + "."
    }//for i in ...
    basename += tokens[tokens.count - 2]
    return (basename, tokens[tokens.count - 1])
}//getBaseNameAndExtenstion(fileName: String)

public class Assert {
    
    public static func isNotNil(object: Any?) {
        isNotNil(object: object, "")
    }//isNotNull(Object object)
    
    public static func isNotNil(object: Any?, _ message: String) {
        isTrue(object != nil, message)
    }//isNotNull(Object object, String message)
    
    public static func isTrue(_ expression : Bool) {
        isTrue(expression, "")
    }//isTrue(expression : Bool)
    
    
    public static func isTrue(_ expression : Bool, _ message: String)  {
        if !expression {
            fatalError(log(0, "###ExamAssert: \(message)"))
            //            throw ExamError.assert(message: message)
        }//if !expression
    }//isTrue(expression : Bool, message: String)
}//class Assert

///////////////
extension Float {
    public var d1: String {
        return String(format: "%.1f", self)
    }//var d1
}//extension Float

extension CGFloat {
    public var d1: String {
        return Float(self).d1
    }//var d1
}//extension CGFloat

extension CGRect {
    public var values: String {
       return "\(self.width.d1) x \(self.height.d1) at (\(self.minX.d1), \(self.minY.d1))"
    }//var values
}//extension CGFloat

public class DeviceOrientation {
    public static var isPortrait: Bool = true
//    private static var standardWidth: CGFloat!
//    private static var currentWidth: CGFloat!
//    private static var tmpWidth: CGFloat!  // 仮のstandardWidth
//    public static var fontRate: Float {
//        if standardWidth != nil {
//            return Float(self.standardWidth / self.currentWidth)
//        } else {
//            return Float(self.tmpWidth / self.currentWidth)
//        }
//    }
    private init() {}
    
    public static func update(baseView: CustomViewController, webView: UIView) {
//        self.currentWidth = webView.frame.width
        let frame = baseView.view.frame
//        let safe = getSafeArea(baseView: baseView)
        if frame.width < frame.height {
            // portrait
            DeviceOrientation.isPortrait = true
//            if self.standardWidth == nil {
//                self.standardWidth = ExamFullWebView.getWidth(baseView: baseView)
//            }
        } else {
            // landscape
            DeviceOrientation.isPortrait = false
//            if self.standardWidth == nil {
//                self.tmpWidth = frame.height - safe.top - safe.bottom - defaultMargin * 2.0
//            }
        }
    }//
    
}//class DeviceOrientation

extension  UISwipeGestureRecognizer.Direction {
    public var value: String {
        if self == .left {
            return "to Left"
        } else if self == .right {
            return "to Right"
        } else if self == .up {
            return "Up"
        } else if self == .down {
            return "Down"
        } else {
            return "?"
        }
    }
}//extension  UISwipeGestureRecognizer.Direction
/** End of File **/
