defmodule Aoc.Y2024.Day7Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day7

  test "basic input test" do
    validation_result = Day7.validate_line("190: 10 19")
    assert validation_result == 190
  end

  test "test with 2 solutions" do
    validation_result = Day7.validate_line("3267: 81 40 27")
    assert validation_result == 3267
  end

  test "no solutions" do
    validation_result = Day7.validate_line("156: 15 6")
    assert validation_result == 0
  end
end
