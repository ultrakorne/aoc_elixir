defmodule Aoc.Y2024.Day9Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day9

  test "test highest fitting id" do
    highest_fitting = Day9.get_highest_fitting_id(3, %{1 => 3, 2 => 2, 3 => 1})
    assert highest_fitting == {3, 1}
  end

  test "compact disk day 2" do
    result = Day9.compact_disk_2([0, 0, nil, nil, 1, 1, 2, 2])
    assert result == [0, 0, 2, 2, 1, 1, nil, nil]
  end

  test "compact disk day 2, more" do
    result = Day9.compact_disk_2([0, 0, nil, nil, 1, 1, 2])
    assert result == [0, 0, 2, nil, 1, 1, nil]
  end

  test "compact disk day 2, should not move" do
    result = Day9.compact_disk_2([0, 0, nil, nil, 1, 1, 2, 3, 3, 3])
    assert result == [0, 0, 2, nil, 1, 1, nil, 3, 3, 3]
  end

  test "day 2, with test input" do
    IO.puts("aaa")

    "2333133121414131402"
    |> String.graphemes()
    |> Day9.decompress_disc()
    |> Day9.compact_disk_2()
    |> IO.inspect(label: "day 2 test input")
  end
end
