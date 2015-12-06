defmodule Solution do
  @input "iwrupvqb"

  # I was going to make this parallel but turns out it was plenty fast anyway…
  def run do
    ints
    |> Enum.find(fn i -> hash(@input <> to_string(i)) |> String.starts_with?("00000") end)
    |> IO.inspect
  end

  defp ints, do: Stream.iterate(1, &(&1 + 1))

  defp hash(string) do
    :crypto.hash(:md5, string) |> Base.encode16
  end
end

Solution.run
