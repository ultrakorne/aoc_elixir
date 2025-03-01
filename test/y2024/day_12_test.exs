defmodule Aoc.Y2024.Day12Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day12
  alias Aoc.Helper

  test "dividing plot with same letters" do
    result =
      """
      OOOOO
      OXOXO
      OXOOO
      OXOXO
      OOOOO
      """
      |> Helper.parse_grid_from_string()
      |> Enum.group_by(fn {_, v} -> v end)
      |> Map.get("X")
      |> Day12.split_non_neighbouring_b()

    assert result ==
             [
               [{{3, 3}, "X"}],
               [{{1, 3}, "X"}],
               [{{3, 1}, "X"}, {{2, 1}, "X"}, {{1, 1}, "X"}]
             ]
  end

  test "plots testing score" do
    grid =
      """
      OOOOO
      OXOXO
      OOOOO
      OXOXO
      OOOOO
      """
      |> Helper.parse_grid_from_string()

    map =
      grid
      |> Enum.group_by(fn {_, v} -> v end)

    result =
      map
      |> Map.get("X")
      |> Day12.fence_price(grid, &Day12.plot_perimeter/3)

    assert result == 16

    result_2 =
      map
      |> Map.get("O")
      |> Day12.fence_price(grid, &Day12.plot_perimeter/3)

    assert result_2 == 756
  end

  test "test input day1" do
    result =
      Helper.parse_grid("data/2024/day12_test.txt")
      |> Day12.fence_price_tot(&Day12.plot_perimeter/3)

    assert result == 1930
  end

  test "test perimeter day2" do
    grid =
      """
      OOOOO
      OXXXO
      OXXXO
      OXOXO
      """
      |> Helper.parse_grid_from_string()

    perimeter =
      grid
      |> Enum.group_by(fn {_, v} -> v end)
      |> Map.get("X")
      |> Day12.plot_perimeter_2(grid)

    assert perimeter == 8
  end

  test "test input day2" do
    result =
      Helper.parse_grid("data/2024/day12_test.txt")
      |> Day12.fence_price_tot(&Day12.plot_perimeter_2/3)

    assert result == 1206
  end
end
