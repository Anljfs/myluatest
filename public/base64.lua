local _M={}
local function log(logstr)
	print(logstr)
end
function _M.ToBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end

    return s64
end

function _M.FromBase64(str64)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local temp={}
    for i=1,64 do
        temp[string.sub(b64chars,i,i)] = i
    end
    temp['=']=0
    local str=""
    for i=1,#str64,4 do
        if i>#str64 then
            break
        end
        local data = 0
        local str_count=0
        for j=0,3 do
            local str1=string.sub(str64,i+j,i+j)
            if not temp[str1] then
                return
            end
            if temp[str1] < 1 then
                data = data * 64
            else
                data = data * 64 + temp[str1]-1
                str_count = str_count + 1
            end
        end
        for j=16,0,-8 do
            if str_count > 0 then
                str=str..string.char(math.floor(data/math.pow(2,j)))
                data=math.mod(data,math.pow(2,j))
                str_count = str_count - 1
            end
        end
    end
    return str
end 

function _M.DecodeFile_base64(filename)
	local f,err = io.open(filename,"r")
	if not f then
		log("file can't open!")
		return
	end
	local decodefile = filename ..".decode"
	local fw,err1 = io.open(decodefile, "w")
	if not f then
		log("can not write file!")
		f:close()
		return
	end
	for line in f:lines() do
		--log(line)
		local decodestr = _M.FromBase64(line)
		--log(decodestr)
		fw:write(decodestr.."\n")
	end
	f:close()
	fw:close()
	return
end

function _M.EncodeFile_base64(filename)
	local f,err = io.open(filename,"r")
	if not f then
		log("file can't open!")
		return
	end
	local encodefile = filename ..".encode"
	local fw,err1 = io.open(encodefile, "w")
	if not f then
		log("can not write file!")
		f:close()
		return
	end
	for line in f:lines() do
		--log(line)
		local encodestr = _M.ToBase64(line)
		--log(decodestr)
		fw:write(encodestr.."\n")
	end
	f:close()
	fw:close()
	return
end
_M.DecodeFile_base64(arg[1])

return _M
