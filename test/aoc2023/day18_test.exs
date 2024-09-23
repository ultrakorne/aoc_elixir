defmodule Aoc2023.Day18Test do
  use ExUnit.Case
  doctest Aoc2023.Day18

  test "calculate perimiter area" do

    polygon = [
      {0, 0},
      {3, 0},
      {3, 1},
      {2, 1},
      {2, 2},
      {0, 2},
      {0, 0}
    ]
    assert Aoc2023.Day18.calculate_perimeter_area(polygon) == 6
  end
end
