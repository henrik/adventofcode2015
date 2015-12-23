defmodule Day23.A do
  require Integer

  defmodule State do
    defstruct a: 1, b: 0, instruction: 0
  end

  def run do
    initial_state = %State{}
    instructions = parse_instructions

    #IO.inspect initial_state

    run(initial_state, instructions)
  end

  def run(%State{instruction: instruction_index} = state, instructions) do
    case Enum.at(instructions, instruction_index, :out_of_bounds) do
      :out_of_bounds ->
        IO.puts "Out of bounds! Terminate! State:"
        IO.inspect state
      instruction ->
        new_state = apply_instruction(state, instruction)
        #IO.puts "apply instruction ##{inspect instruction_index} : #{inspect instruction}"
        #IO.inspect new_state
        run(new_state, instructions)
    end
  end

  # Applying

  defp apply_instruction(state, {:inc, reg}) do
    struct(state, [
      {reg, Map.get(state, reg) + 1},
      instruction: state.instruction + 1,
    ])
  end
  defp apply_instruction(state, {:half, reg}) do
    struct(state, [
      {reg, round(Map.get(state, reg) / 2)},
      instruction: state.instruction + 1,
    ])
  end
  defp apply_instruction(state, {:triple, reg}) do
    struct(state, [
      {reg, Map.get(state, reg) * 3},
      instruction: state.instruction + 1,
    ])
  end
  defp apply_instruction(state, {:jump, offset}) do
    struct(state, [
      instruction: state.instruction + offset,
    ])
  end

  defp apply_instruction(%State{a: a} = state, {:jump_if_even, :a, offset}) when Integer.is_even(a), do: apply_instruction(state, {:jump, offset})
  defp apply_instruction(%State{b: b} = state, {:jump_if_even, :b, offset}) when Integer.is_even(b), do: apply_instruction(state, {:jump, offset})
  defp apply_instruction(state, {:jump_if_even, _reg, _offset}), do: apply_instruction(state, {:jump, 1})

  defp apply_instruction(%State{a: a} = state, {:jump_if_one, :a, offset}) when a == 1, do: apply_instruction(state, {:jump, offset})
  defp apply_instruction(%State{b: b} = state, {:jump_if_one, :b, offset}) when b == 1, do: apply_instruction(state, {:jump, offset})
  defp apply_instruction(state, {:jump_if_one, _reg, _offset}), do: apply_instruction(state, {:jump, 1})

  # Parsing

  defp parse_instructions do
    raw_instructions
    |> String.split("\n", trim: true)
    |> Enum.map &parse_instruction/1
  end

  defp parse_instruction("inc " <> x), do: {:inc, String.to_atom(x)}
  defp parse_instruction("hlf " <> x), do: {:half, String.to_atom(x)}
  defp parse_instruction("tpl " <> x), do: {:triple, String.to_atom(x)}
  defp parse_instruction("jmp " <> offset), do: {:jump, String.to_integer(offset)}
  defp parse_instruction(<<"jie ", reg::bytes-size(1), ", ", offset::bytes>>), do: {:jump_if_even, String.to_atom(reg), String.to_integer(offset)}
  defp parse_instruction(<<"jio ", reg::bytes-size(1), ", ", offset::bytes>>), do: {:jump_if_one, String.to_atom(reg), String.to_integer(offset)}

  # Input

  defp raw_instructions do
    """
    jio a, +18
    inc a
    tpl a
    inc a
    tpl a
    tpl a
    tpl a
    inc a
    tpl a
    inc a
    tpl a
    inc a
    inc a
    tpl a
    tpl a
    tpl a
    inc a
    jmp +22
    tpl a
    inc a
    tpl a
    inc a
    inc a
    tpl a
    inc a
    tpl a
    inc a
    inc a
    tpl a
    tpl a
    inc a
    inc a
    tpl a
    inc a
    inc a
    tpl a
    inc a
    inc a
    tpl a
    jio a, +8
    inc b
    jie a, +4
    tpl a
    inc a
    jmp +2
    hlf a
    jmp -7
    """
  end
end

Day23.A.run
