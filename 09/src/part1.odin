package aoc_09

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    heightmap: [dynamic][dynamic]int

    rows := strings.split_lines(string(data))
    defer delete(rows)
    
    for row, row_index in rows {
      append(&heightmap, [dynamic]int{})

      for height_rune in row {
        height := int(height_rune - '0')
        append(&heightmap[row_index], height)
      }
    }

    assert(len(heightmap) > 0)

    map_height := len(heightmap)
    map_width := len(heightmap[0])

    sum_of_risk_levels := 0

    for r in 0..<map_height {
      for c in 0..<map_width {
        loc := heightmap[r][c]

        switch {
          case r > 0 && loc >= heightmap[r - 1][c]: continue
          case r + 1 < map_height && loc >= heightmap[r + 1][c]: continue
          case c > 0 && loc >= heightmap[r][c - 1]: continue
          case c + 1 < map_width && loc >= heightmap[r][c + 1]: continue
          case: sum_of_risk_levels += 1 + loc
        }
      }
    }

    fmt.println("Sum of risk levels:", sum_of_risk_levels)
  }
}
