struct Point2D: Hashable, CustomStringConvertible {
  let x: Int
  let y: Int

  init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  init(string: String) {
    let parts = string.split(separator: ",").map { Int($0)! }
    x = parts[0]
    y = parts[1]
  }

  var description: String { "(\(x),\(y))" }
}