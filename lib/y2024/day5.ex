defmodule Aoc.Y2024.Day5 do
  defp parse_input() do
    "data/2024/day5.txt"
    |> File.read!()
    |> String.split("\r\n", trim: true)
    |> Enum.split_while(&String.contains?(&1, "|"))
  end

  def execute_1() do
    {rules, manuals} = parse_input()
    rules_map = parse_rules(rules)

    manuals
    |> Enum.reduce(0, fn manual, acc ->
      if is_manual_valid?(rules_map, manual) do
        IO.puts("Valid: #{manual}")
        acc + manual_mid(manual)
      else
        IO.puts("Invalid: #{manual}")
        acc
      end
    end)
  end

  def execute_2() do
    {rules, manuals} = parse_input()
    rules_map = parse_rules(rules)

    manuals
    |> Enum.reduce(0, fn manual, acc ->
      {manual_fixed, was_fixed?} = fix_manual(rules_map, manual)

      # IO.inspect(manual_fixed, charlists: :as_lists, label: "Fixed manual")
      if was_fixed?, do: acc + manual_mid(manual_fixed), else: acc
    end)
  end

  defp parse_rules(rules) do
    rules
    |> Enum.reduce(%{}, fn rule, acc ->
      [first, second] = String.split(rule, "|") |> Enum.map(&String.to_integer/1)

      acc
      |> Map.update(first, [{second, :after}], &[{second, :after} | &1])
      |> Map.update(second, [{first, :before}], &[{first, :before} | &1])
    end)
  end

  defp pages_to_list(pages) do
    pages
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp manual_mid(manual) when is_binary(manual) do
    pages = pages_to_list(manual)
    manual_mid(pages)
  end

  defp manual_mid(manual) when is_list(manual) do
    length = Enum.count(manual)
    Enum.at(manual, div(length, 2))
  end

  defp fix_manual(rules_map, manual) do
    if is_manual_valid?(rules_map, manual) do
      {manual, false}
    else
      pages = pages_to_list(manual)

      fixed_manual =
        pages
        |> Enum.with_index()
        |> Enum.reduce(pages, fn {x, i}, acc ->
          fix_page(acc, x, i, rules_map)
        end)

      {fixed_manual, true}
    end
  end

  defp fix_page(pages, page_num, _, rules_map) do
    # IO.puts("Fixing page #{page_num}")

    Map.get(rules_map, page_num)
    |> Enum.reduce(pages, fn {n, bef_or_after}, acc ->
      fix_page_aux(acc, page_num, n, bef_or_after)
    end)
  end

  defp fix_page_aux(pages, page_num, n, :after) do
    n_idx = Enum.find_index(pages, &(&1 == n))
    page_idx = Enum.find_index(pages, &(&1 == page_num))

    if n_idx > page_idx or n_idx == nil do
      pages
    else
      pages
      |> List.pop_at(n_idx)
      |> elem(1)
      |> List.insert_at(page_idx, n)
    end
  end

  defp fix_page_aux(pages, page_num, n, :before) do
    n_idx = Enum.find_index(pages, &(&1 == n))
    page_idx = Enum.find_index(pages, &(&1 == page_num))

    if n_idx < page_idx or n_idx == nil do
      pages
    else
      new_pages =
        pages
        |> List.pop_at(n_idx)
        |> elem(1)
        |> List.insert_at(page_idx, n)

      new_pages
    end
  end

  defp is_manual_valid?(rules_map, manual) do
    pages = pages_to_list(manual)

    pages
    |> Enum.reduce_while(true, fn x, _ ->
      is_ok =
        Map.get(rules_map, x)
        |> Enum.all?(&satisfy_rule(x, pages, &1))

      if is_ok, do: {:cont, true}, else: {:halt, false}
    end)
  end

  defp satisfy_rule(page_num, pages, {n, bef_or_after}) when bef_or_after in [:before, :after] do
    case Enum.find_index(pages, &(&1 == n)) do
      nil ->
        true

      idx_x ->
        index_of_page = Enum.find_index(pages, &(&1 == page_num))

        case bef_or_after do
          :before -> index_of_page > idx_x
          :after -> index_of_page < idx_x
        end
    end
  end
end
