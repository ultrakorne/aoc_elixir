defmodule Aoc.Y2024.Day6.Cell do
  defstruct visited: [], content: :free, guard_dir: :none

  @type content_type :: :free | :obstructed
  @type guard_dir :: :none | :north | :east | :south | :west

  @type t :: %__MODULE__{
          visited: [guard_dir()],
          content: content_type(),
          guard_dir: guard_dir()
        }
end

defmodule Aoc.Y2024.Day6 do
  alias Aoc.Y2024.Day6.Cell

  defp guard_dir_to_vec(:north), do: {-1, 0}
  defp guard_dir_to_vec(:east), do: {0, 1}
  defp guard_dir_to_vec(:south), do: {1, 0}
  defp guard_dir_to_vec(:west), do: {0, -1}

  def execute_aux() do
    {map, guard_pos} =
      Aoc.Helper.parse_grid("data/2024/day6.txt")
      |> Enum.map_reduce(nil, fn {key, value}, acc ->
        case value do
          "." -> {{key, %Cell{}}, acc}
          "#" -> {{key, %Cell{content: :obstructed}}, acc}
          "^" -> {{key, %Cell{guard_dir: :north}}, key}
        end
      end)

    map = Enum.into(map, %{})
    {map, guard_pos}
  end

  def execute_1() do
    {map, guard_pos} = execute_aux()

    map
    |> walk_map(guard_pos)
    |> elem(0)
    |> count_visited()
  end

  def execute_2() do
    {map, guard_pos} = execute_aux()

    map
    |> walk_map(guard_pos)
    |> elem(1)
  end

  defp guard_next_pos({x, y}, {dx, dy}), do: {x + dx, y + dy}

  defp rotate_dir(:north), do: :east
  defp rotate_dir(:east), do: :south
  defp rotate_dir(:south), do: :west
  defp rotate_dir(:west), do: :north

  defp sum_vec({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  defp prev_visited_in_line(map, {x, y}, dir, acc \\ []) do
    cell = Map.get(map, {x, y})

    if cell == nil or cell.content == :obstructed do
      ## TODO prob we have to rotate and continue because we could have a loop after an obstacle
      acc
    else
      acc = cell.visited ++ acc
      dir_vec = guard_dir_to_vec(dir)
      next_pos = sum_vec({x, y}, dir_vec)
      prev_visited_in_line(map, next_pos, dir, acc)
    end
  end

  defp detect_loop(guard_cell, guard_pos, map) do
    dir = guard_cell.guard_dir
    dir_vec = guard_dir_to_vec(dir)
    guard_rotated = rotate_dir(dir)
    visited_line = prev_visited_in_line(map, guard_pos, guard_rotated)

    if Enum.member?(visited_line, guard_rotated) do
      placing_rock = sum_vec(dir_vec, guard_pos)
      IO.inspect(placing_rock, label: "Placing rock at")
      1
    else
      0
    end
  end

  defp walk_map(map, guard_pos, loops \\ 0) do
    guard_cell = Map.get(map, guard_pos)
    dir = guard_cell.guard_dir
    dir_vec = guard_dir_to_vec(dir)

    loops = loops + detect_loop(guard_cell, guard_pos, map)

    guard_cell = %Cell{guard_cell | visited: [dir | guard_cell.visited], guard_dir: :none}
    map = Map.put(map, guard_pos, guard_cell)

    new_pos_guard = guard_next_pos(guard_pos, dir_vec)
    next_guard_cell = Map.get(map, new_pos_guard)

    cond do
      next_guard_cell == nil ->
        # IO.inspect("Guard is out!")
        {map, loops}

      next_guard_cell.content == :obstructed ->
        # IO.inspect("Obstructed!")
        guard_cell = %Cell{guard_cell | guard_dir: rotate_dir(dir)}
        map = Map.put(map, guard_pos, guard_cell)
        walk_map(map, guard_pos, loops)

      true ->
        # IO.inspect("Moving guard")
        next_guard_cell = %Cell{next_guard_cell | guard_dir: dir}
        map = Map.put(map, new_pos_guard, next_guard_cell)
        walk_map(map, new_pos_guard, loops)
    end
  end

  defp count_visited(map) do
    map
    |> Map.values()
    |> Enum.count(fn x -> x.visited != [] end)
  end
end
