//
//  Setting.swift
//  exam
//
//  Created by suhccarg on 2020/12/20.
//  Copyright © 2020年 株式会社マニフォールド. All rights reserved.
//

import Foundation

import Foundation
import SQLite3
import CryptoSwift

fileprivate let tableName = "settings"
fileprivate let columnId = "_id"
fileprivate let columnItem = "_item"
fileprivate let columnValue = "_value"

fileprivate let columnList = ""
    + columnItem + ", "
    + columnValue

fileprivate let sqlGetAll = "SELECT "
    + columnId + ", " + columnList
    + "\n FROM " + tableName
    + "\n ORDER BY " + columnItem

fileprivate let sqlGetIdList = "SELECT "
    + columnId    + "\n FROM " + tableName
    + "\n ORDER BY " + columnItem

fileprivate let sqlGetById = "SELECT "
    + columnId + ", " + columnList
    + "\n FROM " + tableName
    + "\n WHERE " + columnId + " = ?"
    + "\n ORDER BY " + columnItem

fileprivate let sqlGetByItem = "SELECT "
    + columnId + ", " + columnList
    + "\n FROM " + tableName
    + "\n WHERE " + columnItem + " = ?"

public class SettingDao {
    private var db: OpaquePointer?
    private var statement: OpaquePointer?
    public static let dbFile: String! = ExamSourceDao.dbFile
    
    public init() throws {
        self.db = nil
        self.statement = nil
        if !ExamSourceDao.prepared {
            throw ExamError.sql(log(10, "SettingDao#init: not prepared."))
        }
    }//init()
    
