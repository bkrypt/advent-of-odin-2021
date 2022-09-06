package aoc_15

import "core:c/libc"
import "core:container/priority_queue"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

Point :: [2]int

RiskMap :: struct {
  width: int,
  height: int,
  values: []u8,
}

RiskNode :: struct {
  map_index: int,
  risk_value: int,
}

index_to_coord :: proc(risk_map: RiskMap, index: int) -> Point {
  using risk_map
  return {index % height, index / width}
}

coord_to_index :: proc(risk_map: RiskMap, coord: Point) -> int {
  return coord.y * risk_map.width + coord.x
}

distance_manhattan :: proc(a: Point, b: Point) -> int {
  return abs(a.x - b.x) + abs(a.y - b.y)
}

get_neighbouring_indices :: proc(risk_map: RiskMap, index: int, store: ^[dynamic]int) {
  coord := index_to_coord(risk_map, index)
  clear(store)

  if x := coord.x - 1; x >= 0 do append(store, coord_to_index(risk_map, {x, coord.y}))
  if x := coord.x + 1; x < risk_map.width do append(store, coord_to_index(risk_map, {x, coord.y}))

  if y := coord.y - 1; y >= 0 do append(store, coord_to_index(risk_map, {coord.x, y}))
  if y := coord.y + 1; y < risk_map.height do append(store, coord_to_index(risk_map, {coord.x, y}))
}

a_star_reconstruct_path :: proc(risk_map: RiskMap, came_from: map[int]int, from: int) {
  current := from
  fmt.println(index_to_coord(risk_map, current))
  total_risk := 0
  for {
    if current not_in came_from do break

    total_risk += int(risk_map.values[current])

    current = came_from[current]
    fmt.println(index_to_coord(risk_map, current))
  }
  fmt.println("Path risk total:", total_risk)
}

a_star_open_set_less :: proc(a, b: RiskNode) -> bool {
  return a.risk_value < b.risk_value
}

a_star :: proc(risk_map: RiskMap, start: int, goal: int) {
  goal_coord := index_to_coord(risk_map, goal)

  neighbours := make([dynamic]int, 0, 4)
  defer delete(neighbours)

  open_set: priority_queue.Priority_Queue(RiskNode)
  priority_queue.init(&open_set, a_star_open_set_less, priority_queue.default_swap_proc(RiskNode))
  defer priority_queue.destroy(&open_set)

  queued_set := make(map[int]bool)
  defer delete(queued_set)

  path_scores := make(map[int]int)
  defer delete(path_scores)

  came_from := make(map[int]int)
  defer delete(came_from)

  priority_queue.push(&open_set, RiskNode{start, int(risk_map.values[start])})
  queued_set[start] = true
  path_scores[start] = 0

  for priority_queue.len(open_set) > 0 {
    fmt.println("Priority queue length:", priority_queue.len(open_set))
    node := priority_queue.pop(&open_set)
    delete_key(&queued_set, node.map_index)

    if node.map_index == goal {
      fmt.println("Goal reached")
      a_star_reconstruct_path(risk_map, came_from, node.map_index)
      break
    }

    get_neighbouring_indices(risk_map,  node.map_index, &neighbours)
    for neighbour_index in neighbours {
      neighbour_risk := risk_map.values[neighbour_index]
      tentative_path_score := path_scores[node.map_index] + int(neighbour_risk)

      if neighbour_index not_in path_scores || tentative_path_score < path_scores[neighbour_index] {
        path_scores[neighbour_index] = tentative_path_score
        neighbour_coord := index_to_coord(risk_map, neighbour_index)

        if neighbour_index not_in queued_set {
          neighbour_node := RiskNode {
            map_index = neighbour_index,
            risk_value = tentative_path_score + distance_manhattan(neighbour_coord, goal_coord),
          }

          came_from[neighbour_index] = node.map_index
          priority_queue.push(&open_set, neighbour_node)
          queued_set[neighbour_index] = true
        }
      }
    }
  }
}

init_risk_map :: proc(risk_map: ^RiskMap, input_data: string) {
  lines := strings.split_lines(input_data)
  defer delete(lines)
  assert(len(lines) > 0)

  using risk_map
  width = len(lines[0])
  height = len(lines)
  values = make([]u8, width * height)

  for line_iter, y in lines {
    for char_iter, x in line_iter {
      map_index := coord_to_index(risk_map^, {x, y})
      values[map_index] = u8(char_iter - '0')
    }
  }
}

delete_risk_map :: proc(risk_map: ^RiskMap) {
  using risk_map
  delete(values)
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    risk_map: RiskMap
    init_risk_map(&risk_map, string(data))
    defer delete_risk_map(&risk_map)

    start := 0
    goal := len(risk_map.values) - 1

    a_star(risk_map, start, goal)
  }
}
