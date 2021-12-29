struct HLine
   y::Int
   x1::Int
   x2::Int
   HLine(y, x1, x2) = new(y, min(x1, x2), max(x1, x2))
end

struct VLine
   x::Int
   y1::Int
   y2::Int
   VLine(x, y1, y2) = new(x, min(y1, y2), max(y1, y2))
end

struct DLine
   x0::Int
   dx::Int
   y1::Int
   y2::Int
   function DLine(x0, dx, y1, y2)
      if y1 <= y2
         new(x0, dx, y1, y2)
      else
         new(x0 + dx * (y1 - y2), -dx, y2, y1)
      end
   end
end

Line = Union{HLine, VLine, DLine}
Lines = Vector{Line}

function parse_line(line)
   m = match(r"^(\d+),(\d+) -> (\d+),(\d+)$", line)
   x1, y1, x2, y2 = map(s -> parse(Int, s), m.captures)
   if y1 == y2
      HLine(y1, x1, x2)
   elseif x1 == x2
      VLine(x1, y1, y2)
   elseif abs(x2 - x1) == abs(y2 - y1)
      DLine(x1, sign(x2 - x1), y1, y2)
   else
      throw(ArgumentError("unexpected line type"))
   end
end

parse_file(io) = collect(Line, map(parse_line, eachline(io)))

xmax(l::DLine) = l.dx < 0 ? l.x0 : l.x0 + l.dx * (l.y2 - l.y1)

bbox(l::HLine) = (l.x2, l.y)
bbox(l::VLine) = (l.x, l.y2)
bbox(l::DLine) = (xmax(l), l.y2)
bbox_plus(a::Tuple{Int,Int}, b::Tuple{Int,Int}) = max.(a, b)
bbox(ls::Lines) = reduce(bbox_plus, map(bbox, ls); init=(-1,-1))

struct Buffer
   one::BitMatrix
   two::BitMatrix
end

Buffer(xmax::Int, ymax::Int) = Buffer(falses(xmax+1, ymax+1), falses(xmax+1, ymax+1))
Buffer(bbox::Tuple{Int,Int}) = Buffer(bbox[1], bbox[2])

function set_bit!(b::Buffer, x0::Int, y0::Int)
   x = x0 + 1
   y = y0 + 1
   if b.one[x, y]
      b.two[x, y] = true
   end
   b.one[x, y] = true
end

function trace!(b::Buffer, l::HLine)
   for x = l.x1:l.x2
      set_bit!(b, x, l.y)
   end
end

function trace!(b::Buffer, l::VLine)
   for y = l.y1:l.y2
      set_bit!(b, l.x, y)
   end
end

function trace!(b::Buffer, l::DLine)
   x = l.x0
   for y = l.y1:l.y2
      set_bit!(b, x, y)
      x += l.dx
   end
end

trace!(b::Buffer, ls::Lines) = foreach(l -> trace!(b, l), ls)

function overlaps(ls::Lines)
   buf = Buffer(bbox(ls))
   trace!(buf, ls)
   count(buf.two)
end

get_answer(path) = overlaps(open(parse_file, path))
