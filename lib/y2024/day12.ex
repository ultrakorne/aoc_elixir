defmodule Aoc.Y2024.Day12 do
  alias Aoc.Helper
  alias MapSet

  defp four_dir_from_coords({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  defp four_dir_from_coords_2({x, y}) do
    [
      {x, y + 1, :right},
      {x + 1, y, :bottom},
      {x, y - 1, :left},
      {x - 1, y, :top}
    ]
  end

  def perimeter({x, y}, plot_type, grid) do
    four_dir_from_coords({x, y})
    |> Enum.reduce(0, fn {x, y}, acc ->
      case Map.get(grid, {x, y}) do
        type when type == plot_type ->
          acc

        _ ->
          acc + 1
      end
    end)
  end

  def perimeter_2({x, y}, plot_type, grid) do
    four_dir_from_coords_2({x, y})
    |> Enum.reduce([], fn {x, y, dir}, acc ->
      case Map.get(grid, {x, y}) do
        type when type == plot_type ->
          acc

        _ ->
          [dir | acc]
      end
    end)
  end

  def fence_price(plot_coords, grid, plot_perimeter_func) do
    plot_coords
    |> split_non_neighbouring_b()
    |> Enum.reduce(0, fn coords, acc ->
      plot_area(coords) * plot_perimeter_func.(coords, grid, 0) + acc
    end)
  end

  def split_non_neighbouring_b(plot_coords, acc \\ []) do
    map_set = MapSet.new(plot_coords)
    first = hd(plot_coords)
    {neighbours, remainings} = flood_fill(first, map_set)
    acc = [neighbours | acc]

    if MapSet.size(remainings) > 0 do
      split_non_neighbouring_b(MapSet.to_list(remainings), acc)
    else
      acc
    end
  end

  defp flood_fill({{x, y}, p}, map_set, acc \\ []) do
    if MapSet.member?(map_set, {{x, y}, p}) do
      map_set = MapSet.delete(map_set, {{x, y}, p})
      acc = [{{x, y}, p} | acc]

      four_dir_from_coords({x, y})
      |> Enum.reduce({acc, map_set}, fn {xd, yd}, {acc2, map_set2} ->
        flood_fill({{xd, yd}, p}, map_set2, acc2)
      end)
    else
      {acc, map_set}
    end
  end

  defp plot_area(plot_coords) do
    Enum.count(plot_coords)
  end

  def plot_perimeter(plot_coords, grid, perimeter \\ 0) do
    case plot_coords do
      [{{x, y}, p} | rest] ->
        perimeter = perimeter + perimeter({x, y}, p, grid)
        plot_perimeter(rest, grid, perimeter)

      [] ->
        perimeter
    end
  end

  def plot_perimeter_2(plot_coords, grid, _p \\ 0) do
    plot_perimeter_2_aux(plot_coords, grid)
    |> compute_perimeter(grid)
  end

  defp compute_perimeter(coords, grid, perimeter \\ 0) do
    coords =
      coords
      |> Enum.filter(fn {{_, _}, _, fences_directions} -> length(fences_directions) > 0 end)

    case coords do
      [{_, _, fences_directions} | _] ->
        first_dir = hd(fences_directions)

        perim =
          Enum.filter(coords, fn {{_, _}, _, dirs} -> Enum.member?(dirs, first_dir) end)
          |> count_distinct_fences(first_dir)

        Enum.map(coords, fn {{x, y}, p, dirs} -> {{x, y}, p, List.delete(dirs, first_dir)} end)
        |> compute_perimeter(grid, perimeter + perim)

      [] ->
        perimeter
    end
  end

  defp count_distinct_fences(coords, dir) do
    grouped =
      coords
      |> Enum.group_by(fn {{x, y}, _, _} -> if dir in [:top, :bottom], do: x, else: y end)

    grouped
    |> Map.keys()
    |> Enum.reduce(0, fn key, acc ->
      fence_in_line = Map.get(grouped, key)
      acc + count_distinct_fences_aux(fence_in_line, dir)
    end)
  end

  defp count_distinct_fences_aux(fence_in_line, dir) do
    fence_in_line
    |> Enum.map(fn {{x, y}, _, _} -> if dir in [:top, :bottom], do: y, else: x end)
    |> Enum.sort()
    |> Enum.reduce({-100, 0}, fn x, {prev, acc} ->
      # we need to count how many numbers are not consecutive
      if x - prev > 1, do: {x, acc + 1}, else: {x, acc}
    end)
    |> elem(1)
  end

  defp plot_perimeter_2_aux(plot_coords, grid, acc \\ []) do
    case plot_coords do
      [{{x, y}, p} | rest] ->
        # fences direction [:top, :right, :bottom, :left]
        fences_directions = perimeter_2({x, y}, p, grid)
        acc = [{{x, y}, p, fences_directions} | acc]
        plot_perimeter_2_aux(rest, grid, acc)

      [] ->
        acc
    end
  end

  def fence_price_tot(grid, perimeter_func) do
    plots_map =
      grid
      |> Enum.group_by(fn {_, v} -> v end)

    plots_map
    |> Map.keys()
    |> Enum.reduce(0, fn plot_id, acc ->
      plot_coords = Map.get(plots_map, plot_id)
      price = fence_price(plot_coords, grid, perimeter_func)
      acc + price
    end)
  end

  def execute_1() do
    Helper.parse_grid("data/2024/day12.txt")
    |> fence_price_tot(&plot_perimeter/3)
  end

  def execute_2() do
    Helper.parse_grid("data/2024/day12.txt")
    |> fence_price_tot(&plot_perimeter_2/3)
  end
end
