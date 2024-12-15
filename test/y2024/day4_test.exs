defmodule Aoc.Y2024.Day4Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day4

  test "test direction" do
    dir = Day4.get_directions(:n, 3, {4, 0})
    assert dir == [{3, 0}, {2, 0}, {1, 0}]
  end

  test "check xmas match" do
    input = %{
      {3, 0} => "X",
      {2, 0} => "M",
      {1, 0} => "A",
      {0, 0} => "S",
      {3, 1} => "M",
      {3, 2} => "A",
      {3, 3} => "S"
    }

    result = Day4.check_xmas_at(input, 3, 0)

    assert result == 2
  end

  test "check x mas" do
    input = %{
      {2, 2} => "A",
      {1, 1} => "M",
      {1, 3} => "S",
      {3, 3} => "S",
      {3, 1} => "M"
    }

    result = Day4.check_x_mas_at(input, 2, 2)
    assert result
  end
end
