import Vapor

final class HistoryAPIController: RouteCollection {
    func boot(router: Router) throws {
        let history = router.grouped("api", "history")
        history.get("rows", use: fromAtCoder { $0 })
        history.get("columns", use: fromAtCoder { HistoryColumns(histories: $0) })
        
        let csv = router.grouped("csv", "history")
        csv.get("rows", use: csvRows)
        csv.get("columns", use: csvColumns)
        
        let tab = router.grouped("tab", "history")
        tab.get("rows", use: tabRows)
        tab.get("columns", use: tabColumns)
    }
}

extension HistoryAPIController {
    func fromAtCoder<T>(convertFunc: @escaping ([History]) -> T) -> (Request) throws -> Future<T> {
        let use: (Request) throws -> Future<T> = { req in
            let userId = try req.query.get(String.self, at: "user")
        
            return History.query(on: req).filter(\.userId, .equal, userId).first().flatMap { result in
                if let _ = result {
                    print("rows from database")
                    return History.query(on: req).filter(\.userId, .equal, userId).all().map(convertFunc)
                } else {
                    print("rows from AtCoder")
                    return History.fromAtCoder(from: userId).map { $0.create(on: req) }.flatten(on: req).map(convertFunc)
                }
            }
        }
        return use
    }
    
    var rows: (Request) throws -> Future<[History]> {
        return fromAtCoder { $0 }
    }
    
    var columns: (Request) throws -> Future<HistoryColumns> {
        return fromAtCoder { HistoryColumns(histories: $0) }
    }
}

extension HistoryAPIController {
    var csvRows: (Request) throws -> Future<String> {
        return fromAtCoder { $0.toCSV() }
    }
    var csvColumns: (Request) throws -> Future<String> {
        return fromAtCoder { HistoryColumns(histories: $0).toCSV()}
    }
}

extension HistoryAPIController {
    var tabRows: (Request) throws -> Future<String> {
        return fromAtCoder { $0.joinedByTAB() }
    }
    
    var tabColumns: (Request) throws -> Future<String> {
        return fromAtCoder { HistoryColumns(histories: $0).joinedByTAB() }
    }
}
