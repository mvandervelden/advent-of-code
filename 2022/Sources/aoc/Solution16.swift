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

  func solve1() -> String {
    let pattern = #"Valve ([A-Z][A-Z]) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)"#

    let valves = file.lines.enumerated().map { i, line in
      let match = line.matchFirst(pattern: pattern)
      return Valve(match: match, index: i+1)
    }

    let startValve = valves.first { $0.id == "AA" }!

    let startState = State(minLeft: 30, curValve: startValve.index, valves: OpenValveSet.with(indices: []))
    var states: [State: [State: (Int, [State])]] = [:]
    Solution16.valveFlow = valves.map(\.flowRate)

    states[startState] = [startState: (0, [startState])]

    //var curState = startState
    var nextStateSet = Set([startState])

    for i in 0..<30 {
      // print(i, nextStateSet)
      print(states[startState]!)
      let curStateSet = nextStateSet
      nextStateSet = []

      for state in curStateSet {
        let valve = valves.first { $0.index == state.curValve }!
        let flowToHere = states[startState]![state]!

        if !state.valves.contains(OpenValveSet(rawValue: valve.index)) {
          var valveSet = state.valves
          valveSet.insert(OpenValveSet(rawValue: valve.index))
          let openValveState = State(minLeft: state.minLeft - 1, curValve: state.curValve, valves: valveSet)
          nextStateSet.insert(openValveState)

          let newFlow = flowToHere.0 + openValveState.flowRate

          if let existingStateRate = states[state]?[openValveState]?.0, existingStateRate > newFlow {
          } else {
            states[state, default: [:]][openValveState] = (newFlow, flowToHere.1 + [openValveState])
          }

          if let existingRate = states[startState]?[openValveState]?.0, existingRate > newFlow {
          } else {
            states[startState, default: [:]][openValveState] = (newFlow, flowToHere.1 + [openValveState])
          }
        }

        let nextValves = valve.connections.map { str in valves.first { $0.id == str }! }

        for nextValve in nextValves {
          let nextState = State(minLeft: state.minLeft - 1, curValve: nextValve.index, valves: state.valves)
          nextStateSet.insert(nextState)

          let newFlow = flowToHere.0 + nextState.flowRate

          if let existingStateRate = states[state]?[nextState]?.0, existingStateRate > newFlow {
          } else {
            states[state, default: [:]][nextState] = (newFlow, flowToHere.1 + [nextState])
          }

          if let existingRate = states[startState]?[nextState]?.0, existingRate > newFlow {
          } else {
            states[startState, default: [:]][nextState] = (newFlow, flowToHere.1 + [nextState])
          }
        }
      }
    }

    let max = states[startState]!.values.max { $0.0 < $1.0 }

    return "\(max!.0.description)\n\(max!.1.map(\.description).joined(separator: "\n"))"
  }

  func solve2() -> String {
    return file.filename
  }

  func dp() {
    // var dist = Array(repeating: Array(repeating: Int.min, count: state.count), count: state.count)

    // for t in
  }

  struct State: Hashable, CustomStringConvertible {
    let minLeft: Int
    let curValve: Int
    let valves: OpenValveSet
    // let totalFlow: Int

    // func hash(into hasher: inout Hasher) {
    //     hasher.combine(minLeft)
    //     hasher.combine(curValves)
    //     hasher.combine(valves)
    // }

    var description: String {
      "(valve: \(curValve), min: \(minLeft), valves: \(valves)) -> \(flowRate)"
    }

    var flowRate: Int {
      Solution16.valveFlow.enumerated().filter { i, valve in valves.contains(OpenValveSet(rawValue: i+1)) }.map { $1 }.sum()
    }
  }

  struct OpenValveSet: OptionSet, Hashable, CustomStringConvertible {
    let rawValue: Int

    static func with(indices: [Int]) -> OpenValveSet {
      var set = OpenValveSet(rawValue: 0)

      indices.forEach { index in
        set.insert(OpenValveSet(rawValue: 1 << index))
      }

      return set
    }

    var description: String {
      return String(rawValue, radix: 2)
    }
  }
}