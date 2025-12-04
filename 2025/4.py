#!/usr/bin/env python3

def count_accessible_rolls(grid):
    """Count rolls of paper that have fewer than 4 rolls in adjacent positions."""
    rows = len(grid)
    cols = len(grid[0]) if rows > 0 else 0

    # Directions for 8 adjacent positions (including diagonals)
    directions = [
        (-1, -1), (-1, 0), (-1, 1),  # top-left, top, top-right
        (0, -1),           (0, 1),    # left, right
        (1, -1),  (1, 0),  (1, 1)     # bottom-left, bottom, bottom-right
    ]

    accessible_count = 0

    for row in range(rows):
        for col in range(cols):
            # Check if current position is a roll of paper
            if grid[row][col] == '@':
                # Count adjacent rolls
                adjacent_rolls = 0

                for dr, dc in directions:
                    new_row, new_col = row + dr, col + dc
                    # Check if within bounds
                    if 0 <= new_row < rows and 0 <= new_col < cols:
                        if grid[new_row][new_col] == '@':
                            adjacent_rolls += 1

                # A roll is accessible if fewer than 4 adjacent rolls
                if adjacent_rolls < 4:
                    accessible_count += 1

    return accessible_count


def solve_part1(input_file):
    """Solve part 1 of the puzzle."""
    with open(input_file, 'r') as f:
        grid = [line.strip() for line in f if line.strip()]

    return count_accessible_rolls(grid)


def find_accessible_rolls(grid):
    """Find all accessible rolls (positions with fewer than 4 adjacent rolls)."""
    rows = len(grid)
    cols = len(grid[0]) if rows > 0 else 0

    directions = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1),           (0, 1),
        (1, -1),  (1, 0),  (1, 1)
    ]

    accessible = []

    for row in range(rows):
        for col in range(cols):
            if grid[row][col] == '@':
                adjacent_rolls = 0

                for dr, dc in directions:
                    new_row, new_col = row + dr, col + dc
                    if 0 <= new_row < rows and 0 <= new_col < cols:
                        if grid[new_row][new_col] == '@':
                            adjacent_rolls += 1

                if adjacent_rolls < 4:
                    accessible.append((row, col))

    return accessible


def solve_part2(input_file):
    """Solve part 2 of the puzzle - simulate removing accessible rolls."""
    with open(input_file, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]

    # Convert to mutable list of lists
    grid = [list(line) for line in lines]

    total_removed = 0

    # Keep removing accessible rolls until none remain
    while True:
        accessible = find_accessible_rolls(grid)

        if not accessible:
            break

        # Remove all accessible rolls
        for row, col in accessible:
            grid[row][col] = '.'

        total_removed += len(accessible)

    return total_removed


if __name__ == "__main__":
    input_file = "4.txt"

    part1_result = solve_part1(input_file)
    print(f"Part 1: {part1_result}")

    part2_result = solve_part2(input_file)
    print(f"Part 2: {part2_result}")
