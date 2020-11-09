### A Pluto.jl notebook ###
# v0.12.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 2b37ca3a-0970-11eb-3c3d-4f788b411d1a
begin
	using Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 2dcb18d0-0970-11eb-048a-c1734c6db842
begin
	Pkg.add(["PlutoUI", "Plots"])

	using Plots
	gr()
	using PlutoUI
	using Logging
	using StatsBase
end

# ╔═╡ 19fe1ee8-0970-11eb-2a0d-7d25e7d773c6
md"_homework 5, version 0_"

# ╔═╡ 49567f8e-09a2-11eb-34c1-bb5c0b642fe8
# WARNING FOR OLD PLUTO VERSIONS, DONT DELETE ME

html"""
<script>
const warning = html`
<h2 style="color: #800">Oopsie! You need to update Pluto to the latest version for this homework</h2>
<p>Close Pluto, go to the REPL, and type:
<pre><code>julia> import Pkg
julia> Pkg.update("Pluto")
</code></pre>
`

const super_old = window.version_info == null || window.version_info.pluto == null
if(super_old) {
	return warning
}
const version_str = window.version_info.pluto.substring(1)
const numbers = version_str.split(".").map(Number)
console.log(numbers)

if(numbers[0] > 0 || numbers[1] > 12 || numbers[2] > 1) {
	
} else {
	return warning
}

</script>

"""

# ╔═╡ 181e156c-0970-11eb-0b77-49b143cc0fc0
md"""

# **Homework 5**: _Epidemic modeling II_
`18.S191`, fall 2020

This notebook contains _built-in, live answer checks_! In some exercises you will see a coloured box, which runs a test case on your code, and provides feedback based on the result. Simply edit the code, run it, and the check runs again.

_For MIT students:_ there will also be some additional (secret) test cases that will be run as part of the grading process, and we will look at your notebook and write comments.

Feel free to ask questions!
"""

# ╔═╡ 1f299cc6-0970-11eb-195b-3f951f92ceeb
# edit the code below to set your name and kerberos ID (i.e. email without @mit.edu)

student = (name = "PoorRichRE", kerberos_id = "jazz")

# you might need to wait until all other cells in this notebook have completed running. 
# scroll around the page to see what's up

# ╔═╡ 1bba5552-0970-11eb-1b9a-87eeee0ecc36
md"""

Submission by: **_$(student.name)_** ($(student.kerberos_id)@gmail.com)
"""

# ╔═╡ 2848996c-0970-11eb-19eb-c719d797c322
md"_Let's create a package environment:_"

# ╔═╡ 69d12414-0952-11eb-213d-2f9e13e4b418
md"""
In this problem set, we will look at a simple **spatial** agent-based epidemic model: agents can interact only with other agents that are *nearby*.  (In the previous homework any agent could interact with any other, which is not realistic.)

A simple approach is to use **discrete space**: each agent lives
in one cell of a square grid. For simplicity we will allow no more than
one agent in each cell, but this requires some care to
design the rules of the model to respect this.

We will adapt some functionality from the previous homework. You should copy and paste your code from that homework into this notebook.
"""

# ╔═╡ 3e54848a-0954-11eb-3948-f9d7f07f5e23
md"""
## **Exercise 1:** _Wandering at random in 2D_

In this exercise we will implement a **random walk** on a 2D lattice (grid). At each time step, a walker jumps to a neighbouring position at random (i.e. chosen with uniform probability from the available adjacent positions).

"""

# ╔═╡ 3e623454-0954-11eb-03f9-79c873d069a0
md"""
#### Exercise 1.1
We define a struct type `Coordinate` that contains integers `x` and `y`.
"""

# ╔═╡ 0ebd35c8-0972-11eb-2e67-698fd2d311d2
struct Coordinate
	x::Int64 
	y::Int64
end

# ╔═╡ 027a5f48-0a44-11eb-1fbf-a94d02d0b8e3
md"""
👉 Construct a `Coordinate` located at the origin.
"""

# ╔═╡ b2f90634-0a68-11eb-1618-0b42f956b5a7
origin = Coordinate(0,0)

# ╔═╡ 3e858990-0954-11eb-3d10-d10175d8ca1c
md"""
👉 Write a function `make_tuple` that takes an object of type `Coordinate` and returns the corresponding tuple `(x, y)`. Boring, but useful later!
"""

# ╔═╡ 189bafac-0972-11eb-1893-094691b2073c
function make_tuple(c::Coordinate)
	return (c.x, c.y)
end

# ╔═╡ 73ed1384-0a29-11eb-06bd-d3c441b8a5fc
md"""
#### Exercise 1.2
In Julia, operations like `+` and `*` are just functions, and they are treated like any other function in the language. The only special property you can use the _infix notation_: you can write
```julia
1 + 2
```
instead of 
```julia
+(1, 2)
```
_(There are [lots of special 'infixable' function names](https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm#L23-L24) that you can use for your own functions!)_

When you call it with the prefix notation, it becomes clear that it really is 'just another function', with lots of predefined methods.
"""

# ╔═╡ 96707ef0-0a29-11eb-1a3e-6bcdfb7897eb
+(1, 2)

# ╔═╡ b0337d24-0a29-11eb-1fab-876a87c0973f
+

# ╔═╡ 9c9f53b2-09ea-11eb-0cda-639764250cee
md"""
> #### Extending + in the wild
> Because it is a function, we can add our own methods to it! This feature is super useful in general languages like Julia and Python, because it lets you use familiar syntax (`a + b*c`) on objects that are not necessarily numbers!
> 
> One example we've see before is the `RGB` type in Homework 1. You are able to do:
> ```julia
> 0.5 * RGB(0.1, 0.7, 0.6)
> ```
> to multiply each color channel by $0.5$. This is possible because `Images.jl` [wrote a method](https://github.com/JuliaGraphics/ColorVectorSpace.jl/blob/master/src/ColorVectorSpace.jl#L131):
> ```julia
> *(::Real, ::AbstractRGB)::AbstractRGB
> ```

👉 Implement addition on two `Coordinate` structs by adding a method to `Base.:+`
"""

# ╔═╡ e24d5796-0a68-11eb-23bb-d55d206f3c40
function Base.:+(a::Coordinate, b::Coordinate)
	
	return Coordinate(a.x + b.x, a.y + b.y)
end

# ╔═╡ ec8e4daa-0a2c-11eb-20e1-c5957e1feba3
Coordinate(3,4) + Coordinate(10,10) # uncomment to check + works

# ╔═╡ e144e9d0-0a2d-11eb-016e-0b79eba4b2bb
md"""
_Pluto has some trouble here, you need to manually re-run the cell above!_
"""

# ╔═╡ 71c358d8-0a2f-11eb-29e1-57ff1915e84a
md"""
#### Exercise 1.3
In our model, agents will be able to walk in 4 directions: up, down, left and right. We can define these directions as `Coordinate`s.
"""

# ╔═╡ 5278e232-0972-11eb-19ff-a1a195127297
# uncomment this:

possible_moves = [
 	Coordinate( 1, 0), 
 	Coordinate( 0, 1), 
 	Coordinate(-1, 0), 
 	Coordinate( 0,-1),
 ]

# ╔═╡ 71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
md"""
👉 `rand(possible_moves)` gives a random possible move. Add this to the coordinate `Coordinate(4,5)` and see that it moves to a valid neighbor.
"""

