defmodule Aoc.Y2024.Day10Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day10
  alias Aoc.Helper

  test "find_trailheads" do
    grid = %{
      {0, 0} => "0",
      {0, 1} => "1",
      {0, 2} => "0",
      {2, 1} => "2",
      {2, 2} => "3"
    }

    assert Day10.find_trailheads(grid) == [{0, 0}, {0, 2}]
  end

  test "trailhead with test input" do
    result =
      Helper.parse_grid("data/2024/day10_test.txt")
      |> Day10.find_trailheads()

    assert length(result) == 9
  end

  test "first hiking trail with test input" do
    grid = Helper.parse_grid("data/2024/day10_test.txt")
    trailheads = Day10.find_trailheads(grid)

    hiking_score = Day10.find_hiking_trail_score(grid, hd(trailheads))
    assert hiking_score == 5
  end

  test "finding all the hiking trail scores for the test input" do
    grid = Helper.parse_grid("data/2024/day10_test.txt")

    hiking_scores =
      Day10.find_trailheads(grid)
      |> Day10.find_hiking_trail_score(grid)

    assert hiking_scores == [5, 6, 5, 3, 1, 3, 5, 3, 5]
  end

  test "finding all the hiking trail scores for the test input for Day 2" do
    grid = Helper.parse_grid("data/2024/day10_test.txt")

    hiking_scores =
      Day10.find_trailheads(grid)
      |> Day10.find_hiking_trail_score_2(grid)

    IO.inspect(hiking_scores, label: "Hiking scores day 2")
  end
end
