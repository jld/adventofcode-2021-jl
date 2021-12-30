struct Segs
   on::BitVector
end

struct Entry
   samples::Vector{Segs}
   data::Vector{Segs}
end

function Base.parse(::Type{Segs}, str::AbstractString)
   on = falses(7)
   for c = str
      on[c - 'a' + 1] = true
   end
   Segs(on)
end

parse_seg_seq(str::AbstractString) = map(word -> parse(Segs, word), split(str))

function Base.parse(::Type{Entry}, str::AbstractString)
   samples, data = split(str, "|")
   Entry(parse_seg_seq(samples), parse_seg_seq(data))
end

function is_1478(ss::Segs)
   n = count(ss.on)
   n == 2 || n == 3 || n == 4 || n == 7
end

part1_count(e::Entry) = count(is_1478, e.data)

do_part1(path) = open(path) do io
   sum(part1_count(parse(Entry, line)) for line = eachline(io))
end
