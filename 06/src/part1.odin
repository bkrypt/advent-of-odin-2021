package aoc_06

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

NUM_DAYS :: 80

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    it := string(data)
    lanternfish := make([dynamic]int)
    defer delete(lanternfish)

    for fish_str in strings.split_iterator(&it, ",") {
      append(&lanternfish, strconv.atoi(fish_str))
    }

    spawn := make([dynamic]int)
    defer delete(spawn)
    for _ in 0..<NUM_DAYS {
      for fish in &lanternfish {
        fish -= 1
        if fish < 0 {
          fish = 6
          append(&spawn, 8)
        }
      }
      append(&lanternfish, ..spawn[:])
      clear_dynamic_array(&spawn)
    }

    fmt.println("Total:", len(lanternfish))
  }
}
