defmodule Aoc.Helper do
  def read_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp parse_line(line, x, map) do
    line
    |> String.graphemes()
    |> Stream.with_index()
    |> Enum.reduce(map, fn {char, char_idx}, acc ->
      Map.put(acc, {x, char_idx}, char)
    end)
  end

  def parse_grid(file_path) do
    read_file(file_path)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, index}, acc -> parse_line(line, index, acc) end)
  end

  def grid_size(grid) do
    grid
    |> Map.keys()
    |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
      {max(x, max_x), max(y, max_y)}
    end)
  end

  def sum_vec({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
  def sub_vec({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}
end
