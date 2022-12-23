typealias LazyGrid = [Int: [Int: Character]]

extension LazyGrid {
  var minY: Int { keys.min() ?? 0 }
  var maxY: Int { keys.max() ?? 0 }
  var minX: Int { values.compactMap { line in line.keys.min() }.min() ?? 0 }
  var maxX: Int { values.compactMap { line in line.keys.max() }.max() ?? 0 }

  var prettyDescription: String {
    (minY...maxY).map { y in
      String((minX...maxX).map { x in
        return self[y]?[x] ?? "."
      })
    }.joined(separator: "\n")
  }
}
