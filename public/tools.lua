--[[
	������ ģ��
--]]

local iconv = require("iconv")
local http = require("resty.http")

local _M = {}

--- �������ƴ�ת��ΪHEX�롣
-- @param str Ҫת���Ķ����ƴ���
-- @return ����HEX��ʽ���ַ�����
-- @usage tools.bin2bcd(str)

function _M.bin2bcd(str)
	return ({str:gsub(".", function(c) return string.format("%02X", c:byte(1)) end)})[1]
end


--- ��HEX��ת��Ϊ�����ƴ���
-- @param str Ҫת����HEX��ʽ�ַ�����
-- @return ����ת����Ķ������ַ�����
-- @usage tools.bcd2bin("125E")

function _M.bcd2bin(str)
	return ({str:gsub("..", function(x) return string.char(tonumber(x, 16)) end)})[1]
end


--- ���ַ�������urlת�롣
-- @param s Ҫurl�����ַ�����
-- @return ����urlת�����ַ�����
-- @usage tools.urlEncode(str)

function _M.urlEncode(s)
	return string.gsub(s, "([^A-Za-z0-9_])", function(c) return string.format("%%%02x", string.byte(c)) end)
end


--- ���ַ�������url���롣
-- @param s Ҫurl������ַ�����
-- @return ����url�������ַ�����
-- @usage tools.urlDecode(str)

function _M.urlDecode(s)
	return string.gsub(s, "%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
end


--- �ַ�����ת����utf-8ת��Ϊgbk��
-- @param s Ҫת��gbk��utf-8�ַ�����
-- @return ת�����gbk���롣
-- @usage tools.u8_to_gbk(str)

function _M.u8_to_gbk(s)
	return iconv.new("gbk", "utf-8"):iconv(s)
end


--- �ַ�����ת����gbkת��Ϊutf-8��
-- @param s Ҫת����utf-8��gbk�ַ�����
-- @return ת�����utf-8�ַ�����
-- @usage tools.gbk_to_u8(str)

function _M.gbk_to_u8(s)
	return iconv.new("utf-8", "gbk"):iconv(s)
end


--- ɾ���ַ���ǰ��Ŀհ��ַ���
-- @param s ��Ҫ������ַ�����
-- @return ת������ַ�����
-- @usage tools.trim(str)

function _M.trim(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end


--- �������Ϊnil�򷵻ؿ��ַ��������򷵻�ԭ�ַ�����
-- @param s Ҫת�����ַ�����
-- @return ת������ַ�����
-- @usage tools.nvl(str)

function _M.nvl(s)
	return s or ""
end


--- ��lua����ת��Ϊ�ɶ����ַ�����
-- @param value Ҫת��Ϊ�ַ����ı�����
-- @return ת������ַ�����
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

--- ��ָ����ģʽ�ָ��ַ�����
-- @param pString ���ָ����ַ�����
-- @param pPattern �ָ�ģʽ��һ�㶼�ǵ����ַ���
-- @return �ɹ�ʱ����һ��table��
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


--- ����http post����
-- @param url Ҫ���͵�url��
-- @param postData Ҫ���͵�post���ݡ�
-- @param timeout ��ʱʱ�䡣
-- @return �ɹ�ʱ����һ��table, ʧ�ܵ�ʱ�򷵻�nil,����ԭ��
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




--- �жϸ�ֵ�Ƿ��� (lua nil�����ǿ��ִ�����null/NULL�ִ�)
-- @param  v     Ҫ�жϵ�ֵ
-- @return true  lua nil,���ִ�,null/NULL�ִ�<br/>
--         false ����ֵ
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

--- �жϸ�ֵ�Ƿ�� (lua nil�����ǿ��ִ�����null/NULL�ִ�)<br/>
--  ��ʵ���Ͼ���isnil�� not ����
-- @param  v     Ҫ�жϵ�ֵ
-- @return true  ����ֵ<br/>
--         false lua nil,���ִ�,null/NULL�ִ�
-- @usage  isNotNull(nil) == false<br/>
--         isNotNull("") == false<br/>
--         isNotNull("null") == false<br/>
--         isNotNull("NULL") == false<br/>
--         isNotNull({}) == true<br/>
function _M.isNotNull(v)
	return (not _M.isnil(v) )
end


--- �������ֵΪngx.null����nil��ת��""
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


--- �жϸ�ֵ�Ƿ�Ϊ�յ�lua table<br/>
-- @param  tbl   Ҫ�жϵ�ֵ
-- @return true  ��tblΪlua tableʱ����Ϊ��<br/>
--         false �������
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


--- �жϸ�ֵ���ǿյ�lua table<br/>
-- @param  tbl   Ҫ�жϵ�ֵ
-- @return true  ����ֵ<br/>
--         false ��tblΪlua table����ֵʱ
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


--- ��str��������ķ�ʽ����str��len����<br/>
--  ��str�ĳ���С��lenʱ����str���뵽len���ȣ�������ַ�Ϊchar<br/>
--  ��str�ĳ��ȴ���lenʱ����str��ȡǰlen���ַ�
-- @param  ss        �����ִ�
-- @param  packLen   Ҫ������ȡ�ĳ���(��lenΪ����ʱ������ȡ1��-len�ĳ���)
-- @param  packChar  Ҫ������ַ�(�������1���ַ���ֻȡ��1���ַ�)
-- @return result����ַ���
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


--- ��str�����Ҳ���ķ�ʽ����str��len����<br/>
--  ��str�ĳ���С��lenʱ����str�Ҳ��뵽len���ȣ�������ַ�Ϊchar<br/>
--  ��str�ĳ��ȴ���lenʱ����str��ȡǰlen���ַ�
-- @param  ss        �����ִ�
-- @param  packLen   Ҫ������ȡ�ĳ���(��lenΪ����ʱ������ȡ1��-len�ĳ���)
-- @param  packChar  Ҫ������ַ�(�������1���ַ���ֻȡ��1���ַ�)
-- @return result����ַ���
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


--- ����һ��lua���󣬶����������userdata������copy, ���ظ��ƺ��lua����
-- @param  src Դ����
-- @param  dst Ŀ����󣬿���Ϊ�գ�Ϊ��ʱ���Զ��������ƶ���
-- </br>ֻ��dstΪtable��ʱ��src�е���ᱻcopy��dst�У��Ḳ��dst��ԭ������
-- @return ���ظ��ƺ�Ķ��������dst������ֵ��dstһ����
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
