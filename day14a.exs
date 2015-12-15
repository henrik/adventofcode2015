# Let's try some Elixir again!

defmodule Day14.A do
  @total_seconds 2503

  defmodule Reindeer do
    defstruct [:name, :kps, :duration, :rest, :km]
  end

  def run do
    raw_data
    |> build_reindeer
    |> time_passes
    |> get_winning_distance
    |> IO.inspect
  end

  defp get_winning_distance(reindeer) do
    reindeer
    |> Enum.max_by(fn %Reindeer{km: km} -> km end)
  end

  defp time_passes(reindeer) do
    Enum.map reindeer, &time_passes_for_one(&1)
  end

  defp time_passes_for_one(a_reindeer = %Reindeer{kps: kps, duration: secs_of_flight_per_cycle, rest: rest}) do
    cycle_secs = secs_of_flight_per_cycle + rest
    full_cycles_count = div(@total_seconds, cycle_secs)

    secs_of_partial_cycle = rem(@total_seconds, cycle_secs) |> min(secs_of_flight_per_cycle)

    seconds_of_flight = full_cycles_count * secs_of_flight_per_cycle + secs_of_partial_cycle
    km_of_flight = seconds_of_flight * kps

    %Reindeer{a_reindeer|km: km_of_flight}
  end

  defp build_reindeer(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    captures = Regex.named_captures(
      ~r[(?<name>.+) can fly (?<kps>\d+) km/s for (?<duration>\d+) seconds, but then must rest for (?<rest>\d+) seconds.],
      line
    )

    %Reindeer{
      name:     captures["name"],
      kps:      captures["kps"] |> String.to_integer,
      duration: captures["duration"] |> String.to_integer,
      rest:     captures["rest"] |> String.to_integer,
    }
  end

  defp raw_data do
    """
    Vixen can fly 19 km/s for 7 seconds, but then must rest for 124 seconds.
    Rudolph can fly 3 km/s for 15 seconds, but then must rest for 28 seconds.
    Donner can fly 19 km/s for 9 seconds, but then must rest for 164 seconds.
    Blitzen can fly 19 km/s for 9 seconds, but then must rest for 158 seconds.
    Comet can fly 13 km/s for 7 seconds, but then must rest for 82 seconds.
    Cupid can fly 25 km/s for 6 seconds, but then must rest for 145 seconds.
    Dasher can fly 14 km/s for 3 seconds, but then must rest for 38 seconds.
    Dancer can fly 3 km/s for 16 seconds, but then must rest for 37 seconds.
    Prancer can fly 25 km/s for 6 seconds, but then must rest for 143 seconds.
    """
  end
end

Day14.A.run
