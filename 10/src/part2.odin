package aoc_10

import "core:container/queue"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

get_closing_bracket :: proc(open_bracket: rune) -> rune {
  switch open_bracket {
    case '(': return ')'
    case '[': return ']'
    case '{': return '}'
    case '<': return '>'
    case: return 0
  }
}

compute_closing_sequence_score :: proc(closing_sequence: []rune) -> (score: int) {
  for c in closing_sequence {
    score *= 5
    switch c {
      case ')': score += 1
      case ']': score += 2
      case '}': score += 3
      case '>': score += 4
    }
  }
  return
}

median :: proc(data: []int) -> int {
  slice.sort(data)
  return data[len(data) / 2]
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    open_queue: queue.Queue(rune)
    queue.init(&open_queue)
    defer queue.destroy(&open_queue)

    closing_sequence_scores: [dynamic]int

    it := string(data)
    line_loop: for line in strings.split_lines_iterator(&it) {
      defer queue.clear(&open_queue)

      c_loop: for c in line {
        switch c {
          case '(', '[', '{', '<': {
            queue.push_front(&open_queue, c)
          }
          case: {
            expected := get_closing_bracket(queue.front(&open_queue))
            if expected == c do queue.pop_front(&open_queue)
            else do continue line_loop
          }
        }
      }
      
      closing_sequence: [dynamic]rune
      for queue.len(open_queue) > 0 {
        closing_bracket := get_closing_bracket(queue.pop_front(&open_queue))
        append(&closing_sequence, closing_bracket)
      }

      score := compute_closing_sequence_score(closing_sequence[:])
      append(&closing_sequence_scores, score)
    }

    winning_score := median(closing_sequence_scores[:])
    fmt.println("Median/winning score:", winning_score)
  }
}
