return {
    { -- This helps with php/html for indentation
        'captbaritone/better-indent-support-for-php-with-html',
    },
    { -- This helps with ssh tunneling and copying to clipboard
        'ojroques/vim-oscyank',
    },
    { -- This generates docblocks
        'kkoomen/vim-doge',
        build = ':call doge#install()'
    },
    { -- Git plugin
        'tpope/vim-fugitive',
    },
    { -- Show historical versions of the file locally
        'mbbill/undotree',
    },
    { -- Show CSS Colors
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup({})
        end
    },
    { -- Git signs
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    },
 
    { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
    {
        "chentoast/marks.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "azabiong/vim-highlighter",
        init = function()
            -- settings
        end,
    },
}
