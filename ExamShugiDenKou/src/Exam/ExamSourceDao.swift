//
//  ExamSourceDao.swift
//  Aes01
//
//  Created by Yoshino Kouichi on 2020/07/05.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation
import SQLite3
import ExamLib_iOS1

fileprivate let tableName = "exam"
fileprivate let columnImage = "_image"
fileprivate let columnText = "_text"
fileprivate let columnIv = "_iv"

fileprivate let columnId = "_id"
fileprivate let columnCategory = "_category"
fileprivate let columnCode = "_code"
fileprivate let columnStatus = "_status"
fileprivate let columnOption = "_option"
fileprivate let columnWeight = "_weight"
fileprivate let columnExamIv = "_exam_iv"
fileprivate let columnExam = "_exam"
fileprivate let columnSourceIv = "_source_iv"
fileprivate let columnSource = "_source"
fileprivate let columnCommentIv = "_comment_iv"
fileprivate let columnComment = "_comment"
fileprivate let columnQuestionImage = "_questionImage"
fileprivate let columnAnswerImage = "_answerImage"
fileprivate let columnCommentImage = "_commentImage"
fileprivate let optionConditon  = "## optionConditon ##"

fileprivate let columnList = ""
    + columnCategory + ", "
    + columnCode + ", "
    + columnStatus + ", "
    + columnOption + ", "
    + columnWeight + ", "
    + columnExamIv + ", "
    + columnExam + ", "
    + columnSourceIv + ", "
    + columnSource + ", "
    + columnCommentIv + ", "
    + columnComment + ", "
    + columnQuestionImage + ", "
    + columnAnswerImage + ", "
    + columnCommentImage

public let sqlGetTables = "SELECT name FROM sqlite_master WHERE type='table' "

fileprivate let sqlGetAll = "SELECT "
    + columnId + ", " + columnList
    + "\n FROM " + tableName
    + "\n ORDER BY " + columnCode

fileprivate let sqlGetByCategory = "SELECT "
    + columnId + ", " + columnList
    + "\n FROM " + tableName
    + "\n WHERE " + columnCategory + " = ?"
    + "\n ORDER BY " + columnCode

fileprivate let sqlGetById = "SELECT "
    + columnId + ", " + columnList
    + "\n FROM " + tableName
    + "\n WHERE " + columnId + " = ?"
    + "\n ORDER BY " + columnCode

fileprivate let sqlGetIdList = "SELECT "
    + columnId    + "\n FROM " + tableName
    + "\n WHERE " + columnCategory + " = ?"
    + " AND " + columnOption + " LIKE ? "
    + "\n ORDER BY " + columnCode

fileprivate let sqlGetIdList1of2 = "SELECT "
    + columnId    + "\n FROM " + tableName
    + "\n WHERE " + columnCategory + " = ?"
    + " AND " + columnOption + " LIKE \'%"

fileprivate let sqlGetIdList2of2 = "%\'"
    + "\n ORDER BY " + columnCode

fileprivate let sqlGetIdListByCategoryAndOption = "SELECT "
    + columnId    + "\n FROM " + tableName
    + "\n WHERE " + columnCategory + " = ?"
    + " AND " + optionConditon
    + "\n ORDER BY " + columnCode

fileprivate let sqlGetCountByCategory = ""
    + "SELECT " + columnCategory + ", COUNT(*) FROM " + tableName
    + "  GROUP BY " + columnCategory
    + " ORDER BY " + columnCategory + ";"

fileprivate let sqlGetImageNames = ""
    + "SELECT DISTINCT "
    + columnQuestionImage + " AS " + columnImage
    + "\n   FROM " + tableName
    + "\n   WHERE " + columnImage + " != '' "
    + "\nUNION"
    + "\nSELECT DISTINCT " + columnAnswerImage + " AS " + columnImage
    + "\n   FROM " + tableName
    + "\n   WHERE " + columnImage + " != '' "
    + "\nUNION"
    + "\nSELECT DISTINCT " + columnCommentImage + " AS " + columnImage
    + "\n   FROM " + tableName
    + "\n   WHERE " + columnImage + " != '' "
    + "\n ORDER BY " + columnImage + ""

