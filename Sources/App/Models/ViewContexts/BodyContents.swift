struct BodyContents: Encodable {
    var userId: String
    var basicStatsList: [BasicStats]
    var concreteDataList: [ConcreteData]
}

struct BasicStats: Encodable {
    var title: String
    var mean: Double
    var std: Double
    var min: Double
    var medianLow: Double
    var median: Double
    var medianHigh: Double
    var max: Double
    
    init(title: String, stats: [String: Double]) {
        let stats = stats.mapValues { Double(String(format: "%.2f", $0))! }
        self.title = title
        self.mean = stats["mean"]!
        self.std = stats["std"]!
        self.min = stats["min"]!
        self.medianLow = stats["medianLow"]!
        self.median = stats["median"]!
        self.medianHigh = stats["medianHigh"]!
        self.max = stats["max"]!
    }
}

struct ConcreteData: Encodable {
    var type: String
    var columnsBase: String
    var rowsBase: String
    var columnsURL: String
    var rowsURL: String
}
