package aoc_06

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"

NUM_DAYS :: 256

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    it := string(data)
    lanternfish: [9]int

    for fish_str in strings.split_iterator(&it, ",") {
      group_index := strconv.atoi(fish_str)
      lanternfish[group_index] += 1
    }

    for _ in 0..<NUM_DAYS {
      num_to_spawn := lanternfish[0];

      for group_index in 1..<len(lanternfish) {
        lanternfish[group_index - 1] += lanternfish[group_index]
        lanternfish[group_index] = 0
      }

      if num_to_spawn > 0 {
        lanternfish[6] += num_to_spawn
        lanternfish[8] += num_to_spawn
        lanternfish[0] -= num_to_spawn
      }
    }

    fmt.println("Total:", math.sum(lanternfish[:]))
  }
}
