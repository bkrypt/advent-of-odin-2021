package aoc_14

import "core:fmt"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strings"
import "core:unicode/utf8"

PASSES :: 10

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    foo := strings.split_n(string(data), "\n\n", 2)

    sequence: [dynamic]rune
    elements: map[rune]int
    pair_insertion_rules: map[string]rune

    template := foo[0]
    rules_input := foo[1]

    for c in template {
      append(&sequence, c)
      elements[c] += 1
    }

    for line in strings.split_lines_iterator(&rules_input) {
      rule := strings.split(line, " -> ")
      assert(len(rule) == 2)

      pair := rule[0]
      result := rule[1]
      
      pair_insertion_rules[pair] = utf8.rune_at(result, 0)
    }

    for _ in 0..<PASSES {
      new_sequence: [dynamic]rune
      append(&new_sequence, sequence[0])

      for i in 1..<len(sequence) {
        pair := utf8.runes_to_string(sequence[i-1:i+1])
        assert(len(pair) == 2)
        defer delete(pair)

        
        right := utf8.rune_at_pos(pair, 1)
        middle := pair_insertion_rules[pair]
        elements[middle] += 1

        append(&new_sequence, ..[]rune{middle, right})
      }

      clear(&sequence)
      append(&sequence, ..new_sequence[:])
    }

    sort.map_entries_by_value(&elements)

    least_common := slice.first(slice.map_values(elements))
    most_common := slice.last(slice.map_values(elements))

    result := most_common - least_common
    fmt.println(result)
  }
}
