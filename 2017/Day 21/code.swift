
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

class Rule {
    let input: String
    let result: [[Character]]
    let size: Int
    lazy var hashes: [Int] = {
        let p = permutations()
        return p.map(Rule.hash)
    }()

    init(string: String) {
        let splitFirst = string.split(separator: "=")
        input = String(splitFirst.first!.trimmingCharacters(in: .whitespaces))
        result = splitFirst.last!.dropFirst(2).split(separator:"/").map { Array($0) }
        size = input.count == 5 ? 2 : 3
    }

    func permutations() -> Set<String> {
        var permStrings: Set<String> = [input]
        let inArr: [Character] = Array(input)
        switch size {
        case 2:
            //         orig   r1    r2    r3    f1    f2    f3    f4
            // 12/34 -> 01 -> 30 -> 43 -> 14 -> 10 -> 34 -> 03 -> 41
            //          34    41    10    03    43    01    14    03
            permStrings.insert(String([inArr[3], inArr[0], inArr[4], inArr[1]]))
            permStrings.insert(String([inArr[4], inArr[3], inArr[1], inArr[0]]))
            permStrings.insert(String([inArr[1], inArr[4], inArr[0], inArr[3]]))
            permStrings.insert(String([inArr[1], inArr[0], inArr[4], inArr[3]]))
            permStrings.insert(String([inArr[3], inArr[4], inArr[0], inArr[1]]))
            permStrings.insert(String([inArr[0], inArr[3], inArr[1], inArr[4]]))
            permStrings.insert(String([inArr[4], inArr[1], inArr[0], inArr[3]]))

            return permStrings

        default:
            //               orig    r1     r2     r3     f1     f2     f3     f4
            //                012    840    a98    26a    210    89a    048    a62
            // 123/456/789 -> 456 -> 951 -> 654 -> 159 -> 654 -> 456 -> 159 -> 951
            //                89a    a62    210    048    a98    012    26a    840
            permStrings.insert(String([inArr[8], inArr[4], inArr[0], inArr[9], inArr[5], inArr[1], inArr[10], inArr[6], inArr[2]]))
            permStrings.insert(String([inArr[10], inArr[9], inArr[8], inArr[6], inArr[5], inArr[4], inArr[2], inArr[1], inArr[0]]))
            permStrings.insert(String([inArr[2], inArr[6], inArr[10], inArr[1], inArr[5], inArr[9], inArr[0], inArr[4], inArr[8]]))
            permStrings.insert(String([inArr[2], inArr[1], inArr[0], inArr[6], inArr[5], inArr[4], inArr[10], inArr[9], inArr[8]]))
            permStrings.insert(String([inArr[8], inArr[9], inArr[10], inArr[4], inArr[5], inArr[6], inArr[0], inArr[1], inArr[2]]))
            permStrings.insert(String([inArr[0], inArr[4], inArr[8], inArr[1], inArr[5], inArr[9], inArr[2], inArr[6], inArr[10]]))
            permStrings.insert(String([inArr[10], inArr[6], inArr[2], inArr[9], inArr[5], inArr[1], inArr[8], inArr[4], inArr[0]]))

            return permStrings
        }
    }

    static func hash(_ string: String) -> Int {
        var bin: String = ""
        for char in string {
            switch char {
            case ".":
                bin.append("0")
            case "#":
                bin.append("1")
            default:
                break
            }
        }
        return Int(bin, radix: 2)!
    }

    static func countOf(string: String) -> Int {
        let ones: [Character] = string.filter { (char: Character) in 
            return char == "#" 
        }
        return ones.count
    }
}

struct Database {
    let rules: [Rule]

    init(string: String) {
        let ruleStrings = string.split(separator: "\n")
        rules = ruleStrings.map { Rule(string: String($0)) }
    }

