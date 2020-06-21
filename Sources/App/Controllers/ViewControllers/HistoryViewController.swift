import Vapor

final class HistoryViewController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("data")
        group.get(String.parameter, use: data)
    }
}


extension HistoryViewController {
    func data(_ req: Request) throws -> Future<View> {
        let userId = try req.parameters.next(String.self)
        
        let rowsAndColumns: Future<([History], HistoryColumns)> = History.query(on: req)
            .filter(\.userId, .equal, userId)
            .first().flatMap { result in
            if let _ = result {
                print("colums from database")
                return History.query(on: req).filter(\.userId, .equal, userId).all().map { histories in
                    return (histories, HistoryColumns(histories: histories))
                }
            } else {
                print("colums from AtCoder")
                return History.fromAtCoder(from: userId).map { $0.create(on: req) }.flatten(on: req).map { histories in
                    return (histories, HistoryColumns(histories: histories))
                }
            }
        }
        
        let rowsAndColumnsAndStats: Future<([History], HistoryColumns, [BasicStats])> = rowsAndColumns.map { histories, historyColumns in
            
            let rank = historyColumns.rank.compactMap { Double($0) }.describe()
            let perf = historyColumns.perf.compactMap { x in
                if let x = x {
                    return Double(x)
                } else {
                    return nil
                }
            }.describe()
            
            let diff = historyColumns.diff.compactMap { x in
                if let x = x {
                    return Double(x)
                } else {
                    return nil
                }
            }.describe()
            
            let basicStatsList = [
                BasicStats(title: "パフォーマンス(Ratedのみ)", stats: perf),
                BasicStats(title: "差分", stats: diff),
                BasicStats(title: "順位", stats: rank)
            ]
            
            return (histories, historyColumns, basicStatsList)
        }
        
        let view: Future<View> = rowsAndColumnsAndStats.flatMap { histories, historyColumns, statsList in
            
            let columnsCSV = historyColumns.toCSV()
            let rowsCSV = "\(History.labels.joined(separator: ","))\n\(histories.toCSV())"
            let csv = ConcreteData(type: "CSV", columnsBase: columnsCSV, rowsBase: rowsCSV)
            
            let columnsTAB = historyColumns.joinedByTAB()
            let rowsTAB = "\(History.labels.joined(separator: "\t"))\n\(histories.joinedByTAB())"
            let tab = ConcreteData(type: "TAB", columnsBase: columnsTAB, rowsBase: rowsTAB)
            
            let encoder = JSONEncoder()
            let historiesJSON = try encoder.encode(histories)
            let historiesJSONString = String(data: historiesJSON, encoding: .utf8) ?? "{}"
            let historyColumnsJSON = try encoder.encode(historyColumns)
            let historyColumnsJSONString = String(data: historyColumnsJSON, encoding: .utf8) ?? "{}"
            let json = ConcreteData(type: "JSON", columnsBase: historyColumnsJSONString, rowsBase: historiesJSONString)
            
            let contents = BodyContents(userId: userId, basicStatsList: statsList, concreteDataList: [csv, tab, json])
            return try req.view().render("body/contents", contents)
        }
        
        return view
    }
}
