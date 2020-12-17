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
        print("z=\(z) (xmin=\(xRange.first!), ymin=\(yRange.first!)")
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
    struct Point: Hashable {
      let x, y, z, w: Int
    }

    typealias State = Set<Point>
    typealias Range = ClosedRange<Int>

    let file: File
    var state: State = []
    var previous: State = []

    func getRanges() -> (wRange: Range, zRange: Range, yRange: Range, xRange: Range) {
      var wRange = (Int.max, Int.min)
      var zRange = (Int.max, Int.min)
      var yRange = (Int.max, Int.min)
      var xRange = (Int.max, Int.min)

      for point in state {
        if point.w < wRange.0 { wRange = (point.w, wRange.1) }
        if point.w > wRange.1 { wRange = (wRange.0, point.w) }
        if point.z < zRange.0 { zRange = (point.z, zRange.1) }
        if point.z > zRange.1 { zRange = (zRange.0, point.z) }
        if point.y < yRange.0 { yRange = (point.y, yRange.1) }
        if point.y > yRange.1 { yRange = (yRange.0, point.y) }
        if point.x < xRange.0 { xRange = (point.x, xRange.1) }
        if point.x > xRange.1 { xRange = (xRange.0, point.x) }
      }

      return (wRange.0...wRange.1, zRange.0...zRange.1, yRange.0...yRange.1, xRange.0...xRange.1)
    }

    func plusRange(_ range: Range) -> Range {
      return (range.first! - 1)...(range.last! + 1)
    }

    required init(file: File) {
      self.file = file
      let initialState = file.charsByLine

      for (y, line) in initialState.enumerated() {
        for (x, item) in line.enumerated() {
          if item == "#" {
            state.insert(Point(x: x, y: y, z: 0, w: 0))
          }
        }
      }
    }

    var curWRange: Range = 0...0
    var curZRange: Range = 0...0
    var curYRange: Range = 0...0
    var curXRange: Range = 0...0

    func solve(iterations: Int) -> String {
      for _ in 0..<iterations {
        previous = state
        let ranges = getRanges()
        curWRange = ranges.wRange
        curZRange = ranges.zRange
        curYRange = ranges.yRange
        curXRange = ranges.xRange
        let curWPlusRange = plusRange(curWRange)
        let curZPlusRange = plusRange(curZRange)
        let curYPlusRange = plusRange(curYRange)
        let curXPlusRange = plusRange(curXRange)
        for w in curWPlusRange {
          for z in curZPlusRange {
            for y in curYPlusRange {
              for x in curXPlusRange {
                let point = Point(x: x, y: y, z: z, w: w)
                if previous.contains(point) {
                  let actives = lookupAdjacent(point)
                  if !(actives == 3 || actives == 4) {
                    state.remove(point)
                  }
                } else {
                  let actives = lookupAdjacent(point)
                  if actives == 3 {
                    state.insert(point)
                  }
                }
              }
            }
          }
        }
      }
      let finalRanges = getRanges()
      let occupiedCount = finalRanges.wRange.reduce(0) { (wSum: Int, w: Int) -> Int in
        return wSum + finalRanges.zRange.reduce(0) { (zSum: Int, z: Int) -> Int in
          return zSum + finalRanges.yRange.reduce(0) { (ySum: Int, y: Int) -> Int in
            return ySum + finalRanges.xRange.reduce(0) { (xSum: Int, x: Int) -> Int in
              return xSum + (state.contains(Point(x:x,y:y,z:z,w:w)) ? 1 : 0)
            }
          }
        }
      }
      return occupiedCount.description
    }

    func lookupAdjacent(_ pt: Point) -> Int {
      var active = 0
      for ww in (pt.w - 1)...(pt.w + 1) {
        for zz in (pt.z - 1)...(pt.z + 1) {
          for yy in (pt.y - 1)...(pt.y + 1) {
            for xx in (pt.x - 1)...(pt.x + 1) {
              let point = Point(x: xx, y: yy, z: zz, w: ww)
              if previous.contains(point) {
                active += 1
              }
            }
          }
        }
      }
      return active
    }

    func printState(_ state: State) {
      for w in curWRange {
        for z in curZRange {
          print("z=\(z) w=\(w)")
          for y in curYRange {
            for x in curXRange {
              print(state.contains(Point(x:x,y:y,z:z,w:w)) ? "#" : ".", terminator: "")
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
