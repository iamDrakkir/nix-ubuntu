--!nonstrict

-- Nix actions for the Noctalia launcher. Each entry runs a `just` recipe in a
-- terminal that stays open afterwards, because rebuild output is the point.

local DIR = "~/.config/nix"

local ENTRIES = {
	{ id = "home", title = "Home", subtitle = "Rebuild home-manager", glyph = "home", cmd = "just home" },
	{ id = "system", title = "System", subtitle = "Rebuild system-manager / NixOS", glyph = "server", cmd = "just system" },
	{ id = "rebuild", title = "Rebuild", subtitle = "Rebuild home and system", glyph = "refresh", cmd = "just rebuild" },
	{ id = "update", title = "Update", subtitle = "Update flake inputs", glyph = "download", cmd = "just update" },
	{ id = "check", title = "Check", subtitle = "Evaluate all configurations", glyph = "check", cmd = "just check" },
	{ id = "edit", title = "Edit", subtitle = "Open the config in an editor", glyph = "pencil", cmd = "${EDITOR:-nvim} ." },
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
	for _, entry in ENTRIES do
		if entry.id == id then
			-- Hold the window open so failures are readable; launcher actions are
			-- otherwise detached and a crashed rebuild would vanish silently.
			noctalia.runInTerminal(
				`cd {DIR} && {entry.cmd}; printf '\n[done] press enter to close'; read -r`
			)
			return
		end
	end
end