    public func getTables() throws -> [String] {
        _ = log(50, "SettingDao#getTables")
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
    
    public func get() throws -> [SettingDto] {
        _ = log(50, "SettingDao#get")
        try open()
        defer { close() }
        try self.prepare(sql: sqlGetAll)
        defer { finalize() }
        var list: [SettingDto] = []
        while try self.step() {
            list.append(try getDto())
        }//while self.step()
        return list
    }//get()
    
   
    public func getIdList() throws -> [Int] {
        _ = log(50, "SettingDao#getIdList)")
        try open()
        defer { close() }
        try self.prepare(sql: sqlGetIdList)
        defer { finalize() }
         _ = log(10, "SettingDao#getIdList: \n" + getExpandedSql())
        var list: [Int] = []
        while try self.step() {
            if let id = try getInt32(column: 0) {
                list.append(Int(id))
            }
        }//while self.step()
        return list
    }//getIdList(category: ExamCategory, optionType: OptionType)
    
    public func getById(id: Int) throws -> SettingDto? {
        _ = log(50, "SettingDao#getById(\(id))")
        try open()
        defer { close() }
        try self.prepare(sql: sqlGetById)
        defer { finalize() }
        try bind_int(order: 1, value: Int32(id))
        _ = log(50, "SettingDao#getById: \n" + getExpandedSql())
        if try self.step() == false {
            _ = log(10, "SettingDao#getById:  \(id) -> nil")
            return nil
        }
        return try getDto()
    }//getById(id: Int)
   
    public func getByItem(settingItem: SettingItem) throws -> SettingDto? {
        _ = log(50, "SettingDao#getByItem: \(settingItem.toString())")
        try open()
        defer { close() }
        try self.prepare(sql: sqlGetByItem)
        defer { finalize() }
        try bind_int(order: 1, value: Int32(settingItem.code))
        _ = log(50, "SettingDao#getByItem: \n" + getExpandedSql())
        if try self.step() == false {
            _ = log(10, "SettingDao#getByItem:  \(settingItem.toString()) -> nil")
            return nil
        }
        return try getDto()
    }//getById(id: Int)
    
    private func getDto() throws -> SettingDto {
        let dto = SettingDto()
        dto._id = try getInt32(column: 0)
        dto.item = try getText(column: 1)
        dto.value = try getText(column: 2)
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
    
    public func open() throws {
        _ = log(50, "SettingDao#open")
        sqlite3_shutdown()
        sqlite3_initialize()
        _ = log(100, "SettingDao#isThreadsafe: \(sqlite3_threadsafe())")
        let fileURL = URL(string: SettingDao.dbFile)
        _ = log(100, "Database: \(String(describing: SettingDao.dbFile))")
        _ = log(100, "File exists?: \(checkFileExists(path: SettingDao.dbFile))")
        let status = sqlite3_open_v2(fileURL?.path, &self.db, SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX, nil)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "SettingDao#open: \(SqliteStatus.getStatus(status)) - Cannot connect database file (\(fileURL!))."))
        }
        _ = log(50, "SettingDao#open.")
        return
    }//open()
    
    public func close() {
        let status = sqlite3_close(self.db)
        guard status == SQLITE_OK else {
            _ = log(10, "SettingDao#closed: \(SqliteStatus.getStatus(status)) - cannot close database.")
            return
        }
        _ = log(50, "SettingDao#closed.")
        return
    }//close()
    
    public func execute(sql: String) throws {
        let status = sqlite3_exec(self.db, sql, nil, nil, nil)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "SettingDao#execute: \(SqliteStatus.getStatus(status)), \(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(50, "SettingDao#execute: \(sql)")
    }//prepare(sql: String)
    
    public func prepare(sql: String) throws {
        let status = sqlite3_prepare_v2(self.db, sql, -1, &(self.statement), nil)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "SettingDao#prepared:\(SqliteStatus.getStatus(status)) ,\(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(50, "SettingDao#prepared:\n \(sql)")
    }//prepare(sql: String)
    
    public func finalize() {
        let status = sqlite3_finalize(self.statement)
        guard status == SQLITE_OK else {
            _ = log(10, "SettingDao#finalized: \(SqliteStatus.getStatus(status)), \(String(cString: sqlite3_errmsg(self.db)!))")
            return
        }
        _ = log(50, "SettingDao#finalized.")
        return
    }//finalize()
    
    public func step() throws -> Bool {
        let status = sqlite3_step(self.statement)
        guard status == SQLITE_DONE || status == SQLITE_ROW else {
            throw ExamError.sql(log(10, "SettingDao#stepped: \(SqliteStatus.getStatus(status)), \(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(100, "SettingDao#stepped: status=\(SqliteStatus.getStatus(status))")
        return (status == SQLITE_ROW)
    }//step()
    
    public func bind_text(order: Int32, value: String) throws  {
        let cchars = value.cString(using: String.Encoding.utf8)!
        let length = Int32(value.lengthOfBytes(using: String.Encoding.utf8))
        let status = sqlite3_bind_text(self.statement, order, cchars, length, nil)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "SettingDao#bind: \(SqliteStatus.getStatus(status)), \(order): \(value) --- \(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(50, "SettingDao#bind text \(order): \(value)")
    }//bind_text(order: Int32, value: String)
    
    public func bind_int(order: Int32, value: Int32) throws  {
        let status = sqlite3_bind_int(self.statement, order, value)
        guard status == SQLITE_OK else {
            throw ExamError.sql(log(10, "SettingDao#bind: \(SqliteStatus.getStatus(status)), \(order): \(value) --- \(String(cString: sqlite3_errmsg(self.db)!))"))
        }
        _ = log(50, "SettingDao#bind int \(order): \(value)")
    }//bind_int(order: Int32, value: Int32)
    
}//class SettingDao

public class SettingDto {
    public var _id: Int32!
    public var  item: String!
    public var  value: String!
    
    init() {
        self._id = nil
        self.item = nil
        self.value = nil
    }//init(_id: Int32,...)
    
    public func toString() throws -> String {
        return String(format:"%d %@: %@", self._id, self.item, self.value)
    }//toString()[
    
}//class SettingDto
/** End of File **/
