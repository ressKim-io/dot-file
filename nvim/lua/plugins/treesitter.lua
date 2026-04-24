-- lua/plugins/treesitter.lua
-- treesitter + 추가 파서

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
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
        -- 동기 설치 끄기: gcc 부재 등으로 빌드 실패 시 startup 블로킹 방지
        sync_install = false,
        -- 파일 열 때 자동 설치 끄기: 에러 캐스케이드(Noice 팝업 무한 루프) 방지
        auto_install = false,
        highlight = {
          enable = true,
          -- 파서 미설치 시 조용히 넘어감 (silent fallback)
          disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then return true end
            return false
          end,
        },
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
