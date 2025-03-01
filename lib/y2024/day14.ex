defmodule Aoc.Y2024.Day14.Robot do
  defstruct pos: {0, 0}, velocity: {0, 0}
end

defmodule Aoc.Y2024.Day14 do
  alias Aoc.Y2024.Day14.Robot

  def move_robot(%Robot{pos: {x, y}, velocity: {vx, vy}}, seconds, width, height) do
    dx = vx * seconds
    dy = vy * seconds
    new_x = rem(x + dx, width)
    new_y = rem(y + dy, height)
    new_x = if new_x < 0, do: width + new_x, else: new_x
    new_y = if new_y < 0, do: height + new_y, else: new_y
    {new_x, new_y}
  end

  def parse_input(file_path) do
    File.read!(file_path)
    |> String.split("\n")
    |> Enum.map(fn s ->
      # p=6,3 v=-1,-3
      ~r/p=(\d+),(\d+) v=(-?\d+),(-?\d+)/
      |> Regex.scan(s)
      |> hd()
    end)
    |> Enum.map(fn [_, x, y, vx, vy] ->
      %Robot{
        pos: {String.to_integer(x), String.to_integer(y)},
        velocity: {String.to_integer(vx), String.to_integer(vy)}
      }
    end)
  end

  def get_quadrants(width, height) do
    [
      {0, 0, div(width, 2) - 1, div(height, 2) - 1},
      {div(width, 2) + 1, 0, width - 1, div(height, 2) - 1},
      {0, div(height, 2) + 1, div(width, 2) - 1, height - 1},
      {div(width, 2) + 1, div(height, 2) + 1, width - 1, height - 1}
    ]
  end

  def execute_1() do
    width = 101
    height = 103

    state_after =
      parse_input("data/2024/day14.txt")
      |> Enum.map(fn robot -> move_robot(robot, 100, width, height) end)

    get_quadrants(width, height)
    |> Enum.reduce(1, fn {x1, y1, x2, y2}, acc ->
      count =
        Enum.count(state_after, fn {x, y} -> x >= x1 and x <= x2 and y >= y1 and y <= y2 end)

      acc * count
    end)
  end

  defp is_possible_tree(state_after) do
    Enum.sort(state_after, fn {x1, y1}, {x2, y2} -> if x1 == x2, do: y1 < y2, else: x1 < x2 end)
    |> Enum.reduce({0, 0}, fn {x, y}, {acc, prev_xy} ->
      if abs(x + y - prev_xy) <= 1, do: {acc + 1, x + y}, else: {acc, x + y}
    end)
    |> elem(0)
  end

  def execute_2() do
    width = 101
    height = 103

    grid = parse_input("data/2024/day14.txt")

    1..100_000_000
    |> Enum.reduce_while(0, fn seconds, acc ->
      cluster =
        grid
        |> Enum.map(fn robot -> move_robot(robot, seconds, width, height) end)
        |> is_possible_tree()

      if cluster > 200, do: {:halt, seconds}, else: {:cont, acc}
    end)
  end
end
