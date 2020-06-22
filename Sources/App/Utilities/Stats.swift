import Foundation

extension Array where Self.Element == Double{
    func mean() -> Double {
        return reduce(0, +) / Double(count)
    }
    
    func std(knownMean: Double? = nil) -> Double {
        let m = knownMean ?? mean()
        return sqrt(reduce(0) { $0 + pow(m - $1, 2.0)} / Double(count))
    }
    
    func medianLow(alreadySorted: Bool = false) -> Double {
        let data = alreadySorted ? self : self.sorted()
        return Array(data[..<(count/2)]).median()
    }
    
    func median(alreadySorted: Bool = false) -> Double {
        let data = alreadySorted ? self : self.sorted()
        if count % 2 == 0 {
            let r = data[count/2]
            let l = data[count/2-1]
            return (r + l) / 2
        } else {
            return data[count/2]
        }
    }
    
    func medianHigh(alreadySorted: Bool = false) -> Double {
        let data = alreadySorted ? self : self.sorted()
        let add = count % 2
        return Array(data[(count/2+add)...]).median()
    }
    
    func describe() -> [String: Double]{
        let data = sorted()
        var stats = [String: Double]()
        let m = data.mean()
        stats["mean"] = m
        stats["std"] = data.std(knownMean: m)
        stats["min"] = data.first!
        stats["medianLow"] = data.medianLow(alreadySorted: true)
        stats["median"] = data.median(alreadySorted: true)
        stats["medianHigh"] = data.medianHigh(alreadySorted: true)
        stats["max"] = data.last!
        return stats
    }
}
