package aoc_12

import "core:container/queue"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode"

cave_id :: string

Cave :: struct {
  id: cave_id,
  size: CaveSize,
  connections: [dynamic]cave_id,
}

CaveSize :: enum {
  SMALL,
  LARGE,
}

print_paths_details :: proc(paths: []string) {
  fmt.println("PATHS")
  fmt.println("=====")
  for path in paths {
    fmt.println(path)
  }

  fmt.println()
  fmt.println("DETAILS")
  fmt.println("=======")
  fmt.println("Total paths:", len(paths))
}

get_current_path :: proc(path_stack: ^queue.Queue(cave_id)) -> string {
  path := make([]string, queue.len(path_stack^))
  defer delete(path)

  for i in 0..<queue.len(path_stack^) {
    path[i] = queue.get(path_stack, i)
  }

  return strings.join(path, ", ")
}

travel_recursive :: proc(visiting_cave_id: cave_id, visited_set: ^map[cave_id]bool, path_stack: ^queue.Queue(cave_id), caves: map[cave_id]Cave, paths: ^[dynamic]string) {
  cave := caves[visiting_cave_id]
  queue.push_back(path_stack, cave.id)

  if cave.id != "end" {
    if cave.size == .SMALL do visited_set[cave.id] = true

    for connection in cave.connections {
      if connection not_in visited_set {
        travel_recursive(connection, visited_set, path_stack, caves, paths)
      }
    }

    if cave.size == .SMALL do delete_key(visited_set, cave.id)
  }
  else {
    append(paths, get_current_path(path_stack))
  }

  queue.consume_back(path_stack, 1)
}

is_lower_case :: proc(input: string) -> bool {
  for char in input {
    if unicode.is_upper(char) do return false
  }
  return true
}

create_cave :: proc(id: string) -> Cave {
  return Cave {
    id = id,
    size = .SMALL if is_lower_case(id) else .LARGE,
    connections = {},
  }
}

init_caves_from_input_data :: proc(caves: ^map[string]Cave, data: []byte) {
  it := string(data)
  for connection in strings.split_lines_iterator(&it) {
    connected_caves := strings.split(connection, "-")
    assert(len(connected_caves) == 2)

    cave_a_id := connected_caves[0]
    cave_b_id := connected_caves[1]

    if cave_a_id not_in caves {
      caves[cave_a_id] = create_cave(cave_a_id)
    }

    if cave_b_id not_in caves {
      caves[cave_b_id] = create_cave(cave_b_id)
    }

    cave_a := &caves[cave_a_id]
    cave_b := &caves[cave_b_id]

    append(&cave_a.connections, cave_b_id)
    append(&cave_b.connections, cave_a_id)
  }
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    caves: map[cave_id]Cave;
    init_caves_from_input_data(&caves, data)

    visited_set: map[cave_id]bool
    paths: [dynamic]string

    path_stack: queue.Queue(cave_id)
    queue.init(&path_stack)
    defer queue.destroy(&path_stack)

    start_cave := caves["start"]
    queue.push_back(&path_stack, start_cave.id)
    
    for connection in start_cave.connections {
      clear(&visited_set)
      visited_set[start_cave.id] = true

      travel_recursive(connection, &visited_set, &path_stack, caves, &paths)
    }

    print_paths_details(paths[:])
  }
}
