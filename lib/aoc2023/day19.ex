defmodule Aoc2023.Day19.Workflow do
  @moduledoc """
  Workflow for the day 19.
  """
  defstruct id: "", rules: []

  @type t :: %__MODULE__{
          id: String.t(),
          rules: [Aoc2023.Day19.Rule.t()]
        }
end

defmodule Aoc2023.Day19.Rule do
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

defmodule Aoc2023.Day19.Rating do
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

defmodule Aoc2023.Day19 do
  alias Aoc2023.Day19.{Rule, Workflow, Rating}

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
    file_path = "data/input_day19_test.txt"
    lines = Aoc2023.read_file(file_path)
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
        {:end, Range.new(0, 0), rule.next}

      true ->
        range =
          case {rule.condition, rule.next} do
            # {"<", :reject} -> Range.new(rule.value, 4000)
            {"<", _} -> Range.new(0, rule.value - 1)
            # {">", :reject} -> Range.new(0, rule.value)
            {">", _} -> Range.new(rule.value + 1, 4000)
            _ -> raise "Invalid condition"
          end

        {rule.category, range, rule.next}
    end
  end

  defp flip_result({category, range, next}) do
    case range.first do
      0 ->
        {category, Range.new(range.last + 1, 4000), :flipped}

      _ ->
        {category, Range.new(0, range.first - 1), :flipped}
    end

  end
  defp checking_workflow_rules(workflows, rules, acc, solution) do
    case rules do
      [rule | rest] ->
        rule_result = check_rule(rule)

        case rule_result do
          # {:end, _, _} ->
          #   IO.inspect(rule_result, label: "\nRule result: ")
          #   [rule_result | acc] |> Enum.reverse()

          {_, _, :accept} ->
            IO.inspect(rule_result, label: "\nRule result: ")
            sol = [rule_result | acc] |> Enum.reverse()
            new_solution = [sol | solution]

            flipped_result = flip_result(rule_result)
            checking_workflow_rules(workflows, rest, [flipped_result | acc], new_solution)

          {_, _, :reject} ->
            flipped_result = flip_result(rule_result)
            checking_workflow_rules(workflows, rest, [flipped_result | acc], solution)

          {_, _, next} ->
            IO.inspect(rule_result, label: "\nRule result: ")
            next_workflow = Map.get(workflows, next)
            # new_solution = combination_workflows(workflows, next, [rule_result | acc], solution)
            new_solution = checking_workflow_rules(workflows, next_workflow.rules, [rule_result | acc], solution)
            flipped_result = flip_result(rule_result)
            checking_workflow_rules(workflows, rest, [flipped_result | acc], new_solution)
        end

      [] ->
        solution
    end
  end

  defp combination_workflows(workflows, workflow_id \\ "in", acc \\ [], solution \\[]) do
    current_workflow = Map.get(workflows, workflow_id)

    list_result = checking_workflow_rules(workflows, current_workflow.rules, acc, solution)
    list_result
  end

  def execute_1 do
    IO.puts("Day 19 - Part 1")
    {workflows, ratings} = parse_input()
    result = execute_workflows(workflows, ratings)
    # IO.inspect(workflows)
    IO.puts("Result: #{result}")
  end

  def execute_2 do
    {workflows, _} = parse_input()
    result = combination_workflows(workflows)
    IO.inspect(result)
  end
end
