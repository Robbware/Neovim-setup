return {
	"williamboman/mason.nvim",
	dependencies = {
		--		"Hoffs/omnisharp-extended-lsp.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
			registries = {
				"github:mason-org/mason-registry",
				"github:Crashdummyy/mason-registry",
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				--				"tsserver",
				"html",
				"cssls",
				--				"tailwindcss",
				--				"svelte",
				"lua_ls",
				--				"graphql",
				--				"emmet_ls",
				--				"prismals",
				--				"pyright",
				"gopls",
				"omnisharp",
				-- "omnisharp-mono",
				--"csharp_ls",
			},
			automatic_enable = true,
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier",
				"stylua",
				"isort",
				"black",
				"pylint",
				"eslint_d",
				--				"netcoredbg",
				"csharpier",
				--				"xmlformatter",
			},
		})
	end,
}
