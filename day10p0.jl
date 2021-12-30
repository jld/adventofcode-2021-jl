exptab = Dict(
   '(' => ')',
   '[' => ']',
   '{' => '}',
   '<' => '>')

scoretab = Dict(
   ')' => 3,
   ']' => 57,
   '}' => 1197,
   '>' => 25137)

struct Corrupted
   bad::Char
end

struct Prefix
   depth::Int
end

ChunkType = Union{Corrupted,Prefix}

function classify(str)::ChunkType
   stack = Char[]
   for chr = str
      close = get(exptab, chr, nothing)
      if close != nothing
         push!(stack, close)
      elseif !isempty(stack) && chr == stack[end]
         pop!(stack)
      else
         return Corrupted(chr)
      end
   end
   Prefix(length(stack))
end

iscorrupted(::Corrupted) = true
iscorrupted(_) = false
isincomplete(pf::Prefix) = pf.depth != 0
isincomplete(_) = false
iscomplete(pf::Prefix) = pf.depth == 0
iscomplete(_) = false

classify_file(path)::Vector{ChunkType} = open(path) do io
   map(classify, eachline(io))
end

synscore(co::Corrupted) = scoretab[co.bad]
synscore(::Prefix) = 0
synscore(cv::Vector{ChunkType}) = sum(map(synscore, cv))
