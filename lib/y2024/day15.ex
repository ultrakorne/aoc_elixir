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

  def find_robot(grid) do
    grid
    |> Map.keys()
    |> Enum.find(fn coord -> Map.get(grid, coord) == "@" end)
  end

  def get_grid_slice(grid, {x, y}, dir, acc \\ "") do
    result = Map.get(grid, {x, y})

    case result do
      nil ->
        acc

      r ->
        next_pos = move_coord({x, y}, dir)
        get_grid_slice(grid, next_pos, dir, acc <> r)
    end
  end

  defp move_coord({x, y}, dir) do
    case dir do
      "<" -> {x - 1, y}
      ">" -> {x + 1, y}
      "^" -> {x, y - 1}
      "v" -> {x, y + 1}
    end
  end

  def replace_grid_slice(grid, {x, y}, dir, slice) do
    graphemes = String.graphemes(slice)
    replace_grid_slice_aux(grid, {x, y}, dir, graphemes)
  end

  defp replace_grid_slice_aux(grid, {x, y}, dir, slice_list) do
    case slice_list do
      [] ->
        grid

      [char | rest] ->
        grid = Map.put(grid, {x, y}, char)
        next_pos = move_coord({x, y}, dir)
        replace_grid_slice_aux(grid, next_pos, dir, rest)
    end
  end

  def move_push({grid, dir}) do
    dir_list = String.graphemes(dir)
    robot_pos = find_robot(grid)
    move_push_aux(grid, robot_pos, dir_list)
  end

  defp move_push_aux(grid, robot_pos, dir_list) do
    case dir_list do
      [] ->
        grid

      [dir | rest] ->
        slice = get_grid_slice(grid, robot_pos, dir)
        new_slice = move_robot(slice)
        new_grid = replace_grid_slice(grid, robot_pos, dir, new_slice)
        robot_pos = find_robot(new_grid)
        move_push_aux(new_grid, robot_pos, rest)
    end
  end

  def box_scores(grid) do
    grid
    |> Map.keys()
    |> Enum.filter(fn {x, y} -> Map.get(grid, {x, y}) == "O" end)
    |> Enum.reduce(0, fn {x, y}, acc ->
      acc + 100 * y + x
    end)
  end

  def execute_1() do
    "data/2024/day15.txt"
    |> File.read!()
    |> parse_grid()
    |> move_push()
    |> box_scores()
  end

  def execute_2() do
    "day15 part 2"
  end
end
