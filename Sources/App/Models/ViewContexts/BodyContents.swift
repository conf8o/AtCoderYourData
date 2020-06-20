struct BodyContents: Encodable {
    var basicStatsList: [BasicStats]
    var concreteDataList: [ConcreteData]
}

struct BasicStats: Encodable {
    var title: String
    var mean: Double
    var std: Double
    var min: Double
    var lowMid: Double
    var mid: Double
    var highMid: Double
    var max: Double
}

struct ConcreteData: Encodable {
    var type: String
    var columnsBase: String
    var rowsBase: String
}
