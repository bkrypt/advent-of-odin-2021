package aoc_01

import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    window: [3]int
    prev := 0
    count :int = 0

    initial_input := strings.split_lines_n(string(data), 4)

    for i in 0..=2 {
      window[i] = strconv.atoi(initial_input[i])
      prev += window[i]
    }

    remaining_input := initial_input[3]

    for line in strings.split_lines_iterator(&remaining_input) {
      value := strconv.atoi(line)
      curr := (prev - window[0]) + value

      if curr > prev {
        count += 1
      }

      prev = curr

      // Slide the window

      for i in 1..=2 {
        window[i-1] = window[i]
      }
      window[2] = value
    }

    fmt.println(count)
  }
}
