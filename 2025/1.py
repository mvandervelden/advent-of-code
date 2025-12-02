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


def solve_part2(input_file):
    """
    Solve Day 1 Part 2: Count every time dial points at 0 during rotations.
    
    This includes every click that passes through 0, not just the final position.
    """
    with open(input_file, 'r') as f:
        rotations = [line.strip() for line in f if line.strip()]
    
    position = 50  # Starting position
    zero_count = 0  # Count of times we are at 0
    
    for rotation in rotations:
        direction = rotation[0]
        distance = int(rotation[1:])
        
        if direction == 'L':
            # Rotate left (toward lower numbers)
            # Count how many times we hit 0 going from position down by distance
            # We hit 0 when (position - i) % 100 == 0, meaning position - i = 0, 100, 200, ...
            # So i = position, position + 100, position + 200, ...
            # We need i in range [1, distance] where position - i ≡ 0 (mod 100)
            
            # First 0 we hit is at i = position (if position > 0 and distance >= position)
            # Then every 100 clicks after that
            if distance >= position and position > 0:
                # We hit 0 at click position, then position+100, position+200, etc.
                zero_count += 1 + (distance - position) // 100
            elif position == 0 and distance > 0:
                # Starting at 0, we hit it at 100, 200, 300, etc.
                zero_count += distance // 100
            
            position = (position - distance) % 100
            
        elif direction == 'R':
            # Rotate right (toward higher numbers)
            # Count how many times we hit 0 going from position up by distance
            # We hit 0 when (position + i) % 100 == 0
            # So position + i = 100, 200, 300, ...
            # i = 100 - position, 200 - position, 300 - position, ...
            
            gap_to_zero = (100 - position) % 100  # clicks until we hit 0
            if gap_to_zero == 0:
                # Already at 0, next hit is at 100
                gap_to_zero = 100
            
            if distance >= gap_to_zero:
                # We hit 0 at gap_to_zero, then every 100 after
                zero_count += 1 + (distance - gap_to_zero) // 100
            
            position = (position + distance) % 100
    
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

    password1 = solve_part1(input_file)
    print(f"Part 1 - Password: {password1}")
    
    password2 = solve_part2(input_file)
    print(f"Part 2 - Password: {password2}")


if __name__ == "__main__":
    main()
