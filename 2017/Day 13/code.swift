
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

struct Layer {
    let idx: Int
    let rng: Int
    let currentPosition: Int
    let currentDirection: Direction
    let period: Int

    init(idx: Int, rng: Int, curPos: Int = 0, curDir: Direction = .up) {
        self.idx = idx
        self.rng = rng
        period = rng * 2 - 2
        currentPosition = curPos
        currentDirection = curDir
    }

    func step() -> Layer {
        switch (currentDirection, currentPosition) {
        case (.up, 0..<(rng - 1)):
            return Layer(idx: idx, rng: rng, curPos: currentPosition + 1, curDir: currentDirection)
        case (.up, rng - 1):
            return Layer(idx: idx, rng: rng, curPos: currentPosition - 1, curDir: .down)
        case (.down, 1...(rng - 1)):
            return Layer(idx: idx, rng: rng, curPos: currentPosition - 1, curDir: .down)
        case (.down, _):
            return Layer(idx: idx, rng: rng, curPos: currentPosition + 1, curDir: .up)
        default:
            fatalError()
        }
    }

    func hits(at: Int) -> Bool {
        return (at + idx) % period == 0
    }
}

extension Layer: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(idx): \(rng) [\(currentPosition)]"
    }
}

class FireWall {
    let initialLayers: [Layer]
    let maxIndex: Int
    var layers: [Layer]
    var curIndex = -1
    var severity: Int = 0
    var noCollisions = 0

    init(layers: [Layer]) {
        self.initialLayers = layers
        self.layers = layers
        maxIndex = layers.last!.idx
    }

    func curCollosions() -> Int {
        for layer in layers {
            if layer.idx == curIndex {
                if layer.currentPosition == 0 {
                    // print("COLLISION: \(layer.idx * layer.rng)")
                    noCollisions += 1
                    // print(self)
                    return layer.idx * layer.rng
                }
            }
        }
        return 0
    }

    func step() {
        curIndex += 1
        severity += curCollosions()
        for i in 0..<layers.count {
            layers[i] = layers[i].step()
        }
    }

    func play() -> Int {
        (curIndex...maxIndex).forEach { _ in
            // print(self)
            step()
        }
        return severity
    }

    func bestPlay() -> Int {
        var startIdx = -1
        var collides = true
        while collides {
            collides = false
            startIdx += 1
            for layer in layers {
                if layer.hits(at: startIdx) {
                    collides = true
                    break
                }
            }
        }
        return startIdx
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

func solve2(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let lines = input.split(separator: "\n")
    let layers: [Layer] = lines.map { line in
        let content = line.split(separator: ":")
        return Layer(idx: Int(String(content.first!.trimmingCharacters(in: .whitespaces)))!,
                rng: Int(String(content.last!.trimmingCharacters(in: .whitespaces)))!)
    }
    let fw = FireWall(layers: layers)
    print(fw.bestPlay())
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve2(fileName: fileName)
} else {
    solve2()
}
