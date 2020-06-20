import Vapor

final class HistoryAPIController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("history")
        group.get("rows", String.parameter, use: rows)
        group.get("columns", String.parameter, use: columns)
    }
}

extension HistoryAPIController {
    func rows(_ req: Request) throws -> Future<[History]> {
        let userId = try req.parameters.next(String.self)
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
        let userId = try req.parameters.next(String.self)
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
