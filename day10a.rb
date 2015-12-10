input = "1113222113"

do_it = -> input {
  input.chars.chunk { |x| x }.map { |n, list| list.length.to_s + n }.join
}

value = input
40.times { value = do_it.call(value) }

puts value.length
