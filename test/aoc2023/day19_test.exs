defmodule Aoc2023.Day19Test do
  use ExUnit.Case
  doctest Aoc2023.Day19

  test "union solutions" do
    sol1 = %{
      "a" => Range.new(5, 5),
      "m" => Range.new(3, 6),
      "s" => Range.new(1, 1),
      "x" => Range.new(1, 1)
    }

    sol2 = %{
      "a" => Range.new(5, 6),
      "m" => Range.new(4, 7),
      "s" => Range.new(1, 1),
      "x" => Range.new(1, 1)
    }

    sol3 = %{
      "a" => Range.new(5, 5),
      "m" => Range.new(2, 4),
      "s" => Range.new(1, 1),
      "x" => Range.new(1, 1)
    }

    sol4 = %{
      "a" => Range.new(1, 1),
      "m" => Range.new(1, 1),
      "s" => Range.new(5, 5),
      "x" => Range.new(2, 3)
    }

    solutions = [sol1, sol2, sol3, sol4]
    comb = Aoc2023.Day19.combinations(solutions)
    IO.puts("comb: #{comb}")
    # assert
  end
end
