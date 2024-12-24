defmodule Aoc.Y2024.Day12 do
  alias Aoc.Helper
  alias MapSet

  defp four_dir_from_coords({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
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

  def fence_price(plot_coords, grid) do
    plot_coords
    |> split_non_neighbouring_b()
    |> Enum.reduce(0, fn coords, acc ->
      fence_price_aux(coords, grid) + acc
    end)
  end

  #   defp is_neighbouring?({x1, y1}, {x2, y2}) do
  #     abs(x1 - x2) + abs(y1 - y2) == 1
  #   end

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

  defp fence_price_aux(plot_coords, grid, {area, perimeter} \\ {0, 0}) do
    case plot_coords do
      [{{x, y}, p} | rest] ->
        area = area + 1
        perimeter = perimeter + perimeter({x, y}, p, grid)
        fence_price_aux(rest, grid, {area, perimeter})

      [] ->
        area * perimeter
    end
  end

  def fence_price_tot(grid) do
    plots_map =
      grid
      |> Enum.group_by(fn {_, v} -> v end)

    plots_map
    |> Map.keys()
    |> Enum.reduce(0, fn plot_id, acc ->
      plot_coords = Map.get(plots_map, plot_id)
      price = fence_price(plot_coords, grid)
      #   IO.puts("plot_id: #{plot_id}, price: #{price}")
      acc + price
    end)
  end

  def execute_1() do
    Helper.parse_grid("data/2024/day12.txt")
    |> fence_price_tot()
  end
end
