package aoc_07

import "core:c/libc"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

get_min_max_depths :: proc(depths: []int) -> (min, max: int) {
  slice.sort(depths)
  return slice.first(depths), slice.last(depths)
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    it := string(data)
    sub_depths: [dynamic]int
    for input in strings.split_iterator(&it, ",") {
      append(&sub_depths, strconv.atoi(input))
    }

    min_depth, max_depth := get_min_max_depths(sub_depths[:])

    chosen_alignment_depth := 0
    chosen_alignment_fuel_cost := int(libc.INT32_MAX)

    for alignment_depth in min_depth..=max_depth {
      alignment_fuel_cost := 0

      for depth in sub_depths {
        alignment_fuel_cost += abs(depth - alignment_depth)
      }

      if alignment_fuel_cost < chosen_alignment_fuel_cost {
        chosen_alignment_fuel_cost = alignment_fuel_cost
        chosen_alignment_depth = alignment_depth
      }
    }

    fmt.println("Most effiecient alignment.", "Depth:", chosen_alignment_depth, "Fuel cost:", chosen_alignment_fuel_cost)
  }
}
