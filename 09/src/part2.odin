package aoc_09

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

calculate_basin_size_recursive :: proc(r, c, map_height, map_width: int, heightmap:[dynamic][dynamic]int, discovered_set: ^map[int]bool) -> int {
  if r < 0 || c < 0 || r >= map_height || c >= map_width do return 0

  key := r * map_width + c
  if key in discovered_set do return 0
  else do discovered_set[key] = true

  if heightmap[r][c] == 9 do return 0
  else do return 1 +
    calculate_basin_size_recursive(r - 1, c, map_height, map_width, heightmap, discovered_set) +
    calculate_basin_size_recursive(r + 1, c, map_height, map_width, heightmap, discovered_set) +
    calculate_basin_size_recursive(r, c - 1, map_height, map_width, heightmap, discovered_set) +
    calculate_basin_size_recursive(r, c + 1, map_height, map_width, heightmap, discovered_set)
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    heightmap: [dynamic][dynamic]int

    rows := strings.split_lines(string(data))
    defer delete(rows)
    
    for row, row_index in rows {
      append(&heightmap, [dynamic]int{})

      for rune_height in row {
        height := int(rune_height - '0')
        append(&heightmap[row_index], height)
      }
    }

    assert(len(heightmap) > 0)

    map_height := len(heightmap)
    map_width := len(heightmap[0])

    discovery_map: map[int]bool
    basin_sizes: [dynamic]int

    for r in 0..<map_height {
      for c in 0..<map_width {
        loc := heightmap[r][c]

        switch {
          case r > 0 && loc >= heightmap[r - 1][c]: continue
          case r + 1 < map_height && loc >= heightmap[r + 1][c]: continue
          case c > 0 && loc >= heightmap[r][c - 1]: continue
          case c + 1 < map_width && loc >= heightmap[r][c + 1]: continue
        }

        basin_size := calculate_basin_size_recursive(r, c, map_height, map_width, heightmap, &discovery_map)
        fmt.println("Basin size:", basin_size)
        append(&basin_sizes, basin_size)
      }
    }

    fmt.println()
    fmt.println("Number of basins:", len(basin_sizes))

    slice.reverse_sort(basin_sizes[:])
    largest_3_basins, _ := slice.split_at(basin_sizes[:], 3)
    assert(len(largest_3_basins) == 3)
    fmt.println("Largest 3 basins:", largest_3_basins)

    product_of_3_largest_basins := largest_3_basins[0] * largest_3_basins[1] * largest_3_basins[2]
    fmt.println("Product of largest 3 basins:", product_of_3_largest_basins)
  }
}
