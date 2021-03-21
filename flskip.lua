metaheader = [[;FFMETADATA1
title=%s
]]

metachapter = [[
[CHAPTER]
TIMEBASE=1/1000
START=%d
END=%d
title=%s
]]

bookmarks = {}
run_start = -1
run_end = -1
current_start = -1
current_end = -1
function mark_runstart()
	run_start = mp.get_property_number("playback-time")
	print("Start set at "..to_durstring(run_start))
end

function mark_runend()
	run_end = mp.get_property_number("playback-time")
	print("End set at "..to_durstring(run_end))
end

function savecurrent()
	print(mp.get_property("media-title"))
	if run_start < 0 then
		print("No Run Start Specified.")
		return
	end
	if run_end < 0 then
		print("No Run End Specified.")
		return
	end
	if table.getn(bookmarks) <= 0 then
		print(string.format("Invalid number of bookmarks (%d)", table.getn(bookmarks)))
		return
	end
	f = io.open("metadata_".. string.gsub(to_durstring(run_end-run_start), "%s+", "")..".txt", "w")
	io.output(f)
	io.write(string.format(metaheader, mp.get_property("media-title") .. "\n"))
	io.write(string.format(metachapter, run_start, bookmarks[1][1]*1000 - 1, "Run start") .. "\n") 
	for i=1,table.getn(bookmarks) do
		io.write(string.format(metachapter, bookmarks[i][1]*1000, bookmarks[i][2]*1000, "Load" .. ((i+1)/2)).."\n")
	end	
	io.close(f)
	print("Wrote metadata")
end

function undo_lastmark()
	if table.getn(bookmarks) == 0 then
	print("No bookmarks set")
	return
	end
	if current_start == -1 and current_end == -1 then
	    lastm = table.remove(bookmarks)
		print("Undone last interval starting at " .. to_durstring(lastm[1]))
	elseif current_start == -1 then
	
		print("Removed current ending at " .. to_durstring(current_end))
		current_end = -1
	else
		print("Removed current start at " .. to_durstring(current_start))
		current_start = -1
	end
end

function to_durstring(ts)
	s = ts % 60
	m = math.floor(ts/60) % 60	
	h = math.floor(ts/3600) % 60
	return tostring(h) .. "h " .. tostring(m) .. "m " .. tostring(s) .. "s"
end
function show_retime()
	if run_start < 0 then
		print("No Run Start Specified.")
		return
	end
	if run_end < 0 then
		print("No Run End Specified.")
		return
	end
	if table.getn(bookmarks) < 1 then
		print("No intervals saved")
		return
	end
	print("Run start: "..to_durstring(run_start))
	print("Run end: "..to_durstring(run_end))
	rta = run_end-run_start
	print("RTA Time: "..to_durstring(rta))
	loads = 0
	for i=1,table.getn(bookmarks) do
			print(string.format("Load: %s -> %s", to_durstring(bookmarks[i][1]), to_durstring(bookmarks[i][2])))
			loads = loads + (bookmarks[i][2] - bookmarks[i][1])
	end
	print("Loadless Time: "..to_durstring(rta-loads))
end

function add_start()
	pb_time = mp.get_property_number("playback-time")
	pb_time_ms = pb_time
	if table.getn(bookmarks) > 0 then
		for k, b in pairs(bookmarks) do
			if b[1] == pb_time_ms then
				print(string.format("Bookmark already exists at %4f. s", pb_time))
				return
			end
		end
	end
	if current_end < pb_time_ms and current_end ~= -1 then
		print(string.format("Current Start Marker After End Marker (%s)", to_durstring(current_end)))
		return
	end
	current_start = pb_time_ms
	if current_end == -1 then
		print(string.format("Start marked at %s",to_durstring(current_start)))
		return
	else
		print(string.format("Interval established from %s to %s", to_durstring(current_start), to_durstring(current_end)))
		current_end = -1
		current_start = -1
	end
end

function add_end()
	pb_time = mp.get_property_number("playback-time")
	pb_time_ms = pb_time
	if table.getn(bookmarks) > 0 then
		for k, b in pairs(bookmarks) do
			if b[2] == pb_time_ms then
				print(string.format("End mark already exists at %4f. s", pb_time))
				return
			end
		end
	end
	if  current_start > pb_time_ms and current_start ~= -1 then
		print(string.format("Current Start Marker After End Marker (%s)", 	to_durstring(current_end)))
		return
	end
	current_end = pb_time_ms
	if current_start == -1 then
		print(string.format("End marked at %s",to_durstring(current_end)))
		return
	else
		print(string.format("Interval established from %s to %s", to_durstring(current_start), to_durstring(current_end)))
		current_end = -1
		current_start = -1
	end
end

mp.add_key_binding("Ctrl+Alt+1", "runstart", mark_runstart)
mp.add_key_binding("Ctrl+Alt+2", "run_end", mark_runend)
mp.add_key_binding("Ctrl+1", "bookmarkstart", add_start)
mp.add_key_binding("Ctrl+2", "bookmarkend", add_end)
mp.add_key_binding("Ctrl+Alt+r", "showretime", show_retime)
mp.add_key_binding("Alt+b", "savebookmarks", savecurrent)
mp.add_key_binding("Ctrl+z", "undomark", undo_lastmark)