# ╔═╡ 69151ce6-0aeb-11eb-3a53-290ba46add96
Coordinate(4,5)+rand(possible_moves)

# ╔═╡ 3eb46664-0954-11eb-31d8-d9c0b74cf62b
md"""
We are able to make a `Coordinate` perform one random step, by adding a move to it. Great!

👉 Write a function `trajectory` that calculates a trajectory of a `Wanderer` `w` when performing `n` steps., i.e. the sequence of positions that the walker finds itself in.

Possible steps:
- Use `rand(possible_moves, n)` to generate a vector of `n` random moves. Each possible move will be equally likely.
- To compute the trajectory you can use either of the following two approaches:
  1. 🆒 Use the function `accumulate` (see the live docs for `accumulate`). Use `+` as the function passed to `accumulate` and the `w` as the starting value (`init` keyword argument). 
  1. Use a `for` loop calling `+`. 

"""

# ╔═╡ edf86a0e-0a68-11eb-2ad3-dbf020037019
"""Retuns resulting Coordinate after n::Int random steps, starting from w::Coordinate initial position"""
function trajectory(w::Coordinate, n::Int)
	return accumulate(+, rand(possible_moves, n); init=w)
end

# ╔═╡ 478309f4-0a31-11eb-08ea-ade1755f53e0
function plot_trajectory!(p::Plots.Plot, trajectory::Vector; kwargs...)
	plot!(p, make_tuple.(trajectory); 
		label=nothing, 
		linewidth=2, 
		linealpha=LinRange(1.0, 0.2, length(trajectory)),
		kwargs...)
end

# ╔═╡ 3ebd436c-0954-11eb-170d-1d468e2c7a37
md"""
#### Exercise 1.4
👉 Plot 10 trajectories of length 1000 on a single figure, all starting at the origin. Use the function `plot_trajectory!` as demonstrated above.

Remember from last week that you can compose plots like this:

```julia
let
	# Create a new plot with aspect ratio 1:1
	p = plot(ratio=1)

	plot_trajectory!(p, test_trajectory)      # plot one trajectory
	plot_trajectory!(p, another_trajectory)   # plot the second one
	...

	p
end
```
"""

# ╔═╡ b4d5da4a-09a0-11eb-1949-a5807c11c76c
md"""
#### Exercise 1.5
Agents live in a box of side length $2L$, centered at the origin. We need to decide (i.e. model) what happens when they reach the walls of the box (boundaries), in other words what kind of **boundary conditions** to use.

One relatively simple boundary condition is a **collision boundary**:

> Each wall of the box is a wall, modelled using "collision": if the walker tries to jump beyond the wall, it ends up at the position inside the box that is closest to the goal.

👉 Write a function `collide_boundary` which takes a `Coordinate` `c` and a size $L$, and returns a new coordinate that lies inside the box (i.e. ``[-L,L]\times [-L,L]``), but is closest to `c`. This is similar to `extend_mat` from Homework 1.
"""

# ╔═╡ 0237ebac-0a69-11eb-2272-35ea4e845d84
 function collide_boundary(c::Coordinate, L::Number)
	x0, y0 = 0,0  # placeholders for payload
	x0 = abs(c.x) <= L ? c.x : L  # if c is inside the LxL box
	x0 = (c.x < 0) & (x0 == L) ? -x0 : x0  # if c is outside the LxL box, handle signs
	y0 = abs(c.y) <= L ? c.y : L
	y0 = (c.y < 0) & (y0 == L) ? -y0 : y0
 	return Coordinate(x0, y0)
 end

# ╔═╡ ad832360-0a40-11eb-2857-e7f0350f3b12
collide_boundary(Coordinate(3,2), 10) # uncomment to test

# ╔═╡ b4ed2362-09a0-11eb-0be9-99c91623b28f
md"""
#### Exercise 1.6
👉  Implement a 3-argument method  of `trajectory` where the third argument is a size. The trajectory returned should be within the boundary (use `reflect_boundary` from above). You can still use `accumulate` with an anonymous function that makes a move and then reflects the resulting coordinate, or use a for loop.

"""

# ╔═╡ 0665aa3e-0a69-11eb-2b5d-cd718e3c7432

"Retuns resulting Coordinate after n::Int random steps, starting from w::Coordinate initial position within LxL boundaries "
function trajectory(c::Coordinate, n::Int, L::Number)
 	return [collide_boundary(x, L) for x in accumulate(+, rand(possible_moves, n); init=c)]
 end

# ╔═╡ 44107808-096c-11eb-013f-7b79a90aaac8
test_trajectory = trajectory(Coordinate(4,4), 2) # uncomment to test

# ╔═╡ 87ea0868-0a35-11eb-0ea8-63e27d8eda6e
try
	p = plot(ratio=1, size=(650,200))
	plot_trajectory!(p, test_trajectory; color="black", showaxis=false, axis=nothing, linewidth=4)
	p
catch
end

# ╔═╡ 51788e8e-0a31-11eb-027e-fd9b0dc716b5
let
		long_trajectory = trajectory(Coordinate(4,4), 1000)

 		p = plot(ratio=1)
 		plot_trajectory!(p, long_trajectory)
 		p
 	end

# ^ uncomment to visualize a trajectory

# ╔═╡ dcefc6fe-0a3f-11eb-2a96-ddf9c0891873
let
	p = plot(ratio=1)
	steps = 1000
	starting = Coordinate(0,0)
	for i in 1:10
		random_walk = trajectory(starting, steps, 30)
		plot_trajectory!(p, random_walk)
	end
	p
end

# ╔═╡ 61db7e60-204f-11eb-06b0-9d6495a63c94
trajectory(Coordinate(0,0), 10, 30)

# ╔═╡ 3ed06c80-0954-11eb-3aee-69e4ccdc4f9d
md"""
## **Exercise 2:** _Wanderering Agents_

In this exercise we will create Agents which have a location as well as some infection state information.

Let's define a type `Agent`. `Agent` contains a `position` (of type `Coordinate`), as well as a `status` of type `InfectionStatus` (as in Homework 4).)

(For simplicity we will not use a `num_infected` field, but feel free to do so!)
"""

# ╔═╡ 35537320-0a47-11eb-12b3-931310f18dec
@enum InfectionStatus S I R

# ╔═╡ fd6a5866-22a1-11eb-1afa-6f3ee870ae2c
abstract type AbstractAgent end

# ╔═╡ cf2f3b98-09a0-11eb-032a-49cc8c15e89c
# define agent struct here:
begin
	mutable struct Agent <: AbstractAgent
		status::InfectionStatus
		num_infected::Int64
		position::Coordinate
		path::Array  # coordinate history
	end

	Agent() = Agent(S, 0, Coordinate(0,0), [Coordinate(0,0)]) # default starting position is origin
	Agent(s::InfectionStatus, n::Int64, p::Coordinate) = Agent(s,n,p,[p]) # starting point will always be the first coordinate in path history
end

# ╔═╡ 814e888a-0954-11eb-02e5-0964c7410d30
md"""
#### Exercise 2.1
👉 Write a function `initialize` that takes parameters $N$ and $L$, where $N$ is the number of agents abd $2L$ is the side length of the square box where the agents live.

It returns a `Vector` of `N` randomly generated `Agent`s. Their coordinates are randomly sampled in the ``[-L,L] \times [-L,L]`` box, and the agents are all susceptible, except one, chosen at random, which is infectious.
"""