fileprivate let sqlGetImgText = ""
    + "SELECT  "
    + "\n    " + columnExam + " AS " + columnText
    + ",\n    " + columnExamIv + " AS " + columnIv
    + "\n   FROM " + tableName
    + "\nUNION"
    + "\nSELECT "
    + "\n    " + columnCode + " AS " + columnText
    + ",\n    " + columnCommentIv + " AS " + columnIv
    + "\n   FROM " + tableName
    + "\n ORDER BY " + columnText + ""

fileprivate let pragmaJournalOff = "pragma journal_mode = OFF;"
fileprivate let pragmaGetJournal = "pragma journal_mode;"
//fileprivate let sqlCountByCategory = ""
//    + "SELECT " + columnCategory + ", COUNT(*) FROM " + tableName
//    + "\n  GROUP BY " + columnCategory
//    + "\n ORDER BY " + columnCategory + ""

public class ExamSourceDao {
    public static var prepared : Bool = false
    private var db: OpaquePointer?
    private var statement: OpaquePointer?
    public static var dbFile: String!
    
    public init() throws {
        self.db = nil
        self.statement = nil
        if !ExamSourceDao.prepared {
            throw ExamError.sql(log(10, "ExamSourceDao#init: not prepared."))
        }
    }//init()
    
    public static func prepare(bundledDbFile: String) throws {
        if ExamSourceDao.prepared {
            return
        }
        _ = log(50, "ExamSourceDao#prepare(\"\(bundledDbFile)\")")
        let fileNameParts = splitToBaseAndExtensoin(fileName: bundledDbFile)
        _ = log(100, "Base Name: \(fileNameParts.base)")
        _ = log(100, "Extension: \(fileNameParts.ext)")
        guard let bundlePath = Bundle.main.path(forResource: fileNameParts.base,ofType: fileNameParts.ext) else {
            _ = log(10, "Not exist:[\(bundledDbFile)] application: \(Repository.applicationType.label)")
            fatalError("ExamSourceDao#prepare bundlePath: nil. バンドルファイルの追加は，Added Files to \"Exam\"で\"Create groups\"を指定して、ファイルをコピーする。クリーン後にビルドする。")
        }
        _ = log(50, "ExamSourceDao#prepare bundlePath: \(bundlePath)")
        self.dbFile = NSTemporaryDirectory() + bundledDbFile
        _ = log(10, "ExamSourceDao#prepare Work DB file: \(dbFile!)")
        do {
            try removeFileIfExists(path: dbFile)
            _ = logPrecisely(100, "ExamSourceDao#prepare Work DB file removed?: \(!checkFileExists(path: dbFile))")
            try copyFile(from: bundlePath, to: dbFile)
            _ = logPrecisely(100, "ExamSourceDao#prepare Work DB file copied?: \(checkFileExists(path: dbFile))")
        } catch let e {
            _ = log(10, "ExamSourceDao#prepare Copy file: \(e)")
            throw ExamError.sql("ExamSourceDao#prepare Copy file: \(e)")
        }
        ExamSourceDao.prepared = true
        return
    }//prepare()
    
    public func getTables() throws -> [String] {
        _ = log(50, "ExamSourceDao#getTables")
        try open()
        defer { close() }
        try prepare(sql: sqlGetTables)
        var list: [String] = []
        defer { finalize() }
        while try step() {
            list.append(try getText(column: 0)!)
        }//while self.step()
        return list
    }//getTables()
    
    public func get() throws -> [ExamSourceDto] {
        _ = log(50, "ExamSourceDao#get")
        try open()
        defer { close() }
        try self.prepare(sql: sqlGetAll)
        defer { finalize() }
        var list: [ExamSourceDto] = []
        while try self.step() {
            list.append(try getDto())
        }//while self.step()
        return list
    }//get()
    
