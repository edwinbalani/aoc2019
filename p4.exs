defmodule Puzzle do
  def part1(range) do
    IO.puts(Enum.count(range, &part1_valid?/1))
  end

  def part1_valid?(num) do
    d = digits(num)

    reduction =
      Enum.reduce(d, {0, false, true, 0}, fn next, acc ->
        {repeat, pair, ascending, prev} = acc

        {repeat, pair} =
          case next do
            ^prev ->
              {repeat + 1, pair}

            _ ->
              {0, pair or repeat === 1}
          end

        ascending = ascending and prev <= next
        {repeat, pair, ascending, next}
      end)

    result = (elem(reduction, 0) === 1 or elem(reduction, 1)) and elem(reduction, 2)

    # if elem(reduction, 2), do: IO.puts("#{num} -> #{result}")

    result
  end

  defp digits(n) when n >= 100_000 and n <= 999_999 do
    for power <- 5..0 do
      rem(div(n, pow(10, power)), 10)
    end
  end

  # https://stackoverflow.com/a/44065965
  defp pow(n, k), do: pow(n, k, 1)
  defp pow(_, 0, acc), do: acc
  defp pow(n, k, acc), do: pow(n, k - 1, n * acc)
end

Puzzle.part1(145_852..616_942)
