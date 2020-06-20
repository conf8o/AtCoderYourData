import Vapor

struct HistoryColumns: Content {
    var id: [Int?]
    var userId: [String]
    var date: [String]
    var contest: [String]
    var rank: [Int]
    var perf: [Int?]
    var newRating: [Int?]
    var diff: [Int?]
    
    init(histories: [History]) {
        self.id         = histories.map { $0.id }
        self.userId     = histories.map { $0.userId }
        self.date       = histories.map { $0.date }
        self.contest    = histories.map { $0.contest }
        self.rank       = histories.map { $0.rank }
        self.perf       = histories.map { $0.perf }
        self.newRating  = histories.map { $0.newRating }
        self.diff       = histories.map { $0.diff }
    }
    
}