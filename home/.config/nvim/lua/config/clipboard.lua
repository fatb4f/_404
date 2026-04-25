local M = {}

local clip_cache = { {}, "v" }

local function xclip_env()
  local display = vim.env.DISPLAY
  if not display or display == "" then
    display = ":0"
  end

  local cmd = { "env", "DISPLAY=" .. display }
  if vim.env.XAUTHORITY and vim.env.XAUTHORITY ~= "" then
    table.insert(cmd, "XAUTHORITY=" .. vim.env.XAUTHORITY)
  end

  return cmd
end

local function run_helper(cmd, input)
  if vim.fn.executable(cmd) ~= 1 then
    return false
  end

  vim.fn.system(cmd, input or "")
  return vim.v.shell_error == 0
end

local function run_xclip(args, input)
  local xclip = vim.fn.expand("~/.local/bin/xclip")
  if vim.fn.executable(xclip) ~= 1 then
    return false
  end

  local cmd = vim.list_extend(xclip_env(), { xclip })
  vim.list_extend(cmd, args)
  vim.fn.system(cmd, input or "")
  return vim.v.shell_error == 0
end

local function copy(lines, regtype)
  local text = table.concat(lines, "\n")
  clip_cache = { lines, regtype }

  if run_xclip({ "-in", "-selection", "clipboard" }, text) then
    return
  end

  local copy_cmd = vim.fn.expand("~/.local/bin/copy")
  if run_helper(copy_cmd, text) then
    return
  end

  vim.notify("Clipboard copy failed", vim.log.levels.WARN)
end

local function paste()
  local xclip = vim.fn.expand("~/.local/bin/xclip")
  if vim.fn.executable(xclip) == 1 then
    local cmd = vim.list_extend(xclip_env(), { xclip, "-out", "-selection", "clipboard" })
    local result = vim.fn.systemlist(cmd)
    if vim.v.shell_error == 0 then
      return { result, "v" }
    end
  end

  local paste_cmd = vim.fn.expand("~/.local/bin/paste")
  if vim.fn.executable(paste_cmd) == 1 then
    local result = vim.fn.systemlist(paste_cmd)
    if vim.v.shell_error == 0 then
      return { result, "v" }
    end
  end

  return clip_cache
end

function M.setup()
  vim.opt.clipboard = "unnamedplus"
  vim.g.loaded_clipboard_provider = nil

  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = copy,
      ["*"] = copy,
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
    cache_enabled = false,
  }
end

return M
