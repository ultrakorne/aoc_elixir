defmodule Aoc.Y2024.Day3 do
  defp parse_input() do
    input =
      "data/2024/day3.txt"
      |> File.read!()

    Regex.scan(~r/mul\((\d+,\d+)\)/, input)
  end

  defp parse_input_2() do
    input =
      "data/2024/day3.txt"
      |> File.read!()

    Regex.scan(~r/do\(\)|don't\(\)|mul\((\d+,\d+)\)/, input)
  end

  defp get_int_array(str) do
    String.split(str, ",") |> Enum.map(&String.to_integer/1)
  end

  def execute_1() do
    parse_input()
    |> Enum.reduce(0, fn [_, y | _], acc ->
      [f, s | _] = get_int_array(y)
      acc + f * s
    end)
  end

  def execute_2() do
    parse_input_2()
    |> Enum.reduce({[], true}, fn e, {acc, to_mult} ->
      case e do
        ["do()"] ->
          {acc, true}

        ["don't()"] ->
          {acc, false}

        [_, y] ->
          if to_mult do
            [f, s] = get_int_array(y)
            {acc ++ [[f, s]], to_mult}
          else
            {acc, to_mult}
          end
      end
    end)
    |> elem(0)
    |> Enum.reduce(0, fn [f, s], acc -> acc + f * s end)
  end
end
