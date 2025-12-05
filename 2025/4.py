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


def solve_part2(input_file, visualize=False, max_iterations=None):
    """Solve part 2 of the puzzle - simulate removing accessible rolls."""
    import time

    with open(input_file, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]

    # Convert to mutable list of lists
    grid = [list(line) for line in lines]

    total_removed = 0
    iteration = 0
    iteration_stats = []

    if visualize:
        # Clear screen and show initial state
        print('\033[2J\033[H', end='')
        total_rolls = sum(row.count('@') for row in grid)
        print(f"=== Initial State ===")
        print(f"Total rolls: {total_rolls}\n")
        print_grid(grid)
        time.sleep(0.001)

    # Keep removing accessible rolls until none remain
    while True:
        accessible = find_accessible_rolls(grid)

        if not accessible:
            break

        iteration += 1
        iteration_stats.append(len(accessible))

        if visualize and (max_iterations is None or iteration <= max_iterations):
            # Clear screen and show which rolls are about to be removed
            print('\033[2J\033[H', end='')
            print(f"=== Iteration {iteration}: Removing {len(accessible)} rolls ===\n")
            highlighted_grid = [row[:] for row in grid]
            for row, col in accessible:
                highlighted_grid[row][col] = 'X'  # Highlight accessible rolls
            print_grid(highlighted_grid)
            time.sleep(0.0)

        # Remove all accessible rolls
        for row, col in accessible:
            grid[row][col] = '.'

        total_removed += len(accessible)

        if visualize and (max_iterations is None or iteration <= max_iterations):
            # Clear screen and show after removal
            print('\033[2J\033[H', end='')
            remaining_rolls = sum(row.count('@') for row in grid)
            print(f"=== After Iteration {iteration} ===")
            print(f"Removed: {len(accessible)}, Total removed: {total_removed}, Remaining: {remaining_rolls}\n")
            print_grid(grid)
            time.sleep(0.03)

    if visualize:
        # Clear screen and show final summary
        print('\033[2J\033[H', end='')
        print(f"=== Summary Statistics ===")
        print(f"Total iterations: {iteration}")
        print(f"Total rolls removed: {total_removed}")
        print(f"Average rolls per iteration: {total_removed / iteration:.1f}")
        print(f"Max rolls in single iteration: {max(iteration_stats)}")
        print(f"Min rolls in single iteration: {min(iteration_stats)}")
        print(f"\nIteration breakdown:")
        for i, count in enumerate(iteration_stats[:10], 1):
            print(f"  Iteration {i}: {count} rolls")
        if len(iteration_stats) > 10:
            print(f"  ... ({len(iteration_stats) - 10} more iterations)")

        print(f"\n=== Final State ===")
        remaining_rolls = sum(row.count('@') for row in grid)
        print(f"Remaining rolls: {remaining_rolls}\n")
        print_grid(grid)

    return total_removed


def print_grid(grid, clear=False):
    """Print the grid in a readable format."""
    if clear:
        # Move cursor to top-left and clear screen
        print('\033[H\033[J', end='')
    for row in grid:
        print(''.join(row))
    print()


if __name__ == "__main__":
    import sys
    input_file = "4.txt"

    # Check if visualization flag is passed
    visualize = "--visualize" in sys.argv or "-v" in sys.argv

    # Check for max iterations limit (e.g., --max=5)
    max_iterations = None
    for arg in sys.argv:
        if arg.startswith("--max="):
            max_iterations = int(arg.split("=")[1])

    part1_result = solve_part1(input_file)
    print(f"Part 1: {part1_result}")

    part2_result = solve_part2(input_file, visualize=visualize, max_iterations=max_iterations)
    print(f"Part 2: {part2_result}")
