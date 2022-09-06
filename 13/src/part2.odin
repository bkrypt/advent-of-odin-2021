package aoc_13

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

Point :: [2]int

Axis :: enum {
  X,
  Y,
}

Fold :: struct {
  axis: Axis,
  coord: int,
}

HeatMap :: struct {
  width: int,
  height: int,
  points: [dynamic]Point,
  point_set: map[Point]bool,
  folds: []Fold,
  folds_completed: int,
}

print_heat_map_details :: proc(heat_map: HeatMap) {
  using heat_map
  fmt.println()
  fmt.println("After", folds_completed, "folds")
  fmt.println("==============")
  fmt.println("Number of dots visible:", len(points))

  if folds_completed == len(folds) {
    fmt.println()
    fmt.println("::Code::")
    fmt.println("========")
    tiles := make([]rune, width * height)
    defer delete(tiles)
    slice.fill(tiles, '.')
    for point in points {
      tiles[point.y * width + point.x] = '#'
    }
  
    for y in 0..<height {
      for x in 0..<width {
        fmt.print(tiles[y * width + x])
      }
      fmt.println()
    }
  }
}

fold_heat_map_y :: proc(heat_map: ^HeatMap, y: int) {
  using heat_map

  new_points: [dynamic]Point
  for point in points {
    if point.y > y {
      delete_key(&point_set, point)
      folded_point := Point {point.x, y - (point.y - y)}
      if folded_point not_in point_set {
        append(&new_points, folded_point)
        point_set[folded_point] = true
      }
    }
    else {
      append(&new_points, point)
    }
  }
  clear_dynamic_array(&points)
  append(&points, ..new_points[:])

  height = y
}

fold_heat_map_x :: proc(heat_map: ^HeatMap, x: int) {
  using heat_map

  new_points: [dynamic]Point
  for point in points {
    if point.x > x {
      delete_key(&point_set, point)
      folded_point := Point {x - (point.x - x), point.y}
      if folded_point not_in point_set {
        append(&new_points, folded_point)
        point_set[folded_point] = true
      }
    }
    else {
      append(&new_points, point)
    }
  }  
  clear_dynamic_array(&points)
  append(&points, ..new_points[:])

  width = x
}

fold_heat_map :: proc(heat_map: ^HeatMap, fold: Fold) {
  switch fold.axis {
    case .X: fold_heat_map_x(heat_map, fold.coord)
    case .Y: fold_heat_map_y(heat_map, fold.coord)
  }

  folds_completed += 1
}

init_heat_map :: proc(heat_map: ^HeatMap, points: [dynamic]Point, folds: []Fold) {
  dimensions := Point{0, 0}
  for point in points {
    heat_map.point_set[point] = true
    if dimensions.x < point.x do dimensions.x = point.x
    if dimensions.y < point.y do dimensions.y = point.y
  }
  heat_map.points = points
  heat_map.folds = folds
  heat_map.width = dimensions.x + 1
  heat_map.height = dimensions.y + 1
}

populate_points_from_input :: proc(input: ^string, points: ^[dynamic]Point) {
  for line in strings.split_lines_iterator(input) {
    if line == "" do continue 

    coords := strings.split(line, ",")
    assert(len(coords) == 2)
    defer delete(coords)

    x := strconv.atoi(coords[0])
    y := strconv.atoi(coords[1])

    point := Point{x, y}
    append(points, point)
  }
}

populate_folds_from_input :: proc(input: ^string, folds: ^[dynamic]Fold) {
  for line in strings.split_lines_iterator(input) {
    axis := strings.cut(line, strings.last_index(line, " ") + 1)
    defer delete(axis)

    parts := strings.split(axis, "=")
    assert(len(parts) == 2)
    defer delete(parts)

    append(folds, Fold{
      axis = .X if parts[0] == "x" else .Y,
      coord = strconv.atoi(parts[1]),
    })
  }
}

main :: proc() {
  if data, ok := os.read_entire_file_from_filename("input.txt"); ok {
    defer delete(data, context.allocator)

    inputs := strings.split_after(string(data), "\n\n")
    assert(len(inputs) == 2)
    defer delete(inputs)

    points: [dynamic]Point
    populate_points_from_input(&inputs[0], &points)

    folds: [dynamic]Fold
    populate_folds_from_input(&inputs[1], &folds)

    max := Point{0, 0}
    for point in points {
      if max.x < point.x do max.x = point.x
      if max.y < point.y do max.y = point.y
    }

    heat_map: HeatMap
    init_heat_map(&heat_map, points, folds[:])
    print_heat_map_details(heat_map)

    for fold, count in folds {
      fold_heat_map(&heat_map, fold)
      print_heat_map_details(heat_map)
    }
  }
}
