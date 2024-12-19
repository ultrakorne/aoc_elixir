defmodule Aoc.Y2024.Day8Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day8

  test "find antinodes" do
    c1 = {3, 4}
    c2 = {5, 5}
    bounds = {10, 10}
    antinodes = Day8.find_antinodes(c1, c2, bounds)
    assert length(antinodes) == 2
    assert Enum.member?(antinodes, {1, 3})
    assert Enum.member?(antinodes, {7, 6})
  end

  test "finding antinodes of a list" do
    list = [{5, 6}, {8, 8}, {9, 9}]
    bounds = {20, 20}
    antinodes = Day8.find_antinodes_list(list, bounds, &Day8.find_antinodes/3)
    assert length(antinodes) == 6
  end

  test "antinodes in line for day 2" do
    c1 = {3, 3}
    c2 = {4, 4}
    bound = {7, 7}

    _antinodes = Day8.find_antinodes_2(c1, c2, bound)
  end
end
