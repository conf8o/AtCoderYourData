struct Path: CustomStringConvertible {
    var path: String
    var description: String {
        return "\(ROOT_URL)/\(self.path)"
    }
    
    func grouped(_ path: String) -> Path {
        return Path(path: "\(self.path)/\(path)")
    }
    
    func append(_ path: String) -> Path {
        return self.grouped(path)
    }
}
