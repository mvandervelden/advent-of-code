#!/usr/bin/env python3

import sys
import time
import os


def parse_worksheet(lines):
    """Parse worksheet left-to-right, numbers arranged vertically."""
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


def parse_cephalopod_worksheet(lines):
    """Parse worksheet right-to-left in columns (cephalopod style)."""
    # Pad all lines to the same length
    max_len = max(len(line) for line in lines)
    padded_lines = [line.ljust(max_len) for line in lines]

    problems = []

    # Process columns from right to left
    col = max_len - 1

    while col >= 0:
        # Skip space columns from the right
        while col >= 0 and all(line[col] == ' ' for line in padded_lines):
            col -= 1

        if col < 0:
            break

        # Find the start of this problem (scan left until we hit all-spaces column or start)
        end_col = col
        while col >= 0 and not all(line[col] == ' ' for line in padded_lines):
            col -= 1
        start_col = col + 1

        # Extract numbers by reading each column from right to left
        numbers = []
        for c in range(end_col, start_col - 1, -1):
            # Extract digits from this column (excluding operator line)
            digits = []
            for line in padded_lines[:-1]:
                if c < len(line) and line[c] != ' ':
                    digits.append(line[c])

            # Form a number from these digits (top = most significant)
            if digits:
                number = int(''.join(digits))
                numbers.append(number)

        # Get operator from this problem area (last line)
        operator = None
        for c in range(start_col, end_col + 1):
            if padded_lines[-1][c] in ['+', '*']:
                operator = padded_lines[-1][c]
                break

        if numbers and operator:
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
    """Solve part 1 - standard left-to-right reading."""
    problems = parse_worksheet(lines)
    return sum(solve_problem(numbers, operator) for numbers, operator in problems)


def part2(lines, visualize=False):
    """Solve part 2 - cephalopod math (right-to-left in columns)."""
    if visualize:
        return part2_visualized(lines)

    problems = parse_cephalopod_worksheet(lines)
    return sum(solve_problem(numbers, operator) for numbers, operator in problems)


def part2_visualized(lines):
    """Solve part 2 with visualization of the cephalopod reading process."""
    max_len = max(len(line) for line in lines)
    padded_lines = [line.ljust(max_len) for line in lines]

    total = 0
    problem_num = 1
    col = max_len - 1

    def clear_screen():
        os.system('clear' if os.name != 'nt' else 'cls')

    def print_worksheet_with_highlight(start_col, end_col, current_col=None):
        """Print worksheet with current problem area highlighted."""
        clear_screen()
        print("🐙 CEPHALOPOD MATH WORKSHEET 🐙")
        print("=" * 60)
        print()

        # Show only a 20-column window around the problem area
        focus_col = current_col if current_col is not None else (start_col + end_col) // 2
        window_start = max(0, focus_col - 10)
        window_end = min(max_len - 1, focus_col + 10)

        # Show column numbers
        col_nums = "".join(str(c % 10) for c in range(window_start, window_end + 1))
        print(f"   Columns: {col_nums}")
        print()

        for i, line in enumerate(padded_lines):
            output = "   "
            for c in range(window_start, window_end + 1):
                char = line[c] if c < len(line) else ' '
                if start_col <= c <= end_col:
                    if c == current_col:
                        output += f"\033[93m{char}\033[0m"  # Yellow for current column
                    else:
                        output += f"\033[92m{char}\033[0m"  # Green for problem area
                else:
                    output += f"\033[90m{char}\033[0m"  # Gray for rest
            print(output)
        print()

    while col >= 0:
        # Skip space columns
        while col >= 0 and all(line[col] == ' ' for line in padded_lines):
            col -= 1

        if col < 0:
            break

        # Find problem boundaries
        end_col = col
        while col >= 0 and not all(line[col] == ' ' for line in padded_lines):
            col -= 1
        start_col = col + 1

        # Extract numbers column by column with animation
        numbers = []
        for c in range(end_col, start_col - 1, -1):
            print_worksheet_with_highlight(start_col, end_col, c)
            print(f"Running total: {total}")

            digits = []
            for line in padded_lines[:-1]:
                if c < len(line) and line[c] != ' ':
                    digits.append(line[c])

            if digits:
                number = int(''.join(digits))
                numbers.append(number)

            time.sleep(0.05)

        # Get operator
        operator = None
        for c in range(start_col, end_col + 1):
            if padded_lines[-1][c] in ['+', '*']:
                operator = padded_lines[-1][c]
                break

        if numbers and operator:
            result = solve_problem(numbers, operator)
            total += result
            problem_num += 1    # Final summary
    clear_screen()
    clear_screen()
    print(f"Grand Total: {total}")

    return total


if __name__ == "__main__":
    visualize = len(sys.argv) > 1 and sys.argv[1] in ['--visualize', '-v']

    with open("6.txt") as f:
        lines = f.read().splitlines()

    if not visualize:
        print(f"Part 1: {part1(lines)}")
        print(f"Part 2: {part2(lines)}")
    else:
        print(f"Part 2 (Visualized): {part2(lines, visualize=True)}")
