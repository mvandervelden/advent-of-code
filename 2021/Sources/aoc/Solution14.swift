struct Instr {
  let address: Int
  let val: Int
}

struct Section {
  let mask: String
  var instrs: [Instr] = []
}

class Solution14: Solving {
  let file: File
  let input: [Section]

  required init(file: File) {
    self.file = file

    var sections: [Section] = []
    var openSection: Section? = nil

    for line in file.lines {
      let parts = line.components(separatedBy: " = ")
      if parts[0] == "mask" {
        if let os = openSection {
          sections.append(os)
        }

        openSection = Section(mask: parts[1])
      } else {
        let addressPart = parts[0]
        let addressVal = Int(addressPart.dropFirst(4).dropLast())!
        openSection!.instrs.append(Instr(address: addressVal, val: Int(parts[1])!))
      }
    }
    sections.append(openSection!)
    self.input = sections
  }

  func solve1() -> String {
    var memory: [Int: Int] = [:]
    for section in input {
      let mask = Array(section.mask)
      for instr in section.instrs {
        let bval = Array(String(instr.val, radix: 2))
        let valPadding = Array(repeating: "0" as Character, count: mask.count - bval.count)
        let paddedVal = valPadding + bval
        let bres: [Character] = zip(mask, paddedVal).map { (maskBit, valBit) in
          switch maskBit {
          case "X": return valBit
          default: return maskBit
          }
        }
        let res = Int(String(bres), radix: 2)
        // print(instr, paddedVal, bres, res)
        memory[instr.address] = res
      }
    }
    // print(memory)
    let sum = memory.values.reduce(0, +)
    return sum.description
  }

  func solve2() -> String {
    var memory: [Int: Int] = [:]
    for section in input {
      let mask = Array(section.mask)
      for instr in section.instrs {
        let baddr = Array(String(instr.address, radix: 2))
        let addrPadding = Array(repeating: "0" as Character, count: mask.count - baddr.count)
        let paddedAddr = addrPadding + baddr
        let bres: [Character] = zip(mask, paddedAddr).map { (maskBit, addrBit) in
          switch maskBit {
          case "0": return addrBit
          default: return maskBit
          }
        }

        var resAddresses: [[Character]] = [[]]
        for reschar in bres {
          switch reschar {
          case "X":
            let newResults0 = resAddresses.map { $0 + ["0"] }
            let newResults1 = resAddresses.map { $0 + ["1"] }
            resAddresses = newResults0 + newResults1
          default:
            let newResults = resAddresses.map { $0 + [reschar] }
            resAddresses = newResults
          }
        }

        for address in resAddresses {
          let res = Int(String(address), radix: 2)!
          // print(instr, paddedVal, bres, res)
          memory[res] = instr.val
        }
      }
    }
    // print(memory)
    let sum = memory.values.reduce(0, +)
    return sum.description
  }
}
