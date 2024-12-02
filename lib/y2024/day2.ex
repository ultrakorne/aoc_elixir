defmodule Aoc.Y2024.Day2 do
  defp parse_input() do
    "data/2024/day2_test.txt"
    |> File.read!()
    |> String.split("\r\n", trim: true)
    |> Enum.map(fn x ->
      String.split(x, " ", trim: true) |> Enum.map(&String.to_integer(&1))
    end)
  end

  @spec is_safe?([integer()]) :: boolean()
  defp is_safe?([first | rest]) do
    [second | _] = rest
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

  @spec is_safe_dampen?([integer()]) :: boolean()
  defp is_safe_dampen?([first | rest]) do
    {_, result} =
      Enum.reduce(rest, {first, 0}, fn x, {acc, sign} ->
        if x > acc, do: {x, sign + 1}, else: {x, sign - 1}
      end)

    IO.inspect([first | rest], charlists: :as_lists)
    IO.inspect(result)
    order = if result > 0, do: :asc, else: :desc
    IO.inspect(order)

    out =
      rest
      |> Enum.reduce_while({first, 0}, fn x, {acc, err} ->
        case order do
          :asc
          when x > acc and x - acc <= 3 ->
            {:cont, {x, err}}

          :desc
          when x < acc and acc - x <= 3 ->
            {:cont, {x, err}}

          _ ->
            if err > 0, do: {:halt, nil}, else: {:cont, {acc, 1}}
        end
      end)
      |> is_nil()
      |> Kernel.not()

    IO.inspect(out)
    out = out || is_safe?(rest)
    IO.inspect("out after #{out}")
    IO.puts("----")
    out
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