# ╔═╡ 0cfae7ba-0a69-11eb-3690-d973d70e47f4
 function initialize(N::Number, L::Number)
	agents = [Agent(S, 0, Coordinate(rand(-L:L),rand(-L:L))) for i in 1:N]
	rand(agents).status = I
 	return agents
 end

# ╔═╡ 1d0f8eb4-0a46-11eb-38e7-63ecbadbfa20
initialize(3, 10)

# ╔═╡ e0b0880c-0a47-11eb-0db2-f760bbbf9c11
# Color based on infection status
color(s::InfectionStatus) = if s == S
	"blue"
elseif s == I
	"red"
else
	"green"
end

# ╔═╡ b5a88504-0a47-11eb-0eda-f125d419e909
position(a::AbstractAgent) = last(a.path) #a.position # uncomment this line

# ╔═╡ 87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
color(a::AbstractAgent) = color(a.status) # uncomment this line

# ╔═╡ 49fa8092-0a43-11eb-0ba9-65785ac6a42f
md"""
#### Exercise 2.2
👉 Write a function `visualize` that takes in a collection of agents as argument, and the box size `L`. It should plot a point for each agent at its location, coloured according to its status.

You can use the keyword argument `c=color.(agents)` inside your call to the plotting function make the point colors correspond to the infection statuses. Don't forget to use `ratio=1`.
"""

# ╔═╡ 1ccc961e-0a69-11eb-392b-915be07ef38d
 function visualize(agents::Vector, L)
	scatter([c.x for c in position.(agents)],[c.y for c in position.(agents)], c=color.(agents), ratio=1)
 end

# ╔═╡ 1f96c80a-0a46-11eb-0690-f51c60e57c3f
let
	N = 20
	L = 10
	visualize(initialize(N, L), L) # uncomment this line!
end

# ╔═╡ f953e06e-099f-11eb-3549-73f59fed8132
md"""

### Exercise 3: Spatial epidemic model -- Dynamics

Last week we wrote a function `interact!` that takes two agents, `agent` and `source`, and an infection of type `InfectionRecovery`, which models the interaction between two agent, and possibly modifies `agent` with a new status.

This week, we define a new infection type, `CollisionInfectionRecovery`, and a new method that is the same as last week, except it **only infects `agent` if `agents.position==source.position`**.
"""	

# ╔═╡ e6dd8258-0a4b-11eb-24cb-fd5b3554381b
abstract type AbstractInfection end

# ╔═╡ de88b530-0a4b-11eb-05f7-85171594a8e8
struct CollisionInfectionRecovery <: AbstractInfection
	p_infection::Float64
	p_recovery::Float64
end

# ╔═╡ 80f39140-0aef-11eb-21f7-b788c5eab5c9
md"""

Write a function `interact!` that takes two `Agent`s and a `CollisionInfectionRecovery`, and:

- If the agents are at the same spot, causes a susceptible agent to communicate the desease from an infectious one with the correct probability.
- if the first agent is infectious, it recovers with some probability
"""

# ╔═╡ d1bcd5c4-0a4b-11eb-1218-7531e367a7ff
function interact!(agent::Agent, source::Agent, infection::CollisionInfectionRecovery)
	if agent.position == source.position
		# agents must be in the same location to interact
		if agent.status==S && source.status==I && rand() <= infection.p_infection
			# for potential infect, one must be S and the other I 
			agent.status = I
			source.num_infected += 1
		end
	elseif (agent.status == I)  && (rand() <= infection.p_recovery)
			agent.status = R 
	end
end

# ╔═╡ 34778744-0a5f-11eb-22b6-abe8b8fc34fd
md"""

#### Exercise 3.1
Your turn!

👉 Write a function `step!` that takes a vector of `Agent`s, a box size `L` and an `infection`. This that does one step of the dynamics on a vector of agents. 

- Choose an Agent `source` at random.

- Move the `source` one step, and use `collide_boundary` to ensure that our agent stays within the box.

- For all _other_ agents, call `interact!(other_agent, source, infection)`.

- return the array `agents` again.
"""

# ╔═╡ b8a1a6aa-2059-11eb-369a-7593ec2f2611
begin  # get the ending position after 10 steps in L=5 
	steps = 10
	L = 5
	agent=Agent()
	agent.path = append!(agent.path, trajectory(agent.position, steps, L))
	agent, position(agent)
end

# ╔═╡ 7a07ee6c-2066-11eb-2f6c-37cc195e1f6f
function rand_move!(agent::AbstractAgent, steps::Number, L::Number)
"""move agent in a random direction of steps::Number, within L::Number boundaries"""
	agent.path = append!(agent.path, trajectory(agent.position, steps, L))
	agent.position = position(agent)
end

# ╔═╡ 8477d7a6-2067-11eb-2f76-9d1fe5d12463
let  # test rand_move! function
a = Agent()
rand_move!(a, 1, 5)
a
end

# ╔═╡ 1fc3271e-0a45-11eb-0e8d-0fd355f5846b
md"""
#### Exercise 3.2
If we call `step!` `N` times, then every agent will have made one step, on average. Let's call this one _sweep_ of the simulation.

👉 Create a before-and-after plot of ``k_{sweeps}=1000`` sweeps. 

- Initialize a new vector of agents (`N=50`, `L=40`, `infection` is given as `pandemic` below). 
- Plot the state using `visualize`, and save the plot as a variable `plot_before`.
- Run `k_sweeps` sweeps.
- Plot the state again, and store as `plot_after`.
- Combine the two plots into a single figure using
```julia
plot(plot_before, plot_after)
```
"""

# ╔═╡ 18552c36-0a4d-11eb-19a0-d7d26897af36
pandemic = CollisionInfectionRecovery(0.5, 0.00001)

# ╔═╡ 4e7fd58a-0a62-11eb-1596-c717e0845bd5
@bind k_sweeps Slider(1:10000, default=1000)

# ╔═╡ e964c7f0-0a61-11eb-1782-0b728fab1db0
md"""
#### Exercise 3.3

Every time that you move the slider, a completely new simulation is created an run. This makes it hard to view the progress of a single simulation over time. So in this exercise, we we look at a single simulation, and plot the S, I and R curves.

👉 Plot the SIR curves of a single simulation, with the same parameters as in the previous exercise. Use `k_sweep_max = 10000` as the total number of sweeps.
"""

# ╔═╡ 4d83dbd0-0a63-11eb-0bdc-757f0e721221
k_sweep_max = 10000

# ╔═╡ daf7bdb8-21fb-11eb-17b7-2184fa6257f4
function plot_repeated_sims(simulation)
	n_time, n_sims = size(first(simulation).S)..., size(simulation)...
	left, right = plot(xlabel="time", ylabel="Number of agents Infected"), plot(xlabel="time", ylabel="R0")
	for sim in simulation
		plot!(left, 1:n_time, sim.I, alpha=0.5, label=nothing)
		plot!(right, 1:n_time, sim.R0, alpha=0.5, label=nothing)
	end
	i_mean = mean(reduce(hcat,[sim.I for sim in simulation]), dims=2)
	r0_mean = mean(reduce(hcat,[sim.R0 for sim in simulation]), dims=2)
	plot!(left, i_mean, lw=3, label=nothing)
	plot!(right, r0_mean, lw=3, label=nothing)
	plot(left,right, layout=(2,1))
end


