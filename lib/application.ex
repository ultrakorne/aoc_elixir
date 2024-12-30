defmodule Aoc.Application do
  use Application

  @spec start(any(), any()) :: {:ok, pid()}
  def start(_type, _args) do
    main()
    {:ok, self()}
  end

  defp main do
    result = Aoc.Y2024.Day14.execute_1()
    IO.inspect(result, label: "Result")
  end
end
