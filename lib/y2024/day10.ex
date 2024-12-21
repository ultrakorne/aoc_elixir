defmodule Aoc.Y2024.Day10 do
  alias Aoc.Helper

  def find_trailheads(grid) do
    grid
    |> Map.filter(fn {_k, v} -> v == "0" end)
    |> Map.keys()
  end

  defp four_directions({x, y}) do
    [{x, y + 1}, {x, y - 1}, {x + 1, y}, {x - 1, y}]
  end

  def find_hiking_trail_score(trail_heads, grid) when is_list(trail_heads) do
    Enum.reduce(trail_heads, [], fn {x, y}, acc ->
      [find_hiking_trail_score(grid, {x, y}) | acc]
    end)
    |> Enum.reverse()
  end

  def find_hiking_trail_score(grid, {x, y}) do
    find_hiking_trails_aux(grid, {x, y})
    |> Enum.uniq()
    |> length()
  end

  def find_hiking_trail_score_2(trail_heads, grid) when is_list(trail_heads) do
    Enum.reduce(trail_heads, [], fn {x, y}, acc ->
      [find_hiking_trail_score_2(grid, {x, y}) | acc]
    end)
    |> Enum.reverse()
  end

  def find_hiking_trail_score_2(grid, {x, y}) do
    find_hiking_trails_aux(grid, {x, y})
    |> length()
  end

  defp find_hiking_trails_aux(grid, {x1, y1}, elevation \\ 0, result \\ []) do
    el = Map.get(grid, {x1, y1}, "-1")

    case String.to_integer(el) do
      x when x == 9 and x == elevation ->
        [{x1, y1} | result]

      x when x != elevation ->
        result

      x when x == elevation ->
        four_directions({x1, y1})
        |> Enum.reduce(result, fn {x, y}, acc ->
          find_hiking_trails_aux(grid, {x, y}, elevation + 1, acc)
        end)
    end
  end

  def execute_1() do
    grid = Helper.parse_grid("data/2024/day10.txt")

    grid
    |> find_trailheads()
    |> find_hiking_trail_score(grid)
    |> Enum.sum()
  end

  def execute_2() do
    grid = Helper.parse_grid("data/2024/day10.txt")

    grid
    |> find_trailheads()
    |> find_hiking_trail_score_2(grid)
    |> Enum.sum()
  end
end
