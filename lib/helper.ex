defmodule Aoc.Helper do
  @eol if match?({:win32, _}, :os.type()), do: "\r\n", else: "\n"

  def eol(), do: @eol

  def read_file(file_path) do
    file_path
    |> File.read!()
    |> String.split(@eol, trim: true)
  end

  defp parse_line(line, x, map, flip_ax) do
    line
    |> String.graphemes()
    |> Stream.with_index()
    |> Enum.reduce(map, fn {char, char_idx}, acc ->
      tuple = if flip_ax, do: {x, char_idx}, else: {char_idx, x}
      Map.put(acc, tuple, char)
    end)
  end

  def parse_grid(file_path, flip_ax \\ true) do
    file_path
    |> File.read!()
    |> parse_grid_from_string(flip_ax)
  end

  def parse_grid_from_list(grid_list, flip_ax \\ true) when is_list(grid_list) do
    grid_list
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, index}, acc -> parse_line(line, index, acc, flip_ax) end)
  end

  def parse_grid_from_string(grid_string, flip_ax \\ true) do
    grid_string
    |> String.split(@eol, trim: true)
    |> parse_grid_from_list(flip_ax)
  end

  def print_grid(grid) do
    {max_x, max_y} = grid_size(grid)

    IO.puts("")

    for y <- 0..max_y do
      for x <- 0..max_x do
        IO.write(Map.get(grid, {x, y}, "."))
      end

      IO.puts("")
    end

    grid
  end

  def grid_to_string(grid) do
    {max_x, max_y} = grid_size(grid)

    result =
      for y <- 0..max_y do
        for x <- 0..max_x do
          Map.get(grid, {x, y}, ".")
        end
        |> Enum.join("")
      end
      |> Enum.join("\n")

    result <> "\n"
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
