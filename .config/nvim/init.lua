-- bootstrap lazy.nvim, LazyVim and your plugins
do
  local path = vim.env.PATH or ""
  local wanted = {
    "/home/x404/.local/bin",
    "/home/x404/.local/opt/kitty/bin",
  }

  for i = #wanted, 1, -1 do
    local dir = wanted[i]
    if not path:find(dir, 1, true) then
      path = dir .. ":" .. path
    end
  end

  vim.env.PATH = path
end

require("config.lazy")
