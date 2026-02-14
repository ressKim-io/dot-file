-- lua/plugins/treesitter.lua
-- treesitter + 추가 파서

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          -- 기존
          "go", "python", "javascript", "typescript", "java",
          "lua", "bash", "yaml", "json", "hcl", "dockerfile",
          -- 추가
          "toml", "make", "markdown", "markdown_inline",
          "vim", "vimdoc", "regex", "terraform", "html", "css",
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },
}