# ╔═╡ 4b8bb8f8-2204-11eb-19b6-213dd240834d
function plot_repeated_sims2(simulation)
	n_time, n_sims = size(first(simulation).S)..., size(simulation)...
	p = plot(xlabel="time", ylabel="Number of agents")
	for sim in simulation
		plot!(p, 1:n_time, sim.I, alpha=0.5, label=nothing)
	end
	s_mean = mean(reduce(hcat,[sim.S for sim in simulation]), dims=2)
	i_mean = mean(reduce(hcat,[sim.I for sim in simulation]), dims=2)
	r_mean = mean(reduce(hcat,[sim.R for sim in simulation]), dims=2)
	plot!(p, s_mean, lw=3, label="S")
	plot!(p, i_mean, lw=3, label="I")
	plot!(p, r_mean, lw=3, label="R")
end


# ╔═╡ 201a3810-0a45-11eb-0ac9-a90419d0b723
md"""
#### Exercise 3.4 (optional)
Let's make our plot come alive! There are two options to make our visualization dynamic:

👉1️⃣ Precompute one simulation run and save its intermediate states using `deepcopy`. You can then write an interactive visualization that shows both the state at time $t$ (using `visualize`) and the history of $S$, $I$ and $R$ from time $0$ up to time $t$. $t$ is controlled by a slider.

👉2️⃣ Use `@gif` from Plots.jl to turn a sequence of plots into an animation. Be careful to skip about 50 sweeps between each animation frame, otherwise the GIF becomes too large.

This an optional exercise, and our solution to 2️⃣ is given below.
"""

# ╔═╡ 951d16a4-22a6-11eb-205c-655649fc75e7
let 
	N = 50
	for i in 1:50N
		println(i)
	end
end


# ╔═╡ 2031246c-0a45-11eb-18d3-573f336044bf
md"""
#### Exercise 3.5
👉  Using $L=20$ and $N=100$, experiment with the infection and recovery probabilities until you find an epidemic outbreak. (Take the recovery probability quite small.) Modify the two infections below to match your observations.
"""

# ╔═╡ 13eb29aa-2202-11eb-008a-9f7c7fb16437
p_recovery0 = 0.00005

# ╔═╡ ab75678c-21ff-11eb-171d-9fb13bde2dea
@bind p_infect0 Slider(0.0001:0.0001:0.75, default=0.15, show_value=true)

# ╔═╡ d8c7ce3c-21ff-11eb-3e12-0b52c2722a76
@bind p_infect1 Slider(0.0001:0.0001:0.75, default=0.55, show_value=true)

# ╔═╡ 63dd9478-0a45-11eb-2340-6d3d00f9bb5f
causes_outbreak = CollisionInfectionRecovery(0.15, p_recovery0)

# ╔═╡ 269955e4-0a46-11eb-02cc-1946dc918bfa
does_not_cause_outbreak = CollisionInfectionRecovery(0.55, p_recovery0)

# ╔═╡ 20477a78-0a45-11eb-39d7-93918212a8bc
md"""
#### Exercise 3.6
👉 With the parameters of Exercise 3.2, run 50 simulations. Plot $S$, $I$ and $R$ as a function of time for each of them (with transparency!). This should look qualitatively similar to what you saw in the previous homework. You probably need different `p_infection` and `p_recovery` values from last week. Why?
"""

# ╔═╡ b1b1afda-0a66-11eb-2988-752405815f95
need_different_parameters_because = md"""
The nature in which agents are interacting is fundamentally different, meaning the transmission of the diseases is fundamentally different. In the previous homework, agents interacted based on drawing from a uniform propbability distribution. In this homework, agents are interacting based on a random walk within a bounded space
"""

# ╔═╡ 05c80a0c-09a0-11eb-04dc-f97e306f1603
md"""
## **Exercise 4:** _Effect of socialization_

In this exercise we'll modify the simple mixing model. Instead of a constant mixing probability, i.e. a constant probability that any pair of people interact on a given day, we will have a variable probability associated with each agent, modelling the fact that some people are more or less social or contagious than others.
"""

# ╔═╡ b53d5608-0a41-11eb-2325-016636a22f71
md"""
#### Exercise 4.1
We create a new agent type `SocialAgent` with fields `position`, `status`, `num_infected`, and `social_score`. The attribute `social_score` represents an agent's probability of interacting with any other agent in the population.
"""

# ╔═╡ 1b5e72c6-0a42-11eb-3884-a377c72270c7
# struct SocialAgent here...
begin
	mutable struct SocialAgent <: AbstractAgent
		status::InfectionStatus
		num_infected::Int64
		position::Coordinate
		social_score::Float64
		path::Array  # coordinate history
	end

	SocialAgent() = SocialAgent(S, 0, Coordinate(0,0), rand(LinRange(0.1,0.5,10)), [Coordinate(0,0)]) # default starting position is origin
	SocialAgent(s::InfectionStatus, n::Int64, p::Coordinate) = SocialAgent(s,n,p, rand(LinRange(0.1,0.5,10)), [p]) # starting point will always be the first coordinate in path history
end

# ╔═╡ c704ea4c-0aec-11eb-2f2c-859c954aa520
md"""define the `position` and `color` methods for `SocialAgent` as we did for `Agent`. This will allow the `visualize` function to work. on both kinds of Agents"""

# ╔═╡ b554b654-0a41-11eb-0e0d-e57ff68ced33
md"""
👉 Create a function `initialize_social` that takes `N` and `L`, and creates N agents  within a 2L x 2L box, with `social_score`s chosen from 10 equally-spaced between 0.1 and 0.5. (see LinRange)
"""

# ╔═╡ 40c1c1d6-0a69-11eb-3913-59e9b9ec4332
 function initialize_social(N::Number, L::Number)
	agents = [SocialAgent(S, 0, 
						  Coordinate(rand(-L:L),rand(-L:L))) for i in 1:N]
	rand(agents).status = I
 	return agents
 end

# ╔═╡ 18ac9926-0aed-11eb-034f-e9849b71c9ac
md"""
Now that we have 2 agent types

1. let's create an AbstractAgent type
2. Go back in the notebook and make the agent types a subtype of AbstractAgent.

"""

# ╔═╡ b56ba420-0a41-11eb-266c-719d39580fa9
md"""
#### Exercise 4.2
Not all two agents who end up in the same grid point may actually interact in an infectious way -- they may just be passing by and do not create enough exposure for communicating the disease.

👉 Write a new `interact!` method on `SocialAgent` which adds together the social_scores for two agents and uses that as the probability that they interact in a risky way. Only if they interact in a risky way, the infection is transmitted with the usual probability.
"""

# ╔═╡ 465e918a-0a69-11eb-1b59-01150b4b0f36
function interact!(agent::SocialAgent, source::SocialAgent, infection::CollisionInfectionRecovery)
	# agents must be in the same location to interact
	if agent.position == source.position
		# model risky interaction
		if rand() <= (agent.social_score + source.social_score)
			# for potential infect, one must be S and the other I 
			if agent.status==S && source.status==I && rand() <= infection.p_infection
				agent.status = I
				source.num_infected += 1
			end
		end
	elseif (agent.status == I)  && (rand() <= infection.p_recovery)
			agent.status = R 
	end
end	



# ╔═╡ 739b2d74-2060-11eb-2d37-915d58e7cbdc
let  # test interact! function 
	agents = [Agent(S, 0, Coordinate(0,1)), Agent(I, 0, Coordinate(0,1))]
	interact!(agents[1], agents[2], CollisionInfectionRecovery(.5, .5))
	agents, position(agents[1])
