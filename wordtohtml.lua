local path = arg[1]
assert(#path > 0, "File was expected to be supplied")

---trim
---@param str string
---@return string
function trim(str)
	local _
	local res, _ = str:gsub("^%s*(.-)%s*$", "%1")
	return res
end

function extract(html, tag)
	local _, l0, r0, l1, r1
	l0, r0 = html:find("<"..tag)
	_, r0 = html:find(">", r0)
	l1, r1 = html:find("</"..tag..">")
	return trim(html:sub(r0+1, l1-1))
end

function embed_youtube(html)
	local src = html
	local l, r = src:find("<a%shref=\"https://www.youtube.com/embed/.-</a>")
	while l and r do
		local el, er = src:find("https://www.youtube.com/embed/%g+?", l)
		local href = src:sub(el, er-1)
		local yt = '<iframe width="560" height="315" src="'..href..'" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
		src = src:sub(0, l-1)..yt..src:sub(r+1)
		l, r = src:find("<a%shref=\"https://www.youtube.com/embed/.-</a>")
	end
	return src
end

local htmlIn = assert(io.open(path, "r"))
local html = htmlIn:read("*all")
assert(htmlIn:close())

local headIn = assert(io.open("head.html", "r"))
local head = headIn:read("*all")
assert(headIn:close())

local chinIn = assert(io.open("chin.html", "r"))
local chin = chinIn:read("*all")
assert(chinIn:close())

local footIn = assert(io.open("foot.html", "r"))
local foot = footIn:read("*all")
assert(footIn:close())

local addHead = extract(html, "head")
local addBody = embed_youtube(extract(html, "body"))

local slash = path:find("/[^/]*$")
local to = path:sub(1, slash).."index.html"

local fout = assert(io.open(to, "w"))
--local fout = assert(io.open("test.html", "w"))
fout:write(head..addHead..chin..addBody..foot)
assert(fout:close())
