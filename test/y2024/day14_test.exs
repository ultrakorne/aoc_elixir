defmodule Aoc.Y2024.Day14Test do
  use ExUnit.Case
  alias Aoc.Y2024.Day14

  test "Robot position after seconds" do
    robot = %Day14.Robot{pos: {2, 4}, velocity: {2, -3}}
    assert Day14.move_robot(robot, 1, 11, 7) == {4, 1}
    assert Day14.move_robot(robot, 2, 11, 7) == {6, 5}
    assert Day14.move_robot(robot, 3, 11, 7) == {8, 2}
    assert Day14.move_robot(robot, 4, 11, 7) == {10, 6}
    assert Day14.move_robot(robot, 5, 11, 7) == {1, 3}
  end
end
