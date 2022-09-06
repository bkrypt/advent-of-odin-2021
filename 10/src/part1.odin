package aoc_10

import "core:container/queue"
import "core:fmt"
import "core:os"
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

calculate_syntax_error_score :: proc(illegal_characters: []rune) -> (score: int) {
  for c in illegal_characters {
    switch c {
      case ')': score += 3
      case ']': score += 57
      case '}': score += 1197
      case '>': score += 25137
    }
  }
  return
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    open_queue: queue.Queue(rune)
    queue.init(&open_queue)
    defer queue.destroy(&open_queue)

    line_num := 0
    illegal_characters: [dynamic]rune

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
      defer queue.clear(&open_queue)

      line_num += 1
      c_loop: for c, c_index in line {
        switch c {
          case '(', '[', '{', '<':
            queue.push_front(&open_queue, c)
          case: {
            if expected := get_closing_bracket(queue.front(&open_queue)); expected == c {
              queue.pop_front(&open_queue)
            }
            else {
              fmt.println("Line:", line_num, ":", c_index + 1, "\tExpected '", expected, "', but found '", c, "' instead.")
              append(&illegal_characters, c)
              break c_loop
            }
          }
        }
      }
    }

    syntax_error_score := calculate_syntax_error_score(illegal_characters[:])
    fmt.println("Syntax error score:", syntax_error_score)
  }
}
