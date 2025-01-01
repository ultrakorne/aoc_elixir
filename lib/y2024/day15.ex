defmodule Aoc.Y2024.Day15 do
  alias Aoc.Helper

  def move_robot(str) do
    case String.graphemes(str) do
      ["@", "." | rest] ->
        ".@" <> Enum.join(rest)

      ["@", "#" | _] ->
        str

      ["@", "O" | rest] ->
        result = move_robot_aux(["O" | rest])
        if String.length(result) < String.length(str) - 1, do: ".@" <> result, else: "@" <> result

      _ ->
        raise "move_robot should always start with @"
    end
  end

  defp move_robot_aux(char_list) do
    case char_list do
      ["O", "." | rest] ->
        "O" <> Enum.join(rest)

      ["O", "#" | _] ->
        Enum.join(char_list)

      ["O", "O" | rest] ->
        try_move = move_robot_aux(["O" | rest])
        "O" <> try_move
    end
  end

  def parse_grid(str) do
    [grid_list, moves] =
      str
      |> String.split(Helper.eol())
      |> Enum.chunk_by(fn line -> line == "" end)
      |> Enum.reject(fn chunk -> chunk == [""] end)

    grid = Helper.parse_grid_from_list(grid_list, false)
    {grid, Enum.join(moves)}
  end

  def execute_1() do
    "data/2024/day15_test.txt"
    |> File.read!()
    |> parse_grid()
  end

  def execute_2() do
    "day15 part 2"
  end
end
