#!/usr/bin/env python3

def solve_part1(input_file):
    """
    Solve Day 1 Part 1: Count how many times dial points at 0 after rotations.

    Dial goes 0-99 (wraps around), starts at 50.
    L = rotate left (toward lower numbers)
    R = rotate right (toward higher numbers)
    """
    with open(input_file, 'r') as f:
        rotations = [line.strip() for line in f if line.strip()]

    position = 50  # Starting position
    zero_count = 0  # Count of times we land on 0

    for rotation in rotations:
        direction = rotation[0]
        distance = int(rotation[1:])

        if direction == 'L':
            # Rotate left (toward lower numbers)
            position = (position - distance) % 100
        elif direction == 'R':
            # Rotate right (toward higher numbers)
            position = (position + distance) % 100

        # Check if we landed on 0
        if position == 0:
            zero_count += 1

    return zero_count


def main():
    # Try to read from 1.txt or 1_input.txt
    import os

    possible_inputs = ['1.txt', '1_input.txt', 'input.txt']
    input_file = None

    for filename in possible_inputs:
        if os.path.exists(filename):
            input_file = filename
            break

    if input_file is None:
        print("Please create an input file (1.txt or 1_input.txt) with your puzzle input.")
        return

    password = solve_part1(input_file)
    print(f"Part 1 - Password: {password}")


if __name__ == "__main__":
    main()
