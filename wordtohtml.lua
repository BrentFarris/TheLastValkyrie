local path = arg[1]
assert(#path > 0, "File was expected to be supplied")
local folder = path
if path:find(".html") == (#path - 4) then
	local slash = path:find("/[^/]*$")
	folder = path:sub(1, slash-1)
end
package.path = "./"..folder.."/?.lua;"..package.path

---trim
---@param str string
---@return string
function trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
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
	local l, r = src:find("<a%s?%s?href=\"https://www.youtube.com/embed/.-</a>")
	while l and r do
		local el, er = src:find("https://www.youtube.com/embed/%g+?", l)
		local href = src:sub(el, er-1)
		local yt = '<iframe width="560" height="315" src="'..href..'" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'
		src = src:sub(0, l-1)..yt..src:sub(r+1)
		l, r = src:find("<a%s?%s?href=\"https://www.youtube.com/embed/.-</a>")
	end
	return src
end

function remove_comments(html)
	return html:gsub("<!%-%-.-%-%->", "")
end

function remove_if_comments(html)
	return html:gsub("<!%-%-%[if.-%-%->", "")
end

local info = {
	site = "Brent's Website",
	author = "Brent Farris",
	title = "Some Assembly required",
	description = "A personal log about things I like in computer programming, art, electronics, and other hobbies.",
	image = "https://retroscience.net/Changing-the-Buttons-on-a-Game-Boy-Advance/view_files/image011.jpg",
	url = "https://retroscience.net"
}
local infoFile = io.open(folder.."/info.lua", "r")
if infoFile then
	assert(infoFile:close())
	local mergeInfo = require(folder.."/info")
	for k,v in pairs(mergeInfo) do
		info[k] = v
	end
end

local head = [[
<!DOCTYPE html>
<html lang="en">
 <head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>]]..info.title..[[ | ]]..info.site..[[</title>
  <meta property="og:title" content="]]..info.title..[[">
  <meta name="author" content="]]..info.author..[[">
  <meta property="og:locale" content="en_US">
  <meta name="description" content="]]..info.description..[[">
  <meta property="og:description" content="]]..info.description..[[">
  <link rel="canonical" href="]]..info.url..[[">
  <meta property="og:url" content="]]..info.url..[[">
  <meta property="og:site_name" content="]]..info.site..[[">
  <meta property="og:image" content="]]..info.image..[[">
  <meta property="og:type" content="website">
  <meta name="twitter:card" content="summary_large_image">
  <meta property="twitter:image" content="]]..info.image..[[">
  <meta property="twitter:title" content="]]..info.title..[[">
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"WebPage","author":{"@type":"Person","name":"]]..info.author..[["},"description":"]]..info.description..[[","headline":"]]..info.title..[[","image":"]]..info.image..[[","url":"]]..info.url..[["}</script>
  <link rel="stylesheet" href="../style.css">
]]

local chinIn = assert(io.open("chin.html", "r"))
local chin = remove_comments(chinIn:read("*all"))
assert(chinIn:close())

local htmlIn = assert(io.open(path, "r"))
local html = htmlIn:read("*all")
assert(htmlIn:close())

local footIn = assert(io.open("foot.html", "r"))
local foot = remove_comments(footIn:read("*all"))
assert(footIn:close())

local addHead = extract(remove_if_comments(html), "head")
local addBody = embed_youtube(extract(remove_comments(html), "body"))

local fout = assert(io.open(folder.."/index.html", "w"))
fout:write(head..addHead..chin..addBody..foot)
assert(fout:close())
