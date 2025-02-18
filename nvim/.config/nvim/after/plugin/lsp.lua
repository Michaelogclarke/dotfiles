require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here 
  -- with the ones you want to install
  ensure_installed = {'lua_ls', 'harper_ls'},
  handlers = {
    function(harper_ls)
      require('lspconfig')[harper_ls].setup({})
    end,
  },
})
