---@class Config
---@field base_venv string|nil

---@class Venv
---@field name string
---@field path string
local M = {}

---@type Config
M.config = {
	base_venv = nil,
}

---@param opts Config|nil
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

local function find_project_root()
	local root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		".git",
		".gitignore",
		"main.py",
		"app.py",
		"index.py",
	}

	local cwd = vim.fn.getcwd()
	local home_dir = vim.fn.expand("$HOME")

	while cwd ~= home_dir do
		for _, marker in ipairs(root_markers) do
			if vim.fn.filereadable(cwd .. "/" .. marker) == 1 or vim.fn.isdirectory(cwd .. "/" .. marker) then
				return cwd
			end
		end

		local parent_dir = vim.fn.fnamemodify(cwd, ":h")
		if parent_dir == cwd then
			break
		end
		cwd = parent_dir
	end

	return ""
end

--@param project_root string
---@return Venv[]
local function find_venvs(project_root)
	local common_venv_names = { "venv", ".venv", "env" }
	local venvs = {}

	-- Look for project-specific venvs
	for _, dir in ipairs(common_venv_names) do
		local venv_path = project_root .. "/" .. dir
		if vim.fn.isdirectory(venv_path) == 1 then
			table.insert(venvs, { name = "Project: " .. venv_path, path = venv_path })
		end
	end

	if not M.config.base_venv then
		return venvs
	end

	local expanded_base = vim.fn.expand(M.config.base_venv)

	if M.config.base_venv and vim.fn.isdirectory(expanded_base) == 1 then
		table.insert(venvs, { name = "Base: " .. M.config.base_venv, path = expanded_base })
	end

	return venvs
end

function M.select_venv()
	local project_root = find_project_root()
	local venvs = find_venvs(project_root)

	if #venvs == 0 then
		return
	end

	if #venvs == 1 then
		if M.setup_venv(venvs[1].path) then
			vim.notify_once("[pye.nvim] Activated virtual env: " .. venvs[1].name, vim.log.levels.INFO)
		else
			vim.notify_once("[pye.nvim] Failed to activate virtual env: " .. venvs[1].name, vim.log.levels.WARN)
		end
		return
	end

	vim.ui.select(venvs, {
		prompt = "Pick a virtual environment",
		format_item = function(item)
			return item.name
		end,
	}, function(choice)
		if choice == nil then
			return
		end
		if choice then
			if M.setup_venv(choice.path) then
				vim.notify_once("[pye.nvim] Virtual env ready", vim.log.levels.INFO)
			else
				vim.notify_once("[pye.nvim] Failed to activate virtual env: " .. choice.name, vim.log.levels.WARN)
			end
		end
	end)
end

---@param venv_path string
---@return boolean
function M.setup_venv(venv_path)
	local lib_path = venv_path .. "/lib"
	local python_bin_path = venv_path .. "/bin"

	if vim.fn.isdirectory(venv_path) == 1 then
		local python_versions = vim.fn.readdir(lib_path, "v:val =~ '^python'")
		if #python_versions > 0 then
			local py_version = python_versions[1]
			local site_packages = lib_path .. "/" .. py_version

			if vim.fn.isdirectory(site_packages) == 1 then
				vim.env.VIRTUAL_ENV = venv_path

				vim.env.PATH = python_bin_path .. ":" .. vim.env.PATH

				if vim.env.PYTHONPATH == nil then
					vim.env.PYTHONPATH = site_packages
				else
					vim.env.PYTHONPATH = site_packages .. ":" .. vim.env.PYTHONPATH
				end
			end
		end
		return true
	end

	return false
end

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "python",
	callback = function()
		if not vim.env.VIRTUAL_ENV then
			local project_root = find_project_root()
			local venvs = find_venvs(project_root)
			if #venvs > 0 then
				M.select_venv()
			else
				vim.notify_once("[pye.nvim] No virtual environments found.", vim.log.levels.INFO)
			end
		else
			vim.notify_once("[pye.nvim] Active virtual env: " .. vim.env.VIRTUAL_ENV, vim.log.levels.INFO)
		end
	end,
})

return M
