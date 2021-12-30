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

ascoretab = Dict(
   ')' => 1,
   ']' => 2,
   '}' => 3,
   '>' => 4)

struct Corrupted
   bad::Char
end

struct Prefix
   rest::Vector{Char}
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
   Prefix(stack)
end

iscorrupted(::Corrupted) = true
iscorrupted(_) = false
isincomplete(pf::Prefix) = !isempty(pf.rest)
isincomplete(_) = false
iscomplete(pf::Prefix) = isempty(pf.rest)
iscomplete(_) = false

classify_file(path)::Vector{ChunkType} = open(path) do io
   map(classify, eachline(io))
end

synscore(co::Corrupted) = scoretab[co.bad]
synscore(::Prefix) = 0
synscore(cv::Vector{ChunkType}) = sum(map(synscore, cv))

function odd_middle(seq) 
   n = length(seq)
   @assert mod(n, 2) == 1
   seq[div(n+1, 2)]
end

autoscore(::Corrupted) = 0
autoscore(pf::Prefix) = foldr((chr,acc) -> 5*acc + ascoretab[chr], pf.rest; init=0)
autoscore(cv::Vector{ChunkType}) = odd_middle(sort(filter(n -> n > 0, map(autoscore, cv))))
