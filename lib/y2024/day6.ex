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

  defp rotate_until_free(map, pos, dir) do
    next_pos = sum_vec(pos, guard_dir_to_vec(dir))
    next_cell = Map.get(map, next_pos)

    if next_cell != nil and next_cell.content == :obstructed do
      rotate_until_free(map, pos, rotate_dir(dir))
    else
      {dir, pos}
    end
  end

  defp detect_loop_aux(map, {x, y}, dir, count \\ 0) do
    {new_dir, pos} = rotate_until_free(map, {x, y}, dir)
    next_pos = sum_vec(pos, guard_dir_to_vec(new_dir))
    next_cell = Map.get(map, next_pos)

    current_cell = Map.get(map, {x, y})

    cond do
      Enum.member?(current_cell.visited, new_dir) ->
        1

      next_cell == nil ->
        # map is exited, no loop
        0

      true ->
        # update map with new direction
        updated_cell = %Cell{
          current_cell
          | visited: [new_dir | current_cell.visited],
            guard_dir: :none
        }

        map = Map.put(map, {x, y}, updated_cell)
        detect_loop_aux(map, next_pos, new_dir, count + 1)
    end
  end

  defp detect_loop(guard_cell, guard_pos, map) do
    dir = guard_cell.guard_dir
    dir_vec = guard_dir_to_vec(dir)
    rock_placement = sum_vec(guard_pos, dir_vec)
    rock_cell = Map.get(map, rock_placement)
    # if the cell where we want to place the rock was visited in the past, we cannot place a rock
    if rock_cell == nil or rock_cell.content == :obstructed or rock_cell.visited != [] do
      0
    else
      updated_rock_cell = %Cell{rock_cell | content: :obstructed}
      loop_test_map = Map.put(map, rock_placement, updated_rock_cell)

      detect_loop_aux(loop_test_map, guard_pos, dir)
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
        {map, loops}

      next_guard_cell.content == :obstructed ->
        guard_cell = %Cell{guard_cell | guard_dir: rotate_dir(dir)}
        map = Map.put(map, guard_pos, guard_cell)
        walk_map(map, guard_pos, loops)

      true ->
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
