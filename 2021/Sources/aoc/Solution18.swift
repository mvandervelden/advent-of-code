class Solution18: Solving {
  enum Event: CustomStringConvertible, Equatable {
    case split
    case explode(l: Int?, r: Int?)
    case ok

    var description: String {
      switch self {
      case .split: return "split"
      case .explode: return "explode"
      case .ok: return "ok"
      }
    }
  }

  indirect enum Item: CustomStringConvertible {
    case literal(Int)
    case pair(l: Item, r: Item)

    init(string: String) {
      guard string.first == "[" else { self = .literal(Int(string)!); return }

      let array = Array(string)
      var depth = 0
      var splitIndex = -1
      for (i, char) in array.enumerated() {
        if char == "," && depth == 1 {
          splitIndex = i
          break
        } else if char == "[" {
          depth += 1
        } else if char == "]" {
          depth -= 1
        }
      }

      let left = String(array[1..<splitIndex])
      let right = String(array[(splitIndex + 1)..<(array.count - 1)])

      self = .pair(l: Item(string: left), r: Item(string: right))
    }

    var description: String {
      switch self {
      case .literal(let int): return int.description
      case .pair(let l, let r): return "[\(l),\(r)]"
      }
    }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let lines = file.lines.map(Item.init)

    var result = lines[0]

    print(result)

    for line in lines[1...] {
      result = .pair(l: result, r: line)
      var isResolved = false

      while !isResolved {
        let (newResult, event) = resolve(result, depth: 0)
        print(newResult, "didResolve:", event)
        result = newResult
        isResolved = event == .ok
      }
      print(result)
    }

    return result.description
  }

  func solve2() -> String {
    return "TBD"
  }

  private func resolve(_ item: Item, depth: Int) -> (Item, Event) {
    switch item {
    case .literal(0..<10): return (item, .ok)
    // split even
    case .literal(let n) where n%2 == 0:
      let newN = n / 2
      return (.pair(l: .literal(newN), r: .literal(newN)), .split)
    // split odd
    case .literal(let n):
      let newN = n / 2
      return (.pair(l: .literal(newN), r: .literal(newN + 1)), .split)
    // explode
    case .pair(.literal(let l), .literal(let r)) where depth == 4:
      return (.literal(0), .explode(l: l, r: r))
    case .pair where depth == 4:
      fatalError("unexpected situation, found \(item) at depth 4")
    case .pair(let l, let r):
      let (lResult, lEvent) = resolve(l, depth: depth + 1)
      switch lEvent {
      case .ok:
        break
      case .split:
        return (.pair(l: lResult, r: r), lEvent)
      case .explode(let carryL, .some(let carryR)):
        let newR = addCarryL(carryR, item: r)
        return (.pair(l: lResult, r: newR), .explode(l: carryL, r: nil))
      case .explode(_, .none):
        return (.pair(l: lResult, r: r), lEvent)
      }

      let (rResult, rEvent) = resolve(r, depth: depth + 1)
      switch rEvent {
      case .ok:
        break
      case .split:
        return (.pair(l: lResult, r: rResult), rEvent)
      case .explode(.some(let carryL), let carryR):
        let newL = addCarryR(carryL, item: lResult)
        return (.pair(l: newL, r: rResult), .explode(l: nil, r: carryR))
      case .explode(.none, _):
        return (.pair(l: lResult, r: rResult), rEvent)
      }

      return (item, .ok)
    }
  }

  private func addCarryL(_ carryL: Int, item: Item) -> Item {
    switch item {
    case .literal(let i): return .literal(i + carryL)
    case .pair(let l, let r):
      return .pair(l: addCarryL(carryL, item: l), r: r)
    }
  }

  private func addCarryR(_ carryR: Int, item: Item) -> Item {
    switch item {
    case .literal(let i): return .literal(i + carryR)
    case .pair(let l, let r):
      return .pair(l: l, r: addCarryR(carryR, item: r))
    }
  }
}
