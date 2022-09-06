package aoc_01

import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    it := string(data)
    prev: int = int(libc.INT32_MAX)
    count: int = 0

    for line in strings.split_lines_iterator(&it) {
      if value, ok := strconv.parse_int(line); ok {
        if value > prev {
          count += 1
        }
        prev = value
      }
    }

    fmt.println(count)
  }
}
