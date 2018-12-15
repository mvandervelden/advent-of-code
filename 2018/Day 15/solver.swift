import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {
    struct Pt: Hashable, CustomStringConvertible {
        let x, y: Int

        var description: String {
            return "(\(x), \(y))"
        }
    }

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    let ap = 3
    var field: [[Square]] = []

    enum Square: CustomStringConvertible {
        case wall
        case empty
        case player(Player)

        init(ch: Character, x: Int, y: Int) {
            switch ch {
                case "#": self = .wall
                case ".": self = .empty
                case "E": self = .player(Player(type: .elve, x: x, y: y))
                case "G": self = .player(Player(type: .goblin, x: x, y: y))
                default: fatalError("Unexpected Square: \(ch)")
            }
        }

        var pType: PType? {
            switch self {
                case .player(let p): return p.type
                default: return nil
            }
        }

        var description: String {
            switch self {
                case .wall: return "#"
                case .empty: return "."
                case .player(let p) where p.type == .elve: return "E"
                case .player(let p) where p.type == .goblin: return "G"
                default: return "ERROR"
            }
        }
    }

    enum PType { case elve, goblin }

    class Player: CustomStringConvertible {
        let type: PType
        var hp = 200
        var x: Int
        var y: Int

        init(type: PType, x: Int, y: Int) {
            self.type = type
            self.x = x
            self.y = y
        }

        var opponentType: PType {
            switch type {
                case .elve: return .goblin
                case .goblin: return .elve
            }
        }

        var description: String {
            return "(\(x), \(y)): \(hp)"
        }
    }

    private func solve1(input: String) -> String {
        let lines = input.split(separator: "\n")
        field = lines.enumerated().map { row in Array(row.element).enumerated().map { el in Square(ch: el.element, x: el.offset, y: row.offset) } }
        
        var stillGoing = true
        var no_rounds = 0
        while stillGoing {
            printField()
            let players = getPlayers()
            for player in players {
                if player.hp < 0 {
                    //Player is out
                    continue
                }
                // print("player", player)
                guard hasOpponents(player) else {
                    let sum = hpSum()
                    printField()
                    print("rounds:", no_rounds)
                    print("sum", sum)
                    return "\(no_rounds * sum)"
                }

                if let oppInRange = oppInRange(player) {
                    // print("attack")
                    attack(oppInRange, by: player)
                    // printField()
                    continue
                }
                
                let openTargetSquares = self.openTargetSquares(player)
                if openTargetSquares.isEmpty { 
                    // print("all target squares occupied")
                    //Cannot move
                    continue 
                }

                // print("moving to", openTargetSquares)
                //MOVE
                guard let nextLocation = findPath(player, targets: openTargetSquares) else {
                    // print("no target squares accessible")
                    //Cannot reach target locations
                    continue
                }
                // print("moving to", nextLocation)
                // print("currently", field[nextLocation.y][nextLocation.x])
                let currentLocation = Pt(x: player.x, y: player.y)
                // print("currentLocation", currentLocation)
                // print("currently", field[currentLocation.y][currentLocation.x])
                player.x = nextLocation.x
                player.y = nextLocation.y
                
                field[nextLocation.y][nextLocation.x] = .player(player)
                field[currentLocation.y][currentLocation.x] = .empty
                
                // print("moved \(player)")
                if let oppInRange = oppInRange(player) {
                    // print("attack")
                    attack(oppInRange, by: player)
                }
                // printField()
            }
            no_rounds += 1
            // if no_rounds == 1 { stillGoing = false }
        }
        printField()
        return ""
    }

    func getPlayers() -> [Player] {
        var players: [Player] = []
        field.forEach { row in 
            row.forEach { cell in
                switch cell {
                    case .player(let p): players.append(p)
                    default: break
                }
            }
        }

        return players
    }

    func hasOpponents(_ player: Player) -> Bool {
        let opp = player.opponentType
        return field.contains { return $0.contains { cell in
            switch cell {
                case .player(let p) where p.type == opp: return true
                default: return false 
            }
        }}
    }

    func openTargetSquares(_ player: Player) -> [Pt] {
        var openTargetSquares: Set<Pt> = []
        field.enumerated().forEach { row in
            for cell in row.element.enumerated() {
                if case .empty = cell.element {
                    // print(player, row.offset, cell.offset, cell.element)

                    if field[row.offset - 1][cell.offset].pType == player.opponentType {
                        // print("appending for", cell.offset, row.offset - 1)
                        openTargetSquares.insert(Pt(x: cell.offset, y: row.offset))
                        continue
                    }
                    if field[row.offset + 1][cell.offset].pType == player.opponentType {
                        // print("appending for", cell.offset, row.offset + 1)
                        openTargetSquares.insert(Pt(x: cell.offset, y: row.offset))
                        continue
                    }
                    if field[row.offset][cell.offset - 1].pType == player.opponentType {
                        // print("appending for", cell.offset - 1, row.offset)
                        openTargetSquares.insert(Pt(x: cell.offset, y: row.offset))
                        continue
                    }
                    if field[row.offset][cell.offset + 1].pType == player.opponentType {
                        // print("appending for", cell.offset + 1, row.offset)
                        openTargetSquares.insert(Pt(x: cell.offset, y: row.offset))
                        continue
                    }
                }
            }
        }
        return Array(openTargetSquares).sorted { lhs, rhs in return lhs.y < rhs.y || (lhs.y == rhs.y && lhs.x < rhs.x) }
    }

    func oppInRange(_ player: Player) -> Player? {
        let oppType = player.opponentType
        var pls: [Player] = []
        
        switch field[player.y - 1][player.x] {
        case .player(let opp) where opp.type == oppType:
            pls.append(opp)
        default:
            break
        }
        switch field[player.y][player.x - 1] {
        case .player(let opp) where opp.type == oppType:
            pls.append(opp)
        default:
            break
        }
        switch field[player.y][player.x + 1] {
        case .player(let opp) where opp.type == oppType:
            pls.append(opp)
        default:
            break
        }
        switch field[player.y + 1][player.x] {
        case .player(let opp) where opp.type == oppType:
            pls.append(opp)
        default:
            break
        }

        if pls.isEmpty { return nil }

        let min = pls.min { $0.hp < $1.hp }!.hp
        
        return pls.filter { $0.hp == min }.first
    }

    func attack(_ opponent: Player, by player: Player) {
        opponent.hp -= 3
        if opponent.hp <= 0 {
            field[opponent.y][opponent.x] = .empty
        }
    }

    func findPath(_ player: Player, targets: [Pt]) -> Pt? {
        let paths: [[Pt]] = targets.compactMap { target in
            // print("finding path to:", target, "from:", player)
            return astar(start: Pt(x: player.x, y: player.y), goal: target)
        }
        // print("paths found", paths)
        if paths.count == 0 { return nil }

        let bestPath = paths.min { $0.count < $1.count }!

        return bestPath[bestPath.count - 2]
    }
    //TODO current minimum for early bail out
    func astar(start: Pt, goal: Pt) -> [Pt]? {
        var closedSet: Set<Pt> = []
        var openSet: Set<Pt> = [start]
        var cameFrom: [Pt: Pt] = [:]
        var gScore: [Pt: Int] = [start: 0]
        var fScore: [Pt: Int] = [start: heuristicEstimate(start: start, goal: goal)]

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

                let tentativeG = gScore[current]! + 10000 + neighbor.y * 100 + neighbor.x * 100

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

    func heuristicEstimate(start: Pt, goal: Pt) -> Int {
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

    func printField() {
        field.forEach { 
            $0.forEach { c in 
                print(c, terminator: "")
            }
            print(" ", terminator: "")
            let p = $0.compactMap { c in 
                switch c {
                case .player(let p):
                    return p.description
                default:
                    return nil
                }
            }.joined(separator: ", ")
            print(p)
        }
    }


    private func solve2(input: String) -> String {
        // let lines = input.split(separator: "\n")

        return ""
    }

    private func readFile(_ fileName: String) -> String {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
            print("file not found: \(currentDirectoryURL.path)/\(fileName)")
            return ""
        }
        let content = try! String(contentsOf: fileURL)
        return content
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