    public func getIdList(category: ExamCategory, optionType: OptionType) throws -> [Int] {
        _ = log(50, "ExamSourceDao#getIdList(\(category.toString()), \(optionType.toString()))")
        try open()
        defer { close() }
        // LIKE句(LIKE = ?)でバインドを使うと正しく検索できない。
        // 対策として、文字列連結で回避する。
        // 引数をタイプコードにすることで、SQLインジェクションのリスクを排除する。
        try self.prepare(sql: sqlGetIdList1of2 + optionType.name + sqlGetIdList2of2)
        defer { finalize() }
        try bind_int(order: 1, value: Int32(category.code))
        //        try bind_text(order: 2, value: "%" + optionType.name + "%")
        _ = log(10, "ExamSourceDao#getIdList: \n" + getExpandedSql())
        var list: [Int] = []
        while try self.step() {
            if let id = try getInt32(column: 0) {
                list.append(Int(id))
            }
        }//while self.step()
        return list
    }//getIdList(category: ExamCategory, optionType: OptionType)
    
    public func getIdList(category: ExamCategory, optionList: [OptionType]) throws -> [Int] {
        _ = log(50, "ExamSourceDao#getIdList(\(category.toString()), \(listOpttions(optionList:optionList)))")
        try open()
        defer { close() }
        // LIKE句(LIKE = ?)でバインドを使うと正しく検索できない。
        // 対策として、文字列連結で回避する。
        // 引数をタイプコードにすることで、SQLインジェクションのリスクを排除する。
        let sql = sqlGetIdListByCategoryAndOption.replace(before: optionConditon, after: expandLikePhrase(optionList: optionList))
        try self.prepare(sql: sql)
        defer { finalize() }
        try bind_int(order: 1, value: Int32(category.code))
        //        try bind_text(order: 2, value: "%" + optionType.name + "%")
        _ = log(10, "ExamSourceDao#getIdList: \n" + getExpandedSql())
        var list: [Int] = []
        while try self.step() {
            if let id = try getInt32(column: 0) {
                list.append(Int(id))
            }
        }//while self.step()
        return list
    }//getIdList(category: ExamCategory, optionType: OptionType)
    
    private func listOpttions(optionList: [OptionType]) -> String {
        var s = ""
        for opt in optionList {
            s += opt.name
        }
        return s
    }//listOpttions(optionList: [OptionType])
    
    private func expandLikePhrase(optionList: [OptionType]) -> String {
        if optionList.count == 1 {
            return expandLikePhrase(optionType: optionList[0])
        } else {
            var expression = expandLikePhrase(optionType: optionList[0])
            for i in 1 ..< optionList.count {
                expression += " OR " + expandLikePhrase(optionType: optionList[i])
            }//for i in 1 ..< optionList.count
            return "( " + expression + " )"
        }
    }//expandLikePhrase(optionList: [OptionType]) -> String
    
    private func expandLikePhrase(optionType: OptionType) -> String {
        return columnOption + " LIKE \'%\(optionType.name)%\'"
    }//expandLikePhrase(optionType: OptionType)
    
    public func getById(id: Int) throws -> ExamSourceDto? {
        _ = log(50, "ExamSourceDao#getById(\(id))")
        try open()
        defer { close() }
        try self.prepare(sql: sqlGetById)
        defer { finalize() }
        try bind_int(order: 1, value: Int32(id))
        _ = log(10, "ExamSourceDao#getById: \n" + getExpandedSql())
        if try self.step() == false {
            return nil
        }
        return try getDto()
    }//getById(id: Int)
    
    public func getCountByCategory() throws -> [ ExamCategory : Int ] {
        _ = log(50, "ExamSourceDao#getCountByCategory")
        try open()
        defer { close() }
        try self.prepare(sql: sqlGetCountByCategory)
        defer { finalize() }
        _ = log(10, "ExamSourceDao#getCountByCategory: \n" + getExpandedSql())
        var list: [ ExamCategory : Int ] = [ : ]
        while try self.step() {
            let code = try getInt32(column: 0)
            let count = try getInt32(column: 1)
            if let cd = code {
                if let cnt = count {
                    let category = try ExamCategory.find(code: Int(cd) )
                    list[category] = Int(cnt)
                }
            }
        }//while self.step()
        return list
    }//getCountByCategory()
    
