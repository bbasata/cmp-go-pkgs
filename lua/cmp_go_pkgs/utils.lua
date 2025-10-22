local M = {}

---Get substring from " character
---@param a string
---@return string
local function get_prefix(a)
	local _, pos = string.find(a, '"')

	if pos then
		return string.sub(a, pos + 1)
	end

	return ""
end

---If prompt contains "/" filter items by prefix from "
---@param items table
---@param prompt string
---@return table
M.filter_items_by_prefix = function(items, prompt)
	local prefix = get_prefix(prompt)

	if not string.find(prefix, "/") then
		return items
	end

	local result = {}

	for _, item in ipairs(items) do
		if item.insertText and string.sub(item.insertText, 1, #prefix) == prefix then
			table.insert(result, item)
		end
	end

	return result
end

---@param items table
---@param prompt string
---@return table
M.fuzzy_filter = function(items, prompt)
	local prefix = get_prefix(prompt)
	local result = {}

	for _, item in ipairs(items) do
		if item.insertText then
				vim.print(item.insertText)
				local matches = vim.fn.matchfuzzy({item.insertText}, prefix)
				if next(matches) ~= nil then
						table.insert(result, item)
				end
		end
	end

	return result
end

---Checks whether the cursor is in the "import" section
---@return boolean
M.check_if_inside_imports = function()
	-- get_parser() defaults to current buffer
	local parser = vim.treesitter.get_parser()
	if parser == nil then
		return false
	end

	local tree = parser:parse()
	if tree == nil then
		return false
	end

	local root_node = tree[1]:root()

	-- nvim_win_get_cursor() returns a (row, col) tuple of type integer[]
	local cursor = vim.api.nvim_win_get_cursor(0) -- 0 for current window

	local smallest_node_at_cursor = root_node:descendant_for_range(
		cursor[1] - 1 , cursor[2] - 1, cursor[1] - 1, cursor[2] - 1
	)

	-- local is_in_string = false
	local is_in_string = true

	---@type TSNode?
	local visited_node = smallest_node_at_cursor
	while visited_node do
		local node_type = visited_node:type()

		if node_type == "import_declaration" then
			return is_in_string
		end

		visited_node = visited_node:parent()
	end

	return false
end

return M

-- vim: ts=2 sw=2 sts=2
