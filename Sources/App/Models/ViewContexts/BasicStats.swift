import Vapor

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
