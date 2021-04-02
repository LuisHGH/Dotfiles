-- LSP (Neovim 0.5 built-in lsp client)

-- Set completeopt to have a better completion experience
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force user to select one from the menu
vim.o.completeopt = "menuone,noinsert,noselect"

-- TODO add documentation to this line
vim.g.completion_matching_strategy_list = {"exact", "substring", "fuzzy"}

-- ------------------- Mappings ----------------------------------------------

-- Mapping function
local function noremap(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- ------------------- Language server setups ----------------------------------------------

local on_attach = function(client)
    -- diagnostics
    noremap("n", "<leader>fd", "<cmd>lua require('telescope.builtin').lsp_document_diagnostics")
    noremap("n", "<silent> g[", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>")
    noremap("n", "<silent> g]", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>")

    -- autocommands
    vim.cmd [[augroup LuaAutoCommands]]
    vim.cmd [[au!]] -- This prevents having the autocommands defined twice (e.g., after sourcing the vimrc file again).
    vim.cmd [[autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]] -- Show diagnostic popup on cursor hold
    -- Enable type inlay hints
    vim.cmd [[autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost * lua require'lsp_extensions'.inlay_hints{ prefix = '', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }]]
    vim.cmd [[augroup END]]

    if client.resolved_capabilities.hover then
        vim.cmd "nnoremap <silent>K <cmd>lua vim.lsp.buf.hover()<CR>" -- map K to show documentation in preview window
    end
    if client.resolved_capabilities.goto_definition then
        vim.cmd "nnoremap <silent>gd <cmd>lua require('telescope.builtin').lsp_definitions()<CR>" -- map gd to goto definition
    end
    if client.resolved_capabilities.implementation then
        vim.cmd "nnoremap <silent>gD <cmd>lua vim.lsp.buf.implementation()<CR>" -- Use gD to see all implementations
    end
    if client.resolved_capabilities.completion then
        vim.cmd "inoremap <silent><expr> <C-Space> compe#complete()" -- map <c-space> to manually trigger completion
        vim.cmd 'inoremap <silent><expr> <CR> compe#confirm("<CR>")' -- map <CR> to confirm completion
        vim.cmd 'inoremap <silent><expr> <C-e> compe#close("<C-e>")' -- map <C-e> to close completion
    end
    if client.resolved_capabilities.rename then
        noremap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>") -- map <leader>rn to rename all references to the symbol under the cursor
    end
    if client.resolved_capabilities.code_action then
        vim.cmd [[augroup CodeAction]]
        vim.cmd [[autocmd! * <buffer>]]
        vim.cmd [[autocmd CursorHold * lua require'nvim-lightbulb'.update_lightbulb()]]
        vim.cmd [[augroup END]]

        noremap("n", "<leader>ca", "<cmd>lua require('telescope.builtin').lsp_code_actions()<CR>")
    end
    -- if client.resolved_capabilities.document_formatting then
    --    vim.cmd [[augroup Format]]
    --    vim.cmd [[autocmd! * <buffer>]]
    --    vim.cmd [[autocmd BufWritePost <buffer> lua formatting()]]
    --    vim.cmd [[augroup END]]
    -- end
end

local lspconfig = require "lspconfig"

lspconfig.vimls.setup {on_attach = on_attach}

lspconfig.intelephense.setup {on_attach = on_attach}

lspconfig.pyls.setup {on_attach = on_attach}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.rust_analyzer.setup {
    capabilities = capabilities,
    on_attach = on_attach
}

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        virtual_text = true,
        signs = true,
        update_in_insert = true
    }
)

-- TsServer + Efm (for ESLint)
local eslint = {
    lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
    lintIgnoreExitCode = true,
    formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
    formatStdin = true
}

lspconfig.tsserver.setup {
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        on_attach(client)
    end
}

local function eslint_config_exists()
    local eslintrc = vim.fn.glob(".eslintrc*", 0, 1)

    if not vim.tbl_isempty(eslintrc) then
        return true
    end

    if vim.fn.filereadable("package.json") then
        if vim.fn.json_decode(vim.fn.readfile("package.json"))["eslintConfig"] then
            return true
        end
    end

    return false
end

lspconfig.efm.setup {
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = true
        client.resolved_capabilities.goto_definition = false
        on_attach(client)
    end,
    root_dir = function()
        if not eslint_config_exists() then
            return nil
        end
        return vim.fn.getcwd()
    end,
    settings = {
        languages = {
            javascript = {eslint},
            javascriptreact = {eslint},
            ["javascript.jsx"] = {eslint},
            typescript = {eslint},
            ["typescript.tsx"] = {eslint},
            typescriptreact = {eslint}
        }
    },
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescript.tsx",
        "typescriptreact"
    }
}

--require('nlua.lsp.nvim').setup(lspconfig, {
--	-- Include globals you want to tell the LSP are real :)
--	globals = {
--    -- NodeMCU modules --
--          'file',
--          'gpio',
--          'http',
--          'net',
--          'node',
--          'sjson',
--          'softuart',
--          'tmr',
--          'uart',
--          'wifi'
--    ---------------------
--  }
--})

-- ------------------- Additional features ----------------------------------------------

-- VsCode-like icons
require "lspkind".init {with_text = true}

-- Auto completion (nvim-compe)
require "compe".setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = "enable",
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    source = {
        path = true,
        buffer = true,
        -- calc = true,
        vsnip = true,
        ultisnips = true,
        nvim_lsp = true,
        nvim_lua = true,
        -- spell = true,
        tags = true
        -- snippets_nvim = true,
        -- treesitter = true
    }
}

-- Code Actions (nvim-lightbulb)
require "nvim-lightbulb".update_lightbulb {
    sign = {
        enabled = true,
        -- Priority of the gutter sign
        priority = 10
    },
    float = {
        enabled = false,
        -- Text to show in the popup float
        text = "💡",
        -- Available keys for window options:
        -- - height     of floating window
        -- - width      of floating window
        -- - wrap_at    character to wrap at for computing height
        -- - max_width  maximal width of floating window
        -- - max_height maximal height of floating window
        -- - pad_left   number of columns to pad contents at left
        -- - pad_right  number of columns to pad contents at right
        -- - pad_top    number of lines to pad contents at top
        -- - pad_bottom number of lines to pad contents at bottom
        -- - offset_x   x-axis offset of the floating window
        -- - offset_y   y-axis offset of the floating window
        -- - anchor     corner of float to place at the cursor (NW, NE, SW, SE)
        -- - winblend   transparency of the window (0-100)
        win_opts = {}
    },
    virtual_text = {
        enabled = false,
        -- Text to show at virtual text
        text = "💡"
    }
}
