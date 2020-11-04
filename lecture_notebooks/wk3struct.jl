### A Pluto.jl notebook ###
# v0.12.4

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

# ╔═╡ 8ca235f6-17ad-11eb-2d23-edbd0e75351b
using PlutoUI, ColorSchemes, LinearAlgebra  # for with_terminal

# ╔═╡ 1ddbc5d2-17ab-11eb-290e-4d17d414f5ee
struct OneHot <: AbstractVector{Int}  # subtype of AbstractVector
	# representing a one-hot with 2 numbers
	n::Int  #size
	k::Int  #index
end

# ╔═╡ 63753bc8-17ab-11eb-2f39-f51bf9ee7476
Base.size(x::OneHot) = (x.n, )  # defines size(x), size is always meant to be a tuple

# ╔═╡ 77031e9e-17ab-11eb-37c2-47965c70d303
Base.getindex(x::OneHot, i::Int) = Int(x.k == i)  #defines x[i], checks if k == i

# ╔═╡ d376a272-17ab-11eb-05f0-9fbe4f7ed902
myonehotvector = OneHot(6,2)  # represented as vector

# ╔═╡ 0d7befae-17ac-11eb-3eec-c3c9b6f96393
with_terminal() do
	dump(myonehotvector)  # stored as 2 numbers 
end

# ╔═╡ 6e3da306-17ab-11eb-311d-85cef8b06138
myonehotvector[2], myonehotvector[3]

# ╔═╡ d603edfe-17ad-11eb-36e5-a9b1bd0dfb61
begin 
	show_image(M) = get.([ColorSchemes.rainbow], M ./maximum(M))
	show_image(x::AbstractVector) = show_image(x')
end

# ╔═╡ f7d1bf9c-17ad-11eb-39c6-2d9208eb9b78
@bind nn Slider(1:20, show_value=true)

# ╔═╡ 07adfd22-17ae-11eb-1e79-c976c08d3fd1
@bind kk Slider(1:nn, default=1, show_value=true)

# ╔═╡ 10ce1676-17ae-11eb-1e3c-eb3944f9fe7f
x = OneHot(nn, kk)

# ╔═╡ 16c47192-17ae-11eb-0ae4-dbe26cb03490
show_image(x)

# ╔═╡ e8154b68-17ae-11eb-29af-7b04b42ab651
md"""#Diagonal matrices"""

# ╔═╡ 98aa6e22-17af-11eb-3e9c-a3c15d9cfe1c
M = [5 0 0; 0 6 0; 0 0 -10]

# ╔═╡ 04b7bb34-17af-11eb-0515-87e395b52809
Diagonal(M)  # efficiently representing diagonal matrices

# ╔═╡ ff5e3e3a-17ae-11eb-0d8f-4f911a26b40c
with_terminal() do
	dump(M)
end

# ╔═╡ b14c4e28-17af-11eb-331e-d7af0823aa05
with_terminal() do 
	dump(Diagonal(M))
end

# ╔═╡ c2574ede-17af-11eb-325f-3f9006742b71
# sparse matrix representation means not storing zeros 
# 14minute

# ╔═╡ ad396a38-17b0-11eb-35fc-e7c8ba3e133f
md"""Random Vectors"""

# ╔═╡ be483d90-17b0-11eb-07fc-c1e3f43822bb
vv = rand(1:9, 1_000_000)

# ╔═╡ bd042894-17af-11eb-21d0-1b409574ce8d


# ╔═╡ f083e2b4-17ae-11eb-32fc-9fdcece86b30


# ╔═╡ eb0534f0-17ae-11eb-2f57-993c105daa8f


# ╔═╡ Cell order:
# ╠═8ca235f6-17ad-11eb-2d23-edbd0e75351b
# ╠═1ddbc5d2-17ab-11eb-290e-4d17d414f5ee
# ╠═63753bc8-17ab-11eb-2f39-f51bf9ee7476
# ╠═77031e9e-17ab-11eb-37c2-47965c70d303
# ╠═d376a272-17ab-11eb-05f0-9fbe4f7ed902
# ╠═0d7befae-17ac-11eb-3eec-c3c9b6f96393
# ╠═6e3da306-17ab-11eb-311d-85cef8b06138
# ╠═d603edfe-17ad-11eb-36e5-a9b1bd0dfb61
# ╠═f7d1bf9c-17ad-11eb-39c6-2d9208eb9b78
# ╠═07adfd22-17ae-11eb-1e79-c976c08d3fd1
# ╠═10ce1676-17ae-11eb-1e3c-eb3944f9fe7f
# ╠═16c47192-17ae-11eb-0ae4-dbe26cb03490
# ╠═e8154b68-17ae-11eb-29af-7b04b42ab651
# ╠═98aa6e22-17af-11eb-3e9c-a3c15d9cfe1c
# ╠═04b7bb34-17af-11eb-0515-87e395b52809
# ╠═ff5e3e3a-17ae-11eb-0d8f-4f911a26b40c
# ╠═b14c4e28-17af-11eb-331e-d7af0823aa05
# ╠═c2574ede-17af-11eb-325f-3f9006742b71
# ╠═ad396a38-17b0-11eb-35fc-e7c8ba3e133f
# ╠═be483d90-17b0-11eb-07fc-c1e3f43822bb
# ╠═bd042894-17af-11eb-21d0-1b409574ce8d
# ╠═f083e2b4-17ae-11eb-32fc-9fdcece86b30
# ╠═eb0534f0-17ae-11eb-2f57-993c105daa8f
