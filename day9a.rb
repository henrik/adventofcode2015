data = DATA.read.strip

distances = {}

# Get all distances.

data.each_line do |line|
  line.match(/(\w+) to (\w+) = (\d+)/)
  loc1, loc2, dist = $1, $2, $3.to_i
  distances[[loc1, loc2]] = dist
  distances[[loc2, loc1]] = dist
end

# Now find the shortest leg by brute force (only 8! = 40 320 possible routes).

locations = distances.keys.flatten.uniq
route_lengths = {}

locations.permutation.each do |route|
  route_lengths[route] = route.each_cons(2).map { |loc1, loc2| distances.fetch([loc1, loc2]) }.inject(:+)
end

puts route_lengths.values.min

__END__
Tristram to AlphaCentauri = 34
Tristram to Snowdin = 100
Tristram to Tambi = 63
Tristram to Faerun = 108
Tristram to Norrath = 111
Tristram to Straylight = 89
Tristram to Arbre = 132
AlphaCentauri to Snowdin = 4
AlphaCentauri to Tambi = 79
AlphaCentauri to Faerun = 44
AlphaCentauri to Norrath = 147
AlphaCentauri to Straylight = 133
AlphaCentauri to Arbre = 74
Snowdin to Tambi = 105
Snowdin to Faerun = 95
Snowdin to Norrath = 48
Snowdin to Straylight = 88
Snowdin to Arbre = 7
Tambi to Faerun = 68
Tambi to Norrath = 134
Tambi to Straylight = 107
Tambi to Arbre = 40
Faerun to Norrath = 11
Faerun to Straylight = 66
Faerun to Arbre = 144
Norrath to Straylight = 115
Norrath to Arbre = 135
Straylight to Arbre = 127
