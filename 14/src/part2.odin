package aoc_14

import "core:fmt"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strings"
import "core:unicode/utf8"

PASSES :: 40

PairKey :: distinct [2]u8

Rule :: struct {
  value: u8,
  a_key: PairKey,
  b_key: PairKey,
}

Histogram :: struct {
  values: map[u8]uint,
}

histogram_add :: proc(dest: ^Histogram, other: Histogram) {
  for value, count in other.values do dest.values[value] += count
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    inputs := strings.split_n(string(data), "\n\n", 2)
    
    template := inputs[0]
    rules_input := inputs[1]

    histogram: Histogram

    for char_index := 0; char_index < len(template); char_index += 1 {
      char_value := template[char_index]
      histogram.values[char_value] += 1
    }

    rule_table: map[PairKey]Rule
    pair_histograms: map[PairKey]Histogram

    for rule_iter in strings.split_lines_iterator(&rules_input) {
      rule_params := strings.split(rule_iter, " -> ")
      assert(len(rule_params) == 2)

      pair_str := rule_params[0]
      value_str := rule_params[1]
      assert(len(pair_str) == 2 && len(value_str) == 1)

      a_char := pair_str[0]
      b_char := pair_str[1]
      v_char := value_str[0]

      pair_key := PairKey{a_char, b_char}

      rule_table[pair_key] = Rule{
        value = v_char,
        a_key = PairKey{a_char, v_char},
        b_key = PairKey{v_char, b_char},
      }
    }

    alt_pair_histograms: map[PairKey]Histogram
    for _ in 0..<PASSES {
      for pair_key, rule in rule_table {
        pair_histogram := Histogram{}
        pair_histogram.values[rule.value] += 1
        histogram_add(&pair_histogram, pair_histograms[rule.a_key])
        histogram_add(&pair_histogram, pair_histograms[rule.b_key])
        alt_pair_histograms[pair_key] = pair_histogram
      }

      temp_histograms := pair_histograms
      pair_histograms = alt_pair_histograms
      alt_pair_histograms = temp_histograms
    }

    for i in 0..<(len(template) - 1) {
      pair_key := PairKey{template[i + 0], template[i + 1]}
      histogram_add(&histogram, pair_histograms[pair_key])
    }

    sort.map_entries_by_value(&histogram.values)
    
    most_common := slice.last(slice.map_values(histogram.values))
    least_common := slice.first(slice.map_values(histogram.values))

    final_outcome := most_common - least_common
    fmt.println("most:", most_common, "least:", least_common, "final:", final_outcome)
  }
}
