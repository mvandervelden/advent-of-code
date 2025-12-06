#!/usr/bin/env python3

def parse_worksheet(lines):
    """Parse the worksheet and extract vertical problems."""
    # Find the maximum line length to handle all columns
    max_len = max(len(line) for line in lines)

    # Pad all lines to the same length
    padded_lines = [line.ljust(max_len) for line in lines]

    problems = []
    col = 0

    while col < max_len:
        # Check if this column is all spaces (separator)
        if all(line[col] == ' ' for line in padded_lines):
            col += 1
            continue

        # Extract a problem starting at this column
        numbers = []
        operator = None

        for line in padded_lines[:-1]:  # All lines except the last (operator line)
            if col < len(line):
                cell = line[col:].split()[0] if line[col:].strip() else None
                if cell and cell.isdigit():
                    numbers.append(int(cell))

        # Get the operator from the last line
        if col < len(padded_lines[-1]):
            op_char = padded_lines[-1][col:].strip()
            if op_char and op_char[0] in ['+', '*']:
                operator = op_char[0]

        if numbers and operator:
            problems.append((numbers, operator))

        # Move to the next problem (skip past this number's width)
        # Find the end of the current column of numbers
        col_width = 1
        for line in padded_lines[:-1]:
            if col < len(line):
                cell = line[col:].split()[0] if line[col:].strip() else ""
                col_width = max(col_width, len(cell))

        col += col_width

    return problems


def parse_worksheet_v2(lines):
    """Parse worksheet by processing column by column."""
    # Pad all lines to the same length
    max_len = max(len(line) for line in lines)
    padded_lines = [line.ljust(max_len) for line in lines]

    problems = []
    col = 0

    while col < max_len:
        # Skip spaces
        while col < max_len and all(line[col] == ' ' for line in padded_lines):
            col += 1

        if col >= max_len:
            break

        # Find the width of this problem (until next all-space column)
        start_col = col
        while col < max_len and not all(line[col] == ' ' for line in padded_lines):
            col += 1

        # Extract the problem from columns start_col to col
        numbers = []
        for line in padded_lines[:-1]:
            value = line[start_col:col].strip()
            if value:
                numbers.append(int(value))

        operator = padded_lines[-1][start_col:col].strip()

        if numbers and operator in ['+', '*']:
            problems.append((numbers, operator))

    return problems


def solve_problem(numbers, operator):
    """Solve a single problem."""
    if operator == '+':
        return sum(numbers)
    elif operator == '*':
        result = 1
        for num in numbers:
            result *= num
        return result
    return 0


def part1(lines):
    """Solve part 1."""
    problems = parse_worksheet_v2(lines)

    total = 0
    for numbers, operator in problems:
        result = solve_problem(numbers, operator)
        total += result

    return total


def part2(lines):
    """Solve part 2."""
    # Part 2 will be unlocked after solving part 1
    return 0


if __name__ == "__main__":
    with open("6.txt") as f:
        lines = f.read().splitlines()

    print(f"Part 1: {part1(lines)}")
    print(f"Part 2: {part2(lines)}")