    func deserialize(grid: String) -> ([[String]], Int) {
        let rows: [[Character]] = grid.split(separator: "/").map { Array($0) }
        let size = rows.count
        
        var blocks: [[String]] = []
        let blocksPerRow: Int
        let blockSize: Int
        if size % 2 == 0 {
            // print("! 2")
            blockSize = 2
            blocksPerRow = size / 2
            // print("rows: \(rows)")
            // print("blpr: \(blocksPerRow)")
            for vertBlock in 0..<blocksPerRow {
                blocks.append([])
                for horBlock in 0..<blocksPerRow {
                    // print("idxs: (\(vertBlock * blockSize + 1), \(horBlock * blockSize + 1))")
                    let block: [Character] = [
                        rows[vertBlock * blockSize][horBlock * blockSize],
                        rows[vertBlock * blockSize][horBlock * blockSize + 1],
                        "/",
                        rows[vertBlock * blockSize + 1][horBlock * blockSize],
                        rows[vertBlock * blockSize + 1][horBlock * blockSize + 1]
                    ]
                    blocks[vertBlock].append(String(block))
                }
            }
        } else {//size % 3 == 0
            // print("! 3")
            blockSize = 3
            blocksPerRow = size / 3
            for vertBlock in 0..<blocksPerRow {
                blocks.append([])
                for horBlock in 0..<blocksPerRow {
                    let block: [Character] = [
                        rows[vertBlock * blockSize][horBlock * blockSize],
                        rows[vertBlock * blockSize][horBlock * blockSize + 1],
                        rows[vertBlock * blockSize][horBlock * blockSize + 2],
                        "/",
                        rows[vertBlock * blockSize + 1][horBlock * blockSize],
                        rows[vertBlock * blockSize + 1][horBlock * blockSize + 1],
                        rows[vertBlock * blockSize + 1][horBlock * blockSize + 2],
                        "/",
                        rows[vertBlock * blockSize + 2][horBlock * blockSize],
                        rows[vertBlock * blockSize + 2][horBlock * blockSize + 1],
                        rows[vertBlock * blockSize + 2][horBlock * blockSize + 2]
                    ]
                    blocks[vertBlock].append(String(block))
                }
            }
        }
        return (blocks, blockSize)
    }

    func grow(_ blocks: [[String]]) -> [[[[Character]]]] {
        var next: [[[[Character]]]] = []
        for row in blocks {
            var nextRow: [[[Character]]] = []
            for block in row {
                let hash = Rule.hash(block)
                for rule in rules {
                    if rule.hashes.contains(hash) {
                        nextRow.append(rule.result)
                        break
                    }
                }
            }
            next.append(nextRow)
        }
        return next
    }

    func serialize(_ blocks: [[[[Character]]]], blockSize: Int) -> String {
        let size = blocks.count * blocks.first!.first!.count
        var result: [[Character]] = (0..<size).map { i in 
            return (0..<size).map { j in 
                return "."
            }
        }
        var curRowIndex = 0
        
        for row in blocks {
            var curColIndex = 0
            for block in row {
                var blockRowIndex = curRowIndex
                for blockRow in block {
                    var blockColIndex = curColIndex
                    for item in blockRow {
                        result[blockRowIndex][blockColIndex] = item
                        blockColIndex += 1
                    }
                    blockRowIndex += 1
                }
                curColIndex += blockSize
            }
            curRowIndex += blockSize
        }

        return result.map { (row: [Character]) -> String in 
            return row.reduce("") { (res: String, ch: Character) -> String in
                var res = res
                res.append(ch)
                return res
            }
        }.joined(separator: "/")
    }

    func step(grid: String) -> String {
        let (blocks, blockSize) = deserialize(grid: grid)
        // print("blks: \(blocks)")
        // print("blsz: \(blockSize)")
        let newBlockSize = blockSize + 1
        let nextBlocks = grow(blocks)
        // print("nxtb: \(nextBlocks)")
        let result = serialize(nextBlocks, blockSize: newBlockSize)

        return result
    }
}


func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    
    let startGrid = ".#./..#/###"
    let db = Database(string: input)

    var grid = startGrid
    print("grid: \(grid)")
    for _ in (0..<18) {
        grid = db.step(grid: grid)
        print("grid: \(grid)")
        print("1cnt: \(Rule.countOf(string: grid))")
    }
    // print(particles)
}


if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
