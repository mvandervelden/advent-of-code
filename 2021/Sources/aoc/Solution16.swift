class Solution16: Solving {
  struct Rule {
    let name: String
    let ranges: [ClosedRange<Int>]
  }

  let file: File
  let rules: [Rule]
  let nearbyTickets: [[Int]]
  let yourTicket: [Int]

  required init(file: File) {
    self.file = file
    let blocks = file.linesSplitByEmptyLine
    let rulesString = blocks[0]

    rules = rulesString.map { rule in
      let parts = rule.components(separatedBy: ": ")
      let ruleName = parts[0]
      let vals = parts[1].components(separatedBy: " or ")
      let ranges = vals.map { (valRange: String) -> ClosedRange<Int> in
        let bounds = valRange.split(separator: "-")
        let range = Int(bounds[0])!...Int(bounds[1])!
        return range
      }
      return Rule(name: ruleName, ranges: ranges)
    }

    nearbyTickets = blocks[2].dropFirst().map { $0.components(separatedBy: ",").map { Int($0)! } }
    yourTicket = blocks[1][1].components(separatedBy: ",").map { Int($0)! }
  }

  func solve1() -> String {
    var errorRate = 0
    let allRanges = rules.flatMap(\.ranges)
    let allValues = nearbyTickets.flatMap { $0 }
    for val in allValues {
      var isContained = false
      for range in allRanges where range.contains(val) {
        isContained = true
        break
      }
      if !isContained {
        errorRate += val
      }
    }
    return errorRate.description
  }

  func solve2() -> String {
    // Filtering out the invalid tickets (loosely based on part 1)
    let valids = validTickets()

    // For each item on the tickets, get the possible rules that match all valid tickets
    var potRulesPerSlot: [[Rule]] = []
    for i in 0..<valids[0].count {
      var potentialRules = rules
      for valid in valids {
        if potentialRules.count == 1 { break }

        let nextCheck = valid[i]
        potentialRules = potentialRules.filter { rule in
          var isPossible = false
          for range in rule.ranges where range.contains(nextCheck) {
            isPossible = true
            break
          }
          return isPossible
        }
      }
      potRulesPerSlot.append(potentialRules)
    }

    // sort the possible rules per slot by amount of options,
    // so if for the first ticket item can be both "class" and "row", and the second item only "row",
    // then sort item 1 first. This makes iteration easier.
    var sorted = potRulesPerSlot.enumerated().sorted { $0.element.count < $1.element.count }

    // Loop over the sorted ticket item possibilities, pick the only option left,
    // and remove this option from the remainder of ticket item options
    // This leaves exactly 1 option for each ticket item
    for i in 0..<sorted.count {
      let rules = sorted[i].element
      if rules.count != 1 { preconditionFailure("should be 1 option left, got: \(rules)")}
      let currentRuleName = rules[0].name
      sorted = sorted[0...i] + sorted[(i + 1)...].map { rules in
        return (offset: rules.offset, element: rules.element.filter { $0.name != currentRuleName })
      }
    }

    // Sort the remaining ticket items back according to their original index, and keep the names only
    let reSortedNames = sorted.sorted { $0.offset < $1.offset }.map { $0.element[0].name }

    // match the values on your ticket with the names, only take the names containing "departure",
    // and calculate the product of these values
    let result = zip(reSortedNames, yourTicket)
      .filter { $0.0.contains("departure") }.reduce(1) { $0 * $1.1 }

    return result.description
  }

  func validTickets() -> [[Int]] {
    let allRanges = rules.flatMap(\.ranges)
    var valids: [[Int]] = []
    for ticket in nearbyTickets {
      var isValidTicket = true
      for val in ticket {
        var isContained = false
        for range in allRanges where range.contains(val) {
          isContained = true
          break
        }
        if !isContained {
          isValidTicket = false
        }
      }
      if isValidTicket {
        valids.append(ticket)
      }
    }
    return valids
  }
}
