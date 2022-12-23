import SwiftGraph

class Solution16: Solving {
  struct Valve: CustomStringConvertible, Hashable {
    let index: Int
    let id: String
    let flowRate: Int
    let connections: [String]

    init(match: [String], index: Int) {
      self.index = index
      id = match[1]
      flowRate = Int(match[2])!
      connections = Array(match[3].components(separatedBy: ", "))
    }

    var description: String { "\(index): \(id) [\(flowRate)] -> \(connections.joined(separator: ","))" }
  }

  static var valveFlow: [Int] = []

  let file: File

  required init(file: File) {
    self.file = file
  }

  var valvesDict: [String: Int] = [:]
  var g: WeightedGraph<String, Int>!
  var distances: [String: [Int]] = [:]

  func solve1() -> String {
    let pattern = #"Valve ([A-Z][A-Z]) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)"#

    let valves = file.lines.enumerated().map { i, line in
      let match = line.matchFirst(pattern: pattern)
      return Valve(match: match, index: i+1)
    }

    for valve in valves {
      valvesDict[valve.id] = valve.flowRate
    }

    g = WeightedGraph<String, Int>(vertices: Array(valvesDict.keys))

    for valve in valves {
      for connection in valve.connections {
        if !g.edgeExists(from: valve.id, to: connection) {
          g.addEdge(from: valve.id, to: connection, weight: 1)
        }
      }
    }

    print(valvesDict)
    print(g!)

    for i in 0..<g.vertices.count {
      let (d, _) = g.dijkstra(root: i, startDistance: 0)
      distances[g.vertices[i]] = d.compactMap { $0 }
    }
    print(distances)

    let paths = releasePressure(start: "AA", openValves: [:], maxMin: 30)
    var rPressures = Set<Int>()
    print(paths.count)
    for (_, _, _, _, _, released) in paths {
      if released > 1000 {
        rPressures.insert(released)
      }
    }
    print("part 1", rPressures.max()!)

    return ""
  }

  typealias State = (valve: String, dist: Int, open: [String: Int], moving: Bool, mins: Int, released: Int)

  private func releasePressure(start: String, openValves: [String: Int], maxMin: Int) -> [State] {
    var openValves = openValves
    let valve = start
    let paths = Queue<State>()
    paths.push((valve: valve, dist: 0, open: openValves, moving: false, mins: 0, released: 0))
    var finalPaths: [State] = []

    while !paths.isEmpty {
      var (valve, dist, _, moving, mins, _) = paths.pop()
      if moving {
        if mins + dist < maxMin + 1 {
          paths.push((valve: valve, dist: 0, open: openValves, moving: !moving, mins: mins+dist, released: 0))
        } else {
          finalPaths.append((valve: valve, dist: 0, open: openValves, moving: !moving, mins: mins, released: release(openValves, maxMin: maxMin)))
        }
      } else {
        mins += 1
        if valve != start {
          openValves[valve] = mins - 1
        }
        let nextValves = findNextValves(valve, openValves: openValves)
        if !nextValves.isEmpty {
          for next in nextValves {
            let nexts = next.split(separator: " ")
            let nextValve = String(nexts[0])
            let dist = Int(nexts[1])!
            paths.push((valve: nextValve, dist: dist, open: openValves, moving: !moving, mins: mins, released: 0))
          }
        } else {
          finalPaths.append((valve: valve, dist: 0, open: openValves, moving: !moving, mins: maxMin, released: release(openValves, maxMin: maxMin)))
        }
      }
    }
    return finalPaths
  }

  private func release(_ openValves: [String: Int], maxMin: Int) -> Int {
    var pressure = 0
    for valve in openValves.keys {
      pressure += valvesDict[valve]! * (maxMin - openValves[valve]!)
    }
    return pressure
  }

  private func findNextValves(_ start: String, openValves: [String: Int]) -> Set<(String)> {
    let nodes = Queue<(String, Set<String>)>()
    nodes.push((start, []))
    var possibleValves: Set<String> = []

    while !nodes.isEmpty {
      var (s, visited) = nodes.pop()
      visited.insert(s)
      for v in valvesDict.keys where !visited.contains(v) && v != s {
        nodes.push((v, visited))
        if openValves[v] == nil, v != start {
          possibleValves.insert("\(v) \(distances[start]![g.vertices.firstIndex(of: v)!])")
        }
      }
    }
    return possibleValves
  }

  func solve2() -> String {
    return file.filename
  }
}