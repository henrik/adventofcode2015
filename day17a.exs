defmodule Day17.A do
  @litres 150

  def run do
    raw_data
    |> to_ints
    |> generate_powersets
    |> filter_matching
    |> length
    |> IO.inspect
  end

  # Glanced more than once at http://rosettacode.org/wiki/Power_set#Elixir to wrap my brain around this…
  defp generate_powersets([]), do: [[]]
  defp generate_powersets([h|t]) do
    tail_powersets = generate_powersets(t)
    headed_powersets = for tail_powerset <- tail_powersets, do: [h|tail_powerset]
    headed_powersets ++ tail_powersets
  end

  defp filter_matching(subsets) do
    subsets
    |> Enum.filter &(Enum.sum(&1) == @litres)
  end

  defp to_ints(raw) do
    raw
    |> String.split
    |> Enum.map &String.to_integer/1
  end

  defp raw_data do
    """
    43
    3
    4
    10
    21
    44
    4
    6
    47
    41
    34
    17
    17
    44
    36
    31
    46
    9
    27
    38
    """
  end
end

Day17.A.run
