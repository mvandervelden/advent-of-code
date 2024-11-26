import sys
import math

jet_directions = list(sys.stdin.read().strip())
jet_directions = list(map(lambda _: -1 if _ == '<' else 1, jet_directions))

solid_squares = set([(x,0) for x in range(7)])
placed_rocks = []

X_START_OFFSET = 2
Y_START_OFFSET = 4

def spawn_rock(tower_height, pattern):
  # bottom left coordinate
  x, y = (X_START_OFFSET, tower_height + Y_START_OFFSET)

  if pattern == 0:
    return set([
      (x, y),
      (x + 1, y),
      (x + 2, y),
      (x + 3, y)
    ])
  elif pattern == 1:
    return set([
      (x + 1, y),
      (x, y + 1),
      (x + 1, y + 1),
      (x + 2, y + 1),
      (x + 1, y + 2)
    ])
  elif pattern == 2:
    return set([
      (x, y),
      (x + 1, y),
      (x + 2, y),
      (x + 2, y + 1),
      (x + 2, y + 2)
    ])
  elif pattern == 3:
    return set([
      (x, y),
      (x, y + 1),
      (x, y + 2),
      (x, y + 3)
    ])
  elif pattern == 4:
    return set([
      (x, y),
      (x + 1, y),
      (x, y + 1),
      (x + 1, y + 1)
    ])

def should_fall(rock):
  for square in rock:
    x,y = square

    if (x, y - 1) in solid_squares:
      return False

  return True

def fall(rock):
  return set([(x, y - 1) for x,y in rock])

def should_push(rock, direction):
  for square in rock:
    x,y = square

    if direction == -1 and x - 1 < 0:
      return False

    if direction == 1 and x + 1 > 6:
      return False

    if (x + direction, y) in solid_squares:
      return False

  return True

def push(rock, direction):
  return set([(x + direction, y) for x,y in rock])

def come_to_rest(rock):
  max_y = 0

  for square in rock:
    _,y = square
    solid_squares.add(square)
    max_y = max(max_y, y)

  placed_rocks.append(rock)
  return (max_y, rock)

def visualization(max_y = 10, min_y = 0, rock = set()):
  s = ''

  for y in range(max_y, min_y, -1):
    for x in range(0,7):
      s += '@' if (x,y) in rock else '#' if (x,y) in solid_squares else '.'
    s += '\n'

  return s

next_jet = 0
next_rock = 0
tower_height = 0
seen_states = {}
cycle_found = False
ROCKS_TO_FALL = 1000000000000
N_ROCKS_IN_STATE = 30 # MAGIC NUMBER

r = 0

while r < ROCKS_TO_FALL:
  # detect a cycle when the we reach a "state" we've seen before:
  # same rock type, same jet direction, same set of the last N rocks
  # last_n_rocks in a "state" are stored with relative y values
  #
  # somewhat unjustified assumption that the last N rocks will
  # always produce the same result without edge cases for sufficiently
  # large N
  if not cycle_found:
    last_n_rocks = list(map(
      lambda rock: frozenset([(x, y - tower_height) for x,y in rock]),
      placed_rocks[-N_ROCKS_IN_STATE:]
    ))

    start_state = frozenset([
      next_jet,
      next_rock,
      frozenset(last_n_rocks)
    ])

    # if we've found a cycle, reset r,tower_height
    # to the start of the cycle and repeat it until
    # we are less than 1 cycle away from the goal
    # then continue the simulation
    if start_state in seen_states:
      cycle_found = True
      r0, height0 = seen_states[start_state]

      cycle_length = r - r0
      height_per_cycle = tower_height - height0
      remaining_rocks = ROCKS_TO_FALL - r0
      num_cyles = math.floor(remaining_rocks / cycle_length)

      r = r0 + (cycle_length * num_cyles)
      tower_height = height0 + (height_per_cycle * num_cyles)

      # now that we've adjusted the tower_height, add the last N
      # rocks in as solid higher up so we can continue simulating
      for rock in last_n_rocks:
        for x,y in rock:
          solid_squares.add((x, y + tower_height))

    # we haven't found a cycle yet - store this
    # start_state in memory for lookup later
    else:
      seen_states[start_state] = (r, tower_height)

  rock = spawn_rock(tower_height, next_rock)

  while True:
    direction = jet_directions[next_jet]
    next_jet = (next_jet + 1) % len(jet_directions)

    if should_push(rock, direction):
      rock = push(rock, direction)

    if should_fall(rock):
      rock = fall(rock)
    else:
      break

  max_y, rock = come_to_rest(rock)
  tower_height = max(tower_height, max_y)
  next_rock = (next_rock + 1) % 5
  r += 1

print(tower_height)
