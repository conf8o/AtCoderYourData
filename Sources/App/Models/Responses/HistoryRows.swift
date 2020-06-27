import Vapor

struct HistoryRows: Content {
    struct Row: Content {
        var date: String
        var contest: String
        var rank: Int
        var perf: Int?
        var newRating: Int?
        var diff: Int?
        static let labels = ["date", "contest", "rank", "perf", "newRating", "diff"]
        
        init(history: History) {
            self.date = history.date
            self.contest = history.contest
            self.rank = history.rank
            self.perf = history.perf
            self.newRating = history.newRating
            self.diff = history.diff
        }
    }
    var histories: [HistoryRows.Row]
    
    init(histories: [History]) {
        self.histories = histories.map { HistoryRows.Row(history: $0) }
    }
}

extension HistoryRows.Row {
    private func joined(separator: String) -> String {
        let values: [String] = [
            date,
            contest,
            rank.description,
            perf?.description ?? "NULL",
            newRating?.description ?? "NULL"
        ]
        
        return values.joined(separator: separator)
    }
    
    func toCSV() -> String {
        return joined(separator: ",")
    }
    
    func joinedByTAB() -> String {
        return joined(separator: "\t")
    }
}

extension HistoryRows {
    func toCSV() -> String {
        return self.histories.map { $0.toCSV() }.joined(separator: "\n")
    }
    
    func joinedByTAB() -> String {
        return self.histories.map { $0.joinedByTAB() }.joined(separator: "\n")
    }
}
