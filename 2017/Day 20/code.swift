
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

struct Vector {
    let x: Int
    let y: Int
    let z: Int

    init(string: String) {
        let dimensions: [String] = string.split(separator: ",").map { String($0).trimmingCharacters(in:.whitespaces) }
        x = Int(String(dimensions[0]))!
        y = Int(String(dimensions[1]))!
        z = Int(String(dimensions[2]))!
    }

    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    var magnitude: Int {
        return abs(x) + abs(y) + abs(z)
    }
}

extension Vector: CustomStringConvertible {
    var description: String {
        return "<\(x),\(y),\(z)>"
    }
}

extension Vector {
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
}

extension Vector: Equatable {
    static func ==(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

class Particle {
    var p: Vector
    var v: Vector
    let a: Vector

    init(string: String) {
        let vectors = string.split(separator: ">")
        let pString = vectors[0].dropFirst(3)
        p = Vector(string: String(pString))
        let vString = vectors[1].dropFirst(5)
        v = Vector(string: String(vString))
        let aString = vectors[2].dropFirst(5)
        a = Vector(string: String(aString))
    }

    func move() -> Particle {
        v = v + a
        p = p + v
        return self
    }
}

extension Particle: CustomStringConvertible {
    var description: String {
        return "p=\(p), v=\(v), a=\(a)"
    }
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let particles = input.split(separator:"\n").map { Particle(string: String($0)) }
    
    let slowest = particles.enumerated().min { lhs, rhs in
        return lhs.element.a.magnitude < rhs.element.a.magnitude
    }!
    print(slowest)
    // print(particles)
}

func solve2(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let particles = input.split(separator:"\n").map { Particle(string: String($0)) }
    
    var remaining = particles
    
    for i in 0..<100 {
        print("\(i): \(remaining.count)")
        if remaining.count == 1 {
            break
        }
        remaining = remaining.map { $0.move() }
        remaining = remaining.filter { particle in
            return remaining.filter { $0.p == particle.p }.count == 1
        }
    }

    
    // print(particles)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve2(fileName: fileName)
} else {
    solve2()
}
