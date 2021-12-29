parse_fish(line) = map(s -> parse(UInt8, s), split(line, ","))
read_fish(path) = open(io -> parse_fish(readline(io)), path)

Fish = Vector{UInt8}

function step_fish!(fish::Fish)
   for i = 1:length(fish)
      if fish[i] == 0
         fish[i] = 6
         push!(fish, 8)
      else
         fish[i] -= 1
      end
   end
end

step_fish!(fish::Fish, n) = foreach(_ -> step_fish!(fish), 1:n)

function sim80(path)
   fish = read_fish(path)
   step_fish!(fish, 80)
   length(fish)
end
