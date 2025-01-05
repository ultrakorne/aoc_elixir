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

  defp widen_room(line, result \\ "") do
    case line do
      [] -> result
      ["@" | rest] -> widen_room(rest, result <> "@.")
      ["O" | rest] -> widen_room(rest, result <> "[]")
      ["." | rest] -> widen_room(rest, result <> "..")
      ["#" | rest] -> widen_room(rest, result <> "##")
    end
  end

  def parse_grid_day_2(str) do
    [grid_list, moves] =
      str
      |> String.split(Helper.eol())
      |> Enum.chunk_by(fn line -> line == "" end)
      |> Enum.reject(fn chunk -> chunk == [""] end)

    grid_list =
      grid_list
      |> Enum.map(fn line -> widen_room(String.graphemes(line)) end)

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

  def move_push_2({grid, dir}) do
    dir_list = String.graphemes(dir)
    robot_pos = find_robot(grid)
    move_push_2_aux(grid, robot_pos, dir_list)
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

  defp move_push_2_aux(grid, robot_pos, dir_list) do
    case dir_list do
      [] ->
        grid

      [dir | rest] ->
        pos_ahead = move_coord(robot_pos, dir)
        new_grid = move_robot_2(grid, pos_ahead, dir)
        robot_pos = find_robot(new_grid)
        move_push_2_aux(new_grid, robot_pos, rest)
    end
  end

  defp move_robot_2(grid, pos, dir) do
    {did_push?, new_grid} = push(grid, pos, dir, grid)
    if did_push?, do: new_grid, else: grid
  end

  defp get_lateral_pos(pos, "["), do: move_coord(pos, ">")
  defp get_lateral_pos(pos, "]"), do: move_coord(pos, "<")

  defp push(
         grid,
         pos,
         dir,
         new_grid,
         insert \\ ".",
         recurse \\ true,
         already_moved \\ MapSet.new()
       ) do
    already_moved? = MapSet.member?(already_moved, pos)

    case dir do
      _ when already_moved? ->
        IO.puts("already moved to #{inspect(pos)}")
        {true, new_grid}

      dir when dir in ["^", "v"] ->
        at_pos = Map.get(grid, pos)
        # if insert == x, insert . if it was not visited already

        # insert =
        #   cond do
        #     insert == "x" and MapSet.member?(already_moved, pos) -> "."
        #     insert == "x" -> at_pos
        #     true -> insert
        #   end

        case at_pos do
          "." ->
            new_grid = Map.put(new_grid, pos, insert)
            IO.puts("found . at #{inspect(pos)}, inserting #{insert}")
            {true, new_grid}

          "#" ->
            {false, grid}

          at_pos when at_pos in ["[", "]"] and recurse ->
            # new_grid = Map.put(new_grid, pos, insert)
            lateral_position = get_lateral_pos(pos, at_pos)
            IO.puts("checking laterally #{at_pos} at #{inspect(pos)}")

            {can_push?, new_grid} =
              push(grid, lateral_position, dir, new_grid, ".", false, already_moved)

            if can_push? do
              already_moved = MapSet.put(already_moved, pos)

              {can_push?, new_grid} =
                push(grid, move_coord(pos, dir), dir, new_grid, at_pos, already_moved)

              new_grid = Map.put(new_grid, pos, insert)
              IO.puts("found #{at_pos} at #{inspect(pos)} inserting #{insert}")
              {can_push?, new_grid}
            else
              {false, grid}
            end

          _ ->
            new_grid = Map.put(new_grid, pos, insert)
            IO.puts("at_pos #{at_pos} at #{inspect(pos)} insert #{insert}")
            already_moved = MapSet.put(already_moved, pos)
            push(grid, move_coord(pos, dir), dir, new_grid, at_pos, already_moved)
        end

      dir ->
        nil
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
    # {grid, directions} =
    #   "data/2024/day15_test.txt"
    #   |> File.read!()
    #   |> parse_grid_day_2()

    0
    # new_grid = move_push_2({grid, directions})

    # grid
    # |> Helper.print_grid()
  end
end
