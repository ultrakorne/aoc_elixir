defmodule Aoc.Y2024.Day11 do
  def blink(stones) when is_list(stones) do
    Enum.reduce(stones, [], fn x, acc -> acc ++ blink(x) end)
  end

  def blink(stone) do
    case stone do
      0 ->
        [1]

      x ->
        x_str = to_string(x)
        l = x_str |> String.length()
        even = l |> rem(2) |> Kernel.==(0)

        if even do
          split_at = l |> div(2)

          String.split_at(x_str, split_at)
          |> Tuple.to_list()
          |> Enum.map(&String.to_integer/1)
        else
          [x * 2024]
        end
    end
  end

  def blink_n(stones, n) when is_list(stones) do
    Enum.reduce(stones, 0, fn x, acc -> acc + blink_n(x, n) end)
  end

  @doc """
  blink a stone n times, return the amount of stone after n times
  """
  def blink_n(stone, n, acc \\ 1) do
    result = blink(stone)
    acc = acc + length(result) - 1
    n = n - 1

    if n == 0 do
      acc
    else
      case result do
        [x] ->
          blink_n(x, n, acc)

        [x, y] ->
          new_acc = blink_n(x, n, acc)
          blink_n(y, n, new_acc)
      end
    end
  end

  def execute_1() do
    File.read!("data/2024/day11.txt")
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Task.async_stream(&blink_n(&1, 75),
      max_concurrency: System.schedulers_online(),
      timeout: :infinity
    )
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  def execute_2() do
    IO.puts("Day 11 - Part 2")
  end
end
