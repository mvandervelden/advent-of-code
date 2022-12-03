extension Collection where Element == Int {
    func sum() -> Int { reduce(0, +) }
    func product() -> Int { reduce(1, *) }
}

extension Collection {
    func count(where test: (Element) throws -> Bool) rethrows -> Int {
        return try self.filter(test).count
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
