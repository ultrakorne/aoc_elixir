defmodule Aoc.Y2024.Day8 do
  import Aoc.Helper

  @doc """
  from a map of the grid (key are coords) build a map of signals, and the value is a list of all the coord where they appear
  """
  def frequency_map(grid_map) do
    grid_map
    |> Stream.reject(fn {_, value} -> value == "." end)
    |> Enum.group_by(fn {_, value} -> value end, fn {key, _} -> key end)
  end

  def find_antinodes_list(lst, acc \\ []) when is_list(lst) do
    case lst do
      [_] ->
        acc

      [c1 | rest] ->
        new_acc =
          rest
          |> Enum.flat_map(fn c2 -> find_antinodes(c1, c2) end)

        find_antinodes_list(rest, new_acc ++ acc)
    end
  end

  @spec find_antinodes({integer(), integer()}, {integer(), integer()}) :: [{integer(), integer()}]
  def find_antinodes(c1, c2) do
    [find_antinode(c1, c2), find_antinode(c2, c1)]
  end

  defp find_antinode(c1, c2) do
    d1 = sub_vec(c1, c2)
    sub_vec(c2, d1)
  end

  defp check_out_of_bound({x, y}, {max_x, max_y}) do
    x < 0 or x > max_x or y < 0 or y > max_y
  end

  defp remove_out_of_bound(lst, grid) do
    max_bounds = grid |> grid_size()
    Enum.reject(lst, fn {x, y} -> check_out_of_bound({x, y}, max_bounds) end)
  end

  def execute_1() do
    grid = parse_grid("data/2024/day8.txt")
    signal_map = grid |> frequency_map()

    signal_map
    |> Map.keys()
    |> Enum.reduce([], fn k, acc ->
      signal_nodes = Map.get(signal_map, k)
      find_antinodes_list(signal_nodes, acc)
    end)
    |> Enum.uniq()
    |> remove_out_of_bound(grid)
    |> Enum.count()
  end

  def execute_2() do
    grid = parse_grid("data/2024/day8_test.txt")
    {max_x, max_y} = grid_size(grid)
    signal_map = grid |> frequency_map()

    signal_map
    |> Map.keys()
    |> Enum.reduce([], fn k, acc ->
      signal_nodes = Map.get(signal_map, k)
      find_antinodes_list(signal_nodes, acc)
    end)
    |> Enum.uniq()
    |> remove_out_of_bound(grid)
    |> Enum.count()
  end
end
