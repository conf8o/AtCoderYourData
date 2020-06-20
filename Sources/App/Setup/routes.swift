import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("", use: index)
    try router.register(collection: HistoryAPIController())
    try router.register(collection: HistoryViewController())
}

fileprivate func index(_ req: Request) throws -> Future<View> {
    return try req.view().render("body/index")
}
