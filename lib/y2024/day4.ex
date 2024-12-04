defmodule Aoc.Y2024.Day4 do
  @directions [:n, :ne, :e, :se, :s, :sw, :w, :nw]
  @x_directions [:ne, :se, :sw, :nw]

  defp parse_input() do
    "data/2024/day4.txt"
    |> File.read!()
    |> String.split("\r\n", trim: true)
  end

  defp add_to_map(line, idx, map) do
    line
    |> String.graphemes()
    |> Stream.with_index()
    |> Enum.reduce(map, fn {char, char_idx}, acc ->
      Map.put(acc, {idx, char_idx}, char)
    end)
  end

  def execute_1() do
    parse_input()
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, index}, acc -> add_to_map(line, index, acc) end)
    |> check_xmas()
  end

  def execute_2() do
    parse_input()
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, index}, acc -> add_to_map(line, index, acc) end)
    |> check_x_mas()
  end

  def check_xmas(map) do
    map
    |> Map.keys()
    |> Enum.reduce(0, fn {x, y}, acc ->
      acc + check_xmas_at(map, x, y)
    end)
  end

  def check_x_mas(map) do
    map
    |> Map.keys()
    |> Enum.reduce(0, fn {x, y}, acc ->
      acc + check_x_mas_at(map, x, y)
    end)
  end

  def check_xmas_at(map, x, y) do
    if Map.get(map, {x, y}) == "X" do
      @directions
      |> Enum.reduce([], fn dir, acc ->
        [get_directions(dir, 3, {x, y}) | acc]
      end)
      |> Enum.reduce(0, fn coord_list, acc ->
        acc + check_xmas_match(map, coord_list)
      end)
    else
      0
    end
  end

  def check_x_mas_at(map, x, y) do
    if Map.get(map, {x, y}) == "A" do
      four_dir =
        @x_directions
        |> Enum.reduce([], fn dir, acc ->
          [get_directions(dir, 1, {x, y}) | acc]
        end)
        |> Enum.map(&hd(&1))
        |> Enum.map(fn x -> {x, Map.get(map, x)} end)

      all_m_s = Enum.all?(four_dir, fn {_, char} -> char == "M" or char == "S" end)
      diag_1_ok = Enum.at(four_dir, 0) |> elem(1) != Enum.at(four_dir, 2) |> elem(1)
      diag_2_ok = Enum.at(four_dir, 1) |> elem(1) != Enum.at(four_dir, 3) |> elem(1)
      if all_m_s and diag_1_ok and diag_2_ok, do: 1, else: 0
    else
      0
    end
  end

  defp check_xmas_match(map, coord_list) do
    matching_count =
      ["M", "A", "S"]
      |> Enum.zip(coord_list)
      |> Enum.reduce(0, fn {char, {x, y}}, acc ->
        if char == Map.get(map, {x, y}) do
          acc + 1
        else
          acc
        end
      end)

    if matching_count == 3, do: 1, else: 0
  end

  def get_directions(dir, count, {x, y}, acc \\ []) do
    new_coords =
      case dir do
        :n -> {x - 1, y}
        :ne -> {x - 1, y + 1}
        :e -> {x, y + 1}
        :se -> {x + 1, y + 1}
        :s -> {x + 1, y}
        :sw -> {x + 1, y - 1}
        :w -> {x, y - 1}
        :nw -> {x - 1, y - 1}
      end

    acc = [new_coords | acc]

    if count == 1 do
      Enum.reverse(acc)
    else
      get_directions(dir, count - 1, new_coords, acc)
    end
  end
end
