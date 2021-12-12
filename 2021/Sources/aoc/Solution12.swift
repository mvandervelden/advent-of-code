class Solution12: Solving {
  enum Node: CustomStringConvertible, Hashable {
    case start
    case end
    case large(String)
    case small(String)

    init(string: String) {
      switch string {
      case "start":
        self = .start
      case "end":
        self = .end
      case _ where string.uppercased() == string:
        self = .large(string)
      default:
        self = .small(string)
      }
    }

    var description: String {
      switch self {
      case .start: return "start"
      case .end: return "end"
      case .large(let id), .small(let id): return id
      }
    }
  }

  let file: File
  var edges: [[Node]] = []

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    edges = file.lines.map { $0.split(separator: "-").map(String.init).map(Node.init) }

    let paths = search(path: [.start], visited: [.start], twiceUsed: true)

    return paths.count.description
  }

  func solve2() -> String {
    edges = file.lines.map { $0.split(separator: "-").map(String.init).map(Node.init) }

    let paths = search(path: [.start], visited: [.start], twiceUsed: false)

    return paths.count.description
  }

  private func search(path: [Node], visited: Set<Node>, twiceUsed: Bool) -> Set<[Node]> {
    let node = path.last!

    if node == .end {
      return [path]
    }

    var paths: Set<[Node]> = []

    for next in getAdjacent(node) {
      let isVisited = visited.contains(next)

      if isVisited && twiceUsed { continue }
      if case .start = next { continue }

      switch next {
      case .large:
        paths = paths.union(search(path: path + [next], visited: visited, twiceUsed: twiceUsed))
      case .small where isVisited:
        paths = paths.union(search(path: path + [next], visited: visited.union([next]), twiceUsed: true))
      default:
        paths = paths.union(search(path: path + [next], visited: visited.union([next]), twiceUsed: twiceUsed))
      }
    }

    return paths
  }

  private func getAdjacent(_ node: Node) -> [Node] {
    var adjacents: [Node] = []
    for edge in edges {
      if edge[0] == node { adjacents.append(edge[1]) }
      if edge[1] == node { adjacents.append(edge[0]) }
    }
    return adjacents
  }
}
