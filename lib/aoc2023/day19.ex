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

  defp rate_piece(workflows, rating) do

  end

  defp execute_workflows(workflows, ratings) do
    case ratings do
      [rating | rest] ->
        rate_piece(workflows, rating)
        execute_workflows(workflows, rest)
      [] ->
        workflows
    end
  end
  def execute_1 do
    IO.puts("Day 19 - Part 1")
    {workflows, ratings} = parse_input()
    result = execute_workflows(workflows, ratings)
    IO.inspect(workflows)
  end
end
