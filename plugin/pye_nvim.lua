local pye_nvim = require("pye_nvim.init")

vim.api.nvim_create_user_command("SelectVenv", pye_nvim.select_venv, {})
