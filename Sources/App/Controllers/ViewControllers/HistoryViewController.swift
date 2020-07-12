import Vapor

final class HistoryViewController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("data")
        group.get(use: data)
    }
}


extension HistoryViewController {
    func data(_ req: Request) throws -> Future<View> {
        var userId = try req.query.get(String.self, at: "user")
        
        
        let rowsAndColumns: Future<(HistoryRows, HistoryColumns)> = History.query(on: req)
            .filter(\.userId, .equal, userId)
            .first()
            .and(LastContest.updated(conn: req))
            .flatMap { result, updated in
            if let _ = result {
                print("from database")
                
                let historiesFuture = History.query(on: req).filter(\.userId, .equal, userId).all()
                
                if updated, let lastContest = History.fromAtCoder(from: userId).first {
                    print("updated", updated)
                    return historiesFuture.and(lastContest.create(on: req)).map { histories, contest in
                        var histories = histories
                        histories.insert(contest, at: 0)
                        return (HistoryRows(histories: histories), HistoryColumns(histories: histories))
                    }
                } else {
                    return historiesFuture.map { histories in
                        return (HistoryRows(histories: histories), HistoryColumns(histories: histories))
                    }
                }
            } else {
                print("from AtCoder")
                return History.fromAtCoder(from: userId).map { $0.create(on: req) }.flatten(on: req).map { histories in
                    return (HistoryRows(histories: histories), HistoryColumns(histories: histories))
                }
            }
        }
        
        let rowsAndColumnsAndStats: Future<(HistoryRows, HistoryColumns, [BasicStats])> = rowsAndColumns.map { historyRows, historyColumns in
            
            guard !historyRows.histories.isEmpty else {
                userId = ""
                return (historyRows, historyColumns, [])
            }
            
            let rank = historyColumns.rank.compactMap { Double($0) }.describe()
            let perf = historyColumns.perf.compactMap { $0.map { x in Double(x) } }.describe()
            let diff = historyColumns.diff.compactMap { $0.map { x in Double(x) } }.describe()
            
            let basicStatsList = [
                BasicStats(title: "パフォ", stats: perf),
                BasicStats(title: "差分", stats: diff),
                BasicStats(title: "順位", stats: rank)
            ]
            
            return (historyRows, historyColumns, basicStatsList)
        }
        
        let view: Future<View> = rowsAndColumnsAndStats.flatMap { historyRows, historyColumns, statsList in
            
            let apiURL = Path(path: "api/history")
            let columnsQuery = "columns?user=\(userId)"
            let rowsQuery = "rows?user=\(userId)"
            
            let columnsCSV = historyColumns.toCSV()
            let rowsCSV = "\(HistoryRows.Row.labels.joined(separator: ","))\n\(historyRows.toCSV())"
            let csvURL = apiURL.grouped("csv")
            let csv = ConcreteData(type: "CSV", columnsBase: columnsCSV, rowsBase: rowsCSV, columnsURL: csvURL.append(columnsQuery).description, rowsURL: csvURL.append(rowsQuery).description)
            
            let columnsTAB = historyColumns.joinedByTAB()
            let rowsTAB = "\(HistoryRows.Row.labels.joined(separator: "\t"))\n\(historyRows.joinedByTAB())"
            let tabURL = apiURL.grouped("tab")
            let tab = ConcreteData(type: "TAB", columnsBase: columnsTAB, rowsBase: rowsTAB, columnsURL: tabURL.append(columnsQuery).description, rowsURL: tabURL.append(rowsQuery).description)
            
            let jsonEncodedData: (String, JSONEncoder.OutputFormatting) throws -> ConcreteData = { type, format in
                let encoder = JSONEncoder()
                encoder.outputFormatting = format
                let historyRowsJSON = try encoder.encode(historyRows)
                let historyRowsJSONString = String(data: historyRowsJSON, encoding: .utf8) ?? "{}"
                let historyColumnsJSON = try encoder.encode(historyColumns)
                let historyColumnsJSONString = String(data: historyColumnsJSON, encoding: .utf8) ?? "{}"
                let json = ConcreteData(type: type, columnsBase: historyColumnsJSONString, rowsBase: historyRowsJSONString, columnsURL: apiURL.append(columnsQuery).description, rowsURL: apiURL.append(rowsQuery).description)
                return json
            }
            
            let json = try jsonEncodedData("JSON", .init())
            let jsonPretty = try jsonEncodedData("Pretty_JSON", .prettyPrinted)
            
            
            let contents = BodyContents(userId: userId == "" ? "お探しのユーザは見つかりませんでした。" : userId,
                                        basicStatsList: statsList,
                                        concreteDataList: [csv, tab, json, jsonPretty])
            return try req.view().render("body/contents", contents)
        }
        
        return view
    }
}
