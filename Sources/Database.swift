//
//  Database.swift
//  PerfectTemplate
//
//  Created by Alex Shubin on 16.03.17.
//
//

import SQLite
import PerfectLib

extension SQLiteStmt {
    func columnBool(position: Int) -> Bool {
        return columnInt(position: position) == 0 ? false : true
    }
}

class Database {
    
    static let shared = Database()
    
    static let dbPath = "./db/database"
    
    var db: SQLite
    
    //MARK: - INIT

    private init() {
        
        do {
            db = try SQLite(Database.dbPath)
            try buildTables()
        } catch {
            fatalError("\(error)")
        }
        
    }
    
    deinit {
        db.close()
    }
    
    private func buildTables() throws {
        
        try db.execute(statement: "CREATE TABLE IF NOT EXISTS applications (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, auth_key TEXT NOT NULL, app_id TEXT, auth_style TEXT, pem_path TEXT, key_id TEXT, team_id TEXT, p8_path TEXT, android_api_key TEXT, production INTEGER NOT NULL)")
        
    }
    
    //MARK: - public API
    
    func getAllApps() -> [Application] {
        
        var result = [Application]()
        
        let query = "SELECT id, auth_key, app_id, auth_style, pem_path, key_id, team_id, p8_path, android_api_key, production FROM applications"
        
        do {
            
            try db.forEachRow(statement: query) {(statement: SQLiteStmt, i:Int) -> () in
                
                let app = Application()
                app.id = statement.columnInt(position: 0)
                app.authKey = statement.columnText(position: 1)
                app.appID = statement.columnText(position: 2)
                app.authStyle = Application.AuthStyle(rawValue: statement.columnText(position: 3))
                app.pemPath = statement.columnText(position: 4)
                app.keyID = statement.columnText(position: 5)
                app.teamID = statement.columnText(position: 6)
                app.p8Path = statement.columnText(position: 7)
                app.androidApiKey = statement.columnText(position: 8)
                app.production = (statement.columnInt(position: 9) != 0)
                
                result.append(app)
            }} catch {
                fatalError("\(error)")
        }
        
        return result
    }
    
    func getApplicationBy(id: String) -> Application? {
        
        let query = "SELECT id, auth_key, app_id, auth_style, pem_path, key_id, team_id, p8_path, android_api_key, production FROM applications WHERE id = '\(id)' LIMIT 1"
        
        var app: Application?
        
        do {
            
            try db.forEachRow(statement: query) {(statement: SQLiteStmt, i:Int) -> () in
                
                app = Application()
                app!.id = statement.columnInt(position: 0)
                app!.authKey = statement.columnText(position: 1)
                app!.appID = statement.columnText(position: 2)
                app!.authStyle = Application.AuthStyle(rawValue: statement.columnText(position: 3))
                app!.pemPath = statement.columnText(position: 4)
                app!.keyID = statement.columnText(position: 5)
                app!.teamID = statement.columnText(position: 6)
                app!.p8Path = statement.columnText(position: 7)
                app!.androidApiKey = statement.columnText(position: 8)
                app!.production = (statement.columnInt(position: 9) != 0)
                
                }
            
        } catch {
                fatalError("\(error)")
        }
        
        return app
    }
    
    func insertOrReplace(application: Application) {
        
        do {
            
            var query = "INSERT OR REPLACE INTO applications VALUES ("
            
            query.append("\(application.id),")
            query.append("'\(application.authKey)',")
            query.append("'\(application.appID ?? "null")',")
            query.append("'\(application.authStyle?.rawValue ?? "null")',")
            query.append("'\(application.pemPath ?? "null")',")
            query.append("'\(application.keyID ?? "null")',")
            query.append("'\(application.teamID ?? "null")',")
            query.append("'\(application.p8Path ?? "null")',")
            query.append("'\(application.androidApiKey ?? "null")',")
            query.append("\(application.production ? 1 : 0)")
            
            query.append(")")
            
            query = query.replacingOccurrences(of: "'null'", with: "null")
            
            try db.execute(statement: query)
            
        } catch {
            fatalError("\(error)")
        }
        
    }
    
    func deleteApplicationBy(id: String) {
        
        //first deleting associated files
        if let app = getApplicationBy(id: id) {
            
            do {
                let file = File(app.pemPath ?? "")
                if file.exists { file.delete() }
            }
            
        }
        //
        
        do {
            
            try db.execute(statement: "DELETE FROM applications WHERE id = '\(id)'")
            
        } catch {
            fatalError("\(error)")
        }
        
    }
    
    func getMaxAppID() -> Int {
        
        let query = "SELECT max(id) FROM applications"
        
        var id = 0
        
        do {
            
            try db.forEachRow(statement: query) {(statement: SQLiteStmt, i:Int) -> () in
                
                id = statement.columnInt(position: 0)
                
            }
            
        } catch {
            fatalError("\(error)")
        }
        
        return id
    }
    
}
