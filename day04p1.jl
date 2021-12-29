read_draws(f) = map(s -> parse(Int, s), split(readline(f), ","))

function read_boards(f)
   acc = zeros(Int, 0)
   for line = eachline(f)
      append!(acc, map(s -> parse(Int, s), split(line)))
   end
   reshape(acc, 5, 5, :)
end

struct Game
   draws::Vector{Int}
   board::Array{Int, 3}
end

function read_game(f)
   d = read_draws(f)
   b = read_boards(f)
   Game(d, b)
end

function do_draws(g::Game, n)
   marked = falses(size(g.board))
   for draw = g.draws[begin:n]
      @. marked |= g.board == draw
   end
   marked
end

function score_board(board::Matrix{Int}, marked::BitMatrix, draw::Int)
   sum(@. board * !marked) * draw
end

function throw_bingo(g::Game)
   marked = falses(size(g.board))
   last_wins = falses(size(g.board)[3])
   for draw = g.draws
      @. marked |= g.board == draw
      hwins = vec(reduce(|, reduce(&, marked, dims=1), dims=2))
      vwins = vec(reduce(|, reduce(&, marked, dims=2), dims=1))
      wins = hwins .| vwins
      if all(identity, wins)
         lose = findfirst(!, last_wins)
         return score_board(g.board[:, :, lose], marked[:, :, lose], draw)
      end
      last_wins = wins
   end
   @assert(false)
   nothing
end

xbingo_file(path) = throw_bingo(open(read_game, path))
