require("robbware.core")
require("robbware.lazy")

--required for nvim-notify
vim.opt.termguicolors = true
--ensure omnisharp is always booted
vim.cmd([[autocmd FileType cs lua require'lspconfig'.omnisharp.setup{}]])

-- Show diagnostics in sign column
vim.fn.sign_define("LspDiagnosticsSignError", { text = "", texthl = "LspDiagnosticsDefaultError" })
vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "", texthl = "LspDiagnosticsDefaultWarning" })
vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "", texthl = "LspDiagnosticsDefaultInformation" })
vim.fn.sign_define("LspDiagnosticsSignHint", { text = "", texthl = "LspDiagnosticsDefaultHint" })

-- Show diagnostics in virtual text
vim.lsp.handlers["textDocument/publishDiagnostics"] =
	vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
		virtual_text = true,
		signs = true,
		update_in_insert = false,
	})

-- Auto-kill OmniSharp server on exit for Windows
vim.api.nvim_create_autocmd("VimLeave", {
	pattern = "*",
	callback = function()
		-- Get current Neovim PID
		local nvim_pid = vim.fn.getpid()

		-- Find and kill the OmniSharp process associated with this Neovim instance using PowerShell
		local kill_cmd = string.format(
			'powershell -Command "Get-CimInstance Win32_Process | '
				.. "Where-Object {$_.Name -like '*OmniSharp*' -and $_.CommandLine -like '*%d*'} | "
				.. 'ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue}"',
			nvim_pid
		)
		vim.fn.system(kill_cmd)
	end,
	desc = "Kill OmniSharp server when exiting Neovim on Windows",
})
