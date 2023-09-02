local config = {}

config.terminal = "xterm"
config.editor = os.getenv("EDITOR") or "vim"
config.editor_cmd = config.terminal .. " -e " .. config.editor
config.modekey = "Mod4"

return config