package aoc_05

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Point :: [2]int

plot_vertical_cloud :: proc(p1, p2: Point, vent_map: ^map[Point]int) {
  x, y_min, y_max := p1.x, min(p1.y, p2.y), max(p1.y, p2.y)

  for y in y_min..=y_max {
    vent_map[{x, y}] += 1
  }
}

plot_horizontal_cloud :: proc(p1, p2: Point, vent_map: ^map[Point]int) {
  y, x_min, x_max := p1.y, min(p1.x, p2.x), max(p1.x, p2.x)

  for x in x_min..=x_max {
    vent_map[{x, y}] += 1
  }
}

plot_diagonal_cloud :: proc(p1: Point, p2: Point, vent_map: ^map[Point]int) {
  x, y := p1.x, p1.y

  x_change := 1
  if p1.x > p2.x {
    x_change = -1
  }

  y_change := 1
  if p1.y > p2.y {
    y_change = -1
  }

  for _ in 0..=abs(p1.x - p2.x) {
    vent_map[{x, y}] += 1

    x += x_change
    y += y_change
  }
}

count_points_with_overlapping_lines :: proc(vent_map: map[Point]int) -> (count: int) {
  for k, v in vent_map {
    if v > 1 do count += 1
  }
  return
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data)

    it := string(data)
    vent_map := make(map[Point]int)
    defer delete(vent_map)

    for line in strings.split_lines_iterator(&it) {
      points := strings.split(line, " -> ")
      assert(len(points) == 2)

      str_p1 := strings.split(points[0], ",")
      str_p2 := strings.split(points[1], ",")

      p1 := Point {strconv.atoi(str_p1[0]), strconv.atoi(str_p1[1])}
      p2 := Point {strconv.atoi(str_p2[0]), strconv.atoi(str_p2[1])}

      switch {
        case p1.x == p2.x: plot_vertical_cloud(p1, p2, &vent_map)
        case p1.y == p2.y: plot_horizontal_cloud(p1, p2, &vent_map)
        case: plot_diagonal_cloud(p1, p2, &vent_map)
      }
    }

    num_points_with_overlaps := count_points_with_overlapping_lines(vent_map)
    fmt.println(num_points_with_overlaps)
  }
}
