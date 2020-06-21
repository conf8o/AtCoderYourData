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
        
        let columns: Future<([History], HistoryColumns)> = History.query(on: req).first().flatMap { result in
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
        
        let basicStatsList: Future<([History], HistoryColumns, [BasicStats])> = columns.map { histories, historyColumns in

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
                BasicStats(title: "レート差", stats: diff),
                BasicStats(title: "順位", stats: rank)
            ]
            
            return (histories, historyColumns, basicStatsList)
        }
        
        let view: Future<View> = basicStatsList.flatMap { histories, historyColumns, statsList in
            
            let columnsCSV = historyColumns.toCSV()
            let rowsCSV = "\(History.labels.joined(separator: ","))\n\(histories.toCSV())"
            let csv = ConcreteData(type: "CSV", columnsBase: columnsCSV, rowsBase: rowsCSV)
            
            let columnsTAB = historyColumns.joinedByTAB()
            let rowsTAB = "\(History.labels.joined(separator: "\t"))\n\(histories.joinedByTAB())"
            let tab = ConcreteData(type: "TAB", columnsBase: columnsTAB, rowsBase: rowsTAB)
            
            
            
            let contents = BodyContents(basicStatsList: statsList, concreteDataList: [csv, tab])
            return try req.view().render("body/contents", contents)
        }
        
        return view
    }
}
