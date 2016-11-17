local cjson=require("cjson")

local _M = {}
--[[
	将一个lua变量转换为字符串
	可以让你更加清楚的看到这个变量里面到底存了什么内容

	@param value 要转换成字符串的变量

	@return 变量内容的字符串形式
--]]

local function to_str(value)
	local str = ''

	if type(value) ~= 'table' then
		if type(value) == 'string' then
			str = string.format("%q", value)
		else
			str = tostring(value)
		end
	else
		local auxTable = {}

		for key in pairs(value) do
			if tonumber(key) ~= key then
				table.insert(auxTable, key)
			else
				table.insert(auxTable, to_str(key))
			end
		end

		table.sort(auxTable)

		str = str .. '{'

		local separator = ""
		local entry = ""

		for _, fieldName in ipairs(auxTable) do
			if tonumber(fieldName) and tonumber(fieldName) > 0 then
				entry = to_str(value[tonumber(fieldName)])
			else
				entry = fieldName .. " = " .. to_str(value[fieldName])
			end
			str = str .. separator .. entry

			separator = ", "
		end

		str = str .. '}'

	end

	return str
end

function _M.log(obj, level)
	local logpath = string.format("/home/anlj/test/mycode/log%s.log", os.date("%Y%m%d"))
	local f, err = io.open(logpath, "a")
	if not f then
		return 
	end
	level = level or 2
	local debug_info = debug.getinfo(level, "Snl")

	local i, j = debug_info.short_src:find("[^/]+$")
	local filename = string.sub(debug_info.short_src, i, j)	
	local position = string.format("[%s, %d] ", filename, debug_info.currentline)
	
	local line = position.. to_str(obj) .. "\n"
	f:write(line)
	f:close()
end
local log = _M.log
local function getid(line)
	local cid = string.gsub(line, "^%[(.*)%] %[(.*)%] %[(.*)%] (.*)$", "%2")
	return cid
end
local function gettime(line)
	local cid = string.gsub(line, "^%[(.*)%] %[(.*)%] %[(.*)%] (.*)$", "%1")
	return cid
end
local function getfileinfo(line)
	local fileinfo = string.gsub(line, "^%[(.*)%] %[(.*)%] %[(.*)%] (.*)$", "%3")
	return fileinfo
end
local function getlogstr(line)
	local logstr = string.gsub(line, "^%[(.*)%] %[(.*)%] %[(.*)%] (.*)$", "%4")
	return logstr
end
local function getfilename(line)
	local filename = string.gsub(line, "^(.+) (.+) (.+) (.+) (.+) (.+) (.+) (.+) (.+)$", "%9")
	return filename 
end
local function ismsgline(line)
	local fileinfo = getfileinfo(line)
	log(fileinfo)
	if fileinfo == "public.lua, 159" then
		return true
	else
		return false
	end
end
local function parse(logstr, tab)
	local key = string.gsub(logstr, "^.?%[(.*)%]=%[(.*)%].?$", "%1")
	local value = string.gsub(logstr, "^.?%[(.*)%]=%[(.*)%].?$", "%2")
	tab[key] = value
end
local function readfile(fpath)
	local cdict = {}
	local req = {}
	local resp = {}
	local args ={}
	local flag = 0
	local f,err = io.open(fpath,"r")
	if not f then
		log("not exist ".. fpath)
		return
	end
	for line in f:lines() do
		
		local cid = getid(line)
		
		if cdict[cid] then
			cdict[cid] = cdict[cid] + 1
		else
			log(cid)
			table.insert(args, {req=req,resp=resp})
			cdict[cid] = 1
		end
		
		if ismsgline(line) then
			log(line)
			flag =flag + 1
			local logstr = getlogstr(line)
			if flag >= 1 and cdict[cid] < 20 then
				parse(logstr, req)
			elseif flag >=1 and cdict[cid] >20 then
				parse(logstr, resp)
			end
		else
			flag = 0
		end
	end
	for k,v in ipairs(args) do
		log(v)
	end
	f:close()
end
local function staticTradeTime(fpath)
	local cdict = {}
	local req = {}
	local args ={}
	local flag = 0
	local f,err = io.open(fpath,"r")
	if not f then
		log("not exist ".. fpath)
		return
	end
	for line in f:lines() do
		
		local cid = getid(line)
		
		if cdict[cid] then
			cdict[cid] = cdict[cid] + 1
		else
			log(cid)
			req.starttime = gettime(line)
			table.insert(args, {req=req,resp=resp})
			cdict[cid] = 1
		end
		
		if ismsgline(line) then
			log(line)
			flag =flag + 1
			local logstr = getlogstr(line)
			if flag >= 1 and cdict[cid] < 20 then
				parse(logstr, req)
			elseif flag >=1 and cdict[cid] >20 then
				parse(logstr, resp)
			end
		else
			flag = 0
		end
	end
	for k,v in ipairs(args) do
		log(v)
	end
	f:close()
end
local function getlatestfile(fpath)
	local go = io.popen("ls -lrt ".. (fpath or ""))
	if not go then
		print("not open")
	end
	local lastline 
	for line in go:lines() do
		print(line)
		lastline = line
	end
	go:close()
	local filename = getfilename(lastline)
	print(filename)
	return filename
end
local function getfilelist(fpath)
	local go = io.popen("ls -lrt ".. (fpath or ""))
	if not go then
		print("not open")
	end
	local filelist = {}
	for line in go:lines() do
		print(line)
		local filename = getfilename(line)
		table.insert(filelist,filename)
	end
	
	go:close()
	print(to_str(filelist))
	return filelist
end
local function getsplitfile(fpath)
	local f = io.open(fpath,"r")
	local cjson = require("cjson")
	for line in f:lines() do
		if line:sub(1,1)=="{" then
			print(line)
			local t = cjson.decode(line:sub(1,-1))
			print(t)
		end
					
	end
	f:close()
end


--getfilelist()
--readfile("/data/container_log/log_njfdkh_mc/tradelog/trace20160825.10.log")
getsplitfile("test.txt")
return _M
