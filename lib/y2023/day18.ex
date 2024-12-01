defmodule Aoc.Y2023.Day18.DigPlan do
  defstruct direction: "", distance: 0
end

defmodule Aoc.Y2023.Day18 do
  @moduledoc """
  Day 18 of Advent of Code 2023.
  """
  alias Aoc.Y2023.Day18.DigPlan

  defp dig_plan_2(color) do
    case Regex.run(~r/\(#([\d|\w]{5})(\d)/, color) do
      [_, hex_string, direction] ->
        int_value = String.to_integer(hex_string, 16)

        dir =
          case direction do
            "0" -> "R"
            "1" -> "D"
            "2" -> "L"
            "3" -> "U"
          end

        %DigPlan{direction: dir, distance: int_value}

      _ ->
        raise "Invalid color format"
    end
  end

  def dig_plan_1(dir, distance) do
    %DigPlan{direction: dir, distance: String.to_integer(distance)}
  end

  defp parse_input(star \\ 1) do
    file_path = "data/input_day18.txt"
    lines = Aoc.Helper.read_file(file_path)

    parse = fn
      parse, [first_line | rest], acc ->
        split = String.split(first_line, " ")

        acc =
          case split do
            [d, n, c] ->
              dig_plan = if star == 1, do: dig_plan_1(d, n), else: dig_plan_2(c)
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

  defp dig_line(map, map_pos, direction, distance) do
    next_pos = move_direction(map_pos, direction, distance)
    {[next_pos | map], next_pos}
  end

  defp create_map(input, map, map_pos) do
    case input do
      [line | rest] ->
        {map, next_map_pos} = dig_line(map, map_pos, line.direction, line.distance)
        create_map(rest, map, next_map_pos)

      [] ->
        Enum.reverse(map)
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

  def shoelace_formula(polygon, acc \\ 0) do
    case polygon do
      [{x1, y1}, {x2, y2} | rest] ->
        acc = acc + (x1 * y2 - x2 * y1)
        shoelace_formula([{x2, y2} | rest], acc)

      _ ->
        abs(acc) / 2
    end
  end

  defp execute_helper(input) do
    map = create_map(input, [{0, 0}], {0, 0})
    perimeter_area = calculate_perimeter_area(map)
    inside_area = shoelace_formula(map)
    area = perimeter_area + inside_area
    IO.puts("Perimeter Area: #{perimeter_area}")
    IO.puts("Inside Area: #{inside_area}")
    IO.puts("Area: #{area}")
  end

  def execute do
    lines = parse_input()
    execute_helper(lines)
  end

  def execute_2 do
    lines = parse_input(2)
    execute_helper(lines)
  end
end
