sonar = collect(parse(Int, x) for x = eachline(stdin))
println(count(sonar[1:end-1] .< sonar[2:end]))
