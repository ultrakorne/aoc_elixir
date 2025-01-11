defmodule Aoc.Y2024.Day15Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day15

  test "should not move robot" do
    str = "@##"
    out = Day15.move_robot(str)
    assert out == "@##"

    str = "@O#"
    out = Day15.move_robot(str)
    assert out == "@O#"

    str = "@OOOO#"
    out = Day15.move_robot(str)
    assert out == "@OOOO#"
  end

  test "move robot" do
    str = "@.#"
    out = Day15.move_robot(str)
    assert out == ".@#"

    str = "@O.O.#"
    out = Day15.move_robot(str)
    assert out == ".@OO.#"
  end

  test "move with pushing stack" do
    str = "@OO.#"
    out = Day15.move_robot(str)
    assert out == ".@OO#"

    str = "@OOO.#"
    out = Day15.move_robot(str)
    assert out == ".@OOO#"

    str = "@OOO.O#"
    out = Day15.move_robot(str)
    assert out == ".@OOOO#"

    str = "@OOO...#"
    out = Day15.move_robot(str)
    assert out == ".@OOO..#"
  end

  test "grid slice" do
    {grid, _} = "data/2024/day15_test_2.txt" |> File.read!() |> Day15.parse_grid()
    robot_pos = Day15.find_robot(grid)
    assert robot_pos == {2, 2}

    grid_slice = Day15.get_grid_slice(grid, robot_pos, "<")
    assert grid_slice == "@##"

    grid_slice = Day15.get_grid_slice(grid, robot_pos, "^")
    assert grid_slice == "@.#"

    grid_slice = Day15.get_grid_slice(grid, robot_pos, ">")
    assert grid_slice == "@.O..#"

    grid_slice = Day15.get_grid_slice(grid, robot_pos, "v")
    assert grid_slice == "@.#..#"
  end

  test "replace slice" do
    {grid, _} = "data/2024/day15_test_2.txt" |> File.read!() |> Day15.parse_grid()
    new_grid = Day15.replace_grid_slice(grid, {2, 2}, "<", "@.#")

    assert Map.get(new_grid, {2, 2}) == "@"
    assert Map.get(new_grid, {1, 2}) == "."
    assert Map.get(new_grid, {0, 2}) == "#"
  end

  test "move push" do
    {grid, _} = "data/2024/day15_test_2.txt" |> File.read!() |> Day15.parse_grid()
    new_grid = Day15.move_push({grid, "^"})

    assert Map.get(new_grid, {2, 2}) == "."
    assert Map.get(new_grid, {2, 1}) == "@"
    assert Map.get(new_grid, {2, 0}) == "#"
  end

  test "day 2 pushing" do
    str_grid =
      """
      ##############
      ##......##..##
      ##..[][]....##
      ##...[].....##
      ##....[]....##
      ##....@.....##
      ##############

      ^
      """
      |> Day15.parse_grid()
      |> Day15.move_push_2()
      |> Aoc.Helper.grid_to_string()

    assert str_grid ==
             """
             ##############
             ##..[][]##..##
             ##...[].....##
             ##....[]....##
             ##....@.....##
             ##..........##
             ##############
             """
  end

  test "cannot push down" do
    str_grid =
      """
      ##############
      ##..@...##..##
      ##..[][]....##
      ##...[].....##
      ##....[]....##
      ##.....#....##
      ##############

      v
      """
      |> Day15.parse_grid()
      |> Day15.move_push_2()
      |> Aoc.Helper.grid_to_string()

    assert str_grid ==
             """
             ##############
             ##..@...##..##
             ##..[][]....##
             ##...[].....##
             ##....[]....##
             ##.....#....##
             ##############
             """
  end

  test "day 2 pushing down" do
    str_grid =
      """
      ##############
      ##..@...##..##
      ##..[][]....##
      ##...[].....##
      ##....[]....##
      ##..........##
      ##############

      v
      """
      |> Day15.parse_grid()
      |> Day15.move_push_2()
      |> Aoc.Helper.grid_to_string()

    assert str_grid ==
             """
             ##############
             ##......##..##
             ##..@.[]....##
             ##..[]......##
             ##...[].....##
             ##....[]....##
             ##############
             """
  end

  test "day 2 right" do
    str_grid =
      """
      ##############
      ##......##..##
      ##.@[][].[].##
      ##...[].....##
      ##....[]....##
      ##..........##
      ##############

      >
      """
      |> Day15.parse_grid()
      |> Day15.move_push_2()
      |> Aoc.Helper.grid_to_string()

    assert str_grid ==
             """
             ##############
             ##......##..##
             ##..@[][][].##
             ##...[].....##
             ##....[]....##
             ##..........##
             ##############
             """
  end

  test "day 2 simple test case" do
    result =
      """
      #######
      #...#.#
      #.....#
      #..OO@#
      #..O..#
      #.....#
      #######

      <vv<<^^<<^^
      """
      |> Day15.parse_grid(true)
      |> Day15.move_push_2()
      |> Day15.box_scores()

    assert result == 618
  end
end
