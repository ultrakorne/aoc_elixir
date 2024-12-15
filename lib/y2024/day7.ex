defmodule Aoc.Y2024.Day7.Equation do
  defstruct result: 0, current: 0, operands: []

  @type t :: %__MODULE__{
          result: integer(),
          current: integer(),
          operands: [integer()]
        }
end

defmodule Aoc.Y2024.Day7 do
  alias Aoc.Y2024.Day7.Equation
  @operations [:add, :multiply]
  @operations_day2 [:add, :multiply, :concat]

  @spec parse_into_equation(String.t()) :: Equation.t()
  defp parse_into_equation(line) do
    splits = String.split(line, ":", trim: true)
    result = hd(splits) |> String.to_integer()
    rest = tl(splits) |> hd() |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

    %Equation{result: result, operands: rest}
  end

  defp prepare_equation(eq),
    do: %Equation{eq | current: hd(eq.operands), operands: tl(eq.operands)}

  def string_to_equation(str) do
    str
    |> parse_into_equation()
    |> prepare_equation()
  end

  @spec validate_line(String.t(), [atom()]) :: integer()
  def validate_line(str, operations) do
    str
    |> string_to_equation()
    |> validate_equation_aux(operations)
  end

  @spec validate_equation_aux(Equation.t(), [atom()]) :: integer()
  defp validate_equation_aux(equation, operations) do
    case equation.operands do
      [] ->
        if equation.current == equation.result, do: equation.result, else: 0

      _ ->
        operations
        |> Enum.reduce_while(0, fn o, _ ->
          validation_result = apply_operation(equation, o) |> validate_equation_aux(operations)

          case validation_result do
            0 -> {:cont, 0}
            r -> {:halt, r}
          end
        end)
    end
  end

  @spec apply_operation(Equation.t(), atom()) :: Equation.t()
  def apply_operation(eq, operation) do
    current =
      case operation do
        :add ->
          eq.current + hd(eq.operands)

        :multiply ->
          eq.current * hd(eq.operands)

        :concat ->
          String.to_integer("#{eq.current}#{hd(eq.operands)}")
      end

    %Equation{
      eq
      | current: current,
        operands: tl(eq.operands)
    }
  end

  def execute_1() do
    Aoc.Helper.read_file("data/2024/day7.txt")
    |> Enum.reduce(0, fn line, acc -> acc + validate_line(line, @operations) end)
  end

  def execute_2() do
    Aoc.Helper.read_file("data/2024/day7.txt")
    |> Enum.reduce(0, fn line, acc -> acc + validate_line(line, @operations_day2) end)
  end
end
