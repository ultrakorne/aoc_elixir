defmodule Aoc.Helper do
  def read_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\r\n", trim: true)
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
end
