defmodule Aoc.Y2024.Day3 do
  defp parse_input(regex) do
    input =
      "data/2024/day3.txt"
      |> File.read!()

    Regex.scan(regex, input)
  end

  defp get_int_array(str) do
    String.split(str, ",") |> Enum.map(&String.to_integer/1)
  end

  def execute_1() do
    ~r/mul\((\d+,\d+)\)/
    |> parse_input()
    |> Enum.reduce(0, fn [_, y | _], acc ->
      [f, s | _] = get_int_array(y)
      acc + f * s
    end)
  end

  def execute_2() do
    ~r/do\(\)|don't\(\)|mul\((\d+,\d+)\)/
    |> parse_input()
    |> Enum.reduce({0, true}, fn e, {acc, to_mult} ->
      case e do
        ["do()"] ->
          {acc, true}

        ["don't()"] ->
          {acc, false}

        [_, y] when to_mult ->
          [f, s] = get_int_array(y)
          {acc + f * s, to_mult}

        _ ->
          {acc, to_mult}
      end
    end)
    |> elem(0)
  end
end
