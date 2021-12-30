function read_hmap(io)
   border = UInt8(255)
   buffer = zeros(UInt8, 0)
   width = missing
   for line = eachline(io)
      row = UInt8[c - '0' for c = line]
      if ismissing(width)
         width = length(row)
      else
         @assert width == length(row)
      end
      append!(buffer, row)
      push!(buffer, border)
   end
   append!(buffer, fill(border, width + 1))
   reshape(buffer, width + 1, :)
end

lown(hmap) = min.(
   circshift(hmap, (0, 1)),
   circshift(hmap, (0, -1)),
   circshift(hmap, (1, 0)),
   circshift(hmap, (-1, 0)))

safe_pts(hmap) = hmap .< lown(hmap)

risk_level(n::UInt8) = Int(n) + 1
risk_sum(hmap) = sum(risk_level(hmap[pt]) for pt = findall(safe_pts(hmap)))

risk_of_file(path) = risk_sum(open(read_hmap, path))

function basins(hmap) 
   mov_lf = CartesianIndex(-1, 0)
   mov_rt = CartesianIndex(1, 0)
   mov_up = CartesianIndex(0, -1)
   mov_dn = CartesianIndex(0, 1)
   sh_lf = circshift(hmap, (1, 0))
   sh_rt = circshift(hmap, (-1, 0))
   sh_up = circshift(hmap, (0, 1))
   sh_dn = circshift(hmap, (0, -1))
   moves = [(sh_lf, mov_lf), (sh_rt, mov_rt), (sh_up, mov_up), (sh_dn, mov_dn)]

   lows = findall(hmap .< min.(sh_lf, sh_rt, sh_up, sh_dn))
   acc = Int[]
   for low = lows
      #println("Starting: ", low)
      stack = [low]
      been = falses(size(hmap))
      while !isempty(stack)
         here = pop!(stack)
         if been[here]
            continue 
         end
         been[here] = true
         for (sh, dxy) = moves
            if sh[here] > hmap[here] && sh[here] < 9
               #println("Going: ", here, " -> ", here + dxy)
               push!(stack, here + dxy)
            end
         end
      end
      push!(acc, count(been))
   end
   acc
end

do_part2(path) = prod(sort(basins(open(read_hmap, path)))[end-2:end])
