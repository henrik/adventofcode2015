defmodule Day14.B do
  @total_seconds 2503

  defmodule Reindeer do
    defstruct name: nil, kps: nil, duration: nil, rest: nil, km: nil, score: 0
  end

  def run do
    raw_data
    |> build_reindeer
    |> time_passes
    |> find_highscore
    |> IO.inspect
  end

  defp find_highscore(reindeer) do
    reindeer
    |> Enum.max_by(fn %Reindeer{score: s} -> s end)
  end

  defp time_passes(reindeer) do
    Enum.reduce 1..@total_seconds, reindeer, fn(second, iterated_reindeer) ->
      state_at_second(iterated_reindeer, second)
    end
  end

  defp state_at_second(reindeer, second) do
    reindeer
    |> Enum.map(&state_at_second_for_one(&1, second))
    |> award_leading_reindeer
  end

  defp award_leading_reindeer(reindeer) do
    # There may be a tie.
    a_leading_reindeer = reindeer |> Enum.max_by(fn %Reindeer{km: km} -> km end)
    leading_distance = a_leading_reindeer.km

    Enum.map reindeer, fn a_reindeer ->
      if a_reindeer.km == leading_distance do
        %Reindeer{a_reindeer|score: a_reindeer.score + 1}
      else
        a_reindeer
      end
    end
  end

  defp state_at_second_for_one(a_reindeer = %Reindeer{kps: kps, duration: secs_of_flight_per_cycle, rest: rest}, second) do
    cycle_secs = secs_of_flight_per_cycle + rest
    full_cycles_count = div(second, cycle_secs)

    secs_of_partial_cycle = rem(second, cycle_secs) |> min(secs_of_flight_per_cycle)

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

Day14.B.run
