import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {
    struct Node {
        let id: Int
        var children: [Int]
        var metadata: [Int]

        var totalMetadata: Int {
            return metadata.reduce(0, +)
        }

        func value(tree: [Int: Node]) -> Int {
            if children.isEmpty {
                return totalMetadata
            } else {
                return metadata.reduce(0) { sum, nextChildInd in
                    if (nextChildInd - 1) < 0 || (nextChildInd - 1) >= children.count {
                        return sum
                    }
                    if let node = tree[children[nextChildInd - 1]] {
                        return sum + node.value(tree: tree)
                    } else {
                        return sum
                    }
                }
            }
        }
    }

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        // let result2 = solve2(input: input)
        return "\(result1)"
    }

    var tree: [Int: Node] = [:]
    var _curID: Int = 0
    var currentID: Int {
        let id = _curID
        _curID += 1
        return id
    }

    private func solve1(input: String) -> String {
        let treeInput = input.dropLast().split(separator: " ").map { Int($0)! }
        nextNode(input: treeInput, pendingChildren: [], pendingMetadata: [], currentNode: [], depth: -2)
        // print(tree)
        return "r1: \(tree.reduce(0) { return $0 + $1.value.totalMetadata })\nr2: \(tree[0]!.value(tree: tree))"
    }

    private func nextNode(input: [Int], pendingChildren: [Int], pendingMetadata: [Int], currentNode: [Int], depth: Int) {
        var input = input
        print("in: \(input.count), pc: \(pendingChildren.count), pm: \(pendingMetadata.count), cn: \(currentNode.count), dpt: \(depth)")
        if depth == -2 {
            print("start")
            //start
            let children = input[0]
            let metadata = input[1]
            let id = currentID
            tree[id] = Node(id: id, children: [], metadata: [])

            input.removeFirst(2)

            nextNode(input: input, pendingChildren: [children], pendingMetadata: [metadata], currentNode: [id], depth: 0)
        } else if depth == -1 {
            print("end")
            //end
            return
        } else if pendingChildren[depth] > 0 {
            print("Next node")
            //Next level, select next node
            let children = input[0]
            let metadata = input[1]
            let id = currentID
            tree[id] = Node(id: id, children: [], metadata: [])
            input.removeFirst(2)
            tree[currentNode[depth]]!.children.append(id)
            nextNode(
                input: input, 
                pendingChildren: pendingChildren + [children],
                pendingMetadata: pendingMetadata + [metadata],
                currentNode: currentNode + [id],
                depth: depth + 1)
        } else {
            print("Close node")
            //Add metadata, close node
            let noMetadata = pendingMetadata[depth]
            let metadata = input[0..<noMetadata]
            input.removeFirst(noMetadata)
            tree[currentNode[depth]]!.metadata = Array(metadata)

            var newPendingChildren = Array(pendingChildren[0..<depth])
            
            if newPendingChildren.isEmpty {
                nextNode(input: input, pendingChildren: [], pendingMetadata: [], currentNode: [], depth: depth - 1)
                return
            }
            
            newPendingChildren[newPendingChildren.count - 1] -= 1
            nextNode(
                input: input,
                pendingChildren: newPendingChildren,
                pendingMetadata: Array(pendingMetadata[0..<depth]),
                currentNode: Array(currentNode[0..<depth]),
                depth: depth - 1
            )
        }
    }


    // in: 2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
    // pc: []
    // pm: []
    // cn: []
    // dp: -2
    // tr: []

// Next level, select next node
    // in: 0 3 10 11 12 1 1 0 1 99 2 1 1 2
    // pc: [2]
    // pm: [3]
    // cn: [0]
    // dp: 0
    // tr: [0: (c: [], m: [])]
    // tr: []

// Next level, select next node
    // in: 10 11 12 1 1 0 1 99 2 1 1 2
    // pc: [2, 0]
    // pm: [3, 3]
    // cn: [0, 1]
    // dp: 1
    // tr: [0: (c: [1], m: []), 1: (c: [], m: [])]

// Add metadata, close node
    // in: 1 1 0 1 99 2 1 1 2
    // pc: [1]
    // pm: [3]
    // cn: [0]
    // dp: 0
    // tr: [0: (c: [1], m: []), 1: (c: [], m: [10, 11, 12])]

// Next level, select next node
    // in: 0 1 99 2 1 1 2
    // pc: [1, 1]
    // pm: [3, 1]
    // cn: [0, 2]
    // dp: 1
    // tr: [0: (c: [1, 2], m: []), 1: (c: [], m: [10, 11, 12]), 2: (c: [], m: [])]

// Next level, select next node
    // in: 99 2 1 1 2
    // pc: [1, 1, 0]
    // pm: [3, 1, 1]
    // cn: [0, 2, 3]
    // dp: 2
    // tr: [0: (c: [1, 2], m: []), 1: (c: [], m: [10, 11, 12]), 2: (c: [3], m: []), 3: (c: [], m: [])]

// Add metadata, close node
    // in: 2 1 1 2
    // pc: [1, 0]
    // pm: [3, 1]
    // cn: [0, 2]
    // dp: 1
    // tr: [0: (c: [1, 2], m: []), 1: (c: [], m: [10, 11, 12]), 2: (c: [3], m: []), 3: (c: [], m: [99])]

// Add metadata, close node
    // in: 1 1 2
    // pc: [0]
    // pm: [3]
    // cn: [0]
    // dp: 0
    // tr: [0: (c: [1, 2], m: []), 1: (c: [], m: [10, 11, 12]), 2: (c: [3], m: [2]), 3: (c: [], m: [99])]

// Add metadata, close node
    // in: []
    // pc: []
    // pm: []
    // cn: []
    // dp: -1
    // tr: [0: (c: [1, 2], m: [1, 2, 2]), 1: (c: [], m: [10, 11, 12]), 2: (c: [3], m: [2]), 3: (c: [], m: [99])]

// return


    private func solve2(input: String) -> String {
        return "No match found"
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