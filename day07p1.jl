parse_crabs(line) = map(s -> parse(Int, s), split(line, ","))
read_crabs(path) = open(io -> parse_crabs(readline(io)), path)

tri(n) = div(n*(n+1), 2)

fuel(crabs, t) = sum(tri(abs(crab - t)) for crab = crabs)

least_fuel(crabs) = minimum(t -> fuel(crabs, t), minimum(crabs):maximum(crabs))
