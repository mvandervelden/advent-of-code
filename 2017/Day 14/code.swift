
// to run: `swift code.swift [input_filename]`
import Foundation

func readTerminal(_ fileName: String) -> String {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
        print("file not found: \(currentDirectoryURL.path)/\(fileName)")
        return ""
    }
    let content = try! String(contentsOf: fileURL)
    return content
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)

    var table: [[Character]] = []
    // print(hash(input: input + "-0"))
    for i in 0..<128 {
        let rowInput = input + "-\(i)"
        table.append(hash(input: rowInput))
        // print(table)
    }
    // print(table[0..<8])
    let total = table.reduce(0) { (sum, row) in
        return sum + row.reduce(0) { (rSum, char) in
            return rSum + (char == "1" ? 1 : 0)
        }
    }
    print(total)

    print(findRegions(table))
}

func hash(input: String) -> [Character] {

    var currentIndex = 0
    var currentLenIndex = 0
    var skipSize = 0
    var result:[Int] = []
    var lengths: [Int] = []
    let noRounds = 64
    var curRound = 0

    lengths = input.utf8.map { Int($0) }
    lengths.append(contentsOf: [17, 31, 73, 47, 23])

    let list = Array(0..<256)
    // print(list)
    // print(lengths)

    result = list
    for j in 0..<noRounds {
        curRound = j
        for i in 0..<lengths.count {
            currentLenIndex = i
            // printState()

            let len = lengths[currentLenIndex]
            let endInd = currentIndex + len
            // print("+++++")

            if endInd >= result.count {
                // print("---")
                let firstRange = currentIndex..<result.count
                // print(firstRange.count)
                var part = result[firstRange]
                // print(part)
                let secRange = 0..<(endInd % result.count)
                // print(secRange.count)
                part += result[secRange]

                let revPart: [Int] = part.reversed()
                // print(revPart)

                // print(revPart[0..<firstRange.count])
                // print(revPart[firstRange.count..<revPart.count])
                // print("---")
                result.replaceSubrange(firstRange, with: revPart[0..<firstRange.count])
                result.replaceSubrange(secRange, with: revPart[firstRange.count..<revPart.count])
            } else {
                // print("___")
                let range = currentIndex..<endInd
                let part = result[range]
                let revPart = part.reversed()
                result.replaceSubrange(range, with: revPart)
                // print("___")
            }
            // print("-----")

            currentIndex = (endInd + skipSize) % result.count
            skipSize += 1
        }
    }

    var resultInts: [String] = []
    for i in 0..<16 {
        let idx = i * 16
        let part = Array(result[idx..<idx+16])
        let xored = part[1..<16].reduce(part[0], ^)
        let binaried = pad(string: String(xored, radix: 2), toSize: 8)
        // print(binaried)
        resultInts.append(binaried)
    }

    let str = resultInts.joined()

    // print(result)
    // print(str)
    // print(str.count)
    return Array(str)
    // print(result[0] * result[1])
}

func pad(string : String, toSize: Int) -> String {
  var padded = string
  for _ in 0..<(toSize - string.count) {
    padded = "0" + padded
  }
    return padded
}

struct Cell: Hashable {
    let x: Int
    let y: Int

    static func ==(lhs: Cell, rhs: Cell) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public var hashValue: Int {
        return x * 1000 + y
     }

     var neighbors: [Cell] {
         var nb: [Cell] = []
         if x > 0 {
            nb.append(Cell(x: x - 1, y: y))
         }
         if y > 0 {
            nb.append(Cell(x: x, y: y - 1))
         }
         return nb
     }
}

func findRegions(_ table: [[Character]]) -> Int {
    var regions: [[Cell]] = []
    for rIdx in 0..<table.count {
        print(regions.count)
        let row = table[rIdx]
        for cIdx in 0..<row.count {
            if row[cIdx] == "0" {
                continue
            }
            let cell = Cell(x: rIdx, y: cIdx)
            var containedInRegions: [Int] = []
            for nb in cell.neighbors {
                for region in regions.enumerated() {
                    if region.element.contains(nb) {
                        containedInRegions.append(region.offset)
                    }
                }
            }
            if containedInRegions.count == 0 {
                regions.append([cell])
            } else if containedInRegions.count == 1 || containedInRegions.first! == containedInRegions.last! {
                regions[containedInRegions.first!].append(cell)
            } else {
                //merge regions
                let sec = regions.remove(at: containedInRegions.max()!)
                let frst = regions.remove(at: containedInRegions.min()!)
                let newRegion = frst + sec + [cell]
                regions.append(newRegion)
            }
        }
    }
    return regions.count
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
