Fish = Vector{Int64}

function parse_fish(line) 
   fish = zeros(Int64, 9)
   for n = map(s -> parse(Int, s), split(line, ","))
      fish[n+1] += 1
   end
   fish
end

read_fish(path) = open(io -> parse_fish(readline(io)), path)

function step_fish(fish::Fish)
   fish = circshift(fish, -1)
   fish[7] += fish[9]
   fish
end

function step_fish(fish::Fish, n) 
   for _ = 1:n
      fish = step_fish(fish)
   end
   fish
end

function sim256(path)
   fish = read_fish(path)
   fish = step_fish(fish, 256)
   sum(fish)
end
