defmodule Aoc2023 do
  @moduledoc """
  Documentation for `Aoc2023`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Aoc2023.hello()
      :world

  """
  def hello do
    :world
  end

  @spec read_file(
          binary()
          | maybe_improper_list(
              binary() | maybe_improper_list(any(), binary() | []) | char(),
              binary() | []
            )
        ) :: [binary()]
  @doc """
  Reads the content of the file and returns a list of strings, each representing a line in the file.
  """

  def read_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end
