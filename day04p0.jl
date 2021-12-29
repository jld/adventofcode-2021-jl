read_draws(f) = map(s -> parse(Int, s), split(readline(f), ","))

function read_boards(f)
   acc = zeros(Int, 0)
   for line = eachline(f)
      append!(acc, map(s -> parse(Int, s), split(line)))
   end
   reshape(acc, 5, 5, :)
end

struct Game
   draws::Vector{Int}
   board::Array{Int, 3}
end

function read_game(f)
   d = read_draws(f)
   b = read_boards(f)
   Game(d, b)
end
