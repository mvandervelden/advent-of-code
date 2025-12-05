#!/usr/bin/env python3

def parse_input(filename):
    """Parse the input file into a list of lists of numbers."""
    reports = []

    with open(filename, 'r') as f:
        for line in f:
            numbers = line.strip().split()
            reports.append([int(num) for num in numbers])

    return reports

def is_safe_report(report):
    """Check if a report is safe.

    A report is considered safe if:
    - The levels are either all increasing or all decreasing.
    - Any two adjacent levels differ by at least one and at most three
    """
    increasing = all(x < y for x, y in zip(report, report[1:]))
    decreasing = all(x > y for x, y in zip(report, report[1:]))

    if not (increasing or decreasing):
        return False

    diffs = [abs(x - y) for x, y in zip(report, report[1:])]
    return all(1 <= d <= 3 for d in diffs)

def part1(reports):
    """Calculate the total safe reports"""
    return sum(1 for report in reports if is_safe_report(report))

def part2(reports):
    """Calculate the total safe reports including the problem dampener.

    If removing a single level from an unsafe report would make it safe,
    the report instead counts as safe.
    """
    total_safe = 0
    for report in reports:
        # Check if already safe
        if is_safe_report(report):
            total_safe += 1
            continue

        # Try removing each level and check again
        for i in range(len(report)):
            modified_report = report[:i] + report[i+1:]
            if is_safe_report(modified_report):
                total_safe += 1
                break

    return total_safe

def main():
    reports = parse_input('2.txt')

    result1 = part1(reports)
    print(f"Part 1: {result1}")

    result2 = part2(reports)
    print(f"Part 2: {result2}")

if __name__ == "__main__":
    main()
