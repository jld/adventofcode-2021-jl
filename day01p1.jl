sonar = collect(parse(Int, x) for x = eachline(stdin))
println(count(sonar[1:end-1] .< sonar[2:end]))
winds = sonar[1:end-2] .+ sonar[2:end-1] .+ sonar[3:end]
println(count(winds[1:end-1] .< winds[2:end]))
