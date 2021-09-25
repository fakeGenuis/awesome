--  _____   ___   ____    _____   _____    ___   __  __
-- |  ___| |_ _| |  _ \  | ____| |  ___|  / _ \  \ \/ /
-- | |_     | |  | |_) | |  _|   | |_    | | | |  \  /
-- |  _|    | |  |  _ <  | |___  |  _|   | |_| |  /  \
-- |_|     |___| |_| \_\ |_____| |_|      \___/  /_/\_\
--
--  _  __  _____  __   __  ____
-- | |/ / | ____| \ \ / / / ___|
-- | ' /  |  _|    \ V /  \___ \
-- | . \  | |___    | |    ___) |
-- |_|\_\ |_____|   |_|   |____/

local firefox_keys = {

    ["LibreWolf"] = {
       {
          modifiers = {"Alt"},
          keys = {
             x = "close current tab",
          }
       },
       {
          modifiers = {"Alt", "Shift"},
          keys = {
             [","] = "move tab to left",
             ["."] = "move tab to right",
          }
       },
       {
          modifiers = {"Ctrl", "Shift"},
          keys = {
             s = "open the LibreWolf Screenshots UI",
          }
       },
    },
    ["LibreWolf: Bitwarden"] = {
       {
          modifiers = {"Alt", "Shift"},
          keys = {
             l = "auto-fill",
             u = "open vault popup",
             ["9"] = "generate and copy a new random password"
          }
       }
    },
    ["LibreWolf: Tree Style Tab"] = {
       {
          modifiers = {"Ctrl", "Alt"},
          keys = {
             t = "toggle sidebar",
             e = "expand current tree",
          },
       },
       {
          modifiers = {"Alt", "Shift"},
          keys = {
             c = "collapse current tree",
             x = "close current tree",
          },
       },
    },
    ["LibreWolf: Other extensions"] = {
       {
          modifiers = {"Alt", "Shift"},
          keys = {
             a = "Dark Reader: toogle current site",
             d = "Dark Reader: toogle extension",
             s = "Grasp: quick capture url, title and selection",
             y = "Grasp: capture page, with extra information",
             ['space'] = "Simple Translate: open toolbar popup",
          },
       },
    }

}

return firefox_keys
