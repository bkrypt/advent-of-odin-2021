package aoc_03

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    lines := strings.split_lines(string(data))
    num_bits := len(lines[0])

    gamma_rate := 0
    epsilon_rate := 0

    for bit_index in 0..<num_bits {
      bit_score := 0

      for line in lines {
        if line[bit_index] == '0' {
          bit_score -= 1
        } else {
          bit_score += 1
        }
      }

      gamma_rate <<= 1
      epsilon_rate <<= 1

      if bit_score > 0 {
        gamma_rate |= 1
      } else {
        epsilon_rate |= 1
      }
    }

    fmt.println("Gamma rate:", gamma_rate)
    fmt.println("Epsilon rate:", epsilon_rate)

    power_consumption := gamma_rate * epsilon_rate
    fmt.println("Power consumption:", power_consumption)
  }
}
