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

      for x in (sensor.x-dFromTarget...sensor.x+dFromTarget) {
        xes.insert(x)
      }

      if beacon.y == targetY { xes.remove(beacon.x) }
    }
    // print(xes.sorted())
    return xes.count.description
  }

  func solve2() -> String {
    return file.filename
  }
}
