class Solution19: Solving {
  let file: File
  var map: Set<Point3D> = []
  var diffs: [Point3D.Diff: Set<Point3D>] = [:]

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    var scanners = file.linesSplitByEmptyLine.map { scanner in scanner[1...].map(Point3D.init) }

    map = Set(scanners.dropFirst()[0])

    diffs = getDiffs(map)

    while !scanners.isEmpty {
      var leftovers: [[Point3D]] = []
      for scanner in scanners {
        if !tryMap(scanner: scanner) {
          leftovers.append(scanner)
        }
      }
      scanners = leftovers
    }


    return scanners[0].description
  }

  func solve2() -> String {
    return "TBD"
  }

  private func getDiffs(_ scanner: Set<Point3D>) -> [Point3D.Diff: Set<Point3D>] {
    var diffs: [Point3D.Diff: Set<Point3D>] = [:]

    for pointA in scanner {
      for pointB in scanner where pointA != pointB {
        let diff = pointA.diff(pointB)
        diffs[diff] = [pointA, pointB]
      }
    }

    return diffs
  }

  private func tryMap(scanner: [Point3D]) -> Bool {
    var matches: [Set<Point3D>: Set<Point3D>] = [:]
    for pointA in scanner {
      for pointB in scanner where pointA != pointB {
        let diff = pointA.diff(pointB)
        if let pair = diffs[diff] {
          matches[[pointA, pointB]] = pair
        } else {
          print("checking")
          for d in diffs.keys {
            if d == diff {
              print("equal found, but not hashable")
              // matches[[pointA, pointB]] = pair
            }
          }
        }
      }
    }
    print(matches)

    if matches.count > 64 {
      let firstPair = matches.keys.first!
      let firstMatch = matches[firstPair]!
      var mapping: [Point3D: Point3D] = [:]

      for point in firstPair {
        for candidate in firstMatch {
          var mismatch = false
          for matchKey in matches.keys where matchKey.contains(point) {
            if !matches[matchKey]!.contains(candidate) { mismatch = true; break }
          }
          if mismatch == false { mapping[point] = candidate; break }
        }
      }

      _ = getTranslation(mapping) // WIP
      return true // WIP
    } else {
      return false
    }
  }

  private func getTranslation(_ mapping: [Point3D: Point3D]) -> Point3D.Diff {
  //   let pointA = mapping.keys.first!
  //   let referenceA = mapping[pointA]!
  //   let pointB = mapping.keys.last!
  //   let referenceB = mapping[pointB]!

  //   let origDiff = pointA.relDiff(pointB)
  //   let refDiff = referenceA.relDiff(referenceB)

  //   if origDiff.dx == refDiff.dx && origDiff.dy == refDiff.dy && origDiff.dz == refDiff.dz { return Point3D.Diff(dx: referenceA.x - pointA.x, dy: referenceA.y - pointA.y, dz: referenceA.z - pointA.z)  }
  //   if origDiff.dx == refDiff.dx && origDiff.dy == refDiff.dy && origDiff.dz == -refDiff.dz { return Point3D.Diff(dx: referenceA.x - pointA.x, dy: referenceA.y - pointA.y, dz: referenceA.z - pointA.z)  }
  //   if origDiff.dx == refDiff.dx && origDiff.dy == refDiff.dz && origDiff.dz == refDiff.dy {  }
  //   if origDiff.dx == refDiff.dy && origDiff.dy == refDiff.dx && origDiff.dz == refDiff.dz {  }
  //   if origDiff.dx == refDiff.dy && origDiff.dy == refDiff.dz && origDiff.dz == refDiff.dx {  }
  //   if origDiff.dx == refDiff.dz && origDiff.dy == refDiff.dx && origDiff.dz == refDiff.dy {  }
  //   if origDiff.dx == refDiff.dz && origDiff.dy == refDiff.dy && origDiff.dz == refDiff.dx {  }
    fatalError("WIP")
  }
}
