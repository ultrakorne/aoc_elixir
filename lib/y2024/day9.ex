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

  def compact_disk_2(disk) do
    id_length = Enum.frequencies(disk) |> Map.delete(nil)

    max_id =
      id_length
      |> Map.keys()
      |> Enum.max()

    IO.inspect(id_length)
    IO.puts("Max id: #{max_id}")
    compact_disk_2_aux(disk, id_length)
    disk
  end

  def compact_disk_2_aux(disk, id_length_map, acc \\ []) do
    case disk do
      [] ->
        acc

      [x | tl] ->
        # remove x from the map, since this id is already in place
        id_length_map = Map.delete(id_length_map, x)
        compact_disk_2_aux(tl, id_length_map, [x | acc])
    end
  end

  def compact_disk(disk) do
    nil_amount = Enum.count(disk, &is_nil(&1))
    file_amount = length(disk) - nil_amount

    to_move_buffer = Enum.filter(disk, &(!is_nil(&1))) |> Enum.reverse()
    disk_part = Enum.take(disk, file_amount)

    IO.puts("File amount: #{file_amount}")
    IO.puts("Nil amount: #{nil_amount}")
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
    File.read!("data/2024/day9_test.txt")
    |> String.graphemes()
    |> decompress_disc()
    |> compact_disk_2()
  end
end
