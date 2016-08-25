--[[
	工具箱 模块
--]]

local iconv = require("iconv")
local http = require("resty.http")

local _M = {}

--- 将二进制串转换为HEX码。
-- @param str 要转换的二进制串。
-- @return 返回HEX格式的字符串。
-- @usage tools.bin2bcd(str)

function _M.bin2bcd(str)
	return ({str:gsub(".", function(c) return string.format("%02X", c:byte(1)) end)})[1]
end


--- 将HEX码转换为二进制串。
-- @param str 要转换的HEX格式字符串。
-- @return 返回转换后的二进制字符串。
-- @usage tools.bcd2bin("125E")

function _M.bcd2bin(str)
	return ({str:gsub("..", function(x) return string.char(tonumber(x, 16)) end)})[1]
end


--- 将字符串进行url转码。
-- @param s 要url编码字符串。
-- @return 返回url转码后的字符串。
-- @usage tools.urlEncode(str)

function _M.urlEncode(s)
	return string.gsub(s, "([^A-Za-z0-9_])", function(c) return string.format("%%%02x", string.byte(c)) end)
end


--- 将字符串进行url解码。
-- @param s 要url解码的字符串。
-- @return 返回url解码后的字符串。
-- @usage tools.urlDecode(str)

function _M.urlDecode(s)
	return string.gsub(s, "%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
end


--- 字符编码转换，utf-8转换为gbk。
-- @param s 要转成gbk的utf-8字符串。
-- @return 转换后的gbk编码。
-- @usage tools.u8_to_gbk(str)

function _M.u8_to_gbk(s)
	return iconv.new("gbk", "utf-8"):iconv(s)
end


--- 字符编码转换，gbk转换为utf-8。
-- @param s 要转换成utf-8的gbk字符串。
-- @return 转换后的utf-8字符串。
-- @usage tools.gbk_to_u8(str)

function _M.gbk_to_u8(s)
	return iconv.new("utf-8", "gbk"):iconv(s)
end


--- 删除字符串前后的空白字符。
-- @param s 需要整理的字符串。
-- @return 转换后的字符串。
-- @usage tools.trim(str)

function _M.trim(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end


--- 如果变量为nil则返回空字符串，否则返回原字符串。
-- @param s 要转换的字符串。
-- @return 转换后的字符串。
-- @usage tools.nvl(str)

function _M.nvl(s)
	return s or ""
end


--- 将lua变量转换为可读的字符串。
-- @param value 要转换为字符串的变量。
-- @return 转换后的字符串。
-- @usage tools.toStr(value)

function _M.toStr(value)
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
				table.insert(auxTable, toStr(key))
			end
		end
		table.sort(auxTable)

		str = str .. '{'
		local separator = ""
		local entry = ""
		for _, fieldName in ipairs(auxTable) do
			if tonumber(fieldName) and tonumber(fieldName) > 0 then
				entry = _M.toStr(value[tonumber(fieldName)])
			else
				entry = fieldName .. " = " .. _M.toStr(value[fieldName])
			end
			str = str .. separator .. entry

			separator = ", "
		end
		str = str .. '}'
	end

	return str
end

--- 用指定的模式分隔字符串。
-- @param pString 被分隔的字符串。
-- @param pPattern 分隔模式，一般都是单个字符。
-- @return 成功时返回一个table。
-- @usage tools.split("a^b^c", "^")

function _M.split(pString, pPattern)

	local Table = {}
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)

	while s do
		table.insert(Table, cap)
		last_end = e+1
		s, e, cap = pString:find(fpat, last_end)
	end

	if last_end <= #pString then
		cap = pString:sub(last_end)
		table.insert(Table, cap)
	end

	return Table
end


--- 发送http post请求。
-- @param url 要发送的url。
-- @param postData 要发送的post数据。
-- @param timeout 超时时间。
-- @return 成功时返回一个table, 失败的时候返回nil,错误原因。
-- @usage tools.httpPostClient("http://127.0.0.1:8888/sequence/next", "moduleName=MC&keyName=FLOW")

function _M.httpPostClient(url, postData, timeout)

	local httpc = http.new()

	local timeout = timeout or 30000

	http:set_timeout(timeout)

	if type(postData) == "table" then
		postData = ngx.encode_args(postData)
	end

	local res, err = httpc:request_uri(url, {
		method = "POST",
		body = postData,
		headers = {
			["Content-Type"] = "application/x-www-form-urlencoded",
		}
	})

	return res, err
end




--- 判断该值是否是 (lua nil或者是空字串，或null/NULL字串)
-- @param  v     要判断的值
-- @return true  lua nil,空字串,null/NULL字串<br/>
--         false 其它值
-- @usage  isnil(nil) == true<br/>
--         isnil("") == true<br/>
--         isnil("null") == true<br/>
--         isnil("NULL") == true<br/>
--         isnil({}) == false<br/>
function _M.isnil(v)
	if not v then
		return true
	end
	if type(v) == "string" then
		if #v == 0 or string.lower(string.sub(v,1,4)) == "null" then
			return true
		end
	end
	return false
end

--- 判断该值是否非 (lua nil或者是空字串，或null/NULL字串)<br/>
--  在实现上就是isnil的 not 运算
-- @param  v     要判断的值
-- @return true  其它值<br/>
--         false lua nil,空字串,null/NULL字串
-- @usage  isNotNull(nil) == false<br/>
--         isNotNull("") == false<br/>
--         isNotNull("null") == false<br/>
--         isNotNull("NULL") == false<br/>
--         isNotNull({}) == true<br/>
function _M.isNotNull(v)
	return (not _M.isnil(v) )
end


--- 如果参数值为ngx.null或者nil则转成""
-- @param  str
-- @return result
-- @usage  ngxNull2Str(ngx.null)==""<br/>
--         ngxNull2Str(nil)==""<br/>
--         ngxNull2Str("test")=="test"
function _M.ngxNull2Str(value)
	if value==ngx.null then
		return ""
	end
	if value==nil then
		return ""
	end
	return value
end


--- 判断该值是否为空的lua table<br/>
-- @param  tbl   要判断的值
-- @return true  当tbl为lua table时，且为空<br/>
--         false 其它情况
-- @usage  isEmptyTable({}) == true <br/>
--         isEmptyTable(nil) == false<br/>
--         isEmptyTable({"test", "table"}) == false<br/>
function _M.isEmptyTable(tbl)
	if type(tbl) ~= "table" then
		return true
	end
	local next = next
	if next(tbl) == nil then
		return true
	end
	return false
end


--- 判断该值不是空的lua table<br/>
-- @param  tbl   要判断的值
-- @return true  其它值<br/>
--         false 当tbl为lua table且有值时
-- @usage  isNotEmptyTable({}) == false <br/>
--         isNotEmptyTable(nil) == true<br/>
--         isNotEmptyTable({"test", "table"}) == true<br/>
function _M.isNotEmptyTable(tbl)
	local next = next
	if type(tbl) == "table" then
		if next(tbl) then
			return true
		end
	end
	return false
end


--- 把str按照左补齐的方式补齐str到len长度<br/>
--  当str的长度小于len时，对str左补齐到len长度，补齐的字符为char<br/>
--  当str的长度大于len时，对str截取前len个字符
-- @param  ss        输入字串
-- @param  packLen   要补齐或截取的长度(当len为负数时，将截取1到-len的长度)
-- @param  packChar  要补齐的字符(如果超过1个字符将只取第1个字符)
-- @return result结果字符串
-- @usage  packStrLeft("123", 6, "a")=="aaa123" <br/>
--         packStrLeft("123", 6, "ab")=="aaa123"<br/>
--         packStrLeft("123", 2, "a")=="12"<br/>
--         packStrLeft("123", -1, "a")=="123"<br/>
--         packStrLeft("123", -2, "a")=="12"<br/>
function _M.packStrLeft(ss, packLen, packChar)
	ss      = (type(ss)=="string" and ss) or ""
	packLen = tonumber( packLen ) or 0
	packChar= string.sub(packChar, 1, 1)
	local outstr = ss;
	if (#ss < packLen) then 
		iLeft = packLen - #ss; 
		outstr = string.rep(packChar, iLeft)..ss;
	elseif #ss > packLen then
		outstr = string.sub(ss, 1, packLen)
	end
	return outstr;
end


--- 把str按照右补齐的方式补齐str到len长度<br/>
--  当str的长度小于len时，对str右补齐到len长度，补齐的字符为char<br/>
--  当str的长度大于len时，对str截取前len个字符
-- @param  ss        输入字串
-- @param  packLen   要补齐或截取的长度(当len为负数时，将截取1到-len的长度)
-- @param  packChar  要补齐的字符(如果超过1个字符将只取第1个字符)
-- @return result结果字符串
-- @usage  packStrLeft("123", 6, "a")=="123aaa" <br/>
--         packStrLeft("123", 6, "ab")=="123aaa"<br/>
--         packStrLeft("123", 2, "a")=="12"<br/>
--         packStrLeft("123", -1, "a")=="123"<br/>
--         packStrLeft("123", -2, "a")=="12"<br/>
function _M.packStrRight(ss, packLen, packChar)
	ss      = (type(ss)=="string" and ss) or ""
	packLen = tonumber( packLen ) or 0
	packChar= string.sub(packChar, 1, 1)
	local outstr = ss
	if (#ss < packLen) then
		local iLeft = packLen - #ss
		outstr = ss..string.rep(packChar, iLeft)
	elseif #ss > packLen then
		outstr = string.sub(ss, 1, packLen)
	end
	return outstr;
end


--- 复制一个lua对象，对象里面除了userdata都是深copy, 返回复制后的lua对象。
-- @param  src 源对象。
-- @param  dst 目标对象，可以为空，为空时候自动产生复制对象，
-- </br>只在dst为table的时候，src中的域会被copy到dst中，会覆盖dst中原本的域。
-- @return 返回复制后的对象，如果有dst，返回值和dst一样。
-- @usage  dst = tools.copy(src)

function _M.copy(src, dst)

	dst = dst or {}
	local objs = {}

	local function copy(src, dst)

		dst = dst or {}
   
		for k, v in pairs(src) do
			if type(v) == "table" then
				if objs[v] then
					dst[k] = objs[v]
				else
					local t = {}
					objs[v] = t
					dst[k] = copy(v, t)
				end
			else
				dst[k] = v
			end
		end

		return setmetatable(dst, getmetatable(src))
	end

	if type(src) == "table" then
		objs[src] = dst
		copy(src, dst)
	else
		dst = src
	end

	return dst
end

return _M
