weights = DATA.each_line.map(&:to_i).sort.reverse
group_weight = weights.inject(:+) / 3

# Reached the number 6 by trial and error (5 gave 0 results etc).
p weights.combination(6).select { |x| x.inject(:+) == group_weight }.map { |x| x.inject(:*) }.min

__END__
1
3
5
11
13
17
19
23
29
31
41
43
47
53
59
61
67
71
73
79
83
89
97
101
103
107
109
113
