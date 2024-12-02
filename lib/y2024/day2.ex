defmodule Aoc.Y2024.Day2 do
  defp parse_input() do
    "data/2024/day2.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  @spec is_safe?([integer()]) :: boolean()
  defp is_safe?(report) do
    report
    |> Enum.reduce_while({nil, :none}, fn x, acc ->
      case acc do
        {nil, :none} ->
          {:cont, {x, :none}}
          # {prev, :none} -> if x > {:cont, {x, }}
      end

      if x == 0 do
        {:halt, false}
      else
        {:cont, acc + x}
      end
    end)
  end
end
