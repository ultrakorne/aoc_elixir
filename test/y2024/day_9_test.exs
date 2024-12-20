defmodule Aoc.Y2024.Day9Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day9

  test "test highest fitting id" do
    highest_fitting = Day9.get_highest_fitting_id(3, %{1 => 3, 2 => 2, 3 => 1})
    assert highest_fitting == {3, 1}
  end

  test "replace at index" do
    result = Day9.replace_at_index([0, 0, nil, nil, 1, 1, 2, 2], 2, 2, 2)
    assert result == [0, 0, 2, 2, 1, 1, 2, 2]
  end

  test "compact disk day 2" do
    result = Day9.compact_disk_2b([0, 0, nil, nil, 1, 1, 2, 2])
    assert result == [0, 0, 2, 2, 1, 1, nil, nil]
  end

  test "compact disk day 2, more" do
    result = Day9.compact_disk_2b([0, 0, nil, nil, 1, 1, 2])
    assert result == [0, 0, 2, nil, 1, 1, nil]
  end

  test "compact disk day 2, should not move" do
    result = Day9.compact_disk_2b([0, 0, nil, nil, 1, 1, 2, 3, 3, 3])
    assert result == [0, 0, 2, nil, 1, 1, nil, 3, 3, 3]
  end

  test "find nils of size" do
    result = Day9.find_nils_of_size([0, 0, nil, nil, 1, 1, 2, 2], 2)
    result2 = Day9.find_nils_of_size([0, 0, nil, nil, 1, 1, 2, 2], 1)
    result3 = Day9.find_nils_of_size([0, 0, nil, nil, 1, nil, nil, nil, nil, 1, 2, 2], 3)
    result4 = Day9.find_nils_of_size([0, 0, nil, nil, 1, nil, nil, nil, nil, 1, 2, 2], 6)
    assert result == 2
    assert result2 == 2
    assert result3 == 5
    assert result4 == nil
  end

  test "day 2, with test input" do
    result =
      "2333133121414131402"
      |> String.graphemes()
      |> Day9.decompress_disc()
      |> Day9.compact_disk_2b()
      |> Day9.disk_to_string()

    IO.inspect(result, label: "Result")

    assert result == "00992111777.44.333....5555.6666.....8888.."
    # result should be 00992111777.44.333....5555.6666.....8888..
  end

  test "day 2 checksum" do
    result =
      "2333133121414131402"
      |> String.graphemes()
      |> Day9.decompress_disc()
      |> Day9.compact_disk_2b()
      |> Day9.checksum()

    assert result == 2858
  end
end
