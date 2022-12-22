_G.utils = _G.utils or {}

if vim.fn.has("nvim-0.8") ~= 1 or vim.version().prerelease then
	vim.schedule(function()
		vim.api.nvim_err_writeln("Unsupported Neovim Version! Please check the requirements")
	end)
end

vim.env.XDG_CACHE_HOME = vim.fn.expand("$HOME/.cache")
vim.cmd.colorscheme("catppuccin-macchiato")
vim.g.which_key_use_floating_win = 1
vim.g.autoformat_enabled = true -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
vim.g.autopairs_enabled = true -- enable autopairs at start
vim.g.cmp_enabled = true -- enable completion at start
vim.g.diagnostics_enabled = true -- enable diagnostics at start
vim.g.highlighturl_enabled = true -- highlight URLs by default
vim.g.icons_enabled = true -- disable icons in the UI (disable if no nerd font is available)
vim.g.load_black = false -- disable black
vim.g.loaded_2html_plugin = true -- disable 2html
vim.g.loaded_getscript = true -- disable getscript
vim.g.loaded_getscriptPlugin = true -- disable getscript
--vim.g.loaded_gzip = true -- disable gzip
vim.g.loaded_logipat = true -- disable logipat
vim.g.loaded_matchit = true -- disable matchit
--vim.g.loaded_netrwFileHandlers = true -- disable netrw
--vim.g.loaded_netrwPlugin = true -- disable netrw
--vim.g.loaded_netrwSettngs = true -- disable netrw
--vim.g.loaded_remote_plugins = true -- disable remote plugins
--vim.g.loaded_tar = true -- disable tar
--vim.g.loaded_tarPlugin = true -- disable tar
vim.g.loaded_vimball = true -- disable vimball
vim.g.loaded_vimballPlugin = true -- disable vimball
--vim.g.loaded_zip = true -- disable zip
--vim.g.loaded_zipPlugin = true -- disable zip
vim.g.mapleader = " " -- set leader key
vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_side = "right"
vim.g.status_diagnostics_enabled = true -- enable diagnostics in statusline
vim.g.ui_notifications_enabled = true -- disable notifications when toggling UI elements
vim.g.zipPlugin = false -- disable zip
vim.opt.autoindent = true
vim.opt.autoread = true
vim.opt.background = "dark"
vim.opt.backspace = { "indent", "eol", "start", "nostop" }
vim.opt.backup = false
vim.opt.clipboard = "unnamedplus" -- Connection to the system clipboard
vim.opt.cmdheight = 0 -- hide command line unless needed
vim.opt.completeopt = { "menuone", "noselect" } -- Options for insert mode completion
vim.opt.copyindent = true -- Copy the previous indentation on autoindenting
vim.opt.cursorline = true -- Highlight the text line of the cursor
vim.opt.expandtab = true -- Enable the use of space in tab
vim.opt.fileencoding = "utf-8" -- File content encoding for the buffer
vim.opt.fillchars = { eob = " " } -- Disable `~` on nonexistent lines
vim.opt.foldmethod = "syntax"
vim.opt.foldenable = false
vim.opt.history = 100 -- Number of commands to remember in a history table
vim.opt.hlsearch = true
vim.opt.ignorecase = true -- Case insensitive searching
vim.opt.incsearch = true
vim.opt.laststatus = 3 -- globalstatus
vim.opt.lazyredraw = false -- lazily redraw screen
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.number = true -- Show numberline
vim.opt.preserveindent = true -- Preserve indent structure as much as possible
vim.opt.pumheight = 10 -- Height of the pop up menu
vim.opt.relativenumber = true -- Show relative numberline
vim.opt.ruler = true
vim.opt.scrolloff = 8 -- Number of lines to keep above and below the cursor
vim.opt.shiftwidth = 2 -- Number of space inserted for indentation
vim.opt.showcmd = true
vim.opt.showmode = false -- Disable showing modes in command line
vim.opt.showtabline = 2 -- always display tabline
vim.opt.sidescrolloff = 8 -- Number of columns to keep at the sides of the cursor
vim.opt.signcolumn = "yes" -- Always show the sign column
vim.opt.smartcase = true -- Case sensitivie searching
vim.opt.softtabstop = 2
vim.opt.spell = false
vim.opt.grepprg = "rg --vimgrep"
vim.opt.splitbelow = true -- Splitting a new window below the current one
vim.opt.splitright = true -- Splitting a new window at the right of the current one
vim.opt.startofline = false
vim.opt.swapfile = false -- Disable use of swapfile for the buffer
vim.opt.tabstop = 2 -- Number of space in a tab
vim.opt.termguicolors = true -- Enable 24-bit RGB color in the TUI
vim.opt.timeoutlen = 300 -- Length of time to wait for a mapped sequence
vim.opt.undofile = true -- Enable persistent undo
vim.opt.updatetime = 300 -- Length of time to wait before triggering the plugin
vim.opt.wildmenu = true
vim.opt.wrap = false -- Disable wrapping of lines longer than the width of window
vim.opt.writebackup = false -- Disable making a backup before overwriting a file

