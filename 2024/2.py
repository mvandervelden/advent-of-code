#!/usr/bin/env python3

def parse_input(filename):
    """Parse the input file into a list of lists of numbers."""
    reports = []

    with open(filename, 'r') as f:
        for line in f:
            numbers = line.strip().split()
            reports.append([int(num) for num in numbers])

    return reports

def part1(reports):
    """Calculate the total safe reports"""

    total_safe = 0
    for report in reports:
        """A report is considered safe if:
        - The levels are either all increasing or all decreasing.
        - Any two adjacent levels differ by at least one and at most three
        """
        increasing = all(x < y for x, y in zip(report, report[1:]))
        decreasing = all(x > y for x, y in zip(report, report[1:]))
        if not (increasing or decreasing):
            continue

        diffs = [abs(x - y) for x, y in zip(report, report[1:])]
        if all(1 <= d <= 3 for d in diffs):
            total_safe += 1

    return total_safe

def main():
    reports = parse_input('2.txt')

    result1 = part1(reports)
    print(f"Part 1: {result1}")

    # result2 = part2(left_list, right_list)
    print(f"Pending..")

if __name__ == "__main__":
    main()
