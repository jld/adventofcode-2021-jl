parse_crabs(line) = map(s -> parse(Int, s), split(line, ","))
read_crabs(path) = open(io -> parse_crabs(readline(io)), path)

# Sloppy median
target(crabs) = sort(crabs)[div(length(crabs) + 1, 2)]

fuel(crabs, t = target(crabs)) = sum(abs(crab - t) for crab = crabs)