-- ensure that the global utils table is declared.

--- Trim a string or return nil
-- @param str the string to trim
-- @return a trimmed version of the string or nil if the parameter isn't a string
function _G.utils.trim_or_nil(str)
	return type(str) == "string" and vim.trim(str) or nil
end

--- Wrapper function for neovim echo API
-- @param messages an array like table where each item is an array like table of strings to echo
function _G.utils.echo(messages)
	-- if no parameter provided, echo a new line
	messages = messages or { { "\n" } }
	if type(messages) == "table" then
		vim.api.nvim_echo(messages, false, {})
	end
end

function _G.utils.setup(path, callback)
	local status_ok, plugin = pcall(require, path)
	if not status_ok then
		-- return vim.api.nvim_err_writeln(plugin)
		return nil
	elseif callback == nil then
		return pcall(function(s)
			s.setup()
		end, plugin)
	elseif type(callback) == "table" then
		return pcall(function(s)
			s.setup(callback)
		end, plugin)
	elseif type(callback) == "function" then
		return pcall(callback, plugin)
	else
		vim.api.nvim_err_writeln("Could not load plugin " .. path .. " because " .. type(callback))
		return nil
	end
end

utils.setup("impatient", function(i)
	i.enable_profile()
end)
utils.setup("nvim-surround")
utils.setup("terminal")
utils.setup("dressing")
utils.setup("better_escape")
utils.setup("lualine")
utils.setup("neoscroll")
utils.setup("neodev")

utils.setup("notify", function(notify)
	notify.setup({ stages = "fade" })
	vim.notify = notify
end)

utils.setup("rust-tools", function(rt)
  rt.setup({
    server = {
      on_attach = function(_, bufnr)
        -- Hover actions
        vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
        -- Code action groups
        vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
      end,
    }
  })
end)

utils.setup("null-ls", function(null_ls)
	null_ls.setup({
		fallback_severity = vim.diagnostic.severity.WARN,
		log_level = vim.log.levels.OFF,
		sources = {
			null_ls.builtins.code_actions.gitsigns,
			null_ls.builtins.code_actions.refactoring,
			null_ls.builtins.code_actions.shellcheck,
			null_ls.builtins.completion.luasnip,
			null_ls.builtins.completion.spell,
			null_ls.builtins.completion.tags,
			null_ls.builtins.diagnostics.actionlint,
			null_ls.builtins.diagnostics.ansiblelint,
			null_ls.builtins.diagnostics.commitlint,
			null_ls.builtins.diagnostics.cue_fmt,
			null_ls.builtins.diagnostics.deadnix,
			null_ls.builtins.diagnostics.gitlint,
			null_ls.builtins.diagnostics.golangci_lint,
			null_ls.builtins.diagnostics.revive,
			null_ls.builtins.diagnostics.shellcheck,
			null_ls.builtins.diagnostics.staticcheck,
			null_ls.builtins.diagnostics.statix,
			null_ls.builtins.diagnostics.todo_comments,
			null_ls.builtins.diagnostics.tsc,
			null_ls.builtins.diagnostics.yamllint,
			null_ls.builtins.diagnostics.zsh,
			null_ls.builtins.formatting.alejandra,
			null_ls.builtins.formatting.asmfmt,
			null_ls.builtins.formatting.cue_fmt,
			null_ls.builtins.formatting.gofmt,
			null_ls.builtins.formatting.gofumpt,
			null_ls.builtins.formatting.goimports,
			null_ls.builtins.formatting.jq,
			null_ls.builtins.formatting.markdownlint,
			null_ls.builtins.formatting.packer,
			null_ls.builtins.formatting.protolint,
			null_ls.builtins.formatting.rustfmt,
			null_ls.builtins.formatting.shfmt,
			null_ls.builtins.formatting.trim_newlines,
			null_ls.builtins.formatting.trim_whitespace,
			null_ls.builtins.hover.dictionary,
			null_ls.builtins.hover.printenv,
		},
	})
end)

