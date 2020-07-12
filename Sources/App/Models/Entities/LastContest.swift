import FluentSQLite
import Vapor
import Kanna

final class LastContest: SQLiteModel {
    typealias Database = SQLiteDatabase
    
    var id: Int?
    var date: Date?
    
    init(id: Int?, date: Date) {
        self.id = id
        self.date = date
    }
    
    init(year: Int, month: Int, day: Int) {
        self.id = nil
        self.date = DateComponents(calendar: .current, year: year, month: month, day: day).date
    }
    
    static func fromAtCoder() -> LastContest? {
        do {
            guard let url = URL(string: "https://atcoder.jp/contests/") else { return nil }
            let doc = try HTML(url: url, encoding: .utf8)
            
            guard var recent = doc.xpath("//div[@id='contest-table-recent']//tbody//tr").first?.text else {
                print("No result")
                return nil
            }
            
            recent = recent.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")[0].description
            
            var date = recent.split(separator: "-").makeIterator()
            guard let year = date.next(), let month = date.next(), let day = date.next() else { return nil }
            guard let y = Int(year), let m = Int(month), let d = Int(day) else { return nil }
            
            return LastContest(year: y, month: m, day: d)
            
        } catch {
            print(error)
            return nil
        }
    }
    
    static func updated(conn: DatabaseConnectable) -> Future<Bool> {
        return LastContest.query(on: conn).first().map { contest in
            guard let lastContest = LastContest.fromAtCoder() else { return false }
            
            guard let contest = contest else {
                lastContest.create(on: conn).whenComplete {}
                return true
            }
            return contest.date != lastContest.date
        }
    }
}

extension LastContest: Migration { }

extension LastContest: Content { }

extension LastContest: Parameter { }
