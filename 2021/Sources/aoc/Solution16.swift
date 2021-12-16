class Solution16: Solving {
  enum Instruction: CustomStringConvertible {
    case literal(Int)
    case sum([Instruction])
    case product([Instruction])
    case minimum([Instruction])
    case maximum([Instruction])
    case greaterThan([Instruction])
    case lessThan([Instruction])
    case equal([Instruction])

    var description: String {
      switch self {
      case .literal(let val): return "lit: \(val)"
      case .sum(let instructions): return "sum: \(instructions.description)"
      case .product(let instructions): return "prd: \(instructions.description)"
      case .minimum(let instructions): return "min: \(instructions.description)"
      case .maximum(let instructions): return "max: \(instructions.description)"
      case .greaterThan(let instructions): return "grt: \(instructions.description)"
      case .lessThan(let instructions): return "lst: \(instructions.description)"
      case .equal(let instructions): return "eql: \(instructions.description)"
      }
    }

    init(type: Int, instructions: [Instruction]) {
      switch type {
      case 0: self = .sum(instructions)
      case 1: self = .product(instructions)
      case 2: self = .minimum(instructions)
      case 3: self = .maximum(instructions)
      case 5: self = .greaterThan(instructions)
      case 6: self = .lessThan(instructions)
      case 7: self = .equal(instructions)
      default: fatalError("unexpected type \(type)")
      }
    }

    var value: Int {
      switch self {
      case .literal(let val): return val
      case .sum(let instructions): return instructions.map(\.value).sum()
      case .product(let instructions): return instructions.map(\.value).product()
      case .minimum(let instructions): return instructions.map(\.value).min()!
      case .maximum(let instructions): return instructions.map(\.value).max()!
      case .greaterThan(let instructions): return instructions[0].value > instructions[1].value ? 1 : 0
      case .lessThan(let instructions): return instructions[0].value < instructions[1].value ? 1 : 0
      case .equal(let instructions): return instructions[0].value == instructions[1].value ? 1 : 0
      }
    }
  }

  let file: File
  var versionSum = 0

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let binary = getBinary()
    _ = parsePacket(binary)
    return versionSum.description
  }

  func solve2() -> String {
    let binary = getBinary()
    let (_, instruction) = parsePacket(binary)
    return instruction.value.description
  }

  private func getBinary() -> [Character] {
    var binArray: [Character] = []

    for char in file.lines[0] {
      let int = Int(String(char), radix: 16)!
      var bin = Array(String(int, radix: 2))
      let leading0s = 4 - bin.count
      bin = Array(repeating: "0", count: leading0s) + bin

      binArray.append(contentsOf: bin)
    }

    return binArray
  }

  private func parsePacket(_ binary: [Character]) -> ([Character], Instruction) {
    let version = Int(String(binary[0..<3]), radix: 2)!
    let type = Int(String(binary[3..<6]), radix: 2)!
    versionSum += version

    if type == 4 { // literal
      let remainder = Array(binary[6...])
      var willStop = false
      var i = 0
      var value: [Character] = []

      while !willStop {
        willStop = remainder[i] == "0"
        value.append(contentsOf: remainder[i+1..<i+5])
        i += 5
      }

      let intValue = Int(String(value), radix: 2)!
      let instruction = Instruction.literal(intValue)
      return (Array(remainder[i...]), instruction)
    } else {
      // Operation

      let lengthType = binary[6]
      if lengthType == "0" {
        // 15-bit length description
        let length = Int(String(binary[7..<22]), radix: 2)!
        var remainder = Array(binary[22...])
        let goalRemainderCount = remainder.count - length
        var currentRemainderCount = remainder.count
        var instructions: [Instruction] = []

        while currentRemainderCount > goalRemainderCount {
          let tuple = parsePacket(remainder)
          remainder = tuple.0
          currentRemainderCount = remainder.count
          instructions.append(tuple.1)
        }

        let instruction = Instruction(type: type, instructions: instructions)

        return (remainder, instruction)
      } else {
        // 11-bit no of packets description
        let noOfSubPackets = Int(String(binary[7..<18]), radix: 2)!
        var remainder = Array(binary[18...])
        var instructions: [Instruction] = []

        for _ in 0..<noOfSubPackets {
          let tuple = parsePacket(remainder)
          remainder = tuple.0
          instructions.append(tuple.1)
        }

        let instruction = Instruction(type: type, instructions: instructions)
        return (remainder, instruction)
      }
    }
  }
}
