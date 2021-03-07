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
function mark_runstart()
	run_start = mp.get_property_number("playback-time")
	print("Start set at "..to_durstring(run_start))
end

function mark_runend()
	run_end = mp.get_property_number("playback-time")
	print("End set at "..to_durstring(run_start))
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
	if table.getn(bookmarks) < 2 or table.getn(bookmarks) % 2 ~= 0 then
		print(string.format("Invalid number of bookmarks (%d)", table.getn(bookmarks)))
		return
	end
	f = io.open("metadata_".. string.gsub(to_durstring(run_end-run_start), "%s+", "")..".txt", "w")
	io.output(f)
	io.write(string.format(metaheader, mp.get_property("media-title") .. "\n"))
	io.write(string.format(metachapter, run_start, bookmarks[1]*1000 - 1, "Run start") .. "\n") 
	for i=1,table.getn(bookmarks),2 do
		io.write(string.format(metachapter, bookmarks[i]*1000, bookmarks[i+1]*1000, "Load" .. ((i+1)/2)).."\n")
	end	
	io.close(f)
	print("wrote metadata")
end

function undo_lastmark()
	if table.getn(bookmarks) == 0 then
	print("No bookmarks set")
	return
	end
    lastm = table.remove(bookmarks)
	print("Undone last bookmark at " .. to_durstring(lastm))
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
	if table.getn(bookmarks) < 2 or table.getn(bookmarks) % 2 ~= 0 then
		print(string.format("Invalid number of bookmarks (%d)", table.getn(bookmarks)))
		return
	end
	print("Run start: "..to_durstring(run_start))
	print("Run end: "..to_durstring(run_end))
	rta = run_end-run_start
	print("RTA Time: "..to_durstring(rta))
	loads = 0
	for i=1,table.getn(bookmarks),2 do
			print(string.format("Load: %s -> %s", to_durstring(bookmarks[i]), to_durstring(bookmarks[i+1])))
			loads = loads + (bookmarks[i+1] - bookmarks[i])
	end
	print("Loadless Time: "..to_durstring(rta-loads))
end

function add_bookmark()
	pb_time = mp.get_property_number("playback-time")
	pb_time_ms = pb_time
	if table.getn(bookmarks) > 0 then
		for k, b in pairs(bookmarks) do
			if b == pb_time_ms then
				print(string.format("Bookmark already exists at %4f. s", pb_time))
				return
			end
		end
	end
	table.insert(bookmarks, pb_time_ms)
	print("Bookmarks:")
	for k,b in pairs(bookmarks) do
		print(b)
	end
	if table.getn(bookmarks) % 2 == 0 then
		table.sort(bookmarks)
		print("Load intervals: ")
		for i=1,table.getn(bookmarks),2 do
			print(string.format("%4f. s -> %4f. s", bookmarks[i]/1000, bookmarks[i+1]/1000))
		end
	end
end

mp.add_key_binding("Ctrl+Alt+1", "runstart", mark_runstart)
mp.add_key_binding("Ctrl+Alt+2", "run_end", mark_runend)
mp.add_key_binding("Ctrl+b", "bookmark", add_bookmark)
mp.add_key_binding("Ctrl+Alt+r", "showretime", show_retime)
mp.add_key_binding("Alt+b", "savebookmarks", savecurrent)
mp.add_key_binding("Ctrl+z", "undomark", undo_lastmark)