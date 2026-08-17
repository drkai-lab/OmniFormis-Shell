-- Colemak-DH Keybindings Configuration for Neovim (Full Physical Layout)

-- -------------------------------------------------------------------
-- Langmap: Translates Colemak-DH keys back to QWERTY in Normal/Visual/Op-pending modes
-- This ensures that every physical key on a Colemak-DH keyboard executes
-- the Vim command that resides in the exact same physical position on a QWERTY keyboard.
-- -------------------------------------------------------------------
vim.opt.langmap = 'fe,FE,pr,PR,bt,BT,jy,JY,lu,LU,ui,UI,yo,YO,\\;p,:P,rs,RS,sd,SD,tf,TF,mh,MH,nj,NJ,ek,EK,il,IL,o\\;,O:,dv,DV,vb,VB,kn,KN,hm,HM'

-- -------------------------------------------------------------------
-- Lazy.nvim & Theme Integration
-- -------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "RRethy/nvim-base16",
    lazy = false,
    priority = 1000,
  }
})

local function source_matugen()
  local matugen_path = os.getenv("HOME") .. "/.config/nvim/generated.lua"
  local file, err = io.open(matugen_path, "r")
  if err == nil then
    dofile(matugen_path)
    io.close(file)
  end
end

source_matugen()
