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
    Enum.reduce(stones, 0, fn x, acc ->
      {result, _cache} = blink_n(x, {0, n})
      acc + result
    end)
  end

  @doc """
  blink a stone n times, return the amount of stone after n times
  """
  def blink_n(stone, {c, max}, acc \\ 1, cache \\ %{}) when is_integer(stone) do
    blinks_left = max - c
    acc_init = acc
    result = blink(stone)
    acc = acc + length(result) - 1
    c = c + 1

    cache_value = Map.get(cache, {stone, blinks_left})

    # if cache_value do
    #   IO.puts("+++ cache exist #{stone}:#{blinks_left} => cache: #{cache_value}")
    # end

    {output, cache} =
      cond do
        c == max ->
          {acc, cache}

        cache_value != nil ->
          {acc_init + cache_value, cache}

        true ->
          case result do
            [x] ->
              blink_n(x, {c, max}, acc, cache)

            [x, y] ->
              {new_acc, cache} = blink_n(x, {c, max}, acc, cache)
              blink_n(y, {c, max}, new_acc, cache)
          end
      end

    delta_acc = output - acc_init
    # output = delta_acc + acc_init
    cache = Map.put(cache, {stone, blinks_left}, delta_acc)
    # IO.puts("#{stone}:#{blinks_left} => output: #{delta_acc}")
    {output, cache}
  end

  def execute_1() do
    File.read!("data/2024/day11.txt")
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> blink_n(25)
  end

  def execute_2() do
    File.read!("data/2024/day11.txt")
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> blink_n(75)
  end
end