utils.setup("bufferline", {
	options = {
		offsets = {
			{ filetype = "NvimTree", text = "", padding = 1 },
			{ filetype = "Outline", text = "", padding = 1 },
		},
	},
})

utils.setup("colorizer", {
	user_default_options = {
		names = false,
	},
})

utils.setup("neorg", {})

utils.setup("toggleterm", {
	size = 10,
	open_mapping = [[ <F2> ]],
	shading_factor = 2,
	direction = "float",
	float_opts = {
		border = "curved",
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})

utils.setup("nvim-treesitter", {
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	autotag = {
		enable = true,
	},
	indent = {
		enable = false,
	},
	incremental_selection = {
		enable = true,
	},
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
	rainbow = {
		enable = true,
		disable = { "html" },
		extended_mode = false,
		max_file_lines = nil,
	},
})

-- Language Server Config
utils.setup("lspconfig", function(lspconfig)
	-- Add additional capabilities supported by nvim-cmp
	local capabilities = require("cmp_nvim_lsp").default_capabilities()

	-- Use an on_attach function to only map the following keys
	-- after the language server attaches to the current buffer
	local on_attach = function(client, bufnr)
		-- Enable completion triggered by <c-x><c-o>
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

		-- Mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local bufopts = { noremap = true, silent = true, buffer = bufnr }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, bufopts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
		vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, bufopts)
	end

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
	vim.lsp.handlers["textDocument/signatureHelp"] =
		vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

	lspconfig["gopls"].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	  cmd = {"gopls", "serve"},
	  filetypes = {"go", "gomod"},
	  root_dir = require('lspconfig/util').root_pattern("go.work", "go.mod", ".git"),
	  settings = {
	    gopls = {
	      -- gopls settings doc:  https://github.com/golang/tools/blob/master/gopls/doc/settings.md
	      completeUnimported = false,
	      experimentalPackageCacheKey = true,
	      memoryMode = "DegradeClosed",
	      gofumpt = true,
	      staticcheck = true,
	      hints = {
	        parameterNames = true,
	        rangeVariableTypes = true,
	        constantValues = true,
	        assignVariableTypes = true,
	      },
	      directoryFilters = {"-**/node_modules"},
	      analyses = {
	        unusedparams = true,
	      },
	    },
	  }
	})

	lspconfig["sumneko_lua"].setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { "vim" },
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = vim.api.nvim_get_runtime_file("", true),
				},
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = {
					enable = false,
				},
			},
		},
	})

	lspconfig["jsonls"].setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
      json = {
        schemas = require('schemastore').json.schemas({
          ignore = {
            'non-package.json',
          },
        }),
        validate = { enable = true },
      },
		},
	})

	lspconfig["gopls"].setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			gopls = {
				experimentalPostfixCompletions = true,
				experimentalPackageCacheKey = true,
				completeUnimported = true,
				memoryMode = "DegradeClosed",
				analyses = {
					unusedparams = true,
					shadow = true,
				},
				staticcheck = true,
			},
		},
		init_options = {
			usePlaceholders = true,
		},
	})

	lspconfig["rnix"].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})

	lspconfig["yamlls"].setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			redhat = { telemetry = false },
			yaml = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
			},
		},
	})

	lspconfig["rust_analyzer"].setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = { ["rust-analyzer"] = {} },
		init_options = {
			usePlaceholders = true,
		},
	})
