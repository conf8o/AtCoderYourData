
import Vapor

final class HistoryViewController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("data")
        group.get(String.parameter, use: data)
    }
}


extension HistoryViewController {
    func data(_ req: Request) throws -> Future<View> {
        let userId = try req.parameters.next(String.self)
        let stats1 = BasicStats(title: "test", mean: 1.0, std: 1.0, min: 1.0, lowMid: 1.0, mid: 1.0, highMid: 1.0, max: 1.0)
        let stats2 = BasicStats(title: "test", mean: 1.0, std: 1.0, min: 1.0, lowMid: 1.0, mid: 1.0, highMid: 1.0, max: 1.0)
        
        let csv = ConcreteData(type: "CSV", columnsBase: "a,a,a", rowsBase: "aaa")
        let tab = ConcreteData(type: "TAB", columnsBase: "a    a    a", rowsBase: "a    a    a")
        
        let contents = BodyContents(basicStatsList: [stats1, stats2], concreteDataList: [csv, tab])
        return try req.view().render("body/contents", contents)
    }
}
