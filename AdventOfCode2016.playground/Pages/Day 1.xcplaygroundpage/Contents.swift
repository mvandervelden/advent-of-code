//: [Previous](@previous)
// Day 1: No Time for a Taxicab
import Foundation

enum Direction {
    case N, E, S, W

    func turn(_ turn: Turn) -> Direction {
        switch (self, turn) {
        case (.N, .L), (.S, .R):
            return .W
        case (.N, .R), (.S, .L):
            return .E
        case (.E, .L), (.W, .R):
            return .N
        case (.E, .R), (.W, .L):
            return .S
        }
    }
}

enum Turn {
    case L, R
}

struct Location {
    let x: Int
    let y: Int

    var distanceFromOrigin: Int {
        return abs(x) + abs(y)
    }
}

extension Location: CustomDebugStringConvertible {
    var debugDescription: String {
        return "(\(x), \(y))"
    }
}

enum Orientation {
    case ew, ns, invalid
}

struct Section {
    let from: Location
    let to: Location

    var minX: Int {
        return min(from.x, to.x)
    }

    var maxX: Int {
        return max(from.x, to.x)
    }

    var minY: Int {
        return min(from.y, to.y)
    }

    var maxY: Int {
        return max(from.y, to.y)
    }

    var orientation: Orientation {
        if from.x == to.x {
            return .ns
        }
        if from.y == to.y {
            return .ew
        }
        return .invalid
    }

    func intersects(with section: Section) -> Location? {
        if orientation == section.orientation {
            return nil
        }

        if orientation == .ew && minY >= section.minY && minY <= section.maxY && section.minX >= minX && section.minX <= maxX {
            return Location(x: section.minX, y: minY)
        }
        if orientation == .ns && minX >= section.minX && minX <= section.maxX && section.minY >= minY && section.minY <= maxY {
            return Location(x: minX, y: section.minY)
        }
        return nil
    }
}

extension Section: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(from) -> \(to) dir: \(orientation)"
    }
}

struct Position {
    let direction: Direction
    let location: Location

    let pastLocations: [Location]

    static var start: Position {
        return Position(direction: .N, location: Location(x: 0, y: 0), pastLocations: [])
    }

    func move(_ move: Move) -> Position {
//        print("CurrentPosition: \(self), move: \(move)")
        let newDirection = direction.turn(move.turn)
        let newLoc = newLocation(move)
        let newPastLocations = pastLocations + [location]
        return Position(direction: newDirection, location: newLoc, pastLocations: newPastLocations)
    }

    func newLocation(_ move: Move) -> Location {
        let newDirection = direction.turn(move.turn)
        switch newDirection {
        case .N:
            return Location(x: location.x, y: location.y + move.distance)
        case .E:
            return Location(x: location.x + move.distance, y: location.y)
        case .S:
            return Location(x: location.x, y: location.y - move.distance)
        case .W:
            return Location(x: location.x - move.distance, y: location.y)
        }
    }

    var distanceFromStart: Int {
        return location.distanceFromOrigin
    }
}

extension Position: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(location)\(direction)"
    }
}

struct Move {
    let turn: Turn
    let distance: Int

    init(string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let directionString = trimmed.first!
        distance = Int(String(trimmed.dropFirst()))!

        switch directionString {
        case "L":
            turn = .L
        case "R":
            turn = .R
        default:
            assertionFailure("invalid input")
            turn = .L
        }
    }
}

extension Move: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(turn)\(distance)"
    }
}

class Reader {
    func read() -> [Move] {
        let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt")
        let content = try! String(contentsOf: fileURL!)
        return content
            .split(separator: ",")
            .map {
                Move(string: String($0))
            }
    }
}


let route = Reader().read()

//let endPosition = route.reduce(Position.start) { (currentPosition, move) -> Position in
//    return currentPosition.move(move)
//}

var didIntersectAt: Location? = nil
var routeIndex = 0
var position = Position.start

while didIntersectAt == nil {
    let nextMove = route[routeIndex]; defer { routeIndex += 1 }

    position = position.move(nextMove)

    let newSection = Section(from: position.pastLocations.last!, to: position.location)

    guard position.pastLocations.count > 2 else {
        continue
    }
    for index in 1..<position.pastLocations.count - 1 {
        let section = Section(from: position.pastLocations[index - 1], to: position.pastLocations[index])
        if let intersection = section.intersects(with: newSection) {
            didIntersectAt = intersection
            break
        }
    }
}

//let sectionA = Section(from: Location(x: 0, y: 0), to: Location(x: 0, y: 5))
//let sectionB = Section(from: Location(x: -1, y: 1), to: Location(x: 1, y: 1))
//
//sectionA.intersects(with: sectionB)
//print(endPosition)
//print(endPosition.distanceFromStart)
//print(endPosition.pastLocations)

print(didIntersectAt!)
print(position)
print(position.pastLocations)
print(didIntersectAt!.distanceFromOrigin)
//: [Next](@next)
