defmodule Aoc.Y2024.Day13Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day13

  test "how many solutions" do
    # 94x + 22x = 8400
    # 34y + 67y = 5400
    assert Day13.has_solutions(94, 34, 22, 67, 8400, 5400) == :one
    # Button A: X+26, Y+66
    # Button B: X+67, Y+21
    # Prize: X=12748, Y=12176
    # 26x + 67y = 12748
    # 66x + 21y = 12176
    assert Day13.has_solutions(26, 66, 67, 21, 12748, 12176) == :one
  end

  test "solve matrix" do
    solution = Day13.solve_price(94, 34, 22, 67, 8400, 5400)
    IO.inspect(solution, label: "Solution")

    solution_2 = Day13.solve_price(26, 66, 67, 21, 12748, 12176)
    IO.inspect(solution_2, label: "Solution 2")

    #     Button A: X+17, Y+86
    # Button B: X+84, Y+37
    # Prize: X=7870, Y=6450
    solution_3 = Day13.solve_price(17, 86, 84, 37, 7870, 6450)
    IO.inspect(solution_3, label: "Solution 3")
  end
end
