struct Submarine
   depth::Int
   hpos::Int
   aim::Int
end

struct Vert
   down::Int
end

struct Fwd
   dist::Int
end

Command = Union{Vert, Fwd}

Base.zero(::Type{Submarine}) = Submarine(0, 0, 0)

function Base.parse(::Type{Command}, s::AbstractString) 
   m = match(r"^([a-z]+)\s+(\d+)$", s)
   if m === nothing
      throw(ArgumentError("Bad command syntax: $(repr(s))"))
   end
   word, snum = m
   num = parse(Int, snum)
   if word == "forward"
      Fwd(num)
   elseif word == "down"
      Vert(num)
   elseif word == "up"
      Vert(-num)
   else
      throw(ArgumentError("Bad command word: $word"))
   end
end

move(s::Submarine, v::Vert) = Submarine(s.depth, s.hpos, s.aim + v.down)
move(s::Submarine, f::Fwd) = Submarine(s.depth + s.aim * f.dist, s.hpos + f.dist, s.aim)

move(s::Submarine, cs::Base.Generator) = foldl(move, cs; init=s)
move(s::Submarine, cs::Vector) = foldl(move, cs; init=s)

the_sub = move(zero(Submarine), parse(Command, l) for l = eachline(stdin))
println(the_sub)
println(the_sub.depth * the_sub.hpos)
