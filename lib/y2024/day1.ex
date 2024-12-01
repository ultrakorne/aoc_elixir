defmodule Aoc.Y2024.Day1 do
  defp parse_input() do
    "data/2024/day1.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], []}, fn line, {acc1, acc2} ->
      [first | rest] = String.split(line, " ", trim: true)
      first = first |> String.to_integer()
      second = rest |> hd |> String.trim() |> String.to_integer()
      {[first | acc1], [second | acc2]}
    end)
  end

  def execute_1() do
    {input1, input2} = parse_input()

    input1
    |> Enum.sort()
    |> Enum.zip(Enum.sort(input2))
    |> Enum.reduce(0, fn {a, b}, acc ->
      acc + abs(a - b)
    end)
  end

  def execute_2() do
    {input1, input2} = parse_input()
    freq_map = Enum.frequencies(input2)

    input1
    |> Enum.reduce(0, fn x, acc ->
      acc + x * Map.get(freq_map, x, 0)
    end)
  end
end
