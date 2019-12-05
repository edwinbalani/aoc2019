defmodule Puzzle do
  def run1, do: run_common(&fuel/1)

  def run2, do: run_common(&fuel_realistic/1)

  defp run_common(calc) do
    input = File.read!("input/1.txt")

    IO.puts(
      Enum.sum(
        for line <- String.split(input, "\n"), line != "" do
          line
          |> String.to_integer()
          |> calc.()
        end
      )
    )
  end

  defp fuel(mass), do: div(mass, 3) - 2

  defp fuel_realistic(mass, acc \\ 0) do
    required = fuel(mass)

    if fuel(required) <= 0 do
      required + acc
    else
      fuel_realistic(required, required + acc)
    end
  end
end

Puzzle.run1()
Puzzle.run2()
