TSP = 100
PROPS_TO_COUNT = %w[ capacity durability flavor texture ]

# Parse properties.

ingredients = {}
DATA.read.each_line do |line|
  name, props = line.split(": ", 2)
  ingredients[name] = props.split(", ").map { |x| n, v = x.split; [ n, v.to_i ] }.to_h
end

p ingredients


# Calculate scores.


combos = {}

max_a = TSP

max_a.downto(0) do |a|
  rem = TSP - a

  rem.downto(0) do |b|
    rem = TSP - a - b

    rem.downto(0) do |c|
      rem = TSP - a - b - c
      d = rem

      key = { "Sugar" => a, "Sprinkles" => b, "Candy" => c, "Chocolate" => d }

      combos[key] = PROPS_TO_COUNT.map { |prop|
        [
          ingredients.map { |i, props| key.fetch(i) * props.fetch(prop) }.inject(:+),
          0
        ].max
      }.inject(:*)
    end
  end
end

p combos.values.max

__END__
Sugar: capacity 3, durability 0, flavor 0, texture -3, calories 2
Sprinkles: capacity -3, durability 3, flavor 0, texture 0, calories 9
Candy: capacity -1, durability 0, flavor 4, texture 0, calories 1
Chocolate: capacity 0, durability 0, flavor -2, texture 2, calories 8
