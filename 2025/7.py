#!/usr/bin/env python3

def parse_input(filename):
    """Parse the input file and return the grid."""
    with open(filename, 'r') as f:
        return [line.rstrip('\n') for line in f.readlines()]

def find_start(grid):
    """Find the starting position 'S'."""
    for row_idx, row in enumerate(grid):
        for col_idx, cell in enumerate(row):
            if cell == 'S':
                return (row_idx, col_idx)
    return None

def count_splits(grid):
    """
    Count the number of times the beam is split.

    A beam starts at S and moves downward.
    When it hits a splitter (^), it stops and creates two new beams
    that start from positions immediately left and right of the splitter,
    and those new beams also move downward.
    """
    splits = 0

    # Find starting position
    start = find_start(grid)
    if not start:
        return 0

    # Track active beams: list of (row, col)
    # All beams move downward
    beams = [(start[0], start[1])]

    # Track which beam positions we've already processed to avoid duplicates
    processed = set()

    rows = len(grid)
    cols = len(grid[0]) if rows > 0 else 0

    while beams:
        new_beams = []

        for row, col in beams:
            # Move downward
            next_row = row + 1

            # Check if beam exits the grid
            if next_row >= rows:
                continue

            # Check what's at the next position
            cell = grid[next_row][col]

            if cell == '^':
                # Hit a splitter! The beam splits
                splits += 1
                # Create two new beams starting from left and right of the splitter
                # These new beams also move downward
                left_col = col - 1
                right_col = col + 1

                # Add left beam if it's within bounds and not already processed from this position
                if left_col >= 0 and (next_row, left_col) not in processed:
                    new_beams.append((next_row, left_col))
                    processed.add((next_row, left_col))

                # Add right beam if it's within bounds and not already processed from this position
                if right_col < cols and (next_row, right_col) not in processed:
                    new_beams.append((next_row, right_col))
                    processed.add((next_row, right_col))

            elif cell == '.':
                # Empty space, continue downward
                if (next_row, col) not in processed:
                    new_beams.append((next_row, col))
                    processed.add((next_row, col))

        beams = new_beams

    return splits

def solve_part1(filename):
    """Solve part 1 of the puzzle."""
    grid = parse_input(filename)
    return count_splits(grid)

def count_timelines(grid):
    """
    Count the number of different timelines (paths) a particle can take.

    Each time a particle hits a splitter, it creates two timelines.
    We need to count all unique complete journeys through the manifold.
    """
    # Find starting position
    start = find_start(grid)
    if not start:
        return 0

    rows = len(grid)
    cols = len(grid[0]) if rows > 0 else 0

    # Track paths: each path is a tuple of positions visited
    # Start with one path containing just the starting position
    active_paths = [[(start[0], start[1])]]
    completed_paths = []

    while active_paths:
        new_paths = []

        for path in active_paths:
            row, col = path[-1]  # Current position
            next_row = row + 1

            # Check if we've exited the grid
            if next_row >= rows:
                completed_paths.append(path)
                continue

            # Check what's at the next position
            cell = grid[next_row][col]

            if cell == '^':
                # Hit a splitter - create two new timelines
                # One goes left, one goes right, both continue downward from there
                left_col = col - 1
                right_col = col + 1

                # Left timeline
                if left_col >= 0:
                    new_path = path + [(next_row, left_col)]
                    new_paths.append(new_path)
                else:
                    # Can't go left, this timeline ends
                    completed_paths.append(path)

                # Right timeline
                if right_col < cols:
                    new_path = path + [(next_row, right_col)]
                    new_paths.append(new_path)
                else:
                    # Can't go right, this timeline ends
                    completed_paths.append(path)

            elif cell == '.':
                # Empty space, continue downward in this timeline
                new_path = path + [(next_row, col)]
                new_paths.append(new_path)

        active_paths = new_paths

    return len(completed_paths)

def solve_part2(filename):
    """Solve part 2 of the puzzle."""
    grid = parse_input(filename)
    return count_timelines(grid)

if __name__ == "__main__":
    filename = "7.txt"

    part1_result = solve_part1(filename)
    print(f"Part 1: {part1_result}")

    part2_result = solve_part2(filename)
    print(f"Part 2: {part2_result}")
