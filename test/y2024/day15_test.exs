defmodule Aoc.Y2024.Day15Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day15

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
