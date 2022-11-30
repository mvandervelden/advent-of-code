extension Collection where Element == Int {
    func sum() -> Int { reduce(0, +) }
    func product() -> Int { reduce(1, *) }
}

extension Collection {
    func count(where test: (Element) throws -> Bool) rethrows -> Int {
        return try self.filter(test).count
    }
}