end)

utils.setup("alpha", function(alpha)
	local dashboard = require("alpha.themes.startify")
	dashboard.section.header.val = {
		[[  ___   __   __  ._     ___ ___    ]],
		[[ / _ `\/\ \ /\ \/\ \  / __` __`\   ]],
		[[/\ \/\ \ \ \_/ /\ \ \/\ \/\ \/\ \  ]],
		[[\ \_\ \_\ \___/  \ \_\ \_\ \_\ \_\ ]],
		[[ \/_/\/_/\/__/    \/_/\/_/\/_/\/_/ ]],
	}
	dashboard.nvim_web_devicons.enabled = true
	dashboard.config.opts.noautocmd = false
	dashboard.section.top_buttons.val = {
		dashboard.button("e", "  Create New file", ":ene <BAR> startinsert <CR>"),
		dashboard.button("f", "   File tree", ":NvimTreeOpen<CR>"),
		dashboard.button("R", "   System REPL", ":terminal system repl<BAR> startinsert<CR>"),
		dashboard.button("S", "   System Switch", ":terminal sudo system switch<CR>"),
		dashboard.button("\\", "   Check Health", ":checkhealth<CR>"),
		dashboard.button("?", "   Find help ", ":FzfLua help_tags<CR>"),
	}
	alpha.setup(dashboard.config)
end)

utils.setup("cmp", function(cmp)
	local has_words_before = function()
		if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
			return false
		end
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
	end

	cmp.setup({
		enabled = function()
			-- dynamically toggle completion based on the current context.
			local context = require("cmp.config.context")
			-- enable completion when cursor is in a comment.
			if vim.api.nvim_get_mode().mode == "c" then
				return true
			end
			-- if we're in a comment don't autocomplete.
			if context.in_treesitter_capture("comment") or context.in_syntax_group("Comment") then
				return false
			end
			return true
		end,
		snippet = {
			-- REQUIRED - you must specify a snippet engine
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		formatting = {
			format = function(entry, vim_item)
				if vim.tbl_contains({ "path" }, entry.source.name) then
					local icon, hl_group = require("nvim-web-devicons").get_icon(entry:get_completion_item().label)
					if icon then
						vim_item.kind = icon
						vim_item.kind_hl_group = hl_group
						return vim_item
					end
				end
				return require("lspkind").cmp_format({ with_text = false })(entry, vim_item)
			end,
		},
		sorting = {
			priority_weight = 2,
			comparators = {
				require("copilot_cmp.comparators").prioritize,
				require("copilot_cmp.comparators").score,
				-- Below is the default comparitor list and order for nvim-cmp
				cmp.config.compare.offset,
				-- cmp.config.compare.scopes, --this is commented in nvim-cmp too
				cmp.config.compare.exact,
				cmp.config.compare.score,
				cmp.config.compare.recently_used,
				cmp.config.compare.locality,
				cmp.config.compare.kind,
				cmp.config.compare.sort_text,
				cmp.config.compare.length,
				cmp.config.compare.order,
			},
		},
		mapping = cmp.mapping.preset.insert({
			["<Tab>"] = vim.schedule_wrap(function(fallback)
				if cmp.visible() and has_words_before() then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				else
					fallback()
				end
			end),
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		}),
		sources = cmp.config.sources({
			{ name = "copilot", group_index = 2 },
			{ name = "buffer", group_index = 2 },
			{ name = "calc", group_index = 2 },
			{ name = "digraphs", group_index = 2 },
			{ name = "dictionary", group_index = 2, keyword_length = 2 },
			{ name = "path", group_index = 2, keyword_length = 2 },
			{ name = "rg", option = { additional_arguments = "--smart-case" } },
			{ name = "treesitter", group_index = 2 },
			-- { name = "omni", group_index = 3 }, -- potentially slow.
			{ name = "spell", group_index = 3 },
			{ name = "nvim_lsp", group_index = 2 },
			{ name = "nvim_lua", group_index = 2 },
			{ name = "emoji", group_index = 2 },
			{ name = "luasnip", group_index = 2 }, -- For luasnip users.
		}, {
			{ name = "buffer" },
		}),
	})

	cmp.setup.filetype("gitcommit", {
		sources = cmp.config.sources({ { name = "cmp_git" } }, { { name = "buffer" } }),
	})

	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
	})

	utils.setup("cmp_dictionary", { dic = { ["*"] = { "/usr/share/dict/words" } } })
end)

utils.setup("nvim-autopairs", {
	check_ts = true,
	ts_config = {
		lua = { "string", "source" },
		javascript = { "string", "template_string" },
		java = false,
	},
	disable_filetype = { "spectre_panel" },
	fast_wrap = {
		map = "<M-e>",
		chars = { "{", "[", "(", '"', "'" },
		pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
		keys = "qwertyuiopzxcvbnmasdfghjkl",
		offset = 0,
		end_key = "$",
		check_comma = true,
		highlight = "PmenuSel",
		highlight_grey = "LineNr",
	},
})

utils.setup("gitsigns", {
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "▎" },
		topdelete = { text = "契" },
		changedelete = { text = "▎" },
	},
})

utils.setup("fzf-lua", {
	fzf_colors = {
		["fg"] = { "fg", "CursorLine" },
		["bg"] = { "bg", "Normal" },
		["hl"] = { "fg", "Comment" },
		["fg+"] = { "fg", "Normal" },
		["bg+"] = { "bg", "CursorLine" },
		["hl+"] = { "fg", "Statement" },
		["info"] = { "fg", "PreProc" },
		["prompt"] = { "fg", "Conditional" },
		["pointer"] = { "fg", "Exception" },
		["marker"] = { "fg", "Keyword" },
		["spinner"] = { "fg", "Label" },
		["header"] = { "fg", "Comment" },
		["gutter"] = { "bg", "Normal" },
	},
})

utils.setup("aerial", {
	attach_mode = "global",
	backends = { "lsp", "treesitter", "markdown" },
	layout = {
		min_width = 28,
	},
	show_guides = true,
	filter_kind = false,
	guides = {
		mid_item = "├ ",
		last_item = "└ ",
		nested_top = "│ ",
		whitespace = "  ",
	},
	keymaps = {
		["[y"] = "actions.prev",
		["]y"] = "actions.next",
		["[Y"] = "actions.prev_up",
		["]Y"] = "actions.next_up",
		["{"] = false,
		["}"] = false,
		["[["] = false,
		["]]"] = false,
	},
})

utils.setup("lspkind", function(lspkind)
	lspkind.init({
		symbol_map = {
			Array = "",
			Boolean = "⊨",
			Class = "",
			Constructor = "",
			Key = "",
			NONE = "",
			Namespace = "",
			Null = "NULL",
			Number = "#",
			Object = "⦿",
			Package = "",
			Property = "",
			Reference = "",
			Snippet = "",
			String = "𝓐",
			TypeParameter = "",
			Unit = "",
			Copilot = "",
		},
	})
end)

utils.setup("which-key", function(wk)
	wk.register({
		["<leader>e"] = { "<cmd>NvimTreeToggle<cr>", "File Tree" },
		["<leader>/"] = {
			name = "+find",
			f = { "<cmd>FzfLua files<cr>", "files" },
			b = { "<cmd>FzfLua buffers<cr>", "buffers" },
			j = { "<cmd>FzfLua jumps<cr>", "jumps" },
			T = { "<cmd>FzfLua filetypes<cr>", "filetype" },
			t = { "<cmd>FzfLua tabs<cr>", "tabs" },
			l = { "<cmd>FzfLua loclist<cr>", "loclist" },
			q = { "<cmd>FzfLua quickfix<cr>", "qf" },
			["?"] = { "<cmd>FzfLua help_tags<cr>", "help tags" },
			R = { "<cmd>FzfLua registers<cr>", "registers" },
			m = { "<cmd>FzfLua marks<cr>", "marks" },
			M = { "<cmd>FzfLua man_pages<cr>", "man" },
			c = { "<cmd>FzfLua command_history<cr>", "command history" },
		},
	})

	wk.setup({
		plugins = {
			marks = true, -- shows a list of your marks on ' and `
			registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
			spelling = {
				enabled = true, -- show WhichKey when pressing z= to select spelling suggestions
				suggestions = 20, -- how many suggestions should be shown in the list?
			},
			-- the presets plugin, adds help for a bunch of default keybindings in Neovim
			-- No actual key bindings are created
			presets = {
				operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
				motions = true, -- adds help for motions
				text_objects = true, -- help for text objects triggered after entering an operator
				windows = true, -- default bindings on <c-w>
				nav = true, -- misc bindings to work with windows
				z = true, -- bindings for folds, spelling and others prefixed with z
				g = true, -- bindings for prefixed with g
			},
		},
		-- add operators that will trigger motion and text object completion
		-- to enable all native operators, set the preset / operators plugin above
		operators = { gc = "Comments" },
		key_labels = {
			-- override the label used to display some keys. It doesn't effect WK
			-- in any other way.
			["<space>"] = "SPC",
			["<cr>"] = "RET",
			["<tab>"] = "TAB",
		},
		icons = {
			breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
			separator = "➜", -- symbol used between a key and it's label
			group = "+", -- symbol prepended to a group
		},
		popup_mappings = {
			scroll_down = "<c-d>", -- binding to scroll down inside the popup
			scroll_up = "<c-u>", -- binding to scroll up inside the popup
		},
		window = {
			border = "none", -- none, single, double, shadow
			position = "bottom", -- bottom, top
			margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
			padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
			winblend = 0,
		},
		layout = {
			height = { min = 4, max = 25 }, -- min and max height of the columns
			width = { min = 20, max = 50 }, -- min and max width of the columns
			spacing = 3, -- spacing between columns
			align = "left", -- align columns left, center or right
		},
		ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
		hidden = {
			-- hide mapping boilerplate
			"<silent>",
			"<cmd>",
			"<Cmd>",
			"<CR>",
			"call",
			"lua",
			"^:",
			"^ ",
		},
		show_help = true, -- show help message on the command line when the popup is visible
		show_keys = true, -- show the currently pressed key and its label as a message in the command line
		triggers = "auto", -- automatically setup triggers
		-- triggers = {"<leader>"} -- or specify a list manually
		triggers_blacklist = {
			-- list of mode / prefixes that should never be hooked by WhichKey
			-- this is mostly relevant for key maps that start with a native binding
			-- most people should not need to change this
			i = { "j", "k" },
			v = { "j", "k" },
		},
		-- disable the WhichKey popup for certain buf types and file types.
		-- Disabled by deafult for Telescope
		disable = {
			buftypes = {},
			filetypes = { "TelescopePrompt" },
		},
	})
end)

