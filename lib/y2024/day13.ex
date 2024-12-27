defmodule Aoc.Y2024.Day13 do
  @epsilon 1.0e-9

  def round_if_int(x) do
    rounded = Float.round(x)
    if abs(x - rounded) < @epsilon, do: trunc(rounded), else: 0
  end

  def solve_price(ax, ay, bx, by, x, y) do
    a = ax
    b = bx
    c = ay
    d = by
    inverse_aux = 1 / det_matrix(a, b, c, d)
    {ia, ib, ic, id} = {inverse_aux * d, -inverse_aux * b, -inverse_aux * c, inverse_aux * a}
    sol_button_a = ia * x + ib * y
    sol_button_b = ic * x + id * y
    # {sol_button_b, sol_button_a}
    button_a = round_if_int(sol_button_a)
    button_b = round_if_int(sol_button_b)
    button_a * 3 + button_b
  end

  defp det_matrix(a, b, c, d), do: a * d - b * c

  def has_solutions(ax, ay, bx, by, x, y) do
    has_solutions_aux(ax, bx, ay, by, x, y)
  end

  defp has_solutions_aux(a, b, c, d, x, y) do
    det = det_matrix(a, b, c, d)

    if det != 0 do
      :one
    else
      dx = det_matrix(x, b, y, d)
      dy = det_matrix(a, x, c, y)

      if dx != 0 or dy != 0 do
        IO.puts("no solutions for #{a}x + #{b}y = #{x}, #{c}x + #{d}y = #{y}")
        :none
      else
        IO.puts("infinite solutions for #{a}x + #{b}y = #{x}, #{c}x + #{d}y = #{y}")
        :many
      end
    end
  end

  def execute_1() do
    File.read!("data/2024/day13_test.txt")
    |> String.split("\n")
    |> Enum.chunk_by(fn x -> x == "" end)
    |> Enum.reject(fn x -> x == [""] end)
    |> IO.inspect()
  end
end
