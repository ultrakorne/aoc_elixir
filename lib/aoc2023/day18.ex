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

  defp dig_line(map, map_pos, direction, distance) do
    next_pos = move_direction(map_pos, direction, distance)
    x0 = elem(map_pos, 0)
    x1 = elem(next_pos, 0)
    is_vertical = x0 == x1

    map =
      if is_vertical do
        y0 = elem(map_pos, 1)
        y1 = elem(next_pos, 1)
        step = if y0 <= y1, do: 1, else: -1
        y_range = y0..y1//step

        Enum.reduce(y_range, map, fn y, acc ->
          is_edge = y == y0 or y == y1
          descriptor = if is_edge, do: :corner, else: :edge
          Map.update(acc, y, [{x0, descriptor}], fn lst -> [{x0, descriptor} | lst] end)
        end)
      else
        map
      end

    {map, next_pos}
  end

  defp create_map(input, vertical_map, map_pos) do
    case input do
      [line | rest] ->
        {map, next_map_pos} = dig_line(vertical_map, map_pos, line.direction, line.distance)
        create_map(rest, map, next_map_pos)

      [] ->
        # to do, set the first and last keys  to :edge
        first_key = vertical_map |> Map.keys() |> Enum.min()
        vertical_map =
          Map.update!(vertical_map, first_key, fn lst ->
            Enum.map(lst, fn t -> {elem(t, 0), :edge} end)
          end)

        last_key = vertical_map |> Map.keys() |> Enum.max()

        vertical_map =
          Map.update!(vertical_map, last_key, fn lst ->
            Enum.map(lst, fn t -> {elem(t, 0), :edge} end)
          end)

        vertical_map
    end
  end

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

    vertical_map = create_map(lines, %{}, {0, 0})
    IO.inspect(vertical_map, label: "Vertical Map")

    result =
      Enum.reduce(vertical_map, 0, fn {_, value}, acc ->
        value = Enum.sort(value, fn {a, _}, {b, _} -> a <= b end)
        acc + line_area(value)
      end)

    IO.puts("Result: #{result}")
  end
end
