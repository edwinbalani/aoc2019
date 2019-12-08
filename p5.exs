defmodule Instruction do
  defstruct op: nil, params: {}, imm: {}
end

defmodule State do
  defstruct ip: 0, mem: {}
end

defmodule Puzzle do
  def run(filename) do
    mem =
      File.read!(filename)
      |> String.trim("\n")
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    loaded = %State{mem: mem}
    execute(loaded)
  end

  defp execute(state = %State{mem: mem}) do
    # IO.inspect(Tuple.to_list(mem) |> Enum.slice(state.ip..(state.ip + 5)))
    instr = state |> decode()
    # IO.inspect(instr)

    # Cease recursive execution if this is a halt instruction
    if instr.op === :halt do
      state
    else
      updates =
        case instr.op do
          :add ->
            {a, b, dest} = instr.params
            [mem: put_elem(mem, dest, a + b)]

          :mul ->
            {a, b, dest} = instr.params
            [mem: put_elem(mem, dest, a * b)]

          :read ->
            {dest} = instr.params
            iput = IO.gets("") |> String.trim_trailing() |> String.to_integer()
            [mem: put_elem(mem, dest, iput)]

          :write ->
            {src} = instr.params
            src |> Integer.to_string() |> IO.puts()
            []

          :jnz ->
            {x, target} = instr.params

            if x !== 0 do
              [ip: target]
            else
              []
            end

          :jz ->
            {x, target} = instr.params

            if x === 0 do
              [ip: target]
            else
              []
            end

          :lt ->
            {a, b, dest} = instr.params
            [mem: put_elem(mem, dest, if(a < b, do: 1, else: 0))]

          :eq ->
            {a, b, dest} = instr.params
            [mem: put_elem(mem, dest, if(a === b, do: 1, else: 0))]

          _ ->
            IO.puts(:stderr, "WARN  Unimplemented op #{instr.op}")
            []
        end

      advance(state, instr, updates)
      |> execute()
    end
  end

  defp advance(%State{} = state, %Instruction{} = instr, updates \\ []) do
    state
    |> struct(ip: state.ip + 1 + tuple_size(instr.params))
    |> struct(updates)
  end

  defp decode(%State{ip: ip, mem: mem} = state) do
    opcode = elem(mem, ip)

    {op, nparam, write} =
      case rem(opcode, 100) do
        1 -> {:add, 3, 3}
        2 -> {:mul, 3, 3}
        3 -> {:read, 1, 1}
        4 -> {:write, 1, nil}
        5 -> {:jnz, 2, nil}
        6 -> {:jz, 2, nil}
        7 -> {:lt, 3, 3}
        8 -> {:eq, 3, 3}
        99 -> {:halt, 0, nil}
      end

    immediates =
      if nparam > 0 do
        for i <- 1..nparam do
          imm_encode = rem(div(opcode, pow(10, i + 1)), 10)
          imm_encode == 1 or i === write
        end
        |> List.to_tuple()
      else
        {}
      end

    instr = %Instruction{op: op, imm: immediates}

    if nparam > 0 do
      params = read_param(state, instr, 1..nparam)
      struct(instr, params: params)
    else
      instr
    end
  end

  defp read_param(%State{ip: ip, mem: mem}, %Instruction{imm: immediates}, idx)
       when is_integer(idx) do
    # IO.inspect(immediates)

    pos =
      if elem(immediates, idx - 1) === true do
        ip + idx
      else
        elem(mem, ip + idx)
      end

    elem(mem, pos)
  end

  defp read_param(%State{} = state, %Instruction{} = instr, %Range{} = idx) do
    for i <- idx do
      read_param(state, instr, i)
    end
    |> List.to_tuple()
  end

  # https://stackoverflow.com/a/44065965
  defp pow(n, k), do: pow(n, k, 1)
  defp pow(_, 0, acc), do: acc
  defp pow(n, k, acc), do: pow(n, k - 1, n * acc)
end

final = Puzzle.run("input/5.txt")
# IO.inspect(final.mem)
# IO.puts(elem(final.mem, 0))
