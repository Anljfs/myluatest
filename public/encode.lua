local iconv = require("iconv")

local function bin2bcd(str)
        return ({str.gsub(str,".", function(c) return string.format("%02X", c:byte(1)) end)})[1]
end
local function bcd2bin(str)
        return ({str.gsub(str,"..", function(x) return string.char(tonumber(x, 16)) end)})[1]
end

local str = "test06贾继花"

local function transferstr(str)
        local res = ""
        local i = 1
        while i<=#str do
                if (string.byte(str:sub(i,i)) >=129 and string.byte(str:sub(i,i))) and (string.byte(str:sub(i+1,i+1)) >= 64 and string.byte(str:sub(i+1,i+1)) <= 254) then
                        local tmp = gbk_to_u16(str:sub(i,i+1))
                        res = res .. "&#x" .. bin2bcd(tmp) .. ";"
                        i = i+2  
                else
                        res = res .. str:sub(i,i)
                        i=i+1
                end
        end
        return res
end
print(transferstr(str))
