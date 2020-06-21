import Vapor

final class HistoryAPIController: RouteCollection {
    func boot(router: Router) throws {
        let history = router.grouped("api", "history")
        history.get("rows", use: rows)
        history.get("columns", use: columns)
        
        let csv = router.grouped("csv", "history")
        csv.get("rows", use: csvRows)
        let tab = router.grouped("tab", "history")
        tab.get("rows", use: tabRows)
    }
}

extension HistoryAPIController {
    func rows(_ req: Request) throws -> Future<[History]> {
        let userId = try req.query.get(String.self, at: "user")
        
        return History.query(on: req).first().flatMap { result in
            if let _ = result {
                print("rows from database")
                return History.query(on: req).filter(\.userId, .equal, userId).all()
            } else {
                print("rows from AtCoder")
                return History.fromAtCoder(from: userId).map { $0.create(on: req) }.flatten(on: req)
            }
        }
    }
    
    func columns(_ req: Request) throws -> Future<HistoryColumns> {
        let userId = try req.query.get(String.self, at: "user")
        
        return History.query(on: req).first().flatMap { result in
            if let _ = result {
                print("colums from database")
                return History.query(on: req).filter(\.userId, .equal, userId).all().map { histories in
                    return HistoryColumns(histories: histories)
                }
            } else {
                print("colums from AtCoder")
                return History.fromAtCoder(from: userId).map { $0.create(on: req) }.flatten(on: req).map { histories in
                    return HistoryColumns(histories: histories)
                }
            }
        }
    }
}

extension HistoryAPIController {
    func csvRows(_ req: Request) throws -> Future<String> {
        let userId = try req.query.get(String.self, at: "user")
        
        return History.query(on: req).first().flatMap { result in
            if let _ = result {
                print("rows from database")
                return History.query(on: req).filter(\.userId, .equal, userId).all().map { $0.toCSV() }
            } else {
                print("rows from AtCoder")
                return History.fromAtCoder(from: userId).map { $0.create(on: req) }.flatten(on: req).map { $0.toCSV() }
            }
        }
    }
    
    func csvColumns(_ req: Request) throws ->  Future<String> {
        let userId = try req.query.get(String.self, at: "user")
        
        return History.query(on: req).first().flatMap { result in
            if let _ = result {
                print("colums from database")
                return History.query(on: req).filter(\.userId, .equal, userId).all().map { histories in
                    return HistoryColumns(histories: histories).toCSV()
                }
            } else {
                print("colums from AtCoder")
                return History.fromAtCoder(from: userId).map { $0.create(on: req) }.flatten(on: req).map { histories in
                    return HistoryColumns(histories: histories).toCSV()
                }
            }
        }
    }
}

extension HistoryAPIController {
    func tabRows(_ req: Request) throws -> Future<String> {
        let userId = try req.query.get(String.self, at: "user")
        
        return History.query(on: req).first().flatMap { result in
            if let _ = result {
                print("rows from database")
                return History.query(on: req).filter(\.userId, .equal, userId).all().map { $0.joinedByTAB() }
            } else {
                print("rows from AtCoder")
                return History.fromAtCoder(from: userId).map { $0.create(on: req) }.flatten(on: req).map { $0.joinedByTAB() }
            }
        }
    }
    
    func tabColumns(_ req: Request) throws ->  Future<String> {
        let userId = try req.query.get(String.self, at: "user")
        
        return History.query(on: req).first().flatMap { result in
            if let _ = result {
                print("colums from database")
                return History.query(on: req).filter(\.userId, .equal, userId).all().map { histories in
                    return HistoryColumns(histories: histories).joinedByTAB()
                }
            } else {
                print("colums from AtCoder")
                return History.fromAtCoder(from: userId).map { $0.create(on: req) }.flatten(on: req).map { histories in
                    return HistoryColumns(histories: histories).joinedByTAB()
                }
            }
        }
    }
}
