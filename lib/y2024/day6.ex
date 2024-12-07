defmodule Aoc.Y2024.Day6.Cell do
  defstruct visited: :none, content: :free, guard_dir: :none

  @type content_type :: :free | :obstructed
  @type guard_dir :: :none | :north | :east | :south | :west

  @type t :: %__MODULE__{
          visited: guard_dir(),
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

  def execute_1() do
    {map, guard_pos} =
      Aoc.Helper.parse_grid("data/2024/day6_test.txt")
      |> Enum.map_reduce(nil, fn {key, value}, acc ->
        case value do
          "." -> {{key, %Cell{}}, acc}
          "#" -> {{key, %Cell{content: :obstructed}}, acc}
          "^" -> {{key, %Cell{guard_dir: :north}}, key}
        end
      end)

    map = Enum.into(map, %{})

    map
    |> walk_map(guard_pos)
    |> count_visited()
  end

  defp guard_next_pos({x, y}, {dx, dy}), do: {x + dx, y + dy}

  defp rotate_dir(:north), do: :east
  defp rotate_dir(:east), do: :south
  defp rotate_dir(:south), do: :west
  defp rotate_dir(:west), do: :north

  defp sum_vec({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  defp walk_map(map, guard_pos) do
    guard_cell = Map.get(map, guard_pos)
    dir = guard_cell.guard_dir
    dir_vec = guard_dir_to_vec(dir)

    # if already visited, and current direction rotate is equal to that, there might be a loop if put an obstacle ahead
    if rotate_dir(dir) == guard_cell.visited do
      IO.inspect(guard_pos, label: "potential Loop detected!")
      placing_rock = sum_vec(dir_vec, guard_pos)
      IO.inspect(placing_rock, label: "Placing rock at")
      # 6,3 - 7,6 - 7,7
      # need an array of directions
    end

    guard_cell = %Cell{guard_cell | visited: dir, guard_dir: :none}
    map = Map.put(map, guard_pos, guard_cell)

    new_pos_guard = guard_next_pos(guard_pos, dir_vec)
    next_guard_cell = Map.get(map, new_pos_guard)

    cond do
      next_guard_cell == nil ->
        # IO.inspect("Guard is out!")
        map

      next_guard_cell.content == :obstructed ->
        # IO.inspect("Obstructed!")
        guard_cell = %Cell{guard_cell | guard_dir: rotate_dir(dir)}
        map = Map.put(map, guard_pos, guard_cell)
        walk_map(map, guard_pos)

      true ->
        # IO.inspect("Moving guard")
        next_guard_cell = %Cell{next_guard_cell | guard_dir: dir}
        map = Map.put(map, new_pos_guard, next_guard_cell)
        walk_map(map, new_pos_guard)
    end
  end

  defp count_visited(map) do
    map
    |> Map.values()
    |> Enum.count(fn x -> x.visited != :none end)
  end
end
