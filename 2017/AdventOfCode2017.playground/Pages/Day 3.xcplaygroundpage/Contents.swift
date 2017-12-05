//: [Previous](@previous)

import Foundation

let input = 277678
let example1 = 1 //0
let example2 = 12 //3
let example3 = 23//2
let example4 = 1024//31

func evenOffset(for root: Int) -> (x: Int, y: Int) {
    let rootIndex = root / 2
    return (x: -rootIndex + 1, y: rootIndex)
}

func evenHalfwayOffset(for root: Int) -> (x: Int, y: Int) {
    let rootIndex = root / 2
    return (x: -rootIndex, y: -rootIndex)
}

func oddOffset(for root: Int) -> (x: Int, y: Int) {
    let rootIndex = (root + 1) / 2
    return (x: rootIndex - 1, y: -rootIndex + 1)
}

func oddHalfwayOffset(for root: Int) -> (x: Int, y: Int) {
    let rootIndex = (root + 1) / 2
    return (x: rootIndex, y: rootIndex)
}

func neighbors(of coord: (x: Int, y: Int)) -> [(x: Int, y: Int)] {

    return []
}

func solve1() {
    let address = input

    let root = sqrt(Double(address))
    let baseRoot = floor(root)
    let base = pow(baseRoot, 2.0)

    let nextRoot = ceil(root)
    let next = pow(nextRoot, 2.0)

    let halfWayCorner = Int(ceil((base + next) * 0.5))
    let halfwayOffset = address - halfWayCorner

    var resultCoords: (x: Int, y: Int) = (0, 0)

    switch halfwayOffset {
    case Int.min...0 where Int(baseRoot) % 2 == 0:
        //upper left down
        let baseOffset = evenOffset(for: Int(baseRoot))
        let progress = address - Int(base)
        let yProgress = progress == 0 ? baseOffset.y : baseOffset.y - progress + 1
        let xProgress = progress == 0 ? baseOffset.x : baseOffset.x - 1
        resultCoords = (x: xProgress, y: yProgress)
    case Int.min...0:
        //lower right up
        let baseOffset = oddOffset(for: Int(baseRoot))
        let progress = address - Int(base)
        let yProgress = progress == 0 ? baseOffset.y : baseOffset.y + progress - 1
        let xProgress = progress == 0 ? baseOffset.x : baseOffset.x + 1
        resultCoords = (x: xProgress, y: yProgress)
    case 1...Int.max where Int(baseRoot) % 2 == 0:
        //lower left right
        let baseOffset = evenHalfwayOffset(for: Int(baseRoot))
        let progress = halfwayOffset
        let yProgress = baseOffset.y
        let xProgress = baseOffset.x + progress
        resultCoords = (x: xProgress, y: yProgress)
    default:
        //upper right left
        let baseOffset = oddHalfwayOffset(for: Int(baseRoot))
        let progress = halfwayOffset
        let yProgress = baseOffset.y
        let xProgress = baseOffset.x - progress
        resultCoords = (x: xProgress, y: yProgress)
    }

    print(resultCoords)
    print(abs(resultCoords.x) + abs(resultCoords.y))
}

class Grid {
    lazy var grid: [[Int]] = gridOfSize(5)

    var offset: Int {
        return grid.count / 2
    }

    subscript(x: Int, y: Int) -> Int {
        get {
            if offset - y >= grid.count || x + offset >= grid.count || offset - y < 0 || x + offset < 0 {
                return 0
            }
            return grid[offset - y][x + offset]
        }
        set {
            if x + offset >= grid.count || offset - y >= grid[0].count
                || x + offset < 0 || offset - y < 0 {
                let newGrid = gridOfSize(grid.count + 4)
                fill(newGrid, offset: 2)
            }
            grid[offset - y][x + offset] = newValue
        }
    }

    func gridOfSize(_ size: Int) -> [[Int]] {
        return Array(repeatElement(Array(repeatElement(0, count: size)), count: size))
    }

    func fill(_ newGrid: [[Int]], offset: Int) {
        var newGrid = newGrid
        grid.enumerated().forEach { column in
            column.element.enumerated().forEach { item in
                newGrid[column.offset + offset][item.offset + offset] = item.element
            }
        }
        grid = newGrid
    }

    var index = 1

    func coordinates(for index: Int) -> (x: Int, y: Int) {
        let root = sqrt(Double(index))
        let baseRoot = floor(root)
        let base = pow(baseRoot, 2.0)

        let nextRoot = ceil(root)
        let next = pow(nextRoot, 2.0)

        let halfWayCorner = Int(ceil((base + next) * 0.5))
        let halfwayOffset = index - halfWayCorner

        var resultCoords: (x: Int, y: Int) = (0, 0)

        switch halfwayOffset {
        case Int.min...0 where Int(baseRoot) % 2 == 0:
            //upper left down
            let baseOffset = evenOffset(for: Int(baseRoot))
            let progress = index - Int(base)
            let yProgress = progress == 0 ? baseOffset.y : baseOffset.y - progress + 1
            let xProgress = progress == 0 ? baseOffset.x : baseOffset.x - 1
            resultCoords = (x: xProgress, y: yProgress)
        case Int.min...0:
            //lower right up
            let baseOffset = oddOffset(for: Int(baseRoot))
            let progress = index - Int(base)
            let yProgress = progress == 0 ? baseOffset.y : baseOffset.y + progress - 1
            let xProgress = progress == 0 ? baseOffset.x : baseOffset.x + 1
            resultCoords = (x: xProgress, y: yProgress)
        case 1...Int.max where Int(baseRoot) % 2 == 0:
            //lower left right
            let baseOffset = evenHalfwayOffset(for: Int(baseRoot))
            let progress = halfwayOffset
            let yProgress = baseOffset.y
            let xProgress = baseOffset.x + progress
            resultCoords = (x: xProgress, y: yProgress)
        default:
            //upper right left
            let baseOffset = oddHalfwayOffset(for: Int(baseRoot))
            let progress = halfwayOffset
            let yProgress = baseOffset.y
            let xProgress = baseOffset.x - progress
            resultCoords = (x: xProgress, y: yProgress)
        }
        return resultCoords
    }

    func nextValue() -> Int {
        index += 1
        let nextCoordinates = coordinates(for: index)
        let nextValue = sumOfNeighbors(x: nextCoordinates.x, y: nextCoordinates.y)
        self[nextCoordinates.x, nextCoordinates.y] = nextValue
        return nextValue
    }

    func sumOfNeighbors(x: Int, y: Int) -> Int {
        return ((x - 1)...(x + 1)).reduce(0) { (sum, nextX) in
            return sum + ((y - 1)...(y + 1)).reduce(0) { (sumY, nextY) in
                return sumY + self[nextX, nextY]
            }
        }
    }

}

extension Grid: CustomDebugStringConvertible {
    var debugDescription: String {
        return grid.reduce("") { (linesString, line) in
            return linesString + "\n" + line.reduce("") { (itemsString, item) in
                return itemsString + " " + String.init(format: "%8d", item)
            }
        }
    }
}


func solve2() {
    let grid = Grid()
    grid[0, 0] = 1
    var value = 1
    while value < input {
        value = grid.nextValue()
    }
    print(grid)
    print(value)
}

//solve1()
solve2()

//: [Next](@next)
