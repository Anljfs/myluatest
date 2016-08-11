local _M={}

function _M.bin2bcd(str)
	return ({str.gsub(str,".", function(c) return string.format("%02X", c:byte(1)) end)})[1]
end
function _M.bcd2bin(str)
	return ({str.gsub(str,"..", function(x) return string.char(tonumber(x, 16)) end)})[1]
end
function _M.to_str(value)
	--print("begin>>>>>")
	--print("parse value:"..tostring(value))
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
			--print("key:"..type(key).."--"..tostring(key))
			--print("tonumber(key):"..tostring(tonumber(key)))
			if tonumber(key) ~= key then
				
				table.insert(auxTable, key)
			else
				table.insert(auxTable, to_str(key))
			end
		end

		table.sort(auxTable)
		--print(tostring(auxTable))
		str = str .. '{'

		local separator = ""
		local entry = ""

		for _, fieldName in ipairs(auxTable) do
			--print("fieldName = ".. tostring(fieldName))
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
	--print("end <<<<<")
	return str
end

--local t1 = {["a"]={["b"]={["c"]="123"},},}
--print(to_str(t1))
return _M