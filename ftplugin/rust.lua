local map = vim.keymap.set

map("n", "<leader><localleader>r", "<cmd>RustLsp run<cr>", { buffer = true })
map("n", "<leader><localleader>R", "<cmd>RustLsp runables<cr>", { buffer = true })
map("n", "<leader><localleader>lr", "<cmd>RustLsp! run<cr>", { buffer = true })
map("n", "<leader><localleader>lR", "<cmd>RustLsp! runables<cr>", { buffer = true })

map("n", "<leader><localleader>e", "<cmd>RustLsp explainError current<cr>", { buffer = true })
map("n", "<leader><localleader>E", "<cmd>RustLsp expandMacro<cr>", { buffer = true })

map("n", "<leader><localleader>o", "<cmd>RustLsp openCargo<cr>", { buffer = true })
map("n", "<leader><localleader>p", "<cmd>RustLsp parentModule<cr>", { buffer = true })

map("n", "<leader><localleader>t", "<cmd>RustLsp testables<cr>", { buffer = true })
map("n", "<leader><localleader>lt", "<cmd>RustLsp! testables<cr>", { buffer = true })

map("n", "<leader><localleader>ar", "<cmd>RustAnalyzer restart<cr>", { buffer = true })
map("n", "<leader><localleader>aR", "<cmd>RustAnalyzer reloadSettings<cr>", { buffer = true })
map("n", "<leader><localleader>as", "<cmd>RustAnalyzer stop<cr>", { buffer = true })
