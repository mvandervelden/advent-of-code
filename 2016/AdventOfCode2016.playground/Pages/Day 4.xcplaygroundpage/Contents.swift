//: [Previous](@previous)

import Foundation

struct Room: CustomDebugStringConvertible {
    let name: String
    let sectorID: Int
    let checksum: String

    init(string: String) {
        let splitsChecksum = string.split(separator: "[")
        checksum = String(splitsChecksum.last!.dropLast())
        let splitsSectorID = splitsChecksum.first!.split(separator: "-")
        sectorID = Int(splitsSectorID.last!)!
        name = splitsSectorID.dropLast().joined()
    }

    func isValid() -> Bool {
        var letters: [Character] = []
        var histogram: [Int] = []
        name.forEach { char in
            if let index = letters.index(of: char) {
                histogram[index] += 1
            } else {
                letters.append(char)
                histogram.append(1)
            }
        }
        let sorted = zip(letters, histogram).sorted { (lhs, rhs) -> Bool in
            if lhs.1 > rhs.1 {
                return true
            }
            if lhs.1 == rhs.1 && lhs.0 < rhs.0 {
                return true
            }
            return false
        }
        let calculatedChecksum = sorted[0..<5].map { $0.0 }

        return String(calculatedChecksum) == checksum
    }

    let aScalarValue = 97

    func decrypt() -> (String, Int) {
        let shift = sectorID % 26

        let newCharacters = name.map { (char: Character) -> Character in
            let charValue = Int(char.unicodeScalars.first!.value)
            let newValue = ((charValue - aScalarValue) + shift) % 26 + aScalarValue
            return Character(UnicodeScalar(newValue)!)
        }
        return (String(newCharacters), sectorID)
    }

    var debugDescription: String {
        return "\(name): \(sectorID) [\(checksum)]"
    }
}

func read1(_ fileName: String = "input") -> [Room] {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let content = try! String(contentsOf: fileURL!)
    return content
        .split(separator: "\n")
        .map {
            Room(string: String($0))
    }
}

func solve1() {
    let rooms = read1()

    let sum = rooms.filter {
        $0.isValid()
    }.reduce(0) { $0 + $1.sectorID }
    print(sum)
}

func solve2() {
    let rooms = read1()

    let validRooms = rooms.filter {
        $0.isValid()
    }

    let poleSector = validRooms.map {
        $0.decrypt()
    }.filter {
        $0.0.contains("northpole")
    }.map { $0.1 }
    print(poleSector)
}

//solve1()
solve2()
//: [Next](@next)
