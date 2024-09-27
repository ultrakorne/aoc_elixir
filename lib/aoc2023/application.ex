defmodule Aoc2023.Application do
  use Application

  @spec start(any(), any()) :: {:ok, pid()}
  def start(_type, _args) do
    main()
    {:ok, self()}
  end

  defp main do
    Aoc2023.Day19.execute_2()
  end
end
