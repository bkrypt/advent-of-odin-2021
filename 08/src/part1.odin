package aoc_08

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

get_signal_pattern_value :: proc(signal_pattern: string) -> (int, bool) {
  switch len(signal_pattern) {
    case 2: return 1, true
    case 3: return 7, true
    case 4: return 4, true
    case 7: return 8, true
    case: return -1, false
  }
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    it := string(data)
    count := 0
    for line in strings.split_lines_iterator(&it) {
      inputs := strings.split(line, " | ")
      assert(len(inputs) == 2)

      for digit in strings.fields(inputs[1]) {
        if _, ok := get_signal_pattern_value(digit); ok {
          count += 1
        }
      }
    }

    fmt.println("Total occurences of digits 1, 4, 7, 8:", count)
  }
}
