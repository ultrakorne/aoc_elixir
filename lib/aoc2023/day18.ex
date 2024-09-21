defmodule Aoc2023.Day18 do
  @moduledoc """
  Day 18 of Advent of Code 2023.
  """

  defstruct direction: "", distance: 0, color: ""

  defp parse_input do
    file_path = "data/input_day18.txt"
    lines = Aoc2023.read_file(file_path)
    # parse_lines(lines, [])

    parse = fn
      parse, [first_line | rest], acc ->
        split = String.split(first_line, " ")

        case split do
          [d, n, c] -> IO.puts("Direction: #{d}, Distance: #{n}, Color: #{c}")
          _ -> IO.puts("Invalid line: #{first_line}")
        end

        acc = acc ++ split
        parse.(parse, rest, acc)

      _, [], acc ->
        acc
    end

    parse.(parse, lines, [])
  end

  def execute do
    lines = parse_input()

    case lines do
      [first_line | _] -> IO.puts("First line: #{first_line}")
      [] -> IO.puts("The file is empty.")
    end
  end

  @spec do_work() :: integer()
  def do_work, do: 20
end
