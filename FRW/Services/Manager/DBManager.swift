//
//  DBManager.swift
//  Flow Wallet
//
//  Created by Selina on 9/10/2022.
//

import Combine
import FMDB
import Foundation

// MARK: - DBTable

private enum DBTable: String {
    case webBookmark = "web_bookmark"
}

// MARK: - DBManager

class DBManager {
    // MARK: Lifecycle

    init() {
        prepare()

        UserManager.shared.$activatedUID
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { newUID in
                guard newUID != nil else { return }
                self.closeDB()
                self.prepare()
            }.store(in: &cancelSets)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willReset),
            name: .willResetWallet,
            object: nil
        )
    }

    // MARK: Internal

    static let shared = DBManager()

    // MARK: Private

    private var db: FMDatabase?

    private var cancelSets = Set<AnyCancellable>()

    private func closeDB() {
        db?.close()
        db = nil
    }

    @objc
    private func willReset() {
        closeDB()
    }
}

// MARK: - init

extension DBManager {
    var dbURL: URL {
        let uid = UserManager.shared.activatedUID ?? "0"
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("app_database/\(uid)/database.db")
    }

    private func prepare() {
        guard UserManager.shared.activatedUID != nil else {
            return
        }

        if db != nil {
            return
        }

        let folderURL = dbURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: folderURL.relativePath) {
            debugPrint("DBManager: db folder: \(folderURL) is not exist, create folder")
            let result = FileManager.default.createFolder(folderURL)
            if result == false {
                debugPrint("DBManager: db folder: \(folderURL) create failed")
                return
            }
        }

        let database = FMDatabase(url: dbURL)
        db = database

        if !database.open() {
            debugPrint("DBManager: db open failed")
            db = nil
            return
        }

        prepareDB()
    }

    private func prepareDB() {
        guard let db = db else {
            return
        }

        do {
            if !db.tableExists(DBTable.webBookmark.rawValue) {
                debugPrint("DBManager: web_bookmark table is not exist, creating")

                let sql = """
                    CREATE TABLE \(DBTable.webBookmark.rawValue) (
                        id INTEGER PRIMARY KEY,
                        url Text,
                        title Text,
                        is_fav INTEGER,
                        create_time INTEGER,
                        update_time INTEGER
                    )
                """

                try db.executeUpdate(sql, values: nil)
                try db.executeUpdate(
                    "CREATE INDEX web_bookmark_index ON \(DBTable.webBookmark.rawValue) (id,url)",
                    values: nil
                )
            }
        } catch {
            debugPrint("DBManager: table create failed: \(error)")
        }
    }
}

// MARK: - Public

extension DBManager {
    func save(webBookmark bookmark: WebBookmark) {
        insert(
            into: .webBookmark,
            columns: ["url", "title", "is_fav", "create_time", "update_time"],
            values: bookmark.dbValues
        )
        NotificationCenter.default.post(name: .webBookmarkDidChanged)
    }

    func webBookmarkCount() -> Int {
        count(in: .webBookmark)
    }

    func webBookmarkIsExist(url: String) -> Bool {
        guard let rs = query(from: .webBookmark, where: "url = ?", values: [url]) else {
            return false
        }

        let isExist = rs.next()
        rs.close()

        return isExist
    }

    func getAllWebBookmark() -> [WebBookmark] {
        guard let rs = query(from: .webBookmark, orderBy: "update_time desc") else {
            debugPrint("rs is nil")
            return []
        }

        var list = [WebBookmark]()

        while rs.next() {
            if let map = rs.resultDictionary, let bookmark = WebBookmark.build(fromDBMap: map) {
                list.append(bookmark)
            }
        }
        rs.close()

        list.sort { $0.updateTime > $1.updateTime }

        return list
    }

    func delete(webBookmarkByURL url: String) {
        delete(in: .webBookmark, where: "url = ?", values: [url])
        NotificationCenter.default.post(name: .webBookmarkDidChanged)
    }

    func delete(webBookmark bookmark: WebBookmark) {
        delete(in: .webBookmark, where: "id = ?", values: [bookmark.id])
        NotificationCenter.default.post(name: .webBookmarkDidChanged)
    }
}

// MARK: - Helper

extension DBManager {
    /// 查询
    private func query(
        _ column: String = "*",
        from: DBTable,
        where: String? = nil,
        limit: Int? = nil,
        orderBy: String? = nil,
        values: [Any]? = nil
    ) -> FMResultSet? {
        guard let db = db else {
            debugPrint("execute query but db is nil")
            return nil
        }

        var sql = "SELECT \(column) FROM \(from.rawValue)"
        if let whereString = `where` {
            sql.append(" WHERE \(whereString)")
        }

        if let orderBy = orderBy {
            sql.append(" ORDER BY \(orderBy)")
        }

        if let limit = limit {
            sql.append(" LIMIT \(limit)")
        }

        debugPrint("query sql is: \(sql)")

        do {
            let rs = try db.executeQuery(sql, values: values)
            return rs
        } catch {
            debugPrint("executeQuery failed")
            return nil
        }
    }

    /// 插入或替换
    @discardableResult
    private func insert(into to: DBTable, columns: [String], values: [Any]) -> Bool {
        guard let db = db else {
            debugPrint("execute insert but db is nil")
            return false
        }

        let columnString = columns.joined(separator: ",")
        var valuesArray = [String]()
        columns.forEach { _ in
            valuesArray.append("?")
        }
        let valuesString = valuesArray.joined(separator: ",")
        let sql = "REPLACE INTO \(to.rawValue)(\(columnString)) VALUES (\(valuesString))"

        debugPrint("insert sql is: \(sql)")

        do {
            try db.executeUpdate(sql, values: values)
            return true
        } catch {
            debugPrint("execute insert failed")
            return false
        }
    }

    /// 更新
    @discardableResult
    private func update(
        in table: DBTable,
        set: String,
        where: String? = nil,
        values: [Any]
    ) -> Bool {
        guard let db = db else {
            debugPrint("execute update but db is nil")
            return false
        }

        var sql = "UPDATE \(table.rawValue) SET \(set)"
        if let whereString = `where` {
            sql.append(" WHERE \(whereString)")
        }

        debugPrint("update sql is: \(sql)")

        do {
            try db.executeUpdate(sql, values: values)
            return true
        } catch {
            debugPrint("execute update failed")
            return false
        }
    }

    /// 删除
    @discardableResult
    private func delete(in table: DBTable, where: String, values: [Any]) -> Bool {
        guard let db = db else {
            debugPrint("execute delete but db is nil")
            return false
        }

        let sql = "DELETE FROM \(table.rawValue) WHERE \(`where`)"

        debugPrint("delete sql is: \(sql)")

        do {
            try db.executeUpdate(sql, values: values)
            return true
        } catch {
            debugPrint("execute delete failed")
            return false
        }
    }

    private func count(in table: DBTable) -> Int {
        guard let db = db else {
            debugPrint("query count but db is nil")
            return 0
        }

        let sql = "SELECT count(*) FROM \(table.rawValue)"

        do {
            let result = try db.executeQuery(sql, values: nil)

            var count = 0
            if result.next() {
                count = Int(result.int(forColumnIndex: 0))
            }
            result.close()

            return count
        } catch {
            debugPrint("query count but error: \(error)")
            return 0
        }
    }
}
