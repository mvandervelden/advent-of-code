import ArgumentParser

protocol Solving {
  init(file: File)

  func solve1() -> String
  func solve2() -> String
}

struct AOC: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Running AOC 2020")

    @Argument(help: "Day (1-25)")
    private var day: Int

    @Argument(help: "Part (1-2)")
    private var part: Int = 1

    @Argument(help: "input filename")
    private var inputFileName: String = "input.txt"

    func run() throws {
        print("Running with day \(day), part \(part), input \(inputFileName)")

        let file = File(day: day, filename: inputFileName)
        let result = solution(for: day, file: file)

        switch part {
        case 1:
            print(result.solve1())
        default:
            print(result.solve2())
        }
    }

    func solution(for day: Int, file: File) -> Solving {
        switch day {
        case  1: return Solution01(file: file)
        case  2: return Solution02(file: file)
        case  3: return Solution03(file: file)
        case  4: return Solution04(file: file)
        case  5: return Solution05(file: file)
        case  6: return Solution06(file: file)
        case  7: return Solution07(file: file)
        case  8: return Solution08(file: file)
        case  9: return Solution09(file: file)
        case 10: return Solution10(file: file)
        case 11: return Solution11(file: file)
        case 12: return Solution12(file: file)
        case 13: return Solution13(file: file)
        case 14: return Solution14(file: file)
        case 15: return Solution15(file: file)
        case 16: return Solution16(file: file)
        case 17: return Solution17(file: file)
        case 18: return Solution18(file: file)
        case 19: return Solution19(file: file)
        case 20: return Solution20(file: file)
        case 21: return Solution21(file: file)
        case 22: return Solution22(file: file)
        case 23: return Solution23(file: file)
        case 24: return Solution24(file: file)
        case 25: return Solution25(file: file)
        default: preconditionFailure("wrong day \(day)")
        }
    }
}

AOC.main()