defmodule Aoc.Helper do
  def read_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end
