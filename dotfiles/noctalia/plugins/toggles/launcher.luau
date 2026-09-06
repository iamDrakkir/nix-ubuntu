--!nonstrict

-- Shell toggles for the Noctalia launcher. Every action is a Noctalia IPC
-- command, so these stay in step with whatever the control centre does.

local ENTRIES = {
	{ id = "theme-mode-toggle", title = "Dark mode", subtitle = "Switch light/dark theme", glyph = "moon" },
	{ id = "nightlight-toggle", title = "Nightlight", subtitle = "Warm the display colours", glyph = "sun" },
	{ id = "caffeine-toggle", title = "Caffeine", subtitle = "Keep the screen awake", glyph = "coffee" },
	{ id = "notification-dnd-toggle", title = "Do not disturb", subtitle = "Silence notifications", glyph = "bell-off" },
	{ id = "osd-toggle", title = "OSD", subtitle = "On-screen volume/brightness popups", glyph = "eye" },
	{ id = "bar-toggle", title = "Bar", subtitle = "Show or hide the bar", glyph = "layout" },
	{ id = "wifi-toggle", title = "WiFi", subtitle = "Enable or disable WiFi", glyph = "wifi" },
	{ id = "bluetooth-toggle", title = "Bluetooth", subtitle = "Enable or disable Bluetooth", glyph = "bluetooth" },
}

local function rowsFor(query)
	local trimmed = noctalia.string.trim(tostring(query or ""))
	local rows = {}

	for _, entry in ENTRIES do
		local score = 0

		if trimmed ~= "" then
			score = noctalia.fuzzyScore(trimmed, entry.title .. " " .. entry.subtitle)
		end

		if score ~= nil then
			table.insert(rows, {
				id = entry.id,
				title = entry.title,
				subtitle = entry.subtitle,
				glyph = entry.glyph,
				score = score,
			})
		end
	end

	return rows
end

function onQuery(query: string)
	launcher.setResults(query, rowsFor(query))
end

function onActivate(id: string)
	-- The entry id *is* the IPC command.
	noctalia.runAsync(`noctalia msg {id}`)
end
