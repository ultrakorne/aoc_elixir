defmodule Aoc.Y2024.Day9 do
  def decompress_disc(lst, acc \\ [], is_file? \\ true, id \\ 0) do
    case {lst, is_file?} do
      {[], _} ->
        Enum.reverse(acc)

      {[hd | tl], true} ->
        # this is a file
        acc = create_disk_file(id, hd) ++ acc
        decompress_disc(tl, acc, false, id + 1)

      {[hd | tl], false} ->
        acc = create_disk_file(nil, hd) ++ acc
        decompress_disc(tl, acc, true, id)
    end
  end

  defp create_disk_file(id, str) do
    n = String.to_integer(str)
    List.duplicate(id, n)
  end

  def find_nils_of_size(disk, size) do
    {_, index, found} =
      Enum.with_index(disk)
      |> Enum.reduce_while({size, 0, false}, fn {value, idx}, {x, acc_index, _found} ->
        cond do
          value == nil and x == 1 -> {:halt, {size, acc_index, true}}
          value == nil -> {:cont, {x - 1, acc_index, false}}
          true -> {:cont, {size, idx + 1, false}}
        end
      end)

    if found, do: index, else: nil
  end

  def replace_at_index(list, index, value, count) do
    {left, right} = Enum.split(list, index)
    right = Enum.drop(right, count)
    left ++ List.duplicate(value, count) ++ right
  end

  def compact_disk_2b(disk) do
    id_length = Enum.frequencies(disk) |> Map.delete(nil)
    compact_disk_2b_aux(disk, id_length)
  end

  def compact_disk_2b_aux(disk, id_length_map) do
    if map_size(id_length_map) == 0 do
      disk
    else
      id =
        id_length_map
        |> Map.keys()
        |> Enum.max()

      size_of_id = Map.get(id_length_map, id)

      # we need to find the first nils that would fit the size_od_id on the left side of the the disk
      disk_left = Enum.take_while(disk, &(&1 != id))
      index_of_nils_of_size = find_nils_of_size(disk_left, size_of_id)

      id_length_map = Map.delete(id_length_map, id)

      if index_of_nils_of_size == nil do
        # id cannot be moved
        compact_disk_2b_aux(disk, id_length_map)
      else
        disk = Enum.map(disk, fn x -> if x == id, do: nil, else: x end)
        disk = replace_at_index(disk, index_of_nils_of_size, id, size_of_id)
        compact_disk_2b_aux(disk, id_length_map)
      end
    end
  end

  def get_highest_fitting_id(nil_size, id_length_map) do
    id_length_map
    |> Map.to_list()
    |> Enum.sort(fn {a, _}, {b, _} -> a > b end)
    |> Enum.find(fn {_id, length} -> length <= nil_size end)
    |> case do
      nil -> {nil, nil_size}
      {id, l} -> {id, l}
    end
  end

  def disk_to_string(disk) do
    Enum.reduce(disk, "", fn x, acc ->
      str = if is_nil(x), do: ".", else: to_string(x)
      acc <> str
    end)
  end

  def compact_disk(disk) do
    nil_amount = Enum.count(disk, &is_nil(&1))
    file_amount = length(disk) - nil_amount

    to_move_buffer = Enum.filter(disk, &(!is_nil(&1))) |> Enum.reverse()
    disk_part = Enum.take(disk, file_amount)

    compact_disk_aux(disk_part, to_move_buffer)
  end

  def compact_disk_aux(disk, buffer, acc \\ []) do
    case disk do
      [] ->
        Enum.reverse(acc)

      [nil | tl] ->
        [hd_buffer | rest_buffer] = buffer
        compact_disk_aux(tl, rest_buffer, [hd_buffer | acc])

      [x | tl] ->
        compact_disk_aux(tl, buffer, [x | acc])
    end
  end

  def checksum(disk) do
    disk
    |> Stream.with_index()
    |> Enum.reduce(0, fn {value, idx}, acc ->
      value = if value == nil, do: 0, else: value
      acc + value * idx
    end)
  end

  def execute_1() do
    File.read!("data/2024/day9.txt")
    |> String.graphemes()
    |> decompress_disc()
    |> compact_disk()
    |> checksum()
  end

  def execute_2() do
    File.read!("data/2024/day9.txt")
    |> String.graphemes()
    |> decompress_disc()
    |> compact_disk_2b()
    |> checksum()
  end
end
