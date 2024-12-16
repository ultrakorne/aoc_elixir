defmodule Aoc.Y2024.Day8Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day8

  test "find antinodes" do
    c1 = {3, 4}
    c2 = {5, 5}
    antinodes = Day8.find_antinodes(c1, c2)
    assert length(antinodes) == 2
    assert Enum.member?(antinodes, {1, 3})
    assert Enum.member?(antinodes, {7, 6})
  end

  test "finding antinodes of a list" do
    list = [{5, 6}, {8, 8}, {9, 9}]
    antinodes = Day8.find_antinodes_list(list)
    IO.inspect(antinodes, label: "antinodes list")
  end
end
