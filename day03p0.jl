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

function majority(g)
   xs, ys = axes(g)
   BitVector(2 * sum(g[x, :]) > length(ys) for x = xs)
end

function bton(bv)
   n = length(bv)
   sum(2^(n-i) * bv[i] for i = 1:n)
end

function day03p0(path)
  maj = majority(bitgrid(path))
  gam = bton(maj)
  eps = bton(.!maj)
  gam * eps
end

