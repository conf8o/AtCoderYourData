import FluentSQLite
import Vapor
import Kanna

final class History: SQLiteModel {
    typealias Database = SQLiteDatabase
    static let userIdKey: KeyPath<History, String> = \.userId
    
    var id: Int?
    var userId: String
    var date: String
    var contest: String
    var rank: Int
    var perf: Int?
    var newRating: Int?
    var diff: Int?
    
    init (id: Int?, userId: String, date: String, contest: String, rank: Int, perf: Int?, newRating: Int?, diff: Int?) {
        self.id         = id
        self.userId     = userId
        self.date       = date
        self.contest    = contest
        self.rank       = rank
        self.perf       = perf
        self.newRating  = newRating
        self.diff       = diff
    }
    
    init(userId: String, data: [String]) {
        self.id = nil
        self.userId = userId
        self.date = data[0]
        self.contest = data[1]
        self.rank = Int(data[2])!
        self.perf = Int(data[3])
        self.newRating = Int(data[4])
        self.diff = Int(data[5])
    }
    
    static func fromAtCoder(from userId: String) -> [History] {
        do {
            guard let url = URL(string: "https://atcoder.jp/users/\(userId)/history") else { return [] }
            let doc = try HTML(url: url, encoding: .utf8)
            
            let trs = doc.xpath("//tr").filter { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
            
            let histories: [History] = trs[1...].compactMap { tr in
                let data: [String]? = tr.text?
                                        .split(separator: "\n")
                                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                        .filter { $0 != "" }
                return data.map { History(userId: userId, data: $0) }
            }
            return histories
        } catch {
            print(error)
            return []
        }
    }
}

extension History: Migration { }

extension History: Content { }

extension History: Parameter { }
