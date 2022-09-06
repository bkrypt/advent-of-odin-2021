package aoc_02

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Submarine :: struct {
  horizontal_position: int,
  depth: int,
  aim: int,
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)
    course := string(data)

    submarine := Submarine {
      horizontal_position = 0,
      depth = 0,
      aim = 0,
    }

    for command in strings.split_lines_iterator(&course) {
      parts := strings.split(command, " ")

      if size, ok := strconv.parse_int(parts[1]); ok {
        switch direction := parts[0]; direction {
          case "forward":
            submarine.horizontal_position += size
            submarine.depth += submarine.aim * size
          case "up":
            submarine.aim -= size
          case "down":
            submarine.aim += size
        }
      }
    }

    fmt.println(submarine.horizontal_position * submarine.depth)
  }
}
