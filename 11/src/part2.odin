package aoc_11

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

GRID_SIZE :: 10

Grid :: [GRID_SIZE * GRID_SIZE]int

coords_to_grid_index :: proc(x, y: int) -> int {
  return y * GRID_SIZE + x
}

grid_index_to_coords :: proc(index: int) -> (x, y: int) {
  y = index / GRID_SIZE
  x = index % GRID_SIZE
  return
}

print_grid :: proc(grid: Grid) {
  for y in 0..<GRID_SIZE {
    for x in 0..<GRID_SIZE {
      index := coords_to_grid_index(x, y)
      fmt.print(grid[index])
      fmt.print("\t")
    }
    fmt.println()
  }
}

populate_grid :: proc(grid: ^Grid, input_rows: []string) {
  for row, y in input_rows {
    for char, x in row {
      grid_index := coords_to_grid_index(x, y)
      energy := int(char - '0')
      grid[grid_index] = energy
    }
  }
}

tick_energy :: proc(grid: ^Grid) {
  for energy_level in grid do energy_level += 1
}

get_adjacent_indices :: proc(index: int, grid: Grid) -> [dynamic]int {
  x, y := grid_index_to_coords(index)

  adjacents: [dynamic]int

  // Left
  if x - 1 >= 0 do append(&adjacents, coords_to_grid_index(x - 1, y))
  // Right
  if x + 1 < GRID_SIZE do append(&adjacents, coords_to_grid_index(x + 1, y))
  // Top
  if y - 1 >= 0 {
    append(&adjacents, coords_to_grid_index(x, y - 1))
    // Top left
    if x - 1 >= 0 do append(&adjacents, coords_to_grid_index(x - 1, y - 1))
    // Top right
    if x + 1 < GRID_SIZE do append(&adjacents, coords_to_grid_index(x + 1, y - 1))
  }
  // Bottom
  if y + 1 < GRID_SIZE {
    append(&adjacents, coords_to_grid_index(x, y + 1))
    // Bottom left
    if x - 1 >= 0 do append(&adjacents, coords_to_grid_index(x - 1, y + 1))
    // Bottom right
    if x + 1 < GRID_SIZE do append(&adjacents, coords_to_grid_index(x + 1, y + 1))
  }

  return adjacents
}

flash :: proc(index: int, grid: ^Grid, flashed_set: ^map[int]bool) {
  if index not_in flashed_set {
    flashed_set[index] = true

    adjacent_indices := get_adjacent_indices(index, grid^)
    for adj_index in adjacent_indices {
      grid[adj_index] += 1
      if grid[adj_index] > 9 {
        flash(adj_index, grid, flashed_set)
      }
    }
  }
}

tick_flashes :: proc(grid: ^Grid) -> int {
  flashed_set: map[int]bool

  for energy_level, index in grid {
    if (energy_level > 9) {
      flash(index, grid, &flashed_set)
    }
  }

  for index in slice.map_keys(flashed_set) {
    grid[index] = 0
  }

  return len(flashed_set)
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    it := string(data)
    rows := strings.split_lines(it)
    defer delete(rows)

    grid: Grid
    populate_grid(&grid, rows)

    step_number := 0

    for {
      step_number += 1
      tick_energy(&grid)
      
      num_flashes := tick_flashes(&grid)
      if num_flashes == len(grid) {
        break;
      }
    }

    fmt.println("Octopus flashes synchronized on step:", step_number)
  }
}
