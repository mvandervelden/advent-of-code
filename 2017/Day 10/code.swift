
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

var currentIndex = 0
var currentLenIndex = 0
var skipSize = 0
var result:[Int] = []
var lengths: [Int] = []
let noRounds = 64
var curRound = 0

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)

    lengths = input.split(separator: ",").map {
        Int(String($0).trimmingCharacters(in: .whitespacesAndNewlines))!
    }
    let list = Array(0..<(fileName == "input.txt" ? 256 : 5))
    print(list)
    print(lengths)

    result = list

    for i in 0..<lengths.count {
        currentLenIndex = i
        printState()

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

    print(result)
    print(result[0] * result[1])
}

func solve2(fileName: String = "input.txt") {
    let input = readTerminal(fileName)

    lengths = input.utf8.map { Int($0) }
    lengths.append(contentsOf: [17, 31, 73, 47, 23])

    let list = Array(0..<256)
    // print(list)
    print(lengths)

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
        let hexed = String(format: "%02x", xored)
        resultInts.append(hexed)
    }

    let str = resultInts.joined()

    print(result)
    print(str)
    print(str.count)
    // print(result[0] * result[1])
}

func printState() {
    let string = (0..<result.count).reduce("") {
        var newResult = $0
        if $1 == currentIndex && lengths[currentLenIndex] == 1 {
            newResult += " ([\(result[$1])])"
        } else if $1 == currentIndex {
            newResult += " ([\(result[$1])]"
        } else if $1 == (currentIndex + lengths[currentLenIndex] - 1) % result.count {
            newResult += " \(result[$1]))"
        } else {
            newResult += " \(result[$1])"
        }
        return newResult
    }
    print(string)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve2(fileName: fileName)
} else {
    solve2()
}
