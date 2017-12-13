
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

enum Direction {
    case up, down
}

class Layer {
    let idx: Int
    let rng: Int
    var currentPosition: Int = 0
    var currentDirection: Direction = .up

    init(idx: Int, rng: Int) {
        self.idx = idx
        self.rng = rng
    }

    func step() {
        switch (currentDirection, currentPosition) {
        case (.up, 0..<(rng - 1)):
            currentPosition += 1
        case (.up, rng - 1):
            currentPosition -= 1
            currentDirection = .down
        case (.down, 1...(rng - 1)):
            currentPosition -= 1
        case (.down, _):
            currentPosition += 1
            currentDirection = .up
        default:
            break
        }
    }
}

extension Layer: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(idx): \(rng) [\(currentPosition)]"
    }
}

class FireWall {
    let layers: [Layer]
    var curIndex = -1
    var severity = 0
    let maxIndex: Int

    init(layers: [Layer]) {
        self.layers = layers
        maxIndex = layers.last!.idx
    }

    func curCollosions() -> Int {
        for layer in layers {
            if layer.idx == curIndex {
                if layer.currentPosition == 0 {
                    print("COLLISION: \(layer.idx * layer.rng)")
                    print(self)
                    return layer.idx * layer.rng
                }
            }
        }
        return 0
    }

    func step() {
        curIndex += 1
        severity += curCollosions()
        layers.forEach { $0.step() }
    }

    func play() -> Int {
        (curIndex...maxIndex).forEach { _ in
            // print(self)
            step()
        }
        return severity
    }
}

extension FireWall: CustomDebugStringConvertible {
    var debugDescription: String {
        return "layers: \(layers)\n\(curIndex): severity: \(severity), maxIndex:\(maxIndex)"
    }
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let lines = input.split(separator: "\n")
    let layers: [Layer] = lines.map { line in
        let content = line.split(separator: ":")
        return Layer(idx: Int(String(content.first!.trimmingCharacters(in: .whitespaces)))!,
                rng: Int(String(content.last!.trimmingCharacters(in: .whitespaces)))!)
    }
    let fw = FireWall(layers: layers)
    print(fw.play())
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
