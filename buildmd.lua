local json = require("json")
local root = "docs"

function trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function markdown_files(path)
	local t = {}
	local i = 0
	local addIfmd = function(fName)
		if fName:find(".md") then
			i = i + 1
			t[i] = fName
			print("Adding file "..fName)
		end
	end
	if arg[1] == "ghaction" then
		local lfs = require"lfs"
		for fileName in lfs.dir(path) do
			addIfmd(fileName)
		end
	else
		local popen = io.popen
		local cmd
		if WINDOWS then
			cmd = "for /R %i in ("..path.."/*.*) do @echo "..path.."/%~nsxi"
		else
			cmd = "find "..path.." -maxdepth 1 -type d"
		end
		local pipe = popen(cmd)
		if pipe then
			for fileName in pipe:lines() do
				addIfmd(fileName)
			end
			pipe:close()
		end
	end
	return t
end

function read_md(path, md, search)
	local s, e, _
	_, s = md:find("%-%-%-")
	e, _ = md:find("%-%-%-", s)
	if s and e then
		local info = {
			title = "",
			description = "",
			tags = "",
			image = "",
			author = "Brent Farris",
			date = "0000-00-00"
		}
		local head = trim(md:sub(s, e))
		for k, v in pairs(info) do
			local l, r = head:find(k..":.-\n")
			if l and not r then
				r = e-1
			end
			if l and r then
				info[k] = trim(head:sub(l + #k + 1, r))
			end
		end
		info.path = path:gsub("^"..root, ""):gsub("%.md$", "")
		search[#search+1] = info
	end
end

local search = {}
local all = markdown_files(root)
for i=1, #all do
	local f = assert(io.open(all[i], "r"))
	if f then
		local md = f:read("*all")
		assert(f:close())
		read_md(all[i], md, search)
	end
end

local fout = assert(io.open(root.."/md.json", "w"))
fout:write(json.encode(search))
assert(fout:close())