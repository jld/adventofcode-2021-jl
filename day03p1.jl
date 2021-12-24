function bitgrid(path)
   n = nothing
   b = BitVector()
   open(path) do f
      for l = eachline(f)
         lb = BitVector(c != '0' for c = l)
         if n == nothing
            n = length(lb)
         else
            @assert(n == length(lb))
         end
         append!(b, lb)
      end
   end
   n == nothing ? b : reshape(b, n, :)
end

function majority(bv::AbstractVector{Bool})
   2 * sum(bv) >= length(bv)
end

minority(bv) = !majority(bv)

winnow(g, x, b) = @view g[:, findall(bb -> bb == b, g[x, :])]

step_oxy(g, x) = winnow(g, x, majority(g[x, :]))
step_co2(g, x) = winnow(g, x, minority(g[x, :]))

function rating(g::BitMatrix, step) 
   for x = axes(g, 1)
      if size(g, 2) <= 1
         break
      end
      g = step(g, x)
   end
   vec(g)
end

function bton(bv::AbstractVector{Bool})
   n = length(bv)
   sum(2^(n-i) * bv[i] for i = 1:n)
end

function day03p1(path)
   g = bitgrid(path)
   r_oxy = bton(rating(g, step_oxy))
   r_co2 = bton(rating(g, step_co2))
   r_oxy * r_co2
end
