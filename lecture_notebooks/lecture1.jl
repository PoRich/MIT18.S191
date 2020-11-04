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

# ╔═╡ 25f4a6a4-136d-11eb-3d64-43f4ad2d3722
begin
	#using Pkg  # only needs to happen once
	#Pkg.add.(["Images", "ImageIO", "ImageMagick", "Interact", "IJulia", "WebIO])  # only needs to happen once
	using Images, Interact, WebIO
	#import PlutoUI
	#WebIO.install_jupyter_nbextension()
end

# ╔═╡ d4ce0ed6-1331-11eb-0ea3-610426f55bb3
url = "https://i.imgur.com/VGPeJ6s.jpg"

# ╔═╡ 3e6c3fdc-1332-11eb-198c-25fa59f09485
download(url, "philip.jpg") 

# ╔═╡ 78da1c36-1332-11eb-1f24-af0239f26f81
philip = load("philip.jpg")

# ╔═╡ 03c87d42-1333-11eb-22b4-6d99c66ddcef
typeof(philip)

# ╔═╡ fb74c060-1332-11eb-1f87-991e758638ed
RGBX(0.5, 0.25, .8)

# ╔═╡ 75e623bc-1337-11eb-0a5a-8d032759ba94
begin 
	(h, w) = size(philip)
	head = philip[(h ÷ 2): h, (w ÷10): (9w ÷10)]
end

# ╔═╡ bb09c872-1337-11eb-3561-25e75eac9759
[
	head  	reverse(head, dims=2)
	reverse(head, dims=1) 	reverse(reverse(head, dims=1), dims=2)
]

# ╔═╡ e1de92ca-1337-11eb-0eea-4d064b8c22b5
begin
	new_philip2 = copy(philip)
	new_philip2[100:400, 1:100] .= RGB(1, 0, 0)  # .= is broadcast
	new_philip2
end

# ╔═╡ c3db936a-137e-11eb-24d1-9fa0c2438cb5
begin
	intensity= 0.89
	#@bind intensity slider(0:1, show_value=true)
end

# ╔═╡ 367dceb8-1338-11eb-21f6-dfb8b9bdb1d2
function blueify(color)
	return RGB(0, 0, color.b) * intensity
end

# ╔═╡ c827f38e-1338-11eb-35ec-3d2337de236e
function greenify(color)
	return RGB(0, color.g, 0) * intensity
end

# ╔═╡ 5120ef7a-1338-11eb-2dfd-bf94992c7410
begin
	color = RGB(0.8, .5, .2)
	[color, blueify(color)]
end

# ╔═╡ b1997ba6-1338-11eb-097c-6b00a19cc00b
[blueify.(new_philip2) greenify.(new_philip2)]

# ╔═╡ c7a5470c-136c-11eb-0d6e-f595539e2809
md"""
# A Concrete First Taste at abstraction
> will soon write functions that shouldn't care what type its input is 
"""

# ╔═╡ e31856ca-1338-11eb-2755-8d8880802448
element = [1 2; 3 4]

# ╔═╡ 3ebbf990-136c-11eb-30be-5f837fce02fe
fill(element, 3, 4)

# ╔═╡ 45c9d5b8-136c-11eb-0f52-0d0bde7c3265
typeof(element)

# ╔═╡ 6ed45d42-136f-11eb-2514-9b59087f3444
cute_one = load(download("https://clipartstation.com/wp-content/uploads/2017/11/number-1-clipart.png"))

