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
