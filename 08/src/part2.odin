package aoc_08

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

SignalPattern :: bit_set['a'..='f']

string_to_signal_pattern :: proc(pattern: string) -> (result: SignalPattern) {
  for bit in pattern do result += {bit}
  return
}

init_digit_to_signal_wire_map :: proc(out_map: ^[10]SignalPattern, str_signal_patterns: []string) {
  unknown_patterns := make([dynamic]SignalPattern, 0, 6)
  defer delete(unknown_patterns)

  // Map known, uninque patterns

  for str_pattern in str_signal_patterns {
    pattern := string_to_signal_pattern(str_pattern)
    switch len(str_pattern) {
      case 2: out_map[1] = pattern
      case 3: out_map[7] = pattern
      case 4: out_map[4] = pattern
      case 7: out_map[8] = pattern
      case: append(&unknown_patterns, pattern)
    }
  }

  assert(len(unknown_patterns) == 6)

  // Deduce mapping of unknown patterns

  for pattern in unknown_patterns {
    switch card(pattern) {
      case 5: { // 2, 3, 5
        if pattern > out_map[1] {
          out_map[3] = pattern
        }
        else if card(out_map[4] - pattern) == 1 {
          out_map[5] = pattern
        }
        else {
          out_map[2] = pattern
        }
      }
      case 6: { // 0, 6, 9
        if card(out_map[7] - pattern) == 1 {
          out_map[6] = pattern
        }
        else if card(out_map[4] - pattern) == 0 {
          out_map[9] = pattern
        }
        else {
          out_map[0] = pattern
        }
      }
    }
  }
}

get_reading_output_value :: proc(readings: []string, digit_to_signal_wire_map: [10]SignalPattern) -> (output: int) {
  for pattern_str in readings {
    signal_pattern := string_to_signal_pattern(pattern_str)
    for digit_pattern, value in digit_to_signal_wire_map {
      if digit_pattern == signal_pattern {
        output = output * 10 + value
        break
      }
    }
  }
  return
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    sum_of_all_output_values := 0

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
      inputs := strings.split(line, " | ")
      assert(len(inputs) == 2)

      signal_patterns := strings.fields(inputs[0])
      output_readings := strings.fields(inputs[1])

      digit_to_signal_wire_map: [10]SignalPattern
      init_digit_to_signal_wire_map(&digit_to_signal_wire_map, signal_patterns)

      output_value := get_reading_output_value(output_readings, digit_to_signal_wire_map)
      sum_of_all_output_values += output_value
    }

    fmt.println("Sum of all output values:", sum_of_all_output_values)
  }
}
