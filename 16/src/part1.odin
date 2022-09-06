package aoc_16

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    it := string(data)
    input, _ := strings.split_lines_iterator(&it)

    fmt.println(input)
  }
}