end

# ╔═╡ 24fe0f1a-0a69-11eb-29fe-5fb6cbf281b8
 function step!(agents::Vector, L::Number, infection::AbstractInfection)
	# choose a source at random
	n_agents = length(agents)
	source_idx = rand(1:n_agents)
	source = agents[source_idx]
	# move the source by step
	step = 1
	#@debug "source=agent $(source_idx), start-$(source.position)"
	rand_move!(source, step, L)
	#@debug "end-$(source.position)"
	# interact source with all other agents
	for i in 1:n_agents
		if i != source_idx
			interact!(agents[i], source, infection)
		end
	end
 	return agents
 end

# ╔═╡ 82a8e428-205b-11eb-0ced-f7cfed2363de
let # test step! function with toy example
	infection = CollisionInfectionRecovery(1., 0.002)
	agents = [Agent(S, 0, Coordinate(0,0)), Agent(S, 0, Coordinate(1,1)), Agent(S, 0, Coordinate(1,1)), Agent(S, 0, Coordinate(1,1)), Agent(S, 0, Coordinate(1,1)), Agent(S, 0, Coordinate(1,1))]
	for i in 1:length(agents)
		step!(agents, 5, infection)
		@debug "$(i): $(agents)"
	end
	agents
end

# ╔═╡ fb6af654-2069-11eb-29a5-094f146b1773
function sweep!(agent::Vector{Agent}, infection::AbstractInfection, L::Number)
	for i in 1:length(agent)
		step!(agent, L, infection)
	end
end

# ╔═╡ 778c2490-0a62-11eb-2a6c-e7fab01c6822
let
 	N = 50  # number of agents
 	L = 40  # plot size boundaries
	agents = initialize(N,L) 
	infection = pandemic
 	plot_before = visualize(agents, L)
	for k in 1:k_sweeps
		# 1 sweep = N steps, where N = number of agents
		sweep!(agents, infection, L)
	end
 	plot_after = visualize(agents, L)	
 	plot(plot_before, plot_after)
 end

# ╔═╡ 241bcb52-21f8-11eb-368c-55b22942dab4
function simulation(N::Integer, L::Integer, T::Integer, infection::AbstractInfection)
	agents = initialize(N, L)
	# track S I R after each sweep
	results = (S=[], I=[], R=[], R0=[0.])
	for k in 1:T
		sweep!(agents, infection, L)
		# tally S, I, R
		push!(results.S, count([a.status == S  for a in agents]))
		push!(results.I, count([a.status == I  for a in agents]))
		push!(results.R, count([a.status == R  for a in agents]))
		# calculate R0
		if k>1
			if results.I[k] > 0
				push!(results.R0, results.I[k] / results.I[k-1])
			else
				push!(results.R0, 0)
			end
		end
	end
	return results
end

# ╔═╡ 7814b0f2-21f8-11eb-0020-2754416de7e9
let
	N=40
	results = simulation(N, 30, k_sweep_max, pandemic)
	left = plot(1:k_sweep_max, results.S, ylim=N, label="S")
	plot!(left, results.I, ylim=N, label="I")
	plot!(left, results.R, ylim=N, label="R")
	right = plot(1:k_sweep_max, results.R0, label="R0")
	plot(left, right)
end

# ╔═╡ 8a8cadfe-21fb-11eb-1fd5-2de0fb15f105
function repeat_simulations(N::Integer, L::Integer, T::Integer, infection::AbstractInfection, num_simulations::Integer)
	map(1:num_simulations) do _
		simulation(N, L, T, infection)
	end
end

# ╔═╡ 13f4b6ba-21f5-11eb-1bc3-870b87ea781c
let #not pandemic
N, L, T, n_sims = 100, 20, 500, 20
plot_repeated_sims(repeat_simulations(N, L, T, CollisionInfectionRecovery(p_infect0, p_recovery0), n_sims))
end

# ╔═╡ 3a78e27a-21ff-11eb-33de-cf13e9666c98
let #pandemic
N, L, T, n_sims = 100, 20, 500, 20
plot_repeated_sims(repeat_simulations(N, L, T, CollisionInfectionRecovery(p_infect1, p_recovery0), n_sims))
end

# ╔═╡ 601f4f54-0a45-11eb-3d6c-6b9ec75c6d4a
let #pandemic
N, L, T, n_sims = 50, 40, k_sweeps, 50
plot_repeated_sims2(repeat_simulations(N, L, T, pandemic, n_sims))
end

# ╔═╡ e5040c9e-0a65-11eb-0f45-270ab8161871
let
    N = 50
    L = 40

    agents = initialize(N, L)
    
    # initialize to empty arrays
    Ss, Is, Rs = Int[], Int[], Int[]
    
    Tmax = 200
    
    @gif for t in 1:Tmax
        for i in 1:50N
            step!(agents, L, pandemic)
        end

        #... track S, I, R in Ss Is and Rs
		sweep_result = StatsBase.countmap([agent.status for agent in agents])
		push!(Ss, get(sweep_result, S, 0))
		push!(Is, get(sweep_result, I, 0))
		push!(Rs, get(sweep_result, R, 0))
        
        left = visualize(agents, L)
    
        right = plot(xlim=(1,Tmax), ylim=(1,N), size=(600,300))
        plot!(right, 1:t, Ss, color=color(S), label="S")
        plot!(right, 1:t, Is, color=color(I), label="I")
        plot!(right, 1:t, Rs, color=color(R), label="R")
    
        plot(left, right)
    end
end

# ╔═╡ c2196a64-22aa-11eb-1a99-ed5d00076b60
let # test step! function with toy example
	infection = CollisionInfectionRecovery(1., 0.002)
	agents = [SocialAgent(I, 0, Coordinate(0,0)), SocialAgent(S, 0, Coordinate(1,1))]
	for i in 1:50
		step!(agents, 2, infection)
		@debug "$(i): $(agents)"
	end
	agents
end

# ╔═╡ ed54ac86-22ad-11eb-1555-8157a07a5f98
begin  # test rand_move! function on SocialAgent
a = SocialAgent()
rand_move!(a, 10, 5)
a
end

# ╔═╡ 9a04d940-22ae-11eb-3002-f5bbe764d725
position(a)

# ╔═╡ a885bf78-0a5c-11eb-2383-9d74c8765847
md"""
Make sure `step!`, `position`, `color`, work on the type `SocialAgent`. If `step!` takes an untyped first argument, it should work for both Agent and SocialAgent types without any changes. We actually only need to specialize `interact!` on SocialAgent.

#### Exercise 4.3
👉 Plot the SIR curves of the resulting simulation.

N = 50;
L = 40;
number of steps = 200

In each step call `step!` 50N times.
"""

# ╔═╡ 1f172700-0a42-11eb-353b-87c0039788bd
let
	N = 50
	L = 40

	global social_agents = initialize_social(N, L)
	Ss, Is, Rs = [], [], []
	
	Tmax = 200  # time period Tmax
	
	@gif for t in 1:Tmax
		# 1. Step! a lot
        for i in 1:100N  # for each time period step 100 sweeps
            step!(social_agents, L, pandemic)
        end
		# 2. Count S, I and R, push them to Ss Is Rs
		results = StatsBase.countmap([a.status for a in social_agents])
		push!(Ss, get(results, S, 0))
		push!(Is, get(results, I, 0))
		push!(Rs, get(results, R,0))
		
		# 3. call visualize on the agents,
		left = visualize(social_agents, L)
		# 4. place the SIR plot next to visualize.
		right = plot(xlim=(1,Tmax), ylim=(1,N))
		plot!(right, 1:t, Ss, color=color(S), label="S")
		plot!(right, 1:t, Is, color=color(I), label="I")
		plot!(right, 1:t, Rs, color=color(R), label="R")
		
		plot(left, right, size=(600,300)) # final plot
	end
