-- Clangd - C/C++ Language Server
return {
  cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=iwyu', '--completion-style=detailed', '--function-arg-placeholders' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
}
