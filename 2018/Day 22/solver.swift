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

    enum Equipment: Hashable {
        case torch, climbing, neither
    }

    struct Location: Hashable {
        let x: Int
        let y: Int
        let equipment: Equipment
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
        if cave.count >= targetY && cave[targetY].count >= targetX {
            return
        }

        if cave.count > 0 && cave[targetY].count < targetX {
            for y in (0..<cave.count) {
                for x in (cave[y].count...targetX) {
                    cave[y].append(type(x: x, y: y))
                } 
            }
        }
        
        for y in (cave.count...targetY) {
            cave.append([])
            for x in (0...targetX) {
                cave[y].append(type(x: x, y: y))
            }
        }

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
                return lhsScore < rhsScore || (lhsScore == rhsScore && ($0.y < $1.y || ($0.y == $1.y && $0.x < $1.x)))
            }!
            // let current = openSet.min { fScore[$0] ?? Int.max < fScore[$1] ?? Int.max }!
            // print("current", current)
            if current == goal {
                return reconstruct(cameFrom, current: current)
            }

            openSet.remove(current)
            closedSet.insert(current)

            for neighbor in neighbors(current) {
                // print("neighbor", neighbor)
                if closedSet.contains(neighbor) {
                    continue
                }

                let tentativeG = gScore[current]! // + 1000000 + neighbor.y * 100 + neighbor.x

                if !openSet.contains(neighbor) {
                    openSet.insert(neighbor)
                } else if tentativeG >= gScore[neighbor] ?? Int.max {
                    continue
                }
                // print("Adding neighbor")
                cameFrom[neighbor] = current
                gScore[neighbor] = tentativeG
                fScore[neighbor] = tentativeG + heuristicEstimate(start: neighbor, goal: goal)
                // print("Added neighbor")
            }
        }

        return nil
    }

    func heuristicEstimate(start: Location, goal: Location) -> Int {
        return abs(start.x - goal.x) + abs(start.y - goal.y)
    }

    func reconstruct(_ cameFrom: [Pt: Pt], current: Pt) -> [Pt] {
        var current = current
        var totalPath = [current]
        while cameFrom[current] != nil {
            current = cameFrom[current]!
            totalPath.append(current)
        }
        return totalPath
    }

    func neighbors(_ pt: Pt) -> [Pt] {
        var pts: [Pt] = []
        if case .empty = field[pt.y - 1][pt.x] {
            pts.append(Pt(x: pt.x, y: pt.y - 1))
        }
        if case .empty = field[pt.y][pt.x - 1] {
            pts.append(Pt(x: pt.x - 1, y: pt.y))
        }
        if case .empty = field[pt.y][pt.x + 1] {
            pts.append(Pt(x: pt.x + 1, y: pt.y))
        }
        if case .empty = field[pt.y + 1][pt.x] {
            pts.append(Pt(x: pt.x, y: pt.y + 1))
        }
        // print("found neighbors", pts)
        return pts
    }

    func hpSum() -> Int {
        return field.reduce(0) { sumR, row in 
            return sumR + row.reduce(0) { sumC, cell in 
                if case .player(let p) = cell {
                    return sumC + p.hp
                }
                return sumC
            }
        }
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