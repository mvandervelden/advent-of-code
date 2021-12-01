enum PassportField: String, CaseIterable {
  case ecl
  case pid
  case eyr
  case hcl
  case byr
  case iyr
  case hgt
  // case cid // optional, ignored
}

class Solution04: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let passportStrings = file.wordsSplitByEmptyLine

    var invalids = 0

    for ppt in passportStrings {
      for param in PassportField.allCases {
        guard ppt.first(where: { $0.hasPrefix(param.rawValue) }) != nil else {
          invalids += 1
          break
        }
      }
    }
    return (passportStrings.count - invalids).description
  }

  func solve2() -> String {
    let passportStrings = file.wordsSplitByEmptyLine

    var invalids = 0

    for ppt in passportStrings {
      for param in PassportField.allCases {
        guard let val = ppt.first(where: { $0.hasPrefix(param.rawValue) })?.split(separator: ":").last else {
          invalids += 1
          break
        }

        var foundInvalid = false

        switch param {
        case .byr:
          guard let intVal = Int(val), intVal >= 1920, intVal <= 2002 else {
            foundInvalid = true
            break
          }
        case .iyr:
          guard let intVal = Int(val), intVal >= 2010, intVal <= 2020 else {
            foundInvalid = true
            break
          }
        case .eyr:
          guard let intVal = Int(val), intVal >= 2020, intVal <= 2030 else {
            foundInvalid = true
            break
          }
        case .hgt:
          switch val.count {
          case 4: // in
            guard val.hasSuffix("in"), let intVal = Int(val.prefix(2)), intVal >= 59, intVal <= 76 else {
              foundInvalid = true
              break
            }
          case 5: //cm
            guard val.hasSuffix("cm"), let intVal = Int(val.prefix(3)), intVal >= 150, intVal <= 193 else {
              foundInvalid = true
              break
            }
          default:
            foundInvalid = true
            break
          }
          case .hcl:
            guard let first = val.first, first == "#" else { foundInvalid = true; break }
            let vals = Array(val.dropFirst())

            guard vals.count == 6 else { foundInvalid = true; break }

            let isValid = vals.reduce(true) { $0 && $1.isHexDigit }
            if !isValid { foundInvalid = true; break }
          case .ecl:
            guard ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].contains(val) else { foundInvalid = true; break }
          case .pid:
            guard val.count == 9, Int(val) != nil else { foundInvalid = true; break }
        }
        if foundInvalid {
          invalids += 1
          break
        }
      }
    }
    return (passportStrings.count - invalids).description
  }
}
