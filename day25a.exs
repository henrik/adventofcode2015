defmodule Day do
  # Input
  @row 3010
  @column 3019

  @first_code 20151125
  @multiplicator 252533
  @divisor 33554393

  def run do
    ordinal = ordinal_of(@column, @row)

    out = Enum.reduce 2..ordinal, @first_code, fn(_num, acc) ->
      rem (acc * @multiplicator), @divisor
    end

    IO.inspect result: out
  end

  defp ordinal_of(1, 1), do: 1
  defp ordinal_of(1, r), do: (r - 1) + ordinal_of(1, r - 1)
  defp ordinal_of(c, r), do: ordinal_of(c - 1, r) + r + c - 1
end

Day.run