end

# ╔═╡ b59de26c-0a41-11eb-2c67-b5f3c7780c91
md"""
#### Exercise 4.4
👉 Make a scatter plot showing each agent's `social_score` on one axis, and the `num_infected` from the simulation in the other axis. Run this simulation several times and comment on the results.
"""

# ╔═╡ 4e740430-22b3-11eb-0269-df3b4c2c422c
function plot_social_scores(sagents::Vector{SocialAgent})
	social_scores, num_infected = Float64[], Int[]
	for a in sagents
		push!(social_scores, a.social_score)
		push!(num_infected, a.num_infected)
	end
	scatter(social_scores, num_infected, xlabel="social score", ylabel="number infected")
end

# ╔═╡ faec52a8-0a60-11eb-082a-f5787b09d88c
plot_social_scores(social_agents)

# ╔═╡ b5b4d834-0a41-11eb-1b18-1bd626d18934
md"""
👉 Run a simulation for 100 steps, and then apply a "lockdown" where every agent's social score gets multiplied by 0.25, and then run a second simulation which runs on that same population from there.  What do you notice?  How does changing this factor form 0.25 to other numbers affect things?
"""

# ╔═╡ a83c96e2-0a5a-11eb-0e58-15b5dda7d2d2
let  # apply "lockdown"
	N = 50
	L = 40
	lockdown_factor = .75

	global lockdown_agents = initialize_social(N, L)
	for a in lockdown_agents
		a.social_score = a.social_score * lockdown_factor
	end
	
	Ss, Is, Rs = [], [], []
	
	Tmax = 200  # time period Tmax
	
	@gif for t in 1:Tmax
		# 1. Step! a lot
        for i in 1:100N  # for each time period step 100 sweeps
            step!(lockdown_agents, L, pandemic)
        end
		# 2. Count S, I and R, push them to Ss Is Rs
		results = StatsBase.countmap([a.status for a in lockdown_agents])
		push!(Ss, get(results, S, 0))
		push!(Is, get(results, I, 0))
		push!(Rs, get(results, R,0))
		
		# 3. call visualize on the agents,
		left = visualize(lockdown_agents, L)
		# 4. place the SIR plot next to visualize.
		right = plot(xlim=(1,Tmax), ylim=(1,N))
		plot!(right, 1:t, Ss, color=color(S), label="S")
		plot!(right, 1:t, Is, color=color(I), label="I")
		plot!(right, 1:t, Rs, color=color(R), label="R")
		
		plot(left, right, size=(600,300)) # final plot
	end
end

# ╔═╡ 0c39bc24-22b3-11eb-164b-9b1587564787
plot_social_scores(lockdown_agents)

# ╔═╡ d2097c72-22b7-11eb-358d-871bab0c6754
md""" 
>Incorporating a lockdown factor of 0.25 completely eliminates transmission. 
>Loosening the lockdown factor to 0.75 results in a small uptick in transmission but it avoids a pandemic outcome.
"""

# ╔═╡ 05fc5634-09a0-11eb-038e-53d63c3edaf2
md"""
## **Exercise 5:** (Optional) _Effect of distancing_

We can use a variant of the above model to investigate the effect of the
mis-named "social distancing"  
(we want people to be *socially* close, but *physically* distant).

In this variant, we separate out the two effects "infection" and
"movement": an infected agent chooses a
neighbouring site, and if it finds a susceptible there then it infects it
with probability $p_I$. For simplicity we can ignore recovery.

Separately, an agent chooses a neighbouring site to move to,
and moves there with probability $p_M$ if the site is vacant. (Otherwise it
stays where it is.)

When $p_M = 0$, the agents cannot move, and hence are
completely quarantined in their original locations.

👉 How does the disease spread in this case?

"""

# ╔═╡ 24c2fb0c-0a42-11eb-1a1a-f1246f3420ff


# ╔═╡ c7649966-0a41-11eb-3a3a-57363cea7b06
md"""
👉 Run the dynamics repeatedly, and plot the sites which become infected.
"""

# ╔═╡ 2635b574-0a42-11eb-1daa-971b2596ce44


# ╔═╡ c77b085e-0a41-11eb-2fcb-534238cd3c49
md"""
👉 How does this change as you increase the *density*
    $\rho = N / (L^2)$ of agents?  Start with a small density.

This is basically the [**site percolation**](https://en.wikipedia.org/wiki/Percolation_theory) model.

When we increase $p_M$, we allow some local motion via random walks.
"""

# ╔═╡ 274fe006-0a42-11eb-1869-29193bb84957


# ╔═╡ c792374a-0a41-11eb-1e5b-89d9de2cf1f9
md"""
👉 Investigate how this leaky quarantine affects the infection dynamics with
different densities.

"""

# ╔═╡ d147f7f0-0a66-11eb-2877-2bc6680e396d


# ╔═╡ 0e6b60f6-0970-11eb-0485-636624a0f9d7
if student.name == "Jazzy Doe"
	md"""
	!!! danger "Before you submit"
	    Remember to fill in your **name** and **Kerberos ID** at the top of this notebook.
	"""
end

# ╔═╡ 0a82a274-0970-11eb-20a2-1f590be0e576
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 0aa666dc-0970-11eb-2568-99a6340c5ebd
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 8475baf0-0a63-11eb-1207-23f789d00802
hint(md"""
After every sweep, count the values $S$, $I$ and $R$ and push! them to 3 arrays. 
""")

# ╔═╡ f9b9e242-0a53-11eb-0c6a-4d9985ef1687
hint(md"""
```julia
let
	N = 50
	L = 40

	x = initialize(N, L)
	
	# initialize to empty arrays
	Ss, Is, Rs = Int[], Int[], Int[]
	
	Tmax = 200
	
	@gif for t in 1:Tmax
		for i in 1:50N
			step!(x, L, pandemic)
		end

		#... track S, I, R in Ss Is and Rs
		
		left = visualize(x, L)
	
		right = plot(xlim=(1,Tmax), ylim=(1,N), size=(600,300))
		plot!(right, 1:t, Ss, color=color(S), label="S")
		plot!(right, 1:t, Is, color=color(I), label="I")
		plot!(right, 1:t, Rs, color=color(R), label="R")
	
		plot(left, right)
	end
end
```
""")

# ╔═╡ 0acaf3b2-0970-11eb-1d98-bf9a718deaee
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ 0afab53c-0970-11eb-3e43-834513e4632e
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 0b21c93a-0970-11eb-33b0-550a39ba0843
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ 0b470eb6-0970-11eb-182f-7dfb4662f827
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]

# ╔═╡ 0b6b27ec-0970-11eb-20c2-89515ee3ab88
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ ec576da8-0a2c-11eb-1f7b-43dec5f6e4e7
let
	# we need to call Base.:+ instead of + to make Pluto understand what's going on
	# oops
	if @isdefined(Coordinate)
		result = Base.:+(Coordinate(3,4), Coordinate(10,10))

		if result isa Missing
			still_missing()
		elseif !(result isa Coordinate)
			keep_working(md"Make sure that your return a `Coordinate`. 🧭")
		elseif result.x != 13 || result.y != 14
			keep_working()
		else
			correct()
		end
	end
