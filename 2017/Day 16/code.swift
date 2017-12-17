
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

enum Move {
    case spin(size: Int)
    case exchange(a: Int, b: Int)
    case partner(a: Character, b: Character)

    static func from(string str: String) -> Move {
        let typeChar = str.first!
        let string = str.dropFirst()
        switch typeChar {
        case "s":
            return .spin(size: Int(string)!)
        case "x":
            let vals = string.split(separator: "/")
            return .exchange(a: Int(String(vals[0]))!, b: Int(String(vals[1]))!)
        case "p": fallthrough
        default:
            let vals = string.split(separator: "/")
            return .partner(a: vals[0].first!, b: vals[1].first!)
        }
    }

    func move(dancers: [Character]) -> [Character] {
        switch self {
        case .spin(let size):
            return Array(dancers.dropFirst(dancers.count - size) + dancers.dropLast(size))
        case .exchange(let a, let b):
            var res = dancers
            res.swapAt(a, b)
            return res
        case .partner(let a, let b):
            let idxA = dancers.index(of: a)!
            let idxB = dancers.index(of: b)!
            var res = dancers
            res.swapAt(idxA, idxB)
            return res
        }
    }
}

extension Move: CustomStringConvertible {
    var description: String {
        switch self {
        case .spin(let size):
            return "s\(size)"
        case .exchange(let a, let b):
            return "x\(a)/\(b)"
        case .partner(let a, let b):
            return  "p\(a)/\(b)"
        }
    }
}


func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let moves = input.split(separator: ",").map { Move.from(string: String($0))}

    let dancers = fileName == "input.txt" ? Array("abcdefghijklmnop") : Array("abcde")

    var state = dancers
    var seen: [String] = []
    let reps = 1_000_000_000
    for i in 0..<reps {
        if seen.contains(String(state)) {
            print(i)
            print(seen[reps % i])
            state = Array(seen[reps % i])
            break
        }
        seen.append(String(state))
        for move in moves {
            state = move.move(dancers: state)
            // print(String(state))
        }
        if i % 1_000_000 == 0 {
            print(i)
        }
    }
    print(state)
    // let permutation: [Int] = state.map {
    //     dancers.index(of: $0)!
    // }

    // print(permutation)
    // state = dancers
    // for i in 1..<2 {
    //     print(i)
    //     state = permutation.map { state[$0] }
    //     print(String(state))
    // }
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
