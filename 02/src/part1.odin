package aoc_02

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    Vector2 :: [2]int
    position := Vector2{0, 0}

    course := string(data)
    for command in strings.split_lines_iterator(&course) {
      parts := strings.split(command, " ")

      if distance, ok := strconv.parse_int(parts[1]); ok {
        switch direction := parts[0]; direction {
          case "forward":
            position.x += distance
          case "up":
            position.y -= distance
          case "down":
            position.y += distance
        }
      }
    }

    fmt.println("position", position)
    fmt.println("product", position.x * position.y)
  }
}