end

# ╔═╡ 0b901714-0970-11eb-0b6a-ebe739db8037
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ 66663fcc-0a58-11eb-3568-c1f990c75bf2
if !@isdefined(origin)
	not_defined(:origin)
else
	let
		if origin isa Missing
			still_missing()
		elseif !(origin isa Coordinate)
			keep_working(md"Make sure that `origin` is a `Coordinate`.")
		else
			if origin == Coordinate(0,0)
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ ad1253f8-0a34-11eb-265e-fffda9b6473f
if !@isdefined(make_tuple)
	not_defined(:make_tuple)
else
	let
		result = make_tuple(Coordinate(2,1))
		if result isa Missing
			still_missing()
		elseif !(result isa Tuple)
			keep_working(md"Make sure that you return a `Tuple`, like so: `return (1, 2)`.")
		else
			if result == (2,1)
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ 058e3f84-0a34-11eb-3f87-7118f14e107b
if !@isdefined(trajectory)
	not_defined(:trajectory)
else
	let
		c = Coordinate(8,8)
		t = trajectory(c, 100)
		
		if t isa Missing
			still_missing()
		elseif !(t isa Vector)
			keep_working(md"Make sure that you return a `Vector`.")
		elseif !(all(x -> isa(x, Coordinate), t))
			keep_working(md"Make sure that you return a `Vector` of `Coordinate`s.")
		else
			if length(t) != 100
				almost(md"Make sure that you return `n` elements.")
			elseif 1 < length(Set(t)) < 90
				correct()
			else
				keep_working(md"Are you sure that you chose each step randomly?")
			end
		end
	end
end

# ╔═╡ 4fac0f36-0a59-11eb-03d0-632dc9db063a
if !@isdefined(initialize)
	not_defined(:initialize)
else
	let
		N = 200
		result = initialize(N, 1)
		
		if result isa Missing
			still_missing()
		elseif !(result isa Vector) || length(result) != N
			keep_working(md"Make sure that you return a `Vector` of length `N`.")
		elseif any(e -> !(e isa Agent), result)
			keep_working(md"Make sure that you return a `Vector` of `Agent`s.")
		elseif length(Set(result)) != N
			keep_working(md"Make sure that you create `N` **new** `Agent`s. Do not repeat the same agent multiple times.")
		elseif sum(a -> a.status == S, result) == N-1 && sum(a -> a.status == I, result) == 1
			if 8 <= length(Set(a.position for a in result)) <= 9
				correct()
			else
				keep_working(md"The coordinates are not correctly sampled within the box.")
			end
		else
			keep_working(md"`N-1` agents should be Susceptible, 1 should be Infectious.")
		end
	end
end

# ╔═╡ 61fec3d4-204f-11eb-23bb-a3a2fd09f9ac
trajectory(starting, steps, 30)

# ╔═╡ d5cb6b2c-0a66-11eb-1aff-41d0e502d5e5
bigbreak = html"<br><br><br><br>";

# ╔═╡ fcafe15a-0a66-11eb-3ed7-3f8bbb8f5809
bigbreak

# ╔═╡ ed2d616c-0a66-11eb-1839-edf8d15cf82a
bigbreak

# ╔═╡ e84e0944-0a66-11eb-12d3-e12ae10f39a6
bigbreak

# ╔═╡ e0baf75a-0a66-11eb-0562-938b64a473ac
bigbreak

