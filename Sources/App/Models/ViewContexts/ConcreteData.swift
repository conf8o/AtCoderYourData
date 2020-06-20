import Vapor

struct ConcreteData: Encodable {
    var type: String
    var columnsBase: String
    var rowsBase: String
}
