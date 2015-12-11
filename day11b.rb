# The result of 11A.
old_pw = "vzbxxyzz"

def valid?(password)
  return false if password.match(/[iol]/)

  number_of_unique_letter_pairs = password.scan(/((.)\2)/).map(&:first).uniq.length
  return false if number_of_unique_letter_pairs < 2

  any_triscales = password.chars.each_cons(3).any? { |a, b, c| [a, b, c] == [a, a.next, a.next.next] }
  return false unless any_triscales

  true
end

candidate_pw = old_pw
loop do
  candidate_pw = candidate_pw.next
  break if valid?(candidate_pw)
end

puts candidate_pw
