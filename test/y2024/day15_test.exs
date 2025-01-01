defmodule Aoc.Y2024.Day15Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day15

  test "should not move robot" do
    str = "@##"
    out = Day15.move_robot(str)
    assert out == "@##"

    str = "@O#"
    out = Day15.move_robot(str)
    assert out == "@O#"

    str = "@OOOO#"
    out = Day15.move_robot(str)
    assert out == "@OOOO#"
  end

  test "move robot" do
    str = "@.#"
    out = Day15.move_robot(str)
    assert out == ".@#"

    str = "@O.O.#"
    out = Day15.move_robot(str)
    assert out == ".@OO.#"
  end

  test "move with pushing stack" do
    str = "@OO.#"
    out = Day15.move_robot(str)
    assert out == ".@OO#"

    str = "@OOO.#"
    out = Day15.move_robot(str)
    assert out == ".@OOO#"

    str = "@OOO.O#"
    out = Day15.move_robot(str)
    assert out == ".@OOOO#"

    str = "@OOO...#"
    out = Day15.move_robot(str)
    assert out == ".@OOO..#"
  end
end
