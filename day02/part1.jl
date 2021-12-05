struct Submarine
   depth::Int
   hpos::Int
end

Base.:+(s::Submarine, t::Submarine) = Submarine(s.depth + t.depth, s.hpos + t.hpos)
Base.zero(::Type{Submarine}) = Submarine(0, 0)

function Base.parse(::Type{Submarine}, s::AbstractString) 
   m = match(r"^([a-z]+)\s+(\d+)$", s)
   if m === nothing
      throw(ArgumentError("Bad command syntax: $(repr(s))"))
   end
   word, snum = m
   num = parse(Int, snum)
   if word == "forward"
      Submarine(0, num)
   elseif word == "down"
      Submarine(num, 0)
   elseif word == "up"
      Submarine(-num, 0)
   else
      throw(ArgumentError("Bad command word: $word"))
   end
end

subsum = sum(parse(Submarine, l) for l = eachline(stdin))
println(subsum)
println(subsum.depth * subsum.hpos)
