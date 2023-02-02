-- Source ~/.vimrc
vim.cmd('source ~/.vimrc')

require('nvim-autopairs').setup({
    enable_check_bracket_line = false
})

local lsp = require('lspconfig')
for _, lsp_name in ipairs({
    'sumneko_lua',
    'texlab',
    'gopls',
    'pylsp',
}) do
    lsp[lsp_name].setup{
        capabilities = require'cmp_nvim_lsp'.default_capabilities()
    }
end

local cmp = require('cmp')
cmp.setup({
    snippet = {
        -- XXX: REQUIRED
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    }),
})



-- vim: et sw=4 ts=4 sts=4
