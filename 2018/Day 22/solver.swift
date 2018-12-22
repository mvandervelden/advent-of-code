import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {
    struct Coord: CustomStringConvertible, Hashable {
        let x, y: Int

        var description: String {
            return "(\(x), \(y))"
        }

        func above() -> Coord {
            return Coord(x: x, y: y - 1)
        }

        func below() -> Coord {
            return Coord(x: x, y: y + 1)
        }

        func left() -> Coord {
            return Coord(x: x - 1, y: y)
        }

        func right() -> Coord {
            return Coord(x: x + 1, y: y)
        }
    }

    struct CaveCell: CustomStringConvertible {
        let type: CType
        let val: Int

        init(level: Int) {
            val = level
            type = CType(int: level)
        }

        private init(type: CType, level: Int) {
            self.type = type
            self.val = level
        }

        static func mouth(level: Int) -> CaveCell {
            return CaveCell(type: .mouth, level: level)
        }

        static func target(level: Int) -> CaveCell {
            return CaveCell(type: .target, level: level)
        }

        var risk: Int {
            return CType(int: val).riskValue
        }

        var description: String {
            return type.description
        }
    }

    enum CType: CustomStringConvertible {
        case rocky, narrow, wet, mouth, target

        init(int: Int) {
            switch int % 3 {
            case 0: self = .rocky
            case 1: self = .wet
            case 2: self = .narrow
            default: fatalError()
            }
        }

        var riskValue: Int {
            switch self {
            case .rocky, .mouth, .target: return 0
            case .wet: return 1
            case .narrow: return 2
            }
        }

        var description: String {
            switch self {
            case .rocky: return "."
            case .narrow: return "|"
            case .wet: return "="
            case .mouth: return "M"
            case .target: return "T"
            }
        }
    }

    enum Equipment: Hashable, CustomStringConvertible {
        case torch, climbing, neither

        var description: String {
            switch self {
                case .torch: return "🔥"
                case .climbing: return "🧗"
                case .neither: return "∅"
            }
        }
    }

    struct Location: Hashable, CustomStringConvertible {
        let x: Int
        let y: Int
        let equipment: Equipment

        var description: String {
            return "(\(x),\(y)) \(equipment)"
        }
    }

    var depth = 7305
    var target = Coord(x: 13, y: 734)
    let xBase = 16807
    let yBase = 48271
    let erosionBase = 20183

    var cave: [[CaveCell]] = []

    func solve(_ fileName: String = "input.txt") -> String {
        if fileName == "example.txt" {
            depth = 510
            target = Coord(x: 10, y: 10)
        }
        let result1 = solve1()
        let result2 = solve2()
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1() -> String {
        // let row = Array(repeating: CaveCell(type: CType.rocky, val: 0), count: target.x)
        // cave = Array(repeating: row, count: target.y)
        
        exploreTo(targetX: target.x, targetY: target.y)
        printCave()
        let risk = cave.reduce(0) { sum, row in 
            return sum + row.reduce(0) { $0 + $1.risk }
        }
        return "\(risk)"
    }

    private func solve2() -> String {
        exploreTo(targetX: target.x, targetY: target.y)
        let route = astar(start: Location(x: 0, y: 0, equipment: .torch), goal: Location(x: target.x, y: target.y, equipment: .torch))
        print(route)
        return ""
    }

    func printCave() {
        cave.forEach {
            print($0.map { $0.description }.joined())
        }
        // cave.forEach {
        //     print($0.map { String($0.val) }.joined(separator: ","))
        // }
    }

    func exploreTo(targetX: Int, targetY: Int) {
        // print("Exploring to \(targetX), \(targetY), current size: \(cave.last?.count ?? 0),\(cave.count)")

        if cave.count > targetY && cave[targetY].count > targetX {
            return
        }

        // print("Exploring will expand: size of target row: \(cave.count > targetY ? cave[targetY].count : 0)")
        if cave.count > 0 && cave.first!.count != cave.last!.count {
            printCave()
            fatalError("Fix please")
        }        
        if cave.count > 0 && cave[0].count <= targetX {
            // print("Exploring to right")
            for y in (0..<cave.count) {
                for x in (cave[y].count...targetX) {
                    cave[y].append(type(x: x, y: y))
                } 
            }
        }
        if cave.count <= targetY {
            // print("Exploring to below \(cave.count...targetY)")

            for y in (cave.count...targetY) {
                cave.append([])
                // print(cave.first?.count ?? 0, targetX + 1)
                for x in (0..<max(targetX + 1, cave.first?.count ?? 0)) {
                    cave[y].append(type(x: x, y: y))
                }
            }
        }
        // print("Exploring, size afterwards:  \(cave.last?.count ?? 0),\(cave.count)" )
    }

    func type(x: Int, y: Int) -> CaveCell {
        let geoIndex: Int
        if x == 0 && y == 0 {
            return .mouth(level: depth % erosionBase)
        } else if x == target.x && y == target.y {
            return .target(level: depth % erosionBase)
        } else if x == 0 {
            geoIndex = y * yBase
        } else if y == 0 {
            geoIndex = x * xBase
        } else {
            geoIndex = cave[y][x-1].val*cave[y-1][x].val
        }

        let erosionLevel = (geoIndex + depth) % erosionBase
        return CaveCell(level: erosionLevel)
    }

    func astar(start: Location, goal: Location) -> [Location]? {
        var closedSet: Set<Location> = []
        var openSet: Set<Location> = [start]
        var cameFrom: [Location: Location] = [:]
        var gScore: [Location: Int] = [start: 0]
        var fScore: [Location: Int] = [start: heuristicEstimate(start: start, goal: goal)]

        while !openSet.isEmpty {
            // print("openSet", openSet)
            // print("closedSet", closedSet)
            // print("cameFrom", cameFrom)
            // print("gScore", gScore)
            // print("fScore", fScore)
            // print("finding current")
            let current = openSet.min {
                let lhsScore = fScore[$0] ?? Int.max
                let rhsScore = fScore[$1] ?? Int.max
                return lhsScore < rhsScore //|| (lhsScore == rhsScore && ($0.y < $1.y || ($0.y == $1.y && $0.x < $1.x)))
            }!
            // let current = openSet.min { fScore[$0] ?? Int.max < fScore[$1] ?? Int.max }!
            // print("current", current, fScore[current]!)
            // if fScore[current]! > 45 {
            //     print("openSet", openSet)
            //     print("closedSet", closedSet)
            //     print("cameFrom", cameFrom)
            //     print("gScore", gScore)
            //     print("fScore", fScore)
            //     fatalError()
            // }
            if current == goal {
                print("total cost: ", gScore[current]!)
                return reconstruct(cameFrom, current: current)
            }

            openSet.remove(current)
            closedSet.insert(current)

            for neighbor in neighbors(current) {
                // print("neighbor", neighbor)
                if closedSet.contains(neighbor.loc) {
                    continue
                }

                let tentativeG = gScore[current]! + neighbor.cost// + 1000000 + neighbor.y * 100 + neighbor.x

                if !openSet.contains(neighbor.loc) {
                    openSet.insert(neighbor.loc)
                } else if tentativeG >= gScore[neighbor.loc] ?? Int.max {
                    continue
                }
                // print("Adding neighbor")
                cameFrom[neighbor.loc] = current
                gScore[neighbor.loc] = tentativeG
                fScore[neighbor.loc] = tentativeG + heuristicEstimate(start: neighbor.loc, goal: goal)
                // print("Added neighbor")
            }
        }

        return nil
    }

    func heuristicEstimate(start: Location, goal: Location) -> Int {
        return abs(start.x - goal.x) + abs(start.y - goal.y)
    }

    func reconstruct(_ cameFrom: [Location: Location], current: Location) -> [Location] {
        var current = current
        var totalPath = [current]
        while cameFrom[current] != nil {
            current = cameFrom[current]!
            totalPath.append(current)
        }
        return totalPath
    }

    func neighbors(_ loc: Location) -> [(loc: Location, cost: Int)] {
        var locs: [(loc: Location, cost: Int)] = []
        let possibleNextTypes: [CType]

        switch (loc.equipment, cave[loc.y][loc.x].type) {
        case (.torch, .rocky), (.torch, .mouth), (.torch, .target):
            locs.append((loc: Location(x:loc.x, y: loc.y, equipment: .climbing), cost:7))
            possibleNextTypes = [.rocky, .narrow, .target]
        case (.climbing, .rocky), (.climbing, .mouth), (.climbing, .target):
            locs.append((loc: Location(x:loc.x, y: loc.y, equipment: .torch), cost:7))
            possibleNextTypes = [.rocky, .wet, .target]
        case (.climbing, .wet):
            locs.append((loc: Location(x:loc.x, y: loc.y, equipment: .neither), cost:7))
            possibleNextTypes = [.rocky, .wet, .target]
        case (.neither, .wet):
            locs.append((loc: Location(x:loc.x, y: loc.y, equipment: .climbing), cost:7))
            possibleNextTypes = [.wet, .narrow]
        case (.torch, .narrow):
            locs.append((loc: Location(x:loc.x, y: loc.y, equipment: .neither), cost:7))
            possibleNextTypes = [.rocky, .narrow, .target]
        case (.neither, .narrow):
            locs.append((loc: Location(x:loc.x, y: loc.y, equipment: .torch), cost:7))
            possibleNextTypes = [.wet, .narrow]
        default:
            fatalError("Unexpected state: \(loc), \(cave[loc.y][loc.x])")
        }
        // print("check up & left")
        if loc.x > 0 && possibleNextTypes.contains(cave[loc.y][loc.x - 1].type) {
            // print("check left")
            locs.append((loc: Location(x: loc.x-1, y: loc.y, equipment: loc.equipment), cost: 1))
        }
        if loc.y > 0 && possibleNextTypes.contains(cave[loc.y - 1][loc.x].type) {
            // print("check up")
            locs.append((loc: Location(x: loc.x, y: loc.y - 1, equipment: loc.equipment), cost: 1))
        }
        
        // print("explore next")
        exploreTo(targetX: loc.x+1, targetY: loc.y+1)
        // print("explore right and below")
        if possibleNextTypes.contains(cave[loc.y][loc.x + 1].type) {
            // print("explore right")
            locs.append((loc: Location(x: loc.x+1, y: loc.y, equipment: loc.equipment), cost: 1))
        }
        if possibleNextTypes.contains(cave[loc.y+1][loc.x].type) {
            // print("explore below")
            locs.append((loc: Location(x: loc.x, y: loc.y+1, equipment: loc.equipment), cost: 1))
        }
        // print("found neighbors", locs)
        return locs
    }
}

let solver = Solver()
let result: String

if CommandLine.arguments.count > 1 {
    result = solver.solve(CommandLine.arguments[1])
} else {
    result = solver.solve()
}

print(result)

// gScore [(5,3) 🧗: 22, (0,3) ∅: 17, (0,0) 🔥: 0, (2,0) 🔥: 16, (5,5) 🧗: 24, (1,0) ∅: 10, (7,1) ∅: 15, (3,4) 🧗: 28, (2,2) 🧗: 11, (5,3) 🔥: 22, (6,4) 🧗: 24, (3,2) ∅: 12, (5,1) 🔥: 20, (4,1) ∅: 12, (5,1) ∅: 13, (2,2) ∅: 11, (3,0) ∅: 12, (5,4) ∅: 30, (7,1) 🔥: 22, (4,1) 🧗: 19, (5,0) 🔥: 21, (2,0) 🧗: 9, (1,2) ∅: 10, (6,2) 🧗: 22, (1,3) 🧗: 11, (1,2) 🧗: 10, (3,1) ∅: 11, (4,0) ∅: 13, (3,2) 🔥: 19, (4,0) 🧗: 20, (5,2) 🔥: 21, (2,5) ∅: 28, (6,0) 🔥: 22, (0,2) 🧗: 9, (2,3) ∅: 12, (2,1) 🧗: 10, (3,4) 🔥: 21, (3,0) 🔥: 19, (0,1) 🧗: 8, (1,0) 🧗: 8, (1,3) 🔥: 18, (2,5) 🔥: 21, (1,4) 🔥: 19, (0,0) 🧗: 7, (0,5) ∅: 19, (3,1) 🔥: 18, (2,4) 🧗: 27, (2,1) ∅: 10, (6,1) 🔥: 21, (6,2) 🔥: 22, (0,1) 🔥: 1, (4,4) 🧗: 24, (5,2) 🧗: 21, (4,3) 🧗: 21, (6,1) ∅: 14, (1,4) ∅: 19, (6,3) 🔥: 30, (2,3) 🔥: 19, (0,5) 🧗: 12, (0,4) 🧗: 11, (2,4) 🔥: 20, (0,2) 🔥: 2, (0,4) ∅: 18, (1,1) 🔥: 2, (0,3) 🧗: 10, (5,4) 🧗: 23, (6,0) ∅: 15, (3,5) 🔥: 22, (3,3) 🔥: 20, (1,5) 🔥: 22, (4,2) 🧗: 20, (4,2) 🔥: 22, (1,1) ∅: 9, (6,3) 🧗: 23]
// fScore [(5,3) 🧗: 34, (0,3) ∅: 34, (0,0) 🔥: 20, (2,0) 🔥: 34, (5,5) 🧗: 34, (1,0) ∅: 29, (7,1) ∅: 27, (3,4) 🧗: 41, (2,2) 🧗: 27, (5,3) 🔥: 34, (6,4) 🧗: 34, (3,2) ∅: 27, (5,1) 🔥: 34, (4,1) ∅: 27, (5,1) ∅: 27, (2,2) ∅: 27, (3,0) ∅: 29, (5,4) ∅: 41, (7,1) 🔥: 34, (4,1)🧗: 34, (5,0) 🔥: 36, (2,0) 🧗: 27, (1,2) ∅: 27, (6,2) 🧗: 34, (1,3) 🧗: 27, (1,2) 🧗: 27, (3,1) ∅: 27, (4,0) ∅: 29, (3,2) 🔥: 34, (4,0) 🧗: 36, (5,2) 🔥: 34, (2,5) ∅: 41, (6,0) 🔥: 36, (0,2) 🧗: 27, (2,3) ∅: 27, (2,1) 🧗: 27, (3,4) 🔥: 34, (3,0) 🔥: 36, (0,1) 🧗: 27, (1,0) 🧗: 27, (1,3) 🔥: 34, (2,5) 🔥: 34, (1,4) 🔥: 34, (0,0) 🧗: 27, (0,5) ∅: 34, (3,1) 🔥: 34, (2,4) 🧗: 41, (2,1) ∅: 27, (6,1) 🔥: 34, (6,2) 🔥: 34, (0,1) 🔥: 20, (4,4) 🧗: 36, (5,2) 🧗: 34, (4,3) 🧗: 34, (6,1) ∅: 27, (1,4) ∅: 34, (6,3) 🔥: 41, (2,3) 🔥: 34, (0,5) 🧗: 27, (0,4) 🧗: 27, (2,4) 🔥: 34, (0,2) 🔥: 20, (0,4) ∅: 34, (1,1) 🔥: 20, (0,3) 🧗: 27, (5,4) 🧗: 34, (6,0) ∅: 29, (3,5) 🔥: 34, (3,3) 🔥: 34, (1,5) 🔥: 36, (4,2) 🧗: 34, (4,2) 🔥: 36, (1,1) ∅: 27, (6,3) 🧗: 34]
// current (4,3) 🧗
