class Solution19: Solving {
  struct BluePrint: CustomStringConvertible {
    let id: Int
    let ore: Int
    let clay: Int
    let obsOre: Int
    let obsClay: Int
    let geoOre: Int
    let geoObs: Int

    init(_ match: [String]) {
      id = Int(match[1])!
      ore = Int(match[2])!
      clay = Int(match[3])!
      obsOre = Int(match[4])!
      obsClay = Int(match[5])!
      geoOre = Int(match[6])!
      geoObs = Int(match[7])!
    }

    var description: String {
      return "\(id): Orebot \(ore), Claybot \(clay), ObsBot \(obsOre) ore + \(obsClay) clay, GeoBot \(geoOre) ore + \(geoObs) obs"
    }
  }

  struct State: CustomStringConvertible, Hashable, Equatable {
    let blueprint: BluePrint

    var minute = 0

    var ore = 0
    var clay = 0
    var obs = 0
    var geo = 0

    var oreBots = 1
    var clayBots = 0
    var obsBots = 0
    var geoBots = 0

    // func nextStates() -> [(State, Int)] {
    //   var states: [State] = [(passMinute(), 0)]

    //   if ore >= blueprint.ore {
    //     states.append((passMinute(addOreBot: true), 1))
    //   }
    //   if ore >= blueprint.clay {
    //     states.append((passMinute(addClayBot: true), 2))
    //   }
    //   if ore >= blueprint.obsOre && clay >= blueprint.obsClay {
    //     states.append((passMinute(addObsBot: true), 3))
    //   }
    //   if ore >= blueprint.geoOre && obs >= blueprint.geoObs {
    //     states.append((passMinute(addGeoBot: true), 4))
    //   }

    //   return states
    // }

    func nextStates() -> [State] {
      var states: [State] = [passMinute()]

      if ore >= blueprint.ore {
        states.append(passMinute(addOreBot: true))
      }
      if ore >= blueprint.clay {
        states.append(passMinute(addClayBot: true))
      }
      if ore >= blueprint.obsOre && clay >= blueprint.obsClay {
        states.append(passMinute(addObsBot: true))
      }
      if ore >= blueprint.geoOre && obs >= blueprint.geoObs {
        states.append(passMinute(addGeoBot: true))
      }

      return states
    }

    func passMinute(addOreBot: Bool = false, addClayBot: Bool = false, addObsBot: Bool = false, addGeoBot: Bool = false) -> State {
      var state = self
      state.minute += 1

      if addOreBot {
        state.ore -= blueprint.ore
        state.oreBots += 1
      } else if addClayBot {
        state.ore -= blueprint.clay
        state.clayBots += 1
      } else if addObsBot {
        state.ore -= blueprint.obsOre
        state.clay -= blueprint.obsClay
        state.obsBots += 1
      } else if addGeoBot {
        state.ore -= blueprint.geoOre
        state.obs -= blueprint.geoObs
        state.geoBots += 1
      }

      state.ore += oreBots
      state.clay += clayBots
      state.obs += obsBots
      state.geo += geoBots

      return state
    }

    var cost: Int {
      if clayBots == 0 {
        return blueprint.clay - clay + blueprint.obsOre + blueprint.obsClay + blueprint.geoOre + blueprint.geoObs
      }

      if obsBots == 0 {
        return blueprint.obsOre - ore + blueprint.obsClay - clay + blueprint.geoOre + blueprint.geoObs
      }

      if geoBots == 0 {
        return blueprint.geoOre - ore + blueprint.geoObs - obs
      }

      return -geo
    }

    var description: String {
      "min \(minute): \(ore) ore, \(clay) clay, \(obs) obs, \(geo) geo --- \(oreBots) oreBots, \(clayBots) clayBots, \(obsBots) obsBots, \(geoBots) geoBots"
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(minute)

      hasher.combine(ore)
      hasher.combine(clay)
      hasher.combine(obs)
      hasher.combine(geo)

      hasher.combine(oreBots)
      hasher.combine(clayBots)
      hasher.combine(obsBots)
      hasher.combine(geoBots)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.minute == rhs.minute &&
        lhs.ore == rhs.ore &&
        lhs.clay == rhs.clay &&
        lhs.obs == rhs.obs &&
        lhs.geo == rhs.geo &&
        lhs.oreBots == rhs.oreBots &&
        lhs.clayBots == rhs.clayBots &&
        lhs.obsBots == rhs.obsBots &&
        lhs.geoBots == rhs.geoBots
    }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let pattern = #"Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian."#

    let blueprints = file.lines.map {
      let match = $0.matchFirst(pattern: pattern)
      return BluePrint(match)
    }

    let astar = AStar()

    for bprint in blueprints {
      let state = State(blueprint: bprint)
      let path = astar.astar(start: state, minutes: 24)

      print(path)
      print(path!.map(\.description).joined(separator: "\n"))
    }

    return blueprints.map(\.description).joined(separator: "\n")
  }

  func solve2() -> String {
    return file.filename
  }

  class AStar {
    func astar(start: State, minutes: Int = 24) -> [State]? {
      var closedSet: Set<State> = []
      var openSet: Set<State> = [start]
      var cameFrom: [State: State] = [:]
      var gScore: [State: Int] = [start: 0]
      var fScore: [State: Int] = [start: heuristicEstimate(start: start, goal: minutes)]

      while !openSet.isEmpty {
        let current = openSet.min {
          let lhsScore = fScore[$0] ?? Int.max
          let rhsScore = fScore[$1] ?? Int.max
          return lhsScore < rhsScore
        }!

        print("current", current)
        if current.minute == minutes {
          print("total cost: ", gScore[current]!)
          return reconstruct(cameFrom, current: current)
        }

        openSet.remove(current)
        closedSet.insert(current)

        for neighbor in neighbors(current) {
          if closedSet.contains(neighbor.loc) {
            continue
          }

          let tentativeG = gScore[current]! + neighbor.cost

          if !openSet.contains(neighbor.loc) {
            openSet.insert(neighbor.loc)
          } else if tentativeG >= gScore[neighbor.loc] ?? Int.max {
            continue
          }

          cameFrom[neighbor.loc] = current
          gScore[neighbor.loc] = tentativeG
          fScore[neighbor.loc] = tentativeG + heuristicEstimate(start: neighbor.loc, goal: minutes)
        }
      }

      return nil
    }

    private func heuristicEstimate(start: State, goal: Int) -> Int {
      start.cost
    }

    private func reconstruct(_ cameFrom: [State: State], current: State) -> [State] {
      var current = current
      var totalPath = [current]
      while cameFrom[current] != nil {
        current = cameFrom[current]!
        totalPath.append(current)
      }
      return totalPath
    }

    private func neighbors(_ loc: State) -> [(loc: State, cost: Int)] {
      var locs: [(loc: State, cost: Int)] = []

      let currentValue = loc.cost

      let neighborStates = loc.nextStates()

      for st in neighborStates {
        let newValue = st.cost
        if newValue < currentValue {
          locs.append((loc: st, cost: newValue))
        }
      }

      return locs
    }
  }
}

