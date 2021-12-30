struct Wires
   on::BitVector
end

Base.:(==)(a::Wires, b::Wires) = a.on == b.on

struct Entry
   samples::Vector{Wires}
   data::Vector{Wires}
end

function Base.parse(::Type{Wires}, str::AbstractString)
   on = falses(7)
   for c = str
      on[c - 'a' + 1] = true
   end
   Wires(on)
end

parse_seg_seq(str::AbstractString) = map(word -> parse(Wires, word), split(str))

function Base.parse(::Type{Entry}, str::AbstractString)
   samples, data = split(str, "|")
   Entry(parse_seg_seq(samples), parse_seg_seq(data))
end

# So I had this idea about using a BitMatrix to represent the mapping
# from segments to wires, and refining it down from all true; but I'll
# need the digits eventually, so I gave in and did an "expert system"

# 2 -> 1 (cf)
# 3 -> 7 (acf)
# 4 -> 4 (bcdf)
# 5 -> 235 (-bf, -be, -ce)
# 6 -> 069 (-d, -c, -e)
# 7 -> 8

# 5: if &1==2 then 3; else if &4==2 then 2; else 5
# 6: if &1==1 then 6, else if &4==3 then 0; else 9

struct Digits
   syms::Vector{Wires}
end

function find_digits(e::Entry)
   digits = Vector{Union{Wires,Missing}}(missing, 10)
   for sample = e.samples
      n = count(sample.on)
      if n == 2
         digits[begin+1] = sample
      elseif n == 3
         digits[begin+7] = sample
      elseif n == 4
         digits[begin+4] = sample
      elseif n == 7
         digits[begin+8] = sample
      end
   end
   for sample = e.samples
      n = count(sample.on)
      if n == 5
         if count(sample.on .& digits[begin+1].on) == 2
            digits[begin+3] = sample
         elseif count(sample.on .& digits[begin+4].on) == 2
            digits[begin+2] = sample
         else
            digits[begin+5] = sample
         end
      elseif n == 6
         if count(sample.on .& digits[begin+1].on) == 1
            digits[begin+6] = sample
         elseif count(sample.on .& digits[begin+4].on) == 3
            digits[begin+0] = sample
         else
            digits[begin+9] = sample
         end
      end
   end
   Digits(digits)
end

function xlate(e::Entry)
   dtab = find_digits(e)
   digits = map(d -> findfirst(isequal(d), dtab.syms) - 1, e.data)
   foldl((a,b) -> 10*a+b, digits; init=0)
end

xlate_lines(io) = [xlate(parse(Entry, line)) for line = eachline(io)]
xlate_file(path) = sum(open(xlate_lines, path))
