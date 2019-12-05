defmodule Puzzle do
  @init_state %{ip: 0, mem: {}}

  def run(filename) do
    mem =
      File.read!(filename)
      |> String.trim("\n")
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    loaded = %{@init_state | mem: mem}
    result = execute(loaded)
    IO.puts(elem(result.mem, 0))

    for noun <- 0..99, verb <- 0..99 do
      test_mem =
        loaded.mem
        |> put_elem(1, noun)
        |> put_elem(2, verb)

      test_state = %{loaded | mem: test_mem}

      if elem(execute(test_state).mem, 0) == 19_690_720 do
        IO.puts(noun * 100 + verb)
      end
    end
  end

  defp execute(state = %{ip: ip, mem: mem}) do
    # IO.inspect(state)
    opcode = elem(mem, ip)

    case opcode do
      1 ->
        a = elem(mem, elem(mem, ip + 1))
        b = elem(mem, elem(mem, ip + 2))
        dest = elem(mem, ip + 3)
        # IO.puts("#{a} + #{b} => #{dest}")
        execute(%{state | ip: ip + 4, mem: put_elem(mem, dest, a + b)})

      2 ->
        a = elem(mem, elem(mem, ip + 1))
        b = elem(mem, elem(mem, ip + 2))
        dest = elem(mem, ip + 3)
        # IO.puts("#{a} * #{b} => #{dest}")
        execute(%{state | ip: ip + 4, mem: put_elem(mem, dest, a * b)})

      99 ->
        state
    end
  end
end

Puzzle.run("input/2.txt")
