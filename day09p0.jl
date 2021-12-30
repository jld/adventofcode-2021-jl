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
