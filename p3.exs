defmodule Puzzle do
  def run(filename) do
    runs =
      File.read!(filename)
      |> String.split("\n")
      |> Enum.filter(fn l -> l != "" end)

    runs =
      runs
      |> Enum.map(&parse_line/1)
      |> Enum.map(&mark_run/1)
      |> Enum.map(&MapSet.new/1)

    hits =
      apply(MapSet, :intersection, runs)
      |> Enum.filter(fn pos -> pos != {0, 0} end)

    closest = Enum.min_by(hits, &manhattan/1)
    IO.puts(manhattan(closest))
  end

  defp manhattan({x, y}) do
    abs(x) + abs(y)
  end

  defp parse_line(line) do
    for instruction <- String.split(line, ",") do
      {direction, length} = String.split_at(instruction, 1)
      direction = String.to_atom(direction)
      length = String.to_integer(length)
      {direction, length}
    end
  end

  defp mark_run(moves, turtle \\ %{x: 0, y: 0, visited: []}) do
    [next | remaining] = moves

    turtle = mark_move(turtle, next)

    if length(remaining) != 0 do
      mark_run(remaining, turtle)
    else
      turtle.visited
    end
  end

  defp mark_move(turtle, {dir, len}) do
    case dir do
      :U ->
        %{
          turtle
          | visited: turtle.visited ++ Enum.map(0..len, fn i -> {turtle.x, turtle.y + i} end),
            y: turtle.y + len
        }

      :D ->
        %{
          turtle
          | visited: turtle.visited ++ Enum.map(0..len, fn i -> {turtle.x, turtle.y - i} end),
            y: turtle.y - len
        }

      :L ->
        %{
          turtle
          | visited: turtle.visited ++ Enum.map(0..len, fn i -> {turtle.x - i, turtle.y} end),
            x: turtle.x - len
        }

      :R ->
        %{
          turtle
          | visited: turtle.visited ++ Enum.map(0..len, fn i -> {turtle.x + i, turtle.y} end),
            x: turtle.x + len
        }
    end
  end
end

Puzzle.run("input/3-test1.txt")
Puzzle.run("input/3-test2.txt")
Puzzle.run("input/3.txt")
