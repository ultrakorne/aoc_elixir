defmodule Y2024.Day13.ClawMachine do
  defstruct button_a: {0, 0}, button_b: {0, 0}, prize: {0, 0}
end

defmodule Aoc.Y2024.Day13 do
  alias Y2024.Day13.ClawMachine
  @epsilon 1.0e-3

  def round_if_int(x) do
    rounded = Float.round(x)
    if abs(x - rounded) < @epsilon, do: trunc(rounded), else: 0
  end

  def solve_price(%{button_a: {ax, ay}, button_b: {bx, by}, prize: {x, y}}) do
    solve_price(ax, ay, bx, by, x, y)
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
    File.read!("data/2024/day13.txt")
    |> String.split("\r\n")
    |> Stream.chunk_by(fn x -> x == "" end)
    |> Stream.reject(fn x -> x == [""] end)
    |> Stream.map(fn x -> x |> Enum.join(" ") end)
    |> Stream.map(fn str ->
      ~r/.*Button A: X\+(\d+), Y\+(\d+).*Button B: X\+(\d+), Y\+(\d+).*Prize: X=(\d+), Y=(\d+)/
      |> Regex.scan(str)
      |> hd()
      |> tl()
      |> create_claw_machine()
    end)
    |> Enum.reduce(0, fn claw_machine, acc ->
      acc + solve_price(claw_machine)
    end)
  end

  def execute_2() do
    File.read!("data/2024/day13.txt")
    |> String.split("\r\n")
    |> Stream.chunk_by(fn x -> x == "" end)
    |> Stream.reject(fn x -> x == [""] end)
    |> Stream.map(fn x -> x |> Enum.join(" ") end)
    |> Stream.map(fn str ->
      ~r/.*Button A: X\+(\d+), Y\+(\d+).*Button B: X\+(\d+), Y\+(\d+).*Prize: X=(\d+), Y=(\d+)/
      |> Regex.scan(str)
      |> hd()
      |> tl()
      |> create_claw_machine_2()
    end)
    |> Enum.reduce(0, fn claw_machine, acc ->
      price = solve_price(claw_machine)
      # IO.inspect(claw_machine)
      # IO.puts("Price: #{price}")
      acc + price
    end)
  end

  defp create_claw_machine([ax, ay, bx, by, x, y]) do
    %ClawMachine{
      button_a: {String.to_integer(ax), String.to_integer(ay)},
      button_b: {String.to_integer(bx), String.to_integer(by)},
      prize: {String.to_integer(x), String.to_integer(y)}
    }
  end

  defp create_claw_machine_2([ax, ay, bx, by, x, y]) do
    %ClawMachine{
      button_a: {String.to_integer(ax), String.to_integer(ay)},
      button_b: {String.to_integer(bx), String.to_integer(by)},
      prize:
        {String.to_integer(x) + 10_000_000_000_000, String.to_integer(y) + 10_000_000_000_000}
    }
  end
end