utils.setup("nvim-tree", function(tree)
	local tree_cb = require("nvim-tree.config").nvim_tree_callback
	vim.g.nvim_tree_bindings = {
		{ key = { "<CR>", "o", "<2-LeftMouse>" }, cb = tree_cb("edit") },
		{ key = { "<2-RightMouse>", "<C-]>" }, cb = tree_cb("cd") },
		{ key = "<C-v>", cb = tree_cb("vsplit") },
		{ key = "<C-x>", cb = tree_cb("split") },
		{ key = "<C-t>", cb = tree_cb("tabnew") },
		{ key = "<", cb = tree_cb("prev_sibling") },
		{ key = ">", cb = tree_cb("next_sibling") },
		{ key = "P", cb = tree_cb("parent_node") },
		{ key = "<BS>", cb = tree_cb("close_node") },
		{ key = "<S-CR>", cb = tree_cb("close_node") },
		{ key = "<Tab>", cb = tree_cb("preview") },
		{ key = "K", cb = tree_cb("first_sibling") },
		{ key = "J", cb = tree_cb("last_sibling") },
		{ key = "I", cb = tree_cb("toggle_ignored") },
		{ key = "H", cb = tree_cb("toggle_dotfiles") },
		{ key = "R", cb = tree_cb("refresh") },
		{ key = "a", cb = tree_cb("create") },
		{ key = "d", cb = tree_cb("remove") },
		{ key = "r", cb = tree_cb("rename") },
		{ key = "<C-r>", cb = tree_cb("full_rename") },
		{ key = "x", cb = tree_cb("cut") },
		{ key = "c", cb = tree_cb("copy") },
		{ key = "p", cb = tree_cb("paste") },
		{ key = "y", cb = tree_cb("copy_name") },
		{ key = "Y", cb = tree_cb("copy_path") },
		{ key = "gy", cb = tree_cb("copy_absolute_path") },
		{ key = "[c", cb = tree_cb("prev_git_item") },
		{ key = "]c", cb = tree_cb("next_git_item") },
		{ key = "-", cb = tree_cb("dir_up") },
		{ key = "q", cb = tree_cb("close") },
		{ key = "g?", cb = tree_cb("toggle_help") },
	}
end)