# ╔═╡ 65d03262-136c-11eb-12fa-0f3dd49f88fe
keeptrack = [ typeof(1), typeof(1.0), typeof("one"), typeof(1//1), typeof(cute_one),  typeof([1 2; 3 4])]

# ╔═╡ 7732a2c6-136f-11eb-2c4d-cd300be16cd5
md"""
#Intro to Arrays
"""

# ╔═╡ 1daefbc4-1378-11eb-2f90-792208acd525
v = [1, 2, 3, 4]

# ╔═╡ bc77481a-1378-11eb-1517-757208683cde
x = [1 2 3 4
	 5 6 7 8]

# ╔═╡ d5519b88-1378-11eb-213e-675133f3f481
x[:, 1:2]  # 1 indexing not zero

# ╔═╡ 1ddd8c36-1379-11eb-14a0-690b16f375b6
A1 = rand(1:9, 3,4)

# ╔═╡ 2fe4b08a-1379-11eb-0573-39e76cceb158
size(A1)

# ╔═╡ 547e5f7c-1379-11eb-14a9-e5716ad9e6e4
A2 = string.(rand("🎅🕵💂👴🌂👑😻🙀👨‍👨‍👦‍👦👚👜💍🙉🐦🐠🐟", 3, 4)) 

# ╔═╡ e56c83ba-1379-11eb-1d4a-7f20f5048d8f
colors = distinguishable_colors(40)

# ╔═╡ acdecc92-1379-11eb-260b-fd166ce2f619
A3 = rand(colors, 10, 10)

# ╔═╡ a59a23e6-1379-11eb-29cf-13c5aa5fdec5
snoopy = load(download("https://cdn.theatlantic.com/assets/media/img/2015/09/30/BOB_Boxer_Peanuts_Opener_HP/1920.jpg?1443632690"))

# ╔═╡ 2d09cf30-1379-11eb-2188-b1c27f43ac32
shiba = load(download("https://animalsbreeds.com/wp-content/uploads/2014/11/Shiba-Inu-3.jpg"))

# ╔═╡ e53c9cde-137b-11eb-2ea9-51e99486f5b1
A4 = rand([shiba, snoopy], 5,6)

# ╔═╡ 73dd8586-137c-11eb-215d-9784037b576f
begin
	B1 = copy(A1)
	B1[1,1] = 123
	B1
end

# ╔═╡ 9dc4ee1e-137c-11eb-1cbb-97c857588406
begin
	C = fill(snoopy, 3,3)
	C[1,1] = shiba
	C
end

# ╔═╡ c3dafa94-137c-11eb-2804-91fc0f2d58ec
D = [i*j for i=1:5, j=1:5]  #multiplication table via comprehension 

# ╔═╡ f46d4518-137c-11eb-37c0-19b3523f9f9b
begin
	E = fill(0, 5, 5)
	for i=1:5, j=1:5  # double loop, no semi-colon
		E[i,j] = i*j
	end  # close for loops with an end
	E
end

# ╔═╡ 4abc6e6c-137d-11eb-2254-7f50e39a5d2a
begin 
	F = fill(0, 5,5)
	for i=1:5
		for j=1:5
			F[i,j] = i*j
		end
	end
	F
end

# ╔═╡ 992dfce6-137d-11eb-0e17-f1669b62c0db
D.^2  # square every element

# ╔═╡ dd9880a4-137d-11eb-2c3f-3563115d7457
D^2  # matrix multiplied

# ╔═╡ 0e427296-137e-11eb-231d-c5bb582dfa25
[A1 A1]  #concatenate along dim=2

# ╔═╡ 40cdbd24-137e-11eb-25fb-4d7a05f8ffbb
[A2; A1]  # concatenate along dim=1


# ╔═╡ 56523ed6-137e-11eb-22cb-610d790ce56c
[A3 A3 ; A3 A3]

# ╔═╡ Cell order:
# ╠═25f4a6a4-136d-11eb-3d64-43f4ad2d3722
# ╠═d4ce0ed6-1331-11eb-0ea3-610426f55bb3
# ╠═3e6c3fdc-1332-11eb-198c-25fa59f09485
# ╠═78da1c36-1332-11eb-1f24-af0239f26f81
# ╠═03c87d42-1333-11eb-22b4-6d99c66ddcef
# ╠═fb74c060-1332-11eb-1f87-991e758638ed
# ╠═75e623bc-1337-11eb-0a5a-8d032759ba94
# ╠═bb09c872-1337-11eb-3561-25e75eac9759
# ╠═e1de92ca-1337-11eb-0eea-4d064b8c22b5
# ╠═c3db936a-137e-11eb-24d1-9fa0c2438cb5
# ╠═367dceb8-1338-11eb-21f6-dfb8b9bdb1d2
# ╠═c827f38e-1338-11eb-35ec-3d2337de236e
# ╠═5120ef7a-1338-11eb-2dfd-bf94992c7410
# ╠═b1997ba6-1338-11eb-097c-6b00a19cc00b
# ╠═c7a5470c-136c-11eb-0d6e-f595539e2809
# ╠═e31856ca-1338-11eb-2755-8d8880802448
# ╠═3ebbf990-136c-11eb-30be-5f837fce02fe
# ╠═45c9d5b8-136c-11eb-0f52-0d0bde7c3265
# ╠═65d03262-136c-11eb-12fa-0f3dd49f88fe
# ╠═6ed45d42-136f-11eb-2514-9b59087f3444
# ╠═7732a2c6-136f-11eb-2c4d-cd300be16cd5
# ╠═1daefbc4-1378-11eb-2f90-792208acd525
# ╠═bc77481a-1378-11eb-1517-757208683cde
# ╠═d5519b88-1378-11eb-213e-675133f3f481
# ╠═1ddd8c36-1379-11eb-14a0-690b16f375b6
# ╠═2fe4b08a-1379-11eb-0573-39e76cceb158
# ╠═547e5f7c-1379-11eb-14a9-e5716ad9e6e4
# ╠═e56c83ba-1379-11eb-1d4a-7f20f5048d8f
# ╠═acdecc92-1379-11eb-260b-fd166ce2f619
# ╠═a59a23e6-1379-11eb-29cf-13c5aa5fdec5
# ╠═2d09cf30-1379-11eb-2188-b1c27f43ac32
# ╠═e53c9cde-137b-11eb-2ea9-51e99486f5b1
# ╠═73dd8586-137c-11eb-215d-9784037b576f
# ╠═9dc4ee1e-137c-11eb-1cbb-97c857588406
# ╠═c3dafa94-137c-11eb-2804-91fc0f2d58ec
# ╠═f46d4518-137c-11eb-37c0-19b3523f9f9b
# ╠═4abc6e6c-137d-11eb-2254-7f50e39a5d2a
# ╠═992dfce6-137d-11eb-0e17-f1669b62c0db
# ╠═dd9880a4-137d-11eb-2c3f-3563115d7457
# ╠═0e427296-137e-11eb-231d-c5bb582dfa25
# ╠═40cdbd24-137e-11eb-25fb-4d7a05f8ffbb
# ╠═56523ed6-137e-11eb-22cb-610d790ce56c
