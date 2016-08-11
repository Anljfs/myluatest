
local _M = {}
--日期时间操作
--[[
	srcDateTime   YYYYMMDDhi24mmss
	interval      要增加或减少的天数/小时数/分钟数/秒数
	dateUnit	  DAY HOUR MINUTE SECOND
]]
function _M.getNewTime(srcDateTime,interval ,dateUnit)  
	--从日期字符串中截取出年月日时分秒  
	local Y = string.sub(srcDateTime,1,4)  
	local M = string.sub(srcDateTime,5,6)  
	local D = string.sub(srcDateTime,7,8)  
	local H = string.sub(srcDateTime,9,10)
	local MM = string.sub(srcDateTime,11,12)  
	local SS = string.sub(srcDateTime,13,14)  
  
	--把日期时间字符串转换成对应的日期时间  
	local dt1 = os.time{year=Y, month=M, day=D, hour=H,min=MM,sec=SS}  
  
	--根据时间单位和偏移量得到具体的偏移数据  
	local ofset=0  
  
	if dateUnit =='DAY' then  
		ofset = 60 *60 * 24 * interval  
  
	elseif dateUnit == 'HOUR' then  
		ofset = 60 *60 * interval  
		  
 elseif dateUnit == 'MINUTE' then  
		ofset = 60 * interval  
  
	elseif dateUnit == 'SECOND' then  
		ofset = interval  
	end  
  
	--指定的时间+时间偏移量  
	local newTime = os.date("*t", dt1 + tonumber(ofset))
	--{day = 12, hour = 15, isdst = false, min = 19, month = 7, sec = 28, wday = 3, yday = 194, year = 2016}
	local newTimeStr = string.format("%04d%02d%02d%02d%02d%02d", newTime.year, newTime.month, newTime.day, 
																 newTime.hour, newTime.min,newTime.sec)
	return newTimeStr  
end

--计算两时间相差秒数
--[[
	starttime     YYYYMMDDhi24mmss 开始时间
	endtime       YYYYMMDDhi24mmss 结束时间
	return        seconds 相差秒数
]]
function _M.diffTimes(starttime, endtime)  
	--从日期字符串中截取出年月日时分秒  
	local Y = string.sub(starttime,1,4)  
	local M = string.sub(starttime,5,6)  
	local D = string.sub(starttime,7,8)  
	local H = string.sub(starttime,9,10)
	local MM = string.sub(starttime,11,12)  
	local SS = string.sub(starttime,13,14)  
  
	--把日期时间字符串转换成对应的日期时间  
	local dt1 = os.time{year=Y, month=M, day=D, hour=H,min=MM,sec=SS}  
  
	local Y2 = string.sub(endtime,1,4)  
	local M2 = string.sub(endtime,5,6)  
	local D2 = string.sub(endtime,7,8)  
	local H2 = string.sub(endtime,9,10)
	local MM2 = string.sub(endtime,11,12)  
	local SS2 = string.sub(endtime,13,14)  
	
	--把日期时间字符串转换成对应的日期时间  
	local dt2 = os.time{year=Y2, month=M2, day=D2, hour=H2,min=MM2,sec=SS2}  
  
	--根据时间单位和偏移量得到具体的偏移数据  
	local secs = dt2 - dt1
  
	return secs 
end

function _M.checkDate(starttime)
	print(starttime)
	--从日期字符串中截取出年月日时分秒  
	local Y = string.sub(starttime,1,4)  
	local M = string.sub(starttime,5,6)  
	local D = string.sub(starttime,7,8)  
	
	--local dt1 = os.time{year=Y, month=M, day=D, hour="00",min="00",sec="00"}  
	local dt1 = os.time{year=Y, month=M, day=D }  
	local newTime = os.date("*t", dt1) 
	local newstr = string.format("%04d%02d%02d", newTime.year, newTime.month, newTime.day)
	print(newstr)
	if newstr ~= starttime then
		return false
	else
		return true
	end
end
--local flag = checkDate("20180220")
--print(flag)
--flag = checkDate("20173929")
--print(flag)
return _M
