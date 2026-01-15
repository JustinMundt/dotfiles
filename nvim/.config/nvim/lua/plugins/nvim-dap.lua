return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- UI for debugging
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'nvim-neotest/nvim-nio' },
    },

    -- Virtual text for variable values
    'theHamsta/nvim-dap-virtual-text',

    -- Mason integration for installing debug adapters
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Language-specific extensions
    'mfussenegger/nvim-dap-python', -- Python
    'leoluz/nvim-dap-go', -- Go
  },
  keys = {
    -- Breakpoints
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end,
      desc = 'Debug: Conditional Breakpoint',
    },
    {
      '<leader>dl',
      function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
      end,
      desc = 'Debug: Log Point',
    },

    -- Execution control
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<leader>do',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<leader>dO',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>dr',
      function()
        require('dap').restart()
      end,
      desc = 'Debug: Restart',
    },
    {
      '<leader>dq',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug: Terminate',
    },

    -- UI
    {
      '<leader>du',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: Toggle UI',
    },
    {
      '<leader>de',
      function()
        require('dapui').eval()
      end,
      mode = { 'n', 'v' },
      desc = 'Debug: Evaluate Expression',
    },

    -- REPL
    {
      '<leader>dR',
      function()
        require('dap').repl.toggle()
      end,
      desc = 'Debug: Toggle REPL',
    },

    -- Run last
    {
      '<leader>dL',
      function()
        require('dap').run_last()
      end,
      desc = 'Debug: Run Last',
    },
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    -- Mason DAP setup - auto-install debug adapters
    require('mason-nvim-dap').setup({
      automatic_installation = true,
      ensure_installed = {
        'debugpy', -- Python
        'delve', -- Go
        'js-debug-adapter', -- JavaScript/TypeScript
        'codelldb', -- Rust, C, C++
      },
      handlers = {},
    })

    -- DAP UI setup
    dapui.setup({
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    })

    -- Virtual text setup
    require('nvim-dap-virtual-text').setup({
      commented = true, -- Show virtual text alongside comment
    })

    -- Automatically open/close DAP UI
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    -- Breakpoint signs
    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define(
      'DapBreakpointCondition',
      { text = '◐', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' }
    )
    vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = '' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })

    -- Highlight for current stopped line
    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#e5a514' })
    vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4d3d' })

    -- =========================================================================
    -- Python Configuration
    -- =========================================================================
    require('dap-python').setup('python3')

    -- =========================================================================
    -- Go Configuration
    -- =========================================================================
    require('dap-go').setup()

    -- =========================================================================
    -- JavaScript/TypeScript Configuration
    -- =========================================================================
    -- js-debug-adapter is installed via Mason
    local js_debug_path = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter'

    for _, adapter in ipairs({ 'pwa-node', 'pwa-chrome' }) do
      dap.adapters[adapter] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = { js_debug_path .. '/js-debug/src/dapDebugServer.js', '${port}' },
        },
      }
    end

    for _, language in ipairs({ 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }) do
      dap.configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to process',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Debug Jest Tests',
          runtimeExecutable = 'node',
          runtimeArgs = { './node_modules/jest/bin/jest.js', '--runInBand' },
          rootPath = '${workspaceFolder}',
          cwd = '${workspaceFolder}',
          console = 'integratedTerminal',
          internalConsoleOptions = 'neverOpen',
        },
      }
    end

    -- =========================================================================
    -- Rust/C/C++ Configuration (codelldb)
    -- =========================================================================
    local codelldb_path = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/codelldb'
    local liblldb_path = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/lldb/lib/liblldb.so'

    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = codelldb_path,
        args = { '--port', '${port}' },
      },
    }

    -- Rust
    dap.configurations.rust = {
      {
        name = 'Launch',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    -- C
    dap.configurations.c = {
      {
        name = 'Launch',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    -- C++
    dap.configurations.cpp = dap.configurations.c
  end,
}
