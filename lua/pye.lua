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

	-- local cwd = vim.fn.expand("%:p:h")
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

	-- if we got nothing, return an empty string
	return ""
end

local function setup_venv()
	local common_venv_names = { "venv", ".venv", "env" }

	local project_root = find_project_root()
	if project_root == "" then
		return false
	end

	for _, dir in ipairs(common_venv_names) do
		local venv_path = project_root .. "/" .. dir
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
	end

	return false
end

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "python",
	callback = function()
		if setup_venv() then
			vim.notify("[pye.nvim] All set", vim.log.INFO)
		else
			vim.notify("[pye.nvim] Something went wrong", vim.log.ERROR)
		end
	end,
})
