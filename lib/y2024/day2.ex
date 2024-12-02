defmodule Aoc.Y2024.Day2 do
  defp parse_input() do
    "data/2024/day2.txt"
    |> File.read!()
    |> String.split("\r\n", trim: true)
    |> Enum.map(fn x ->
      String.split(x, " ", trim: true) |> Enum.map(&String.to_integer(&1))
    end)
  end

  @spec is_safe?([integer()]) :: boolean()
  defp is_safe?([first | rest]) do
    second = hd(rest)
    order = if second > first, do: :asc, else: :desc

    rest
    |> Enum.reduce_while(first, fn x, acc ->
      case order do
        :asc when x > acc and x - acc <= 3 -> {:cont, x}
        :desc when x < acc and acc - x <= 3 -> {:cont, x}
        _ -> {:halt, nil}
      end
    end)
    |> is_nil()
    |> Kernel.not()
  end

  defp is_safe_dampen_aux?(list, order, prev \\ []) do
    case {list, order} do
      {[f, s | rest], :asc} when s > f and s - f <= 3 ->
        is_safe_dampen_aux?([s | rest], :asc, prev ++ [f])

      {[f, s | rest], :desc} when s < f and f - s <= 3 ->
        is_safe_dampen_aux?([s | rest], :desc, prev ++ [f])

      {[f, s | rest], _} ->
        is_safe?(prev ++ [f] ++ rest) or is_safe?(prev ++ [s] ++ rest)

      {[_], _} ->
        true
    end
  end

  @spec is_safe_dampen?([integer()]) :: boolean()
  defp is_safe_dampen?([first | rest]) do
    {_, result} =
      Enum.reduce(rest, {first, 0}, fn x, {acc, sign} ->
        if x > acc, do: {x, sign + 1}, else: {x, sign - 1}
      end)

    order = if result > 0, do: :asc, else: :desc

    is_safe_dampen_aux?([first | rest], order)
  end

  def execute_1() do
    parse_input()
    |> Enum.reduce(0, fn x, acc ->
      acc + if is_safe?(x), do: 1, else: 0
    end)
  end

  def execute_2() do
    parse_input()
    |> Enum.reduce(0, fn x, acc ->
      acc + if is_safe_dampen?(x), do: 1, else: 0
    end)
  end
end
