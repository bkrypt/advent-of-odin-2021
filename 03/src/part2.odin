package aoc_03

import "core:fmt"
import "core:os"
import "core:strings"

most_common_bit_at_index :: proc(number_list: [dynamic]string, bit_index: int) -> int {
  count := 0
  for number in number_list {
    if number[bit_index] == '1' {
      count += 1
    } else {
      count -= 1
    }
  }
  return count
}

binary_number_string_to_int :: proc(binary_string: string) -> int {
  result := 0
  for char in binary_string {
    result <<= 1
    if char == '1' {
      result |= 1
    }
  }
  return result
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    lines := strings.split_lines(string(data))
    num_bits := len(lines[0])

    // Find O2 rating

    o2_list := make([dynamic]string)
    defer delete(o2_list)
    append(&o2_list, ..lines)

    o2_outer_loop: for bit_index in 0..<num_bits {
      selected_bit: u8 = '1'
      if most_common_bit_at_index(o2_list, bit_index) < 0 {
        selected_bit = '0'
      }

      for list_index := 0; list_index < len(o2_list); {
        if (len(o2_list) == 1) {
          break o2_outer_loop
        }

        if o2_list[list_index][bit_index] != selected_bit {
          unordered_remove(&o2_list, list_index)
        } else {
          list_index += 1
        }
      }
    }

    assert(len(o2_list) == 1)
    o2_rating := binary_number_string_to_int(o2_list[0])
    fmt.println("O2 rating:", o2_rating)

    // Find CO2 rating

    co2_list := make([dynamic]string)
    defer delete(co2_list)
    append(&co2_list, ..lines)

    co2_outer_loop: for bit_index in 0..<num_bits {
      selected_bit: u8 = '0'
      if most_common_bit_at_index(co2_list, bit_index) < 0 {
        selected_bit = '1'
      }

      for list_index := 0; list_index < len(co2_list); {
        if (len(co2_list) == 1) {
          break co2_outer_loop
        }

        if co2_list[list_index][bit_index] != selected_bit {
          unordered_remove(&co2_list, list_index)
        } else {
          list_index += 1
        }
      }
    }

    assert(len(co2_list) == 1)
    co2_rating := binary_number_string_to_int(co2_list[0])
    fmt.println("CO2 rating:", co2_rating)

    life_support_rating := o2_rating * co2_rating
    fmt.println("Life support rating:", life_support_rating)
  }
}