# ╔═╡ Cell order:
# ╟─19fe1ee8-0970-11eb-2a0d-7d25e7d773c6
# ╠═1bba5552-0970-11eb-1b9a-87eeee0ecc36
# ╟─49567f8e-09a2-11eb-34c1-bb5c0b642fe8
# ╟─181e156c-0970-11eb-0b77-49b143cc0fc0
# ╠═1f299cc6-0970-11eb-195b-3f951f92ceeb
# ╟─2848996c-0970-11eb-19eb-c719d797c322
# ╠═2b37ca3a-0970-11eb-3c3d-4f788b411d1a
# ╠═2dcb18d0-0970-11eb-048a-c1734c6db842
# ╟─69d12414-0952-11eb-213d-2f9e13e4b418
# ╟─fcafe15a-0a66-11eb-3ed7-3f8bbb8f5809
# ╟─3e54848a-0954-11eb-3948-f9d7f07f5e23
# ╟─3e623454-0954-11eb-03f9-79c873d069a0
# ╠═0ebd35c8-0972-11eb-2e67-698fd2d311d2
# ╟─027a5f48-0a44-11eb-1fbf-a94d02d0b8e3
# ╠═b2f90634-0a68-11eb-1618-0b42f956b5a7
# ╟─66663fcc-0a58-11eb-3568-c1f990c75bf2
# ╟─3e858990-0954-11eb-3d10-d10175d8ca1c
# ╠═189bafac-0972-11eb-1893-094691b2073c
# ╟─ad1253f8-0a34-11eb-265e-fffda9b6473f
# ╟─73ed1384-0a29-11eb-06bd-d3c441b8a5fc
# ╠═96707ef0-0a29-11eb-1a3e-6bcdfb7897eb
# ╠═b0337d24-0a29-11eb-1fab-876a87c0973f
# ╟─9c9f53b2-09ea-11eb-0cda-639764250cee
# ╠═e24d5796-0a68-11eb-23bb-d55d206f3c40
# ╠═ec8e4daa-0a2c-11eb-20e1-c5957e1feba3
# ╟─e144e9d0-0a2d-11eb-016e-0b79eba4b2bb
# ╟─ec576da8-0a2c-11eb-1f7b-43dec5f6e4e7
# ╟─71c358d8-0a2f-11eb-29e1-57ff1915e84a
# ╠═5278e232-0972-11eb-19ff-a1a195127297
# ╟─71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
# ╠═69151ce6-0aeb-11eb-3a53-290ba46add96
# ╟─3eb46664-0954-11eb-31d8-d9c0b74cf62b
# ╠═edf86a0e-0a68-11eb-2ad3-dbf020037019
# ╠═44107808-096c-11eb-013f-7b79a90aaac8
# ╟─87ea0868-0a35-11eb-0ea8-63e27d8eda6e
# ╟─058e3f84-0a34-11eb-3f87-7118f14e107b
# ╠═478309f4-0a31-11eb-08ea-ade1755f53e0
# ╠═51788e8e-0a31-11eb-027e-fd9b0dc716b5
# ╟─3ebd436c-0954-11eb-170d-1d468e2c7a37
# ╠═dcefc6fe-0a3f-11eb-2a96-ddf9c0891873
# ╠═61db7e60-204f-11eb-06b0-9d6495a63c94
# ╟─b4d5da4a-09a0-11eb-1949-a5807c11c76c
# ╠═0237ebac-0a69-11eb-2272-35ea4e845d84
# ╠═ad832360-0a40-11eb-2857-e7f0350f3b12
# ╟─b4ed2362-09a0-11eb-0be9-99c91623b28f
# ╠═0665aa3e-0a69-11eb-2b5d-cd718e3c7432
# ╟─ed2d616c-0a66-11eb-1839-edf8d15cf82a
# ╟─3ed06c80-0954-11eb-3aee-69e4ccdc4f9d
# ╠═35537320-0a47-11eb-12b3-931310f18dec
# ╠═fd6a5866-22a1-11eb-1afa-6f3ee870ae2c
# ╠═cf2f3b98-09a0-11eb-032a-49cc8c15e89c
# ╟─814e888a-0954-11eb-02e5-0964c7410d30
# ╠═0cfae7ba-0a69-11eb-3690-d973d70e47f4
# ╠═1d0f8eb4-0a46-11eb-38e7-63ecbadbfa20
# ╟─4fac0f36-0a59-11eb-03d0-632dc9db063a
# ╠═e0b0880c-0a47-11eb-0db2-f760bbbf9c11
# ╠═b5a88504-0a47-11eb-0eda-f125d419e909
# ╠═87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
# ╟─49fa8092-0a43-11eb-0ba9-65785ac6a42f
# ╠═1ccc961e-0a69-11eb-392b-915be07ef38d
# ╠═1f96c80a-0a46-11eb-0690-f51c60e57c3f
# ╟─f953e06e-099f-11eb-3549-73f59fed8132
# ╠═e6dd8258-0a4b-11eb-24cb-fd5b3554381b
# ╠═de88b530-0a4b-11eb-05f7-85171594a8e8
# ╟─80f39140-0aef-11eb-21f7-b788c5eab5c9
# ╠═d1bcd5c4-0a4b-11eb-1218-7531e367a7ff
# ╠═739b2d74-2060-11eb-2d37-915d58e7cbdc
# ╟─34778744-0a5f-11eb-22b6-abe8b8fc34fd
# ╠═b8a1a6aa-2059-11eb-369a-7593ec2f2611
# ╠═7a07ee6c-2066-11eb-2f6c-37cc195e1f6f
# ╠═8477d7a6-2067-11eb-2f76-9d1fe5d12463
# ╠═24fe0f1a-0a69-11eb-29fe-5fb6cbf281b8
# ╠═82a8e428-205b-11eb-0ced-f7cfed2363de
# ╟─1fc3271e-0a45-11eb-0e8d-0fd355f5846b
# ╟─18552c36-0a4d-11eb-19a0-d7d26897af36
# ╠═4e7fd58a-0a62-11eb-1596-c717e0845bd5
# ╠═fb6af654-2069-11eb-29a5-094f146b1773
# ╠═778c2490-0a62-11eb-2a6c-e7fab01c6822
# ╟─e964c7f0-0a61-11eb-1782-0b728fab1db0
# ╠═4d83dbd0-0a63-11eb-0bdc-757f0e721221
# ╠═241bcb52-21f8-11eb-368c-55b22942dab4
# ╠═7814b0f2-21f8-11eb-0020-2754416de7e9
# ╠═8a8cadfe-21fb-11eb-1fd5-2de0fb15f105
# ╠═daf7bdb8-21fb-11eb-17b7-2184fa6257f4
# ╠═4b8bb8f8-2204-11eb-19b6-213dd240834d
# ╟─8475baf0-0a63-11eb-1207-23f789d00802
# ╟─201a3810-0a45-11eb-0ac9-a90419d0b723
# ╠═e5040c9e-0a65-11eb-0f45-270ab8161871
# ╠═951d16a4-22a6-11eb-205c-655649fc75e7
# ╟─f9b9e242-0a53-11eb-0c6a-4d9985ef1687
# ╟─2031246c-0a45-11eb-18d3-573f336044bf
# ╠═13eb29aa-2202-11eb-008a-9f7c7fb16437
# ╠═ab75678c-21ff-11eb-171d-9fb13bde2dea
# ╠═13f4b6ba-21f5-11eb-1bc3-870b87ea781c
# ╠═d8c7ce3c-21ff-11eb-3e12-0b52c2722a76
# ╠═3a78e27a-21ff-11eb-33de-cf13e9666c98
# ╠═63dd9478-0a45-11eb-2340-6d3d00f9bb5f
# ╠═269955e4-0a46-11eb-02cc-1946dc918bfa
# ╟─20477a78-0a45-11eb-39d7-93918212a8bc
# ╠═601f4f54-0a45-11eb-3d6c-6b9ec75c6d4a
# ╠═b1b1afda-0a66-11eb-2988-752405815f95
# ╟─e84e0944-0a66-11eb-12d3-e12ae10f39a6
# ╟─05c80a0c-09a0-11eb-04dc-f97e306f1603
# ╟─b53d5608-0a41-11eb-2325-016636a22f71
# ╠═1b5e72c6-0a42-11eb-3884-a377c72270c7
# ╟─c704ea4c-0aec-11eb-2f2c-859c954aa520
# ╟─b554b654-0a41-11eb-0e0d-e57ff68ced33
# ╠═40c1c1d6-0a69-11eb-3913-59e9b9ec4332
# ╟─18ac9926-0aed-11eb-034f-e9849b71c9ac
# ╟─b56ba420-0a41-11eb-266c-719d39580fa9
# ╠═465e918a-0a69-11eb-1b59-01150b4b0f36
# ╠═c2196a64-22aa-11eb-1a99-ed5d00076b60
# ╠═ed54ac86-22ad-11eb-1555-8157a07a5f98
# ╠═9a04d940-22ae-11eb-3002-f5bbe764d725
# ╟─a885bf78-0a5c-11eb-2383-9d74c8765847
# ╠═1f172700-0a42-11eb-353b-87c0039788bd
# ╟─b59de26c-0a41-11eb-2c67-b5f3c7780c91
# ╠═4e740430-22b3-11eb-0269-df3b4c2c422c
# ╠═faec52a8-0a60-11eb-082a-f5787b09d88c
# ╠═0c39bc24-22b3-11eb-164b-9b1587564787
# ╟─b5b4d834-0a41-11eb-1b18-1bd626d18934
# ╟─a83c96e2-0a5a-11eb-0e58-15b5dda7d2d2
# ╟─d2097c72-22b7-11eb-358d-871bab0c6754
# ╟─05fc5634-09a0-11eb-038e-53d63c3edaf2
# ╠═24c2fb0c-0a42-11eb-1a1a-f1246f3420ff
# ╟─c7649966-0a41-11eb-3a3a-57363cea7b06
# ╠═2635b574-0a42-11eb-1daa-971b2596ce44
# ╟─c77b085e-0a41-11eb-2fcb-534238cd3c49
# ╠═274fe006-0a42-11eb-1869-29193bb84957
# ╟─c792374a-0a41-11eb-1e5b-89d9de2cf1f9
# ╠═d147f7f0-0a66-11eb-2877-2bc6680e396d
# ╟─e0baf75a-0a66-11eb-0562-938b64a473ac
# ╟─0e6b60f6-0970-11eb-0485-636624a0f9d7
# ╟─0a82a274-0970-11eb-20a2-1f590be0e576
# ╟─0aa666dc-0970-11eb-2568-99a6340c5ebd
# ╟─0acaf3b2-0970-11eb-1d98-bf9a718deaee
# ╟─0afab53c-0970-11eb-3e43-834513e4632e
# ╟─0b21c93a-0970-11eb-33b0-550a39ba0843
# ╟─0b470eb6-0970-11eb-182f-7dfb4662f827
# ╟─0b6b27ec-0970-11eb-20c2-89515ee3ab88
# ╟─0b901714-0970-11eb-0b6a-ebe739db8037
# ╠═61fec3d4-204f-11eb-23bb-a3a2fd09f9ac
# ╟─d5cb6b2c-0a66-11eb-1aff-41d0e502d5e5
