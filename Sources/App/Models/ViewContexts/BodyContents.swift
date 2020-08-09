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
        let stats = stats.mapValues { Double(String(format: "%.2f", $0)) ?? 0.0 }
        self.title = title
        self.mean = stats["mean"] ?? 0.0
        self.std = stats["std"] ?? 0.0
        self.min = stats["min"] ?? 0.0
        self.medianLow = stats["medianLow"] ?? 0.0
        self.median = stats["median"] ?? 0.0
        self.medianHigh = stats["medianHigh"] ?? 0.0
        self.max = stats["max"] ?? 0.0
    }
}

struct ConcreteData: Encodable {
    var type: String
    var columnsBase: String
    var rowsBase: String
    var columnsURL: String
    var rowsURL: String
}
