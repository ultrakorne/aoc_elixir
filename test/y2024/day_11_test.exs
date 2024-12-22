defmodule Aoc.Y2024.Day11Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day11

  test "blink" do
    assert Day11.blink(0) == [1]
    assert Day11.blink(2024) == [20, 24]
    assert Day11.blink(1000) == [10, 0]
    assert Day11.blink(2) == [4048]
  end

  test "blink with list" do
    assert Day11.blink([125, 17]) == [253_000, 1, 7]
    assert Day11.blink([253_000, 1, 7]) == [253, 0, 2024, 14168]
  end

  test "blink n times" do
    blink_n = Day11.blink_n(125, {0, 4})
    assert blink_n == 3

    blink_left = Day11.blink_n(125, {0, 6})
    blink_right = Day11.blink_n(17, {0, 6})
    assert blink_left + blink_right == 22

    blink_left = Day11.blink_n(125, {0, 6})
    blink_right = Day11.blink_n(17, {0, 6})
    assert blink_left + blink_right == 22

    blink_all = Day11.blink_n([125, 17], 25)
    assert blink_all == 55312
  end
end
