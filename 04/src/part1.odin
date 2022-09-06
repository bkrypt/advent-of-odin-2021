package aoc_04

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

BOARD_SIZE :: 5

Board :: struct {
  numbers: [25]int,
  marks: bit_set[0..<25],
  row_state: [5]int,
  col_state: [5]int,
}

create_board :: proc(board_input: string) -> Board {
  board := Board {
    row_state = {0..=4 = 5},
    col_state = {0..=4 = 5},
  }

  for number, index in strings.fields(board_input) {
    board.numbers[index] = strconv.atoi(number)
  }

  return board
}

update_board :: proc(board: ^Board, drawn_number: int) {
  for number, index in board.numbers {
    if number == drawn_number {
      row_index := index / BOARD_SIZE
      col_index := index % BOARD_SIZE

      board.row_state[row_index] -= 1
      board.col_state[col_index] -= 1

      board.marks += {index}
    }
  }
}

is_winner_board :: proc(board: Board) -> bool {
  for index in 0..<BOARD_SIZE {
    if board.row_state[index] == 0 || board.col_state[index] == 0 {
      return true
    }
  }
  return false
}

get_board_score :: proc(board: Board, last_number: int) -> int {
  unmarked_sum := 0
  for number, index in board.numbers {
    if (index not_in board.marks) {
      unmarked_sum += number
    }
  }
  return unmarked_sum * last_number
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    inputs := strings.split_n(string(data), "\n\n", 2)
    assert(len(inputs) == 2)

    draw_inputs := inputs[0]
    board_inputs := inputs[1]

    boards: [dynamic]Board

    for board_input in strings.split_iterator(&board_inputs, "\n\n") {
      append(&boards, create_board(board_input))
    }

    outer: for str_number in strings.split_iterator(&draw_inputs, ",") {
      number := strconv.atoi(str_number)

      for board in &boards {
        update_board(&board, number)
        if is_winner_board(board) {
          score := get_board_score(board, number)
          fmt.println("First winning board score:", score)
          break outer
        }
      }
    }
  }
}
