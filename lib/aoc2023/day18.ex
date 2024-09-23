defmodule Aoc2023.Day18.DigPlan do
  defstruct direction: "", distance: 0, color: ""
end

defmodule Aoc2023.Day18 do
  @moduledoc """
  Day 18 of Advent of Code 2023.
  """
  alias Aoc2023.Day18.DigPlan

  defp parse_input do
    file_path = "data/input_day18_test.txt"
    lines = Aoc2023.read_file(file_path)
    # parse_lines(lines, [])

    parse = fn
      parse, [first_line | rest], acc ->
        split = String.split(first_line, " ")

        acc =
          case split do
            [d, n, c] ->
              dig_plan = %DigPlan{direction: d, distance: String.to_integer(n), color: c}
              [dig_plan | acc]

            _ ->
              acc
          end

        parse.(parse, rest, acc)

      _, [], acc ->
        Enum.reverse(acc)
    end

    parse.(parse, lines, [])
  end

  defp move_direction(map_pos, direction, distance) do
    {x, y} = map_pos

    case direction do
      "U" -> {x, y - distance}
      "D" -> {x, y + distance}
      "L" -> {x - distance, y}
      "R" -> {x + distance, y}
    end
  end

  # defp dig_line(map, map_pos, direction, distance) do
  #   next_pos = move_direction(map_pos, direction, distance)
  #   x0 = elem(map_pos, 0)
  #   x1 = elem(next_pos, 0)
  #   is_vertical = x0 == x1

  #   map =
  #     if is_vertical do
  #       y0 = elem(map_pos, 1)
  #       y1 = elem(next_pos, 1)
  #       step = if y0 <= y1, do: 1, else: -1
  #       y_range = y0..y1//step

  #       Enum.reduce(y_range, map, fn y, acc ->
  #         is_edge = y == y0 or y == y1
  #         descriptor = if is_edge, do: :corner, else: :edge
  #         Map.update(acc, y, [{x0, descriptor}], fn lst -> [{x0, descriptor} | lst] end)
  #       end)
  #     else
  #       map
  #     end

  #   {map, next_pos}
  # end

  defp dig_line_2(map, map_pos, direction, distance) do
    next_pos = move_direction(map_pos, direction, distance)
    {[next_pos | map], next_pos}
  end

  defp create_map_2(input, map, map_pos) do
    case input do
      [line | rest] ->
        {map, next_map_pos} = dig_line_2(map, map_pos, line.direction, line.distance)
        create_map_2(rest, map, next_map_pos)

      [] ->
        Enum.reverse(map)
    end
  end

  # defp create_map(input, vertical_map, map_pos) do
  #   case input do
  #     [line | rest] ->
  #       {map, next_map_pos} = dig_line(vertical_map, map_pos, line.direction, line.distance)
  #       create_map(rest, map, next_map_pos)

  #     [] ->
  #       # to do, set the first and last keys  to :edge
  #       first_key = vertical_map |> Map.keys() |> Enum.min()

  #       vertical_map =
  #         Map.update!(vertical_map, first_key, fn lst ->
  #           Enum.map(lst, fn t -> {elem(t, 0), :edge} end)
  #         end)

  #       last_key = vertical_map |> Map.keys() |> Enum.max()

  #       vertical_map =
  #         Map.update!(vertical_map, last_key, fn lst ->
  #           Enum.map(lst, fn t -> {elem(t, 0), :edge} end)
  #         end)

  #       vertical_map
  #   end
  # end

  @spec line_area([{number(), :edge | :corner}], :inside | :outside, number()) :: number()
  def line_area(vertical_list, state \\ :inside, acc \\ 0) do
    case vertical_list do
      [{n1, type1}, {n2, type2} | rest] when type1 == :corner and type2 == :corner ->
        # acc = if state == :inside, do: acc + (n2 - n1 + 1), else: acc
        acc = acc + (n2 - n1 + 1)
        n2 = n2 + 1
        # we sum 1 to n2, because we already counted n2 in the previous iteration doing n1 + 1
        # n2 = if state == :inside, do: n2 + 1, else: n2
        line_area([{n2, type2} | rest], state, acc)

      [{n1, _}, {n2, type2} | rest] ->
        acc = if state == :inside, do: acc + (n2 - n1 + 1), else: acc
        n2 = if state == :inside, do: n2 + 1, else: n2
        state = if state == :inside, do: :outside, else: :inside
        line_area([{n2, type2} | rest], state, acc)

      _ ->
        IO.puts("acc = #{acc}")
        acc
    end
  end

  defp distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp direction({px, py}, {x1, y1}) do
    cond do
      px == x1 and y1 < py -> :up
      px == x1 and y1 > py -> :down
      py == y1 and x1 < px -> :left
      py == y1 and x1 > px -> :right
      true -> :none
    end
  end

  defp calculate_turning_value({px, py}, {x1, y1}, {x2, y2}) do
    moving_direction = direction({px, py}, {x1, y1})

    cond do
      # straight line
      moving_direction == :none -> 0
      (px == x1 and x1 == x2) or (py == y1 and y1 == y2) -> 0
      # turning right, relative to the previous point when moving up
      moving_direction == :up and x2 > px -> 0.25
      # turning left, relative to the previous point when moving up
      moving_direction == :up and x2 < px -> -0.25
      # turning left, relative to the previous point when moving up
      moving_direction == :down and x2 > px -> -0.25
      # turning right, relative to the previous point when moving up
      moving_direction == :down and x2 < px -> 0.25
      moving_direction == :left and y2 < py -> 0.25
      moving_direction == :right and y2 < py -> -0.25
      moving_direction == :left and y2 > py -> -0.25
      moving_direction == :right and y2 > py -> 0.25
    end
  end

  def calculate_perimeter_area(polygon) do
    [_, second_point | _] = polygon
    calculate_perimeter_area(polygon, second_point, {0, 0}, 0)
  end

  defp calculate_perimeter_area(polygon, second_point, prev_point, acc) do
    case polygon do
      [f, s | rest] ->
        perimeter_area = 0.25 * 2 + 0.5 * (distance(f, s) - 1)
        turning_value = calculate_turning_value(prev_point, f, s)
        perimeter_area = perimeter_area + turning_value
        calculate_perimeter_area([s | rest], second_point, f, acc + perimeter_area)

      [s | []] ->
        last_turn_value = calculate_turning_value(prev_point, s, second_point)
        acc + last_turn_value
    end
  end

  def execute do
    lines = parse_input()

    case lines do
      [first_line | _] ->
        IO.puts(
          "First line: #{first_line.direction}, #{first_line.distance}, #{first_line.color}"
        )

      [] ->
        IO.puts("The file is empty.")
    end

    map = create_map_2(lines, [{0, 0}], {0, 0})
    perimeter_area = calculate_perimeter_area(map)
    IO.inspect(map, label: "Map")
    IO.puts("Perimeter Area: #{perimeter_area}")
    # vertical_map = create_map(lines, %{}, {0, 0})
    # IO.inspect(vertical_map, label: "Vertical Map")

    # result =
    #   Enum.reduce(vertical_map, 0, fn {_, value}, acc ->
    #     value = Enum.sort(value, fn {a, _}, {b, _} -> a <= b end)
    #     acc + line_area(value)
    #   end)

    # IO.puts("Result: #{result}")
  end
end
