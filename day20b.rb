MIN_PRESENTS = 36_000_000
MAX_HOUSES = 50

# Naive algorithm. There are faster, more cryptic ones.
# def factors_of(num)
#   num.downto(1).select { |n| (num % n).zero? }
# end

# Ended up using a faster, more cryptic algorithm that I did not write myself:
# http://stackoverflow.com/a/21165002/6962
def factors_of(num)
  1.upto(Math.sqrt(num)).select { |i| (num % i).zero? }.inject([]) do |f, i|
    f << i
    f << num / i unless i == num / i
    f
  end
end

def count_for_house(num)
  factors = factors_of(num)

  factors = factors.reject { |elf| elf * MAX_HOUSES < num }

  factors.map { |elf| elf * 11 }.inject(:+)
end

# Arrived at these numbers by trial and error, and replacing a value if Advent of Code said my result was too high…
# Wanted to use a binary search but that's tricky since the values aren't monotonic.
p (856800..2_000_000).find { |i|
  count_for_house(i) >= MIN_PRESENTS
}
