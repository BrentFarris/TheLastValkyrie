local json = require("json")
local root = "docs"

package.path = "./"..root.."/?.lua;"..package.path

function dirs(path)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen("find "..path.." -maxdepth 1 -type d")
	for filename in pfile:lines() do
		local f = io.open(filename.."/index.html", "r")
		if f then
			assert(f:close())
			i = i + 1
			t[i] = filename
		end
	end
	pfile:close()
	return t
end

local all = dirs(root.."/")
local search = {}

local defaultInfo = {
	site = "Brent's Website",
	author = "Brent Farris",
	title = "Some Assembly required",
	description = "A personal log about things I like in computer programming, art, electronics, and other hobbies.",
	keywords = "Programming, Blog, Art, Tutorials, Electronics",
	image = "https://retroscience.net/Changing-the-Buttons-on-a-Game-Boy-Advance/view_files/image011.jpg",
	url = "https://retroscience.net"
}

for i=1, #all do
	local info = {}
        for k,v in pairs(defaultInfo) do
                info[k] = v
        end
	info.path = all[i]:sub(#(root.."/")+1)
	local pfile = io.popen("stat "..all[i].."/index.html | grep 'Birth:'")
	local stat = pfile:lines()()
	pfile:close()
	local sl, sr = stat:find("%d")
	info.stat = stat:sub(sl)
	local infoFile = io.open(all[i].."/info.lua", "r")
	if infoFile then
	        assert(infoFile:close())
	        local mergeInfo = require(all[i].."/info")
	        for k,v in pairs(mergeInfo) do
	                info[k] = v
	        end
	end
	search[#search+1] = info
end

print(json.encode(search))

local fout = assert(io.open(root.."/search.json", "w"))
fout:write(json.encode(search))
assert(fout:close())
