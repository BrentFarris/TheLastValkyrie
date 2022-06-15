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

local htmlIn = assert(io.open(arg[1], "r"))
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
local addBody = extract(html, "body")

local slash = arg[1]:find("/[^/]*$")
local to = arg[1]:sub(1,slash).."index.html"

local fout = assert(io.open(to, "w"))
--local fout = assert(io.open("test.html", "w"))
fout:write(head..addHead..chin..addBody..foot)
assert(fout:close())
