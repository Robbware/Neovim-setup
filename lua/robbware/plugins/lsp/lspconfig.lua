return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"Hoffs/omnisharp-extended-lsp.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		"tris203/rzls.nvim",
	},
	config = function()
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		local data_path = vim.fn.stdpath("data")
		local install_dir = data_path .. "/mason/packages/omnisharp"
		local bin_name = vim.loop.os_uname().sysname == "Windows_NT" and "\\OmniSharp.exe" or "/OmniSharp"
		local omnisharp_cmd = install_dir .. bin_name

		-- Warn if missing
		if vim.fn.filereadable(omnisharp_cmd) == 0 then
			vim.notify("Could not find OmniSharp binary at: " .. omnisharp_cmd, vim.log.levels.ERROR)
			return
		end

		-- vim.filetype.add({
		-- 	extension = {
		-- 		cshtml = "razor",
		-- 		razor = "razor",
		-- 	},
		-- })
		--
		-- -- Set up highlighting for Razor files
		-- vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
		-- 	pattern = { "*.cshtml", "*.razor" },
		-- 	callback = function()
		-- 		vim.bo.filetype = "razor"
		-- 		-- Enable both HTML and C# syntax highlighting
		-- 		vim.cmd("runtime! syntax/html.vim")
		-- 		vim.cmd("runtime! syntax/cs.vim")
		-- 	end,
		-- })

		-- require("lspconfig").omnisharp.setup({
		-- 	cmd = { omnisharp_cmd, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
		-- 	capabilities = require("cmp_nvim_lsp").default_capabilities(),
		-- 	filetypes = { "cs", "vb", "cshtml" },
		-- 	root_dir = function(fname)
		-- 		return lspconfig.util.root_pattern("*.sln", "*.csproj")(fname)
		-- 	end,
		-- 	settings = {
		-- 		MsBuild = {
		-- 			LoadProjectsOnDemand = false,
		-- 		},
		-- 		RoslynExtensionsOptions = {
		-- 			EnableDecompilationSupport = true,
		-- 			EnableImportCompletion = true,
		-- 			EnableAsyncCompletion = true,
		-- 			EnableAnalyzersSupport = true,
		-- 		},
		-- 		FormattingOptions = {
		-- 			EnableEditorConfigSupport = true,
		-- 		},
		-- 	},
		-- })

		local mason_registry = require("mason-registry")

		---@type string[]
		local cmd = {}

		local roslyn_package = mason_registry.get_package("roslyn")
		if roslyn_package:is_installed() then
			vim.list_extend(cmd, {
				"roslyn",
				"--stdio",
				"--logLevel=Information",
				"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
			})

			local rzls_package = mason_registry.get_package("rzls")
			if rzls_package:is_installed() then
				local rzls_path = vim.fn.expand("$MASON/packages/rzls/libexec")
				table.insert(
					cmd,
					"--razorSourceGenerator=" .. vim.fs.joinpath(rzls_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll")
				)
				table.insert(
					cmd,
					"--razorDesignTimePath="
						.. vim.fs.joinpath(rzls_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets")
				)
				vim.list_extend(cmd, {
					"--extension",
					vim.fs.joinpath(rzls_path, "RazorExtension", "Microsoft.VisualStudioCode.RazorExtension.dll"),
				})
			end
		end

		require("roslyn").setup({
			cmd = cmd,
			config = {
				-- the rest of your Roslyn configuration
				handlers = require("rzls.roslyn_handlers"),
			},
		})

		require("lspconfig").html.setup({
			capabilities = capabilities,
			filetypes = { "html", "razor", "cshtml" },
		})

		--		local rounded_borders = {
		--			["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
		--			["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
		--		}

		--local omnisharp_bin = "C:/Users/rober/AppData/Roaming/nvim/omnisharp-3/OmniSharp.dll"

		-- Lua Configuration for Neovim (init.lua)
	end,
}
