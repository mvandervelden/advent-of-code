
// to run: `swift code.swift [input_filename]`
import Foundation


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

class Node {
    let id: String
    let weight: Int
    let subNodeIDs: [String]

    lazy var subNodes: [Node] = {
        return subNodeIDs.map { nodeID in nodes.filter { $0.id == nodeID }.first! }
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
    var wrongWeightSubNode: Node?
    var shouldWeigh: Int?

    func getAnswer() -> Int? {
        if shouldWeigh != nil {
            return shouldWeigh
        }
        if wrongWeightSubNode != nil {
            return wrongWeightSubNode!.getAnswer()
        }
        return subNodes.flatMap {
            $0.getAnswer()
        }.first
    }

    lazy var isUnbalanced: Bool = {
        if !hasSubNodes {
            print("\(id) BALANCED: has no subnodes")
            return false }

        let hasUnbalancedSubNodes = subNodes.reduce(false) {
            return $0 || $1.isUnbalanced
        }
        if hasUnbalancedSubNodes {
            unbalancedSubNode = subNodes.filter { $0.isUnbalanced }.first!
            print("\(id) UNBALANCED: due to subnodes")
            return true
        }

        let weights = subNodes.map { $0.totalWeight }
        let uniqueWeights = Set(weights)
        let allweightsBalanced = uniqueWeights.count == 1

        if allweightsBalanced {
            print("\(id) BALANCED")
        } else {
            print("\(id) UNBALANCED: due to weights")
            let wrongWeight = uniqueWeights.filter { w in weights.filter { $0 == w }.count == 1 }.first!
            let correctWeight = uniqueWeights.filter { w in weights.filter { $0 == w }.count > 1 }.first!
            wrongWeightSubNode = subNodes.filter { $0.totalWeight == wrongWeight }.first!

            wrongWeightSubNode!.shouldWeigh = correctWeight - wrongWeightSubNode!.totalWeight + wrongWeightSubNode!.weight
        }
        return !allweightsBalanced
    }()

    lazy var totalWeight: Int = {
        return weight + subNodes.reduce(0) { $0 + $1.totalWeight }
    }()
}

extension Node: CustomDebugStringConvertible {
    var debugDescription: String {
        if !hasSubNodes {
           return "\(id) (\(weight))"
        }
        return  "\(id) (\(weight)) -> \(subNodeIDs)"
    }
}

var nodes: [Node] = []

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

func findWrongWeight() {
    let root = findRoot()!
    print(root.id)

    print(root.isUnbalanced)
    print(root.unbalancedSubNode ?? "nil")
    print(root.wrongWeightSubNode ?? "nil")
    print(root.wrongWeightSubNode?.shouldWeigh ?? "nil")
    print(root.getAnswer() ?? "not found")
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    nodes = input.map { Node(string: $0)}
     findWrongWeight()
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