    private func getDto() throws -> ExamSourceDto {
        let dto = ExamSourceDto()
        dto._id = try getInt32(column: 0)
        dto.category = try getInt32(column: 1)
        dto.code = try getText(column: 2)
        dto.status = try getInt32(column: 3)
        dto.option = try getText(column: 4)
        dto.weight = try getInt32(column: 3)
        dto.encryptedExam = try getCryptogram(ivColumn: 6,textColumn: 7)
        dto.encryptedSource = try getCryptogram(ivColumn: 8,textColumn: 9)
        dto.encryptedComment = try getCryptogram(ivColumn: 10,textColumn: 11)
        dto.questionImage = try getText(column: 12)
        dto.answerImage = try getText(column: 13)
        dto.commentImage = try getText(column: 14)
        return dto
    }//getDto()
    
    private func getInt32(column: Int) throws -> Int32? {
        return Int32(sqlite3_column_int(self.statement, Int32(column)))
    }//getInt32(column: Int)
    
    private func getText(column: Int) throws -> String? {
        return String(cString: sqlite3_column_text(self.statement, Int32(column)))
    }//getText(column: Int)
    
    private func getCryptogram(ivColumn: Int, textColumn: Int) throws -> Cryptogram {
        let iv = try getText(column: ivColumn)
        let encryptedCode = try getText(column: textColumn)
        return try Cryptogram(iv: iv, encryptedBase64: encryptedCode)
    }//getCryptogram(ivColumn: Int, textColumn: Int)
    
    
    private func getExpandedSql() -> String {
        //        return String(cString: sqlite3_expanded_sql(self.statement)!)
        if #available(iOS 10.0, *) {
            return String(cString: sqlite3_expanded_sql(self.statement)!)
        } else {
            return String(cString: sqlite3_sql(self.statement)!)
        }
    }//getExpandedSql(prefix: String)
    
    /////////// Low Level /////////////////
    public func open() throws {
        _ = log(50, "ExamSourceDao#open")
        sqlite3_shutdown()
        sqlite3_initialize()
        _ = log(100, "ExamSourceDao#isThreadsafe: \(sqlite3_threadsafe())")
        let fileURL = URL(string: ExamSourceDao.dbFile)
        _ = log(100, "Database: \(String(describing: ExamSourceDao.dbFile))")
        _ = log(100, "File exists?: \(checkFileExists(path: ExamSourceDao.dbFile))")
        let status = sqlite3_open_v2(fileURL?.path, &self.db, SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX, nil)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "ExamSourceDao#open: \(SqliteStatus.getStatus(status)) - Cannot connect database file (\(fileURL!))."))
        }
        //        _ = log(90, "Old journal mode: \(try getJournalMode())")
        //        try self.execute(sql: pragmaJournalOff)
        //        _ = log(90, "New journal mode: \(try getJournalMode())")
        _ = log(50, "ExamSourceDao#open.")
        return
    }//open()
    
    public func getJournalMode() throws -> String {
        _ = log(50, "ExamSourceDao#getJournalMode")
        try self.prepare(sql: pragmaGetJournal)
        defer { finalize() }
        if try self.step() == false {
            throw ExamError.sql(log(10, "Cannot get journal mode."))
        }
        let mode = try getText(column: 0)!
        return mode
    }//getJournalMode()
    
    public func close() {
        let status = sqlite3_close(self.db)
        guard status == SQLITE_OK else {
            _ = log(10, "ExamSourceDao#closed: \(SqliteStatus.getStatus(status)) - cannot close database.")
            return
        }
        _ = log(50, "ExamSourceDao#closed.")
        return
    }//close()
    
    public func execute(sql: String) throws {
        let status = sqlite3_exec(self.db, sql, nil, nil, nil)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "ExamSourceDao#execute: \(SqliteStatus.getStatus(status)), \(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(50, "ExamSourceDao#execute: \(sql)")
    }//prepare(sql: String)
    
    public func prepare(sql: String) throws {
        let status = sqlite3_prepare_v2(self.db, sql, -1, &(self.statement), nil)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "ExamSourceDao#prepared:\(SqliteStatus.getStatus(status)) ,\(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(50, "ExamSourceDao#prepared:\n \(sql)")
    }//prepare(sql: String)
    
    public func finalize() {
        let status = sqlite3_finalize(self.statement)
        guard status == SQLITE_OK else {
            _ = log(10, "ExamSourceDao#finalized: \(SqliteStatus.getStatus(status)), \(String(cString: sqlite3_errmsg(self.db)!))")
            return
        }
        _ = log(50, "ExamSourceDao#finalized.")
        return
    }//finalize()
    
    public func step() throws -> Bool {
        let status = sqlite3_step(self.statement)
        guard status == SQLITE_DONE || status == SQLITE_ROW else {
            throw ExamError.sql(log(10, "ExamSourceDao#stepped: \(SqliteStatus.getStatus(status)), \(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(100, "ExamSourceDao#stepped: status=\(SqliteStatus.getStatus(status))")
        return (status == SQLITE_ROW)
    }//step()
    
    public func bind_text(order: Int32, value: String) throws  {
        let cchars = value.cString(using: String.Encoding.utf8)!
        let length = Int32(value.lengthOfBytes(using: String.Encoding.utf8))
        let status = sqlite3_bind_text(self.statement, order, cchars, length, nil)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "ExamSourceDao#bind: \(SqliteStatus.getStatus(status)), \(order): \(value) --- \(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(50, "ExamSourceDao#bind text \(order): \(value)")
    }//bind_text(order: Int32, value: String)
    
    public func bind_int(order: Int32, value: Int32) throws  {
        let status = sqlite3_bind_int(self.statement, order, value)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "ExamSourceDao#bind: \(SqliteStatus.getStatus(status)), \(order): \(value) --- \(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(50, "ExamSourceDao#bind int \(order): \(value)")
    }//bind_int(order: Int32, value: Int32)
    
}//class ExamSourceDao

public class ExamSourceDto {
    var _id: Int32!
    var  category: Int32!
    var  code: String!
    var  status: Int32!
    var  option: String!
    var  weight: Int32!
    var  encryptedExam: Cryptogram!
    var  encryptedSource: Cryptogram!
    var  encryptedComment: Cryptogram!
    var  questionImage: String!
    var  answerImage: String!
    var  commentImage: String!
    
    init() {
        self._id = nil
        self.category = nil
        self.code = nil
        self.status = nil
        self.option = nil
        self.weight = nil
        self.encryptedExam = nil
        self.encryptedSource = nil
        self.encryptedComment = nil
        self.questionImage = nil
        self.answerImage = nil
        self.commentImage = nil
    }//init(_id: Int32,...)
    
    public func toString() throws -> String {
        var s = ""
        s += self.code! + ": "
        s += String(describing: self.category!) + ", "
        s += self.option! + "\n"
        s += try self.encryptedExam!.decrypt() + "\n"
        s += self.questionImage! + "\n"
        s += try self.encryptedSource!.decrypt()  + "\n"
        s += self.questionImage! + "\n"
        s += try self.encryptedComment!.decrypt() + "\n"
        s += self.questionImage!
        return s
    }//toString()
    
}//class ExamSourceDto

class Cryptogram {
    static let secretKey = "(c)2019 Manjfold Inc."
    static let keyLength: Int = 128 / 8      // AES128
    var iv: String
    var encryptedBase64: String
    
    public init(iv: String? , plainText: String?) throws {
        if iv == nil || plainText == nil {
            throw ExamError.isNil("iv == nil || plainText == nil")
        }
        self.iv = iv!
        self.encryptedBase64 = ""
        try encrypt(plainText: plainText!)
    }//init(iv: String , plainText: String)
    
    public init(iv: String?, encryptedBase64: String?) throws {
        if iv == nil || encryptedBase64 == nil {
            throw ExamError.isNil("iv == nil || encryptedBase64 == nil")
        }
        self.iv = iv!
        self.encryptedBase64 = encryptedBase64!
    }//init(iv: String , encryptedCode: String)
    
    public func encrypt(plainText: String) throws  {
        self.encryptedBase64 = ""
    }//encrypt(plainText: String)
    
    private func generateKey(source: String) -> String {
        if source.count >= Cryptogram.keyLength {
            return String(source.prefix(Cryptogram.keyLength))
        } else {
            return generateKey( source: source + source )
        }
    }//generateKey(source: String)
    
    public func decrypt() throws -> String {
        let key = generateKey(source: Cryptogram.secretKey)
        let aes = try AES(key: key, iv: self.iv)
        guard let base64 = self.encryptedBase64.data(using: String.Encoding.utf8) else {
            throw ExamError.crypt("nil")
        }
        let encryptedCode = Data(base64Encoded: base64, options: [])
        var buffer = Array<UInt8>(repeating: 0, count: encryptedCode!.count)
        encryptedCode!.copyBytes(to: &buffer, count: encryptedCode!.count)
        let plainText = try aes.decrypt(buffer)
        //        return String(data: Data(bytes: plainText), encoding: .utf8) ?? "nil"
        return String(data: Data(plainText), encoding: .utf8) ?? "nil"
    }//decrypt()
    
    
    private func encodeBase64(plainText: String) -> String {
        return plainText.data(using: .utf8)!.base64EncodedString()
    }//encodeBase64(plainText: String)
    
    private func decodeBase64(code: String) -> String {
        return String(data: Data(base64Encoded: code)!, encoding: .utf8)!
    }//decodeBase64(code: String)
}//class Cryptogram

public class SqliteStatus {
    static let statusCodes = [
        SQLITE_OK: "SQLITE_OK",
        SQLITE_ERROR: "SQLITE_ERROR",
        SQLITE_INTERNAL: "SQLITE_INTERNAL",
        SQLITE_PERM: "SQLITE_PERM",
        SQLITE_ABORT: "SQLITE_ABORT",
        SQLITE_BUSY: "SQLITE_BUSY",
        SQLITE_LOCKED: "SQLITE_LOCKED",
        SQLITE_NOMEM: "SQLITE_NOMEM",
        SQLITE_READONLY: "SQLITE_READONLY",
        SQLITE_INTERRUPT: "SQLITE_INTERRUPT",
        SQLITE_IOERR: "SQLITE_IOERR",
        SQLITE_CORRUPT: "SQLITE_CORRUPT",
        SQLITE_NOTFOUND: "SQLITE_NOTFOUND",
        SQLITE_FULL: "SQLITE_FULL",
        SQLITE_CANTOPEN: "SQLITE_CANTOPEN",
        SQLITE_PROTOCOL: "SQLITE_PROTOCOL",
        SQLITE_EMPTY: "SQLITE_EMPTY",
        SQLITE_SCHEMA: "SQLITE_SCHEMA",
        SQLITE_TOOBIG: "SQLITE_TOOBIG",
        SQLITE_CONSTRAINT: "SQLITE_CONSTRAINT",
        SQLITE_MISMATCH: "SQLITE_MISMATCH",
        SQLITE_MISUSE: "SQLITE_MISUSE",
        SQLITE_NOLFS: "SQLITE_NOLFS",
        SQLITE_AUTH: "SQLITE_AUTH",
        SQLITE_FORMAT: "SQLITE_FORMAT",
        SQLITE_RANGE: "SQLITE_RANGE",
        SQLITE_NOTADB: "SQLITE_NOTADB",
        SQLITE_ROW: "SQLITE_ROW",
        SQLITE_DONE: "SQLITE_DONE"
    ]//static let statusCodes
    
    public static func getStatus(_ code: Int32) -> String {
        if let status = statusCodes[code] {
            return status
        } else {
            return "Unknown Error: \(code)"
        }
    }//getStatus(code: Int)
}//class SqliteStatus
/** End of File **/

