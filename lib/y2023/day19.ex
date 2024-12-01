defmodule Aoc.Y2023.Day19.Workflow do
  @moduledoc """
  Workflow for the day 19.
  """
  defstruct id: "", rules: []

  @type t :: %__MODULE__{
          id: String.t(),
          rules: [Aoc.Y2023.Day19.Rule.t()]
        }
end

defmodule Aoc.Y2023.Day19.Rule do
  @moduledoc """
  Rule for the workflow.
  """
  defstruct next: "", category: "", condition: "", value: 0

  @type next_t :: String.t() | :accept | :reject
  @type t :: %__MODULE__{
          next: next_t(),
          category: String.t(),
          condition: String.t(),
          value: integer()
        }
end

defmodule Aoc.Y2023.Day19.Rating do
  @moduledoc """
  Part rating for the day 19.
  """
  defstruct x: 0, m: 0, a: 0, s: 0

  @type t :: %__MODULE__{
          x: integer(),
          m: integer(),
          a: integer(),
          s: integer()
        }
end

defmodule Aoc.Y2023.Day19 do
  alias Aoc.Y2023.Day19.{Rule, Workflow, Rating}

  defp parse_rules(rules_str, acc \\ []) do
    parse_rule = fn rule_str ->
      condition = String.split(rule_str, ":")

      parse_destination = fn dest_str ->
        case dest_str do
          "A" -> :accept
          "R" -> :reject
          _ -> dest_str
        end
      end

      case condition do
        [c, dest] ->
          next = parse_destination.(dest)

          [_, category, sign, value] = Regex.run(~r/(\w)([<|>])(\d+)/, c)
          %Rule{next: next, category: category, condition: sign, value: String.to_integer(value)}

        [dest] ->
          [dest | _] = String.split(dest, "}")
          dest = parse_destination.(dest)
          %Rule{next: dest}
      end
    end

    case rules_str do
      [rule_str | rest] ->
        rule = parse_rule.(rule_str)
        acc = [rule | acc]
        parse_rules(rest, acc)

      [] ->
        Enum.reverse(acc)
    end
  end

  defp parse_workflow(line) do
    [name | rest] = String.split(line, "{")
    rules_line = List.first(rest)
    rules_str = String.split(rules_line, ",")
    rules = parse_rules(rules_str)

    %Workflow{id: name, rules: rules}
  end

  defp parse_part_rating(line) do
    [_, x, m, a, s] = Regex.run(~r/{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}/, line)

    %Rating{
      x: String.to_integer(x),
      m: String.to_integer(m),
      a: String.to_integer(a),
      s: String.to_integer(s)
    }
  end

  defp parse_input_aux(lines, workflow_map, input_acc, mode \\ :workflow) do
    case {mode, lines} do
      {:workflow, [line | rest]} ->
        if String.trim(line) == "" do
          parse_input_aux(rest, workflow_map, input_acc, :rating)
        else
          workflow = parse_workflow(line)
          workflow_map = Map.put(workflow_map, workflow.id, workflow)
          parse_input_aux(rest, workflow_map, input_acc, mode)
        end

      {:rating, [line | rest]} ->
        input = parse_part_rating(line)
        input_acc = [input | input_acc]
        parse_input_aux(rest, workflow_map, input_acc, mode)

      {_, []} ->
        {workflow_map, input_acc}
    end
  end

  defp parse_input() do
    file_path = "data/input_day19.txt"
    lines = Aoc.Helper.read_file(file_path)
    parse_input_aux(lines, %{}, [])
  end

  @spec rate_piece_aux(Rule.t(), Rating.t()) :: Rule.next_t() | :next
  defp rate_piece_aux(rule, rating) do
    case rule.condition do
      "<" ->
        piece_rating = Map.get(rating, String.to_atom(rule.category))
        if piece_rating < rule.value, do: rule.next, else: :next

      ">" ->
        piece_rating = Map.get(rating, String.to_atom(rule.category))
        if piece_rating > rule.value, do: rule.next, else: :next

      "" ->
        rule.next

      _ ->
        raise "Invalid condition"
    end
  end

  defp rate_piece([rule | rest], rating) do
    next = rate_piece_aux(rule, rating)

    if next == :next do
      rate_piece(rest, rating)
    else
      next
    end
  end

  @spec execute_workflows(%{String.t() => Workflow.t()}, [Rating.t()], integer(), String.t()) ::
          integer()
  defp execute_workflows(workflows, ratings, acc \\ 0, workflow_id \\ "in") do
    case ratings do
      [rating | rest] ->
        first_workflow = Map.get(workflows, workflow_id)
        result = rate_piece(first_workflow.rules, rating)

        case result do
          :accept ->
            acc =
              rating
              |> Map.from_struct()
              |> Enum.reduce(acc, fn {_, value}, acc2 -> acc2 + value end)

            execute_workflows(workflows, rest, acc)

          :reject ->
            execute_workflows(workflows, rest, acc)

          next_workflow_id when is_binary(next_workflow_id) ->
            execute_workflows(workflows, ratings, acc, next_workflow_id)
        end

      [] ->
        acc
    end
  end

  defp check_rule(rule) do
    cond do
      rule.condition == "" ->
        {:end, Range.new(1, 1), rule.next}

      true ->
        range =
          case {rule.condition, rule.next} do
            {"<", _} -> Range.new(1, rule.value - 1)
            {">", _} -> Range.new(rule.value + 1, 4000)
            _ -> raise "Invalid condition"
          end

        {rule.category, range, rule.next}
    end
  end

  defp flip_result({category, range, _}) do
    case range.first do
      1 ->
        {category, Range.new(range.last + 1, 4000), :flipped}

      _ ->
        {category, Range.new(1, range.first - 1), :flipped}
    end
  end

  defp range_intersection(range1, range2) do
    if Range.disjoint?(range1, range2) do
      nil
    else
      Range.new(max(range1.first, range2.first), min(range1.last, range2.last))
    end
  end

  defp combin_n(solution, keys \\ ["a", "m", "s", "x"], acc \\ 1) do
    case keys do
      [key | rest] ->
        range =
          if Map.has_key?(solution, key) do
            Map.get(solution, key)
          else
            Range.new(1, 4000)
          end

        combin_n(solution, rest, acc * (range.last - range.first + 1))

      [] ->
        acc
    end
  end

  defp intersect(sol, processed, acc \\ []) do
    case processed do
      [p | rest] ->
        sol_interesected = Map.merge(sol, p, fn _, r1, r2 -> range_intersection(r1, r2) end)
        has_nil_key = Enum.any?(Map.values(sol_interesected), fn v -> v == nil end)

        if has_nil_key do
          intersect(sol, rest, acc)
        else
          intersect(sol, rest, [sol_interesected | acc])
        end

      [] ->
        acc
    end
  end

  def combinations(solutions, processed \\ [], acc \\ 0) do
    case solutions do
      [sol | rest] ->
        c = combin_n(sol)
        # intersect current solution with all previously processed
        all_previous_interesections = intersect(sol, processed)
        remaining_c = c - combinations(all_previous_interesections)

        processed = [sol | processed]
        combinations(rest, processed, acc + remaining_c)

      [] ->
        acc
    end
  end

  defp process_solution(solution, acc \\ %{}) do
    case solution do
      [{:end, _, _} | rest] ->
        process_solution(rest, acc)

      [{category, range, _} | rest] ->
        {_, new_map} =
          Map.get_and_update(acc, category, fn current_value ->
            case current_value do
              nil ->
                {nil, range}

              range_value ->
                new_range = range_intersection(range_value, range)
                {current_value, new_range}
            end
          end)

        process_solution(rest, new_map)

      [] ->
        acc
    end
  end

  defp checking_workflow_rules(workflows, rules, acc, final_solution) do
    case rules do
      [rule | rest] ->
        rule_result = check_rule(rule)

        case rule_result do
          {_, _, :accept} ->
            sol = [rule_result | acc] |> Enum.reverse()
            solution_processed = process_solution(sol)
            final_solution = [solution_processed | final_solution]

            flipped_result = flip_result(rule_result)
            checking_workflow_rules(workflows, rest, [flipped_result | acc], final_solution)

          {_, _, :reject} ->
            flipped_result = flip_result(rule_result)
            checking_workflow_rules(workflows, rest, [flipped_result | acc], final_solution)

          {_, _, next} ->
            next_workflow = Map.get(workflows, next)

            new_final_solution =
              checking_workflow_rules(
                workflows,
                next_workflow.rules,
                [rule_result | acc],
                final_solution
              )

            flipped_result = flip_result(rule_result)
            checking_workflow_rules(workflows, rest, [flipped_result | acc], new_final_solution)
        end

      [] ->
        final_solution
    end
  end

  defp combination_workflows(workflows) do
    current_workflow = Map.get(workflows, "in")

    list_result = checking_workflow_rules(workflows, current_workflow.rules, [], [])
    list_result
  end

  def execute_1 do
    IO.puts("Day 19 - Part 1")
    {workflows, ratings} = parse_input()
    result = execute_workflows(workflows, ratings)
    IO.puts("Result day19 star 1: #{result}")
  end

  def execute_2 do
    IO.puts("Day 19 - Part 2")
    {workflows, _} = parse_input()
    result = combination_workflows(workflows)
    comb = combinations(result)
    IO.puts("Result day19 star 2: #{comb}")
  end
end