--[[ Autocommands ]]
----------------------------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank()
	end,
	group = vim.api.nvim_create_augroup("config", { clear = false }),
})

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter"}, {
  pattern = "*",
	desc = "Activate relative numbering",
	callback = function()
    if vim.o.nu and vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt.relativenumber = true
    end
	end,
	group = "config",
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave"}, {
  pattern = "*",
	desc = "Deactivate relative numbering",
	callback = function()
    if vim.o.nu then
      vim.opt.relativenumber = false
      vim.cmd("redraw")
    end
	end,
	group = "config",
})



vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "InsertLeave" }, {
	desc = "Reset indent guide settings",
	callback = function()
		vim.opt.list = true
		vim.opt.listchars = { nbsp = "␣", tab = "│ ", trail = "•" }
		vim.opt.showbreak = "└ "
	end,
	group = "config",
})

vim.api.nvim_create_autocmd("BufWritePre", {
	desc = "String trailing whitespace from buffer",
	callback = function()
		if not (vim.bo.binary or vim.bo.filetype == "diff") then
			local winview = vim.fn.winsaveview()
			vim.api.nvim_command([[silent! %s/\s\+$//e]])
			vim.fn.winrestview(winview)
		end
	end,
	group = "config",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
	desc = "Organize Go imports.",
	callback = function ()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 0)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
  end,
	group = "config",
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Automatically set omnifun/tagfunc on attach",
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client.server_capabilities.completionProvider then
			vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
		end
		if client.server_capabilities.definitionProvider then
			vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
		end
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
	desc = "Automatically unset omnifun/tagfunc on detach",
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		-- Do something with the client
		vim.cmd("setlocal tagfunc< omnifunc<")
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Automatically set omnifun/tagfunc on attach",
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
		if client.server_capabilities.completionProvider then
			vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
		end
		if client.server_capabilities.definitionProvider then
			vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
		end
	end,
})

--[[ Commands ]]
--------------------------------------------------------------

vim.api.nvim_create_user_command("SpacesToTabs", function(tbl)
	vim.opt.expandtab = false
	local previous_tabstop = vim.bo.tabstop
	vim.opt.tabstop = tonumber(tbl.args)
	vim.api.nvim_command("retab!")
	vim.opt.tabstop = previous_tabstop
end, { force = true, nargs = 1 })

vim.api.nvim_create_user_command("TabsToSpaces", function(tbl)
	vim.opt.expandtab = true
	local previous_tabstop = vim.bo.tabstop
	vim.opt.tabstop = tonumber(tbl.args)
	vim.api.nvim_command("retab")
	vim.opt.tabstop = previous_tabstop
end, { force = true, nargs = 1 })

--[[ Finally ]]
--------------------------------------------------------------
-- theres are things I'm still too lazy to port into my lua configuration...
vim.cmd([[
if has("user_commands")
  command! -bang -nargs=? -complete=file E e<bang> <args>
  command! -bang -nargs=? -complete=file W w<bang> <args>
  command! -bang -nargs=? -complete=file Wq wq<bang> <args>
  command! -bang -nargs=? -complete=file WQ wq<bang> <args>
  command! -bang Wa wa<bang>
  command! -bang WA wa<bang>
  command! -bang Q q<bang>
  command! -bang QA qa<bang>
  command! -bang Qa qa<bang>
endif

nnoremap <silent> <C-e> <CMD>NvimTreeToggle<CR>
nnoremap <silent> <C-s> <CMD>write<CR>

]])
