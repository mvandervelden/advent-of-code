class Solution17: Solving {
  class Part1 {
    typealias State = [Int: [Int: [Int: Character]]]

    let file: File
    var state: State = [:]
    var previous: State = [:]

    var zRange: ClosedRange<Int> {
      state.keys.min()!...state.keys.max()!
    }

    var yRange: ClosedRange<Int> {
      let ys = state.values.flatMap { $0.keys }
      return ys.min()!...ys.max()!
    }

    var xRange: ClosedRange<Int> {
      let xs = state.values.flatMap { $0.values.flatMap { $0.keys } }
      return xs.min()!...xs.max()!
    }

    var zPlusRange: ClosedRange<Int> {
      let range = zRange
      return (range.first! - 1)...(range.last! + 1)
    }

    var yPlusRange: ClosedRange<Int> {
      let range = yRange
      return (range.first! - 1)...(range.last! + 1)
    }

    var xPlusRange: ClosedRange<Int> {
      let range = xRange
      return (range.first! - 1)...(range.last! + 1)
    }

    required init(file: File) {
      self.file = file
      let initialState = file.charsByLine
      state[0] = [:]
      for (y, line) in initialState.enumerated() {
        state[0]![y] = [:]
        for (x, item) in line.enumerated() {
          state[0]![y]![x] = item
        }
      }
    }

    func solve(iterations: Int) -> String {
      for _ in 0..<iterations {
        previous = state

        for z in zPlusRange {
          for y in yPlusRange {
            for x in xPlusRange {
              switch previous[z]?[y]?[x] {
              case "#":
                let actives = lookupAdjacent(x: x, y: y, z: z)
                if !(actives == 3 || actives == 4) {
                  // if z == 0 { print("toggling (\(x),\(y),\(z)) (prev: \(previous[z]?[y]?[x] ?? "_")) to . (actives: \(actives))") }
                  state[z]![y]![x] = "."
                }
              case ".", .none:
                let actives = lookupAdjacent(x: x, y: y, z: z)
                if actives == 3 {
                  // if z == 0 { print("toggling (\(x),\(y),\(z)) (prev: \(previous[z]?[y]?[x] ?? "_")) to #") }
                  state[z, default: [:]][y, default: [:]][x] = "#"
                }
              default: continue
              }
            }
          }
        }
        printState(state)
      }
      let occupiedCount = zRange.reduce(0) { (zSum: Int, z: Int) -> Int in
        return zSum + yRange.reduce(0) { (ySum: Int, y: Int) -> Int in
          return ySum + xRange.reduce(0) { (xSum: Int, x: Int) -> Int in
            return xSum + ((state[z]?[y]?[x] ?? "." == "#") ? 1 : 0)
          }
        }
      }
      return occupiedCount.description
    }

    func lookupAdjacent(x: Int, y: Int, z: Int) -> Int {
      var active = 0
      for zz in (z - 1)...(z + 1) {
        for yy in (y - 1)...(y + 1) {
          for xx in (x - 1)...(x + 1) {
            let item = previous[zz]?[yy]?[xx]
            if item == "#" {
              active += 1
            }
          }
        }
      }
      return active
    }

    func printState(_ state: State) {
      for z in zRange {
        print("z=\(z)")
        for y in yRange {
          for x in xRange {
            print(state[z]?[y]?[x] ?? ".", terminator: "")
          }
          print()
        }
        print()
      }
      print()
    }
  }

  class Part2 {
    typealias State = [Int: [Int: [Int: [Int: Character]]]]

    let file: File
    var state: State = [:]
    var previous: State = [:]

    var wRange: ClosedRange<Int> {
      state.keys.min()!...state.keys.max()!
    }

    var zRange: ClosedRange<Int> {
      let zs = state.values.flatMap { $0.keys }
      return zs.min()!...zs.max()!
    }

    var yRange: ClosedRange<Int> {
      let ys = state.values.flatMap { $0.values.flatMap { $0.keys } }
      return ys.min()!...ys.max()!
    }

    var xRange: ClosedRange<Int> {
      let xs = state.values.flatMap { $0.values.flatMap { $0.values.flatMap { $0.keys } } }
      return xs.min()!...xs.max()!
    }

    var wPlusRange: ClosedRange<Int> {
      let range = wRange
      return (range.first! - 1)...(range.last! + 1)
    }

    var zPlusRange: ClosedRange<Int> {
      let range = zRange
      return (range.first! - 1)...(range.last! + 1)
    }

    var yPlusRange: ClosedRange<Int> {
      let range = yRange
      return (range.first! - 1)...(range.last! + 1)
    }

    var xPlusRange: ClosedRange<Int> {
      let range = xRange
      return (range.first! - 1)...(range.last! + 1)
    }

    required init(file: File) {
      self.file = file
      let initialState = file.charsByLine
      state[0] = [:]
      state[0]![0] = [:]
      for (y, line) in initialState.enumerated() {
        state[0]![0]![y] = [:]
        for (x, item) in line.enumerated() {
          state[0]![0]![y]![x] = item
        }
      }
    }

    func solve(iterations: Int) -> String {
      for _ in 0..<iterations {
        previous = state

        for w in wPlusRange {
          for z in zPlusRange {
            for y in yPlusRange {
              for x in xPlusRange {
                switch previous[w]?[z]?[y]?[x] {
                case "#":
                  let actives = lookupAdjacent(x: x, y: y, z: z, w: w)
                  if !(actives == 3 || actives == 4) {
                    // if z == 0 { print("toggling (\(x),\(y),\(z)) (prev: \(previous[z]?[y]?[x] ?? "_")) to . (actives: \(actives))") }
                    state[w]![z]![y]![x] = "."
                  }
                case ".", .none:
                  let actives = lookupAdjacent(x: x, y: y, z: z, w: w)
                  if actives == 3 {
                    // if z == 0 { print("toggling (\(x),\(y),\(z)) (prev: \(previous[z]?[y]?[x] ?? "_")) to #") }
                    state[w, default: [:]][z, default: [:]][y, default: [:]][x] = "#"
                  }
                default: continue
                }
              }
            }
          }
        }
        printState(state)
      }
      let occupiedCount = wRange.reduce(0) { (wSum: Int, w: Int) -> Int in
        return wSum + zRange.reduce(0) { (zSum: Int, z: Int) -> Int in
          return zSum + yRange.reduce(0) { (ySum: Int, y: Int) -> Int in
            return ySum + xRange.reduce(0) { (xSum: Int, x: Int) -> Int in
              return xSum + ((state[w]?[z]?[y]?[x] ?? "." == "#") ? 1 : 0)
            }
          }
        }
      }
      return occupiedCount.description
    }

    func lookupAdjacent(x: Int, y: Int, z: Int, w: Int) -> Int {
      var active = 0
      for ww in (w - 1)...(w + 1) {
        for zz in (z - 1)...(z + 1) {
          for yy in (y - 1)...(y + 1) {
            for xx in (x - 1)...(x + 1) {
              let item = previous[ww]?[zz]?[yy]?[xx]
              if item == "#" {
                active += 1
              }
            }
          }
        }
      }
      return active
    }

    func printState(_ state: State) {
      for w in wRange {
        for z in zRange {
          print("z=\(z) w=\(w)")
          for y in yRange {
            for x in xRange {
              print(state[w]?[z]?[y]?[x] ?? ".", terminator: "")
            }
            print()
          }
          print()
        }
      print()
      }
    }
  }

  let part1: Part1
  let part2: Part2

  required init(file: File) {
    part1 = Part1(file: file)
    part2 = Part2(file: file)
  }

  func solve1() -> String {
    return part1.solve(iterations: 6)
  }

  func solve2() -> String {
    return part2.solve(iterations: 6)
  }
}
