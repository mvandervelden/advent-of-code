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

    var magnitude: Int {
      switch self {
      case .literal(let n): return n
      case .pair(let l, let r): return 3 * l.magnitude + 2 * r.magnitude
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
        let (newResult, eventsHappened) = resolve(result)
        result = newResult
        isResolved = !eventsHappened
      }
      print(result)
    }

    return result.magnitude.description
  }

  func solve2() -> String {
    let lines = file.lines.map(Item.init)
    var topMagnitude = 0

    for i in 0..<lines.count {
      for j in 0..<lines.count where i != j {
        var result = Item.pair(l: lines[i], r: lines[j])
        var isResolved = false

        while !isResolved {
          let (newResult, eventsHappened) = resolve(result)
          result = newResult
          isResolved = !eventsHappened
        }
        let mag = result.magnitude
        topMagnitude = max(mag, topMagnitude)
      }
    }

    return topMagnitude.description
  }

  private func resolve(_ item: Item) -> (Item, Bool) {
    var didHaveAnyEvent = false
    var parsedExplosions = false
    var result = item
    while !parsedExplosions {
      let (newResult, event) = resolveExplosions(result, depth: 0)
      print(result, "will resolve:", event)
      result = newResult
      if case .ok = event { parsedExplosions = true }
      if case .explode = event { didHaveAnyEvent = true }
    }

    let (newResult, event) = resolveSplits(result)
    print(result, "will resolve:", event)
    result = newResult
    if case .split = event { didHaveAnyEvent = true }

    return (result, didHaveAnyEvent)
  }

  private func resolveExplosions(_ item: Item, depth: Int) -> (Item, Event) {
    switch item {
    case .literal: return (item, .ok)
    // explode
    case .pair(.literal(let l), .literal(let r)) where depth == 4:
      return (.literal(0), .explode(l: l, r: r))
    case .pair where depth == 4:
      fatalError("unexpected situation, found \(item) at depth 4")
    case .pair(let l, let r):
      let (lResult, lEvent) = resolveExplosions(l, depth: depth + 1)
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

      let (rResult, rEvent) = resolveExplosions(r, depth: depth + 1)
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

  private func resolveSplits(_ item: Item) -> (Item, Event) {
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
    // pairs
    case .pair(let l, let r):
      let (lResult, lEvent) = resolveSplits(l)
      switch lEvent {
      case .split:
        return (.pair(l: lResult, r: r), lEvent)
      default: break
      }

      let (rResult, rEvent) = resolveSplits(r)
      return (.pair(l: lResult, r: rResult), rEvent)
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
