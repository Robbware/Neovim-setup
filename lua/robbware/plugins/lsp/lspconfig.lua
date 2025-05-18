return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		--		"Hoffs/omnisharp-extended-lsp.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
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

		--		local rounded_borders = {
		--			["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
		--			["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
		--		}

		local omnisharp_bin = "C:/Users/rober/AppData/Roaming/nvim/omnisharp-3/OmniSharp.dll"

		-- Lua Configuration for Neovim (init.lua)
		mason_lspconfig.setup_handlers({
			-- default handler for installed servers
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			--["csharp_ls"] = function()
			--	lspconfig.csharp_ls.setup({
			--		capabilities = capabilities,
			--	})
			--end,
			["omnisharp"] = function()
				lspconfig.omnisharp.setup({
					capabilities = capabilities,
					cmd = { "dotnet", omnisharp_bin, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
					on_attach = function(client, bufnr)
						-- Enable keymaps for LSP features
						local bufopts = { noremap = true, silent = true, buffer = bufnr }
						vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
						vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
						vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
						vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
						vim.keymap.set("n", "rn", vim.lsp.buf.rename, bufopts)
					end,
					flags = {
						debounce_text_changes = 150,
					},
					--					cmd = { "dotnet", omnisharp_bin },
					root_dir = function(fname)
						local primary = lspconfig.util.root_pattern("*.sln")(fname)
						local fallback = lspconfig.util.root_pattern("*.csproj")(fname)
						return primary or fallback
					end,
					settings = { -- Add settings here
						omnisharp = {
							wait_for_debugger = true,
							enable_editorconfig_support = true,
							enable_ms_build_load_projects_on_demand = false,
							enable_roslyn_analyzers = true,
							organize_imports_on_format = true,
							enable_import_completion = true,
							analyze_open_documents_only = false,
							enable_decompilation_support = true,
							filetypes = { "cs", "vb", "csproj", "sln", "slnx", "props", "csx", "targets" },
						},
					},
				})
			end,
			-- ["svelte"] = function()
			--   -- configure svelte server
			--   lspconfig["svelte"].setup({
			--     capabilities = capabilities,
			--     on_attach = function(client, bufnr)
			--       vim.api.nvim_create_autocmd("BufWritePost", {
			--         pattern = { "*.js", "*.ts" },
			--         callback = function(ctx)
			--           -- Here use ctx.match instead of ctx.file
			--           client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
			--         end,
			--       })
			--     end,
			--   })
			-- end,
			-- ["graphql"] = function()
			--   -- configure graphql language server
			--   lspconfig["graphql"].setup({
			--     capabilities = capabilities,
			--     filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
			--   })
			-- end,
			--			["emmet_ls"] = function()
			-- configure emmet language server
			--				lspconfig["emmet_ls"].setup({
			--					capabilities = capabilities,
			--					filetypes = {
			--						"html",
			--						"typescriptreact",
			--						"javascriptreact",
			--						"css",
			--						"sass",
			--						"scss",
			--						"less",
			--						"svelte",
			--					},
			--				})
			--			end,
			-- ["lua_ls"] = function()
			-- 	-- configure lua server (with special settings)
			-- 	lspconfig["lua_ls"].setup({
			-- 		capabilities = capabilities,
			-- 		settings = {
			-- 			Lua = {
			-- 				-- make the language server recognize "vim" global
			-- 				diagnostics = {
			-- 					globals = { "vim" },
			-- 				},
			-- 				completion = {
			-- 					callSnippet = "Replace",
			-- 				},
			-- 			},
			-- 		},
			-- 	})
			-- end,
		})
	end,
}
