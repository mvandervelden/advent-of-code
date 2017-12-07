
// to run: `swift code.swift [input_filename]`
import Foundation

var nodes: [Node] = []

func readTerminal(_ fileName: String) -> [String] {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
        print("file not found: \(currentDirectoryURL.path)/\(fileName)")
        return []
    }
    let content = try! String(contentsOf: fileURL)
    let lines = content.split(separator: "\n")
    return lines.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
}

struct Node {
    let id: String
    let weight: Int
    let subNodeIDs: [String]

    lazy var subNodes: [Node] = {
        return subNodeIDs.map { nodes.index { $0.id == nodeID }! }
    }()

    var hasSubNodes: Bool {
        return subNodeIDs.count > 0
    }

    init(string: String) {
        let idSplitOff = string.split(separator: "(")
        id = String(idSplitOff.first!).trimmingCharacters(in: .whitespacesAndNewlines)
        let weightSplitOff = idSplitOff.last!.split(separator: ")")
        weight = Int(String(describing: weightSplitOff.first!).trimmingCharacters(in: .whitespacesAndNewlines))!
        var subNodeIDs: [String] = []
        if weightSplitOff.count > 1 {
            subNodeIDs = weightSplitOff.last!.dropFirst(4).split(separator: ",").map { String(describing: $0).trimmingCharacters(in: .whitespaces) }
        }
        self.subNodeIDs = subNodeIDs
    }

    var unbalancedSubNode: Node?

    lazy var isUnbalanced: Bool = {
        if !hasSubNodes { return false }

        let hasUnbalancedSubNodes = subNodes.reduce(false) {
            return $0 || $1.isUnbalanced
        }
        if hasUnbalancedSubNodes {
            unbalancedSubNode = subNodes.filter { $0.isUnbalanced }.first!
            return true
        }

        let weights = subNodes.map { $0.totalWeight }
        return weights.reduce(true) { $0 && $1 == weights[0] }
    }()

    lazy var totalWeight: Int {
        return weight + subNodes.map { $0.totalWeight }
    }
}

extension Node: CustomDebugStringConvertible {
    var debugDescription: String {
        if !hasSubNodes {
           return "\(id) (\(weight))"
        }
        return  "\(id) (\(weight)) -> \(subNodeIDs)"
    }
}

func findRoot() -> Node? {
    for node in nodes {
        var isRoot = true
        // print(node)
        for other in nodes.filter({ $0.hasSubNodes }) {
            if other.subNodeIDs.contains(node.id) {
                isRoot = false
                break
            }
        }
        if isRoot {
            return node
        }
    }
    return nil
}

func findWrongWeight() -> Int {
    let root = findRoot()
    print(root!.id)

    root.isUnbalanced()
    return 0
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    nodes = input.map { Node(string: $0)}
    let weightThatFixesIt = findWrongWeight()
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
