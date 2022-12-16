class Solution16: Solving {
  struct Valve: CustomStringConvertible, Hashable {
    let id: String
    let flowRate: Int
    let connections: [String]

    init(match: [String]) {
      id = match[1]
      flowRate = Int(match[2])!
      connections = Array(match[3].components(separatedBy: ", "))
    }

    var description: String { "\(id) [\(flowRate)] -> \(connections.joined(separator: ","))" }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let pattern = #"Valve ([A-Z][A-Z]) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)"#

    let valves = file.lines.map { line in
      let match = line.matchFirst(pattern: pattern)
      return Valve(match: match)
    }

    let map = Map(valves: valves)
    let astar = AStar(map: map)
    let startValve = valves.first { $0.id == "AA" }!
    let startPos = Position(valve: startValve,
                           openValves: [],
                           totalFlow: 0,
                           flowRate: 0,
                           minutesLeft: 30,
                           isGoal: false)
    let goalPos = Position(valve: startValve,
                           openValves: valves.map(\.id),
                           totalFlow: Int.max / 2,
                           flowRate: Int.max / 2,
                           minutesLeft: 0,
                           isGoal: true)
    let path = astar.astar(start: startPos, goal: goalPos)
    print()
    return path!.map(\.description).joined(separator: "\n")
  }

  func solve2() -> String {
    return file.filename
  }

  struct Map {
    let valves: [Valve]

    func neighbors(of position: Position) -> [(position: Position, cost: Int)] {
      let neighbors = position.valve.connections.map { id in
        let valve = valves.first { $0.id == id }!
        let position = Position(valve: valve,
                                openValves: position.openValves,
                                totalFlow: position.totalFlow + position.flowRate,
                                flowRate: position.flowRate,
                                minutesLeft: position.minutesLeft - 1,
                                isGoal: false)
        return (position: position, cost: 1)
      }

      if let o = position.openNeighbor {
        return [(position: o, cost: 1-position.totalFlow)] + neighbors
      }

      return neighbors
    }
  }

  struct Position: Hashable, CustomStringConvertible {
    let valve: Valve
    let openValves: [String]
    let totalFlow: Int
    let flowRate: Int
    let minutesLeft: Int
    let isGoal: Bool

    var isOpen: Bool { openValves.contains(valve.id) }

    func heuristicEstimate(to goal: Self) -> Int {
      return goal.totalFlow - totalFlow
    }

    var openNeighbor: Position? {
      if isOpen { return nil }
      return Position(valve: valve,
                      openValves: openValves + [valve.id],
                      totalFlow: totalFlow + flowRate + valve.flowRate,
                      flowRate: flowRate + valve.flowRate,
                      minutesLeft: minutesLeft - 1,
                      isGoal: false)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
      if lhs.isGoal { return rhs.minutesLeft == 0 }
      if rhs.isGoal { return lhs.minutesLeft == 0 }

      return lhs.valve == rhs.valve &&
             lhs.openValves == rhs.openValves &&
             lhs.totalFlow == rhs.totalFlow &&
             lhs.flowRate == rhs.flowRate &&
             lhs.minutesLeft == rhs.minutesLeft
    }

    var description: String {
      return "open: \(openValves), current: \(valve.description), flow: \(flowRate), total: \(totalFlow), minutesLeft: \(minutesLeft)"
    }
  }

  class AStar {
    let map: Map

    init(map: Map) {
      self.map = map
    }

    func astar(start: Position, goal: Position) -> [Position]? {
      var closedSet: Set<Position> = []
      var openSet: Set<Position> = [start]
      var cameFrom: [Position: Position] = [:]
      var gScore: [Position: Int] = [start: 0]
      var fScore: [Position: Int] = [start: heuristicEstimate(start: start, goal: goal)]

      while !openSet.isEmpty {
        let current = openSet.min {
          let lhsScore = fScore[$0] ?? Int.max
          let rhsScore = fScore[$1] ?? Int.max
          return lhsScore < rhsScore
        }!

        if current == goal {
          print("total cost: ", gScore[current]!)
          return reconstruct(cameFrom, current: current)
        }

        openSet.remove(current)
        closedSet.insert(current)
        print("cur", current)
        for neighbor in neighbors(current) {
          // print("nbr", neighbor)
          if closedSet.contains(neighbor.position) {
            continue
          }

          let tentativeG = gScore[current]! + neighbor.cost
          if !openSet.contains(neighbor.position) {
            openSet.insert(neighbor.position)
          } else if tentativeG >= gScore[neighbor.position] ?? Int.max {
            continue
          }

          cameFrom[neighbor.position] = current
          gScore[neighbor.position] = tentativeG
          fScore[neighbor.position] = tentativeG + heuristicEstimate(start: neighbor.position, goal: goal)
        }
      }

      return nil
    }

    private func heuristicEstimate(start: Position, goal: Position) -> Int {
      return start.heuristicEstimate(to: goal)
    }

    private func reconstruct(_ cameFrom: [Position: Position], current: Position) -> [Position] {
      var current = current
      var totalPath = [current]
      while cameFrom[current] != nil {
        current = cameFrom[current]!
        totalPath.append(current)
      }
      return totalPath
    }

    private func neighbors(_ position: Position) -> [(position: Position, cost: Int)] {
      return map.neighbors(of: position)
    }
  }
}