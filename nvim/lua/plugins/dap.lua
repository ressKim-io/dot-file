-- lua/plugins/dap.lua
-- 디버거: nvim-dap + dap-ui + Go/Python/JS 어댑터

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- DAP UI 설정
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.35 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 0.25,
            position = "bottom",
          },
        },
      })

      -- Virtual text 설정
      require("nvim-dap-virtual-text").setup()

      -- DAP UI 자동 열기/닫기
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Go 디버거 (Delve)
      require("dap-go").setup()

      -- Python 디버거 (debugpy)
      require("dap-python").setup("python3")

      -- JS/TS 디버거 (js-debug-adapter via mason)
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      for _, lang in ipairs({ "javascript", "typescript" }) do
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
        }
      end

      -- 키맵
      local map = vim.keymap.set
      map('n', '<F5>', dap.continue, {desc = 'Debug: Continue'})
      map('n', '<F9>', dap.toggle_breakpoint, {desc = 'Debug: Toggle Breakpoint'})
      map('n', '<F10>', dap.step_over, {desc = 'Debug: Step Over'})
      map('n', '<F11>', dap.step_into, {desc = 'Debug: Step Into'})
      map('n', '<S-F11>', dap.step_out, {desc = 'Debug: Step Out'})
      map('n', '<leader>du', function() dapui.toggle() end, {desc = 'Debug: Toggle UI'})
      map('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, {desc = 'Debug: Conditional Breakpoint'})
      map('n', '<leader>dr', dap.repl.open, {desc = 'Debug: Open REPL'})
      map('n', '<leader>dl', dap.run_last, {desc = 'Debug: Run Last'})

      -- 브레이크포인트 아이콘
      vim.fn.sign_define('DapBreakpoint', {text='B', texthl='DiagnosticError'})
      vim.fn.sign_define('DapBreakpointCondition', {text='C', texthl='DiagnosticWarn'})
      vim.fn.sign_define('DapStopped', {text='>', texthl='DiagnosticOk', linehl='DapStoppedLine'})
    end,
  },
}
