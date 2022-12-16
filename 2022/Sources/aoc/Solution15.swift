class Solution15: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let pattern = #"Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)"#

    let targetY = file.filename == "input.txt" ? 2_000_000 : 10

    let pairs: [(sensor: Point2D, beacon: Point2D)] = file.lines.map { line in
      let match = line.matchFirst(pattern: pattern)

      return (sensor: Point2D(x: Int(match[1])!, y: Int(match[2])!),
              beacon: Point2D(x: Int(match[3])!, y: Int(match[4])!))
    }

    var xes: Set<Int> = []

    for (sensor, beacon) in pairs {
      let d = sensor.manhattanDist(to: beacon)
      guard (sensor.y-d)...(sensor.y+d) ~= targetY else { continue }

      let mx = sensor.y < targetY ? 1 : -1
      let dFromTarget = abs(sensor.y + (mx * d) - targetY)

      xes = xes.union(Set(sensor.x-dFromTarget...sensor.x+dFromTarget))

      if beacon.y == targetY { xes.remove(beacon.x) }
    }

    return xes.count.description
  }

  func solve2() -> String {
    let pattern = #"Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)"#

    let targetRange = file.filename == "input.txt" ? 4_000_000 : 20

    let pairs: [(sensor: Point2D, beacon: Point2D)] = file.lines.map { line in
      let match = line.matchFirst(pattern: pattern)

      return (sensor: Point2D(x: Int(match[1])!, y: Int(match[2])!),
              beacon: Point2D(x: Int(match[3])!, y: Int(match[4])!))
    }

    var result: Point2D? = nil

    for targetY in 0...targetRange {
      var xes: [ClosedRange<Int>] = []

      for (sensor, beacon) in pairs {
        let d = sensor.manhattanDist(to: beacon)
        guard (sensor.y-d)...(sensor.y+d) ~= targetY else { continue }

        let mx = sensor.y < targetY ? 1 : -1
        let dFromTarget = abs(sensor.y + (mx * d) - targetY)

        xes = xes.union(max(0,sensor.x-dFromTarget)...min(targetRange,sensor.x+dFromTarget))
      }

      if xes.count > 1 {
        print("found")
        let x = xes[0].upperBound + 1
        result = Point2D(x: x, y: targetY)
        break
      }
    }

    return (result!.x * 4_000_000 + result!.y).description
  }
}

extension Array<ClosedRange<Int>> {
  func union(_ range: ClosedRange<Int>) -> Array<ClosedRange<Int>> {
    var range = range
    if isEmpty { return [range] }
    if range.upperBound < self[0].lowerBound { return [range] + self }
    if range.lowerBound > self.last!.upperBound { return self + [range] }

    var result: Array<ClosedRange<Int>> = []

    for (i, r) in enumerated() {
      if !range.overlaps(r) {
        if range.upperBound < r.lowerBound {
          // RRR...rrr
          result.append(range)
          result.append(contentsOf: self[i...])
          break
        } else {
          // rrr...RRR
          result.append(r)
        }
      } else if range.lowerBound >= r.lowerBound && range.upperBound <= r.upperBound {
        // rrrrr
        // .RRR.
        result.append(contentsOf: self[i...])
        break
      } else if range.lowerBound <= r.lowerBound && range.upperBound >= r.upperBound {
        // .rrr.
        // RRRRR
        continue
      } else if range.lowerBound >= r.lowerBound && range.upperBound > r.upperBound {
        // rrrrr..
        // ..RRRRR
        range = r.joined(with: range)
      } else if range.lowerBound < r.lowerBound && range.upperBound <= r.upperBound {
        // ..rrrrr
        // RRRRR..
        range = range.joined(with: r)
      }
    }

    if result.isEmpty || range.lowerBound > result.last!.upperBound {
      result.append(range)
    }

    return result
  }
}

extension ClosedRange<Int> {
  func joined(with other: ClosedRange<Int>) -> ClosedRange<Int> {
    return lowerBound...other.upperBound
  }
}
