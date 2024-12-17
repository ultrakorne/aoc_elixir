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

  def find_antinodes_list(lst, bounds, acc \\ []) when is_list(lst) do
    case lst do
      [_] ->
        acc

      [c1 | rest] ->
        new_acc =
          rest
          |> Enum.flat_map(fn c2 -> find_antinodes(c1, c2, bounds) end)

        find_antinodes_list(rest, bounds, new_acc ++ acc)
    end
  end

  @spec find_antinodes({integer(), integer()}, {integer(), integer()}, {integer(), identifier()}) ::
          [{integer(), integer()}]
  def find_antinodes(c1, c2, bounds) do
    right_side = find_antinode(c1, c2, bounds)
    left_side = find_antinode(c2, c1, bounds)

    [right_side, left_side]
    |> Enum.reject(&is_nil/1)
  end

  def find_antinodes_2(c1, c2, bounds) do
    right_side = find_antinodes_line(c1, c2, bounds)
    all_antinodes = find_antinodes_line(c2, c1, bounds, right_side)
    all_antinodes
  end

  defp find_antinodes_line(c1, c2, bounds, acc \\ []) do
    case find_antinode(c1, c2, bounds) do
      nil -> acc
      n -> find_antinodes_line(c2, n, bounds, [n | acc])
    end
  end

  defp find_antinode(c1, c2, bounds) do
    d1 = sub_vec(c1, c2)
    result = sub_vec(c2, d1)
    if check_out_of_bound(result, bounds), do: nil, else: result
  end

  defp check_out_of_bound({x, y}, {max_x, max_y}) do
    x < 0 or x > max_x or y < 0 or y > max_y
  end

  def execute_1() do
    grid = parse_grid("data/2024/day8.txt")
    bounds = grid_size(grid)
    signal_map = grid |> frequency_map()

    signal_map
    |> Map.keys()
    |> Enum.reduce([], fn k, acc ->
      signal_nodes = Map.get(signal_map, k)
      find_antinodes_list(signal_nodes, bounds, acc)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def execute_2() do
    grid = parse_grid("data/2024/day8_test.txt")
    bounds = grid_size(grid)
    signal_map = grid |> frequency_map()

    signal_map
    |> Map.keys()
    |> Enum.reduce([], fn k, acc ->
      signal_nodes = Map.get(signal_map, k)
      find_antinodes_list(signal_nodes, bounds, acc)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end
end
