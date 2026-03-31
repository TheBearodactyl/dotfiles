use std "path add"

# xdg stuff
$env.XDG_DATA_HOME = $"($env.HOME)/.local/share"
$env.XDG_STATE_HOME = $"($env.HOME)/.local/state"
$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
$env.XDG_CACHE_HOME = $"($env.HOME)/.cache"

$env.CARGO_HOME = $"($env.XDG_DATA_HOME)/cargo"
$env.NPM_CONFIG_INIT_MODULE = $"($env.XDG_CONFIG_HOME)/npm/config/npm-init.js"
$env.NPM_CONFIG_CACHE = $"($env.XDG_CACHE_HOME)/npm"
$env.NPM_CONFIG_TMP = $"($env.XDG_RUNTIME_DIR)/npm"
$env.OPAMROOT = $"($env.XDG_DATA_HOME)/opam"
$env.RUSTUP_HOME = $"($env.XDG_DATA_HOME)/rustup"
$env.CUDA_CACHE_PATH = $"($env.XDG_CACHE_HOME)/nv"
$env.GNUPGHOME = $"($env.XDG_DATA_HOME)/gnupg"
$env.GTK2_RC_FILES = $"($env.XDG_CONFIG_HOME)/gtk-2.0/gtkrc"
$env.XMAKE_GLOBALDIR = $"($env.XDG_CONFIG_HOME)/xmake"
$env.XMAKE_PKG_INSTALLDIR = $"($env.XDG_DATA_HOME)/xmake"
$env.XMAKE_PKG_CACHEDIR = $"($env.XDG_CACHE_HOME)/xmake"
$env.GHCUP_USE_XDG_DIRS = true
$env.STACK_XDG = true

$env.GEODE_SDK = $"($env.HOME)/.junk/xdg/Documents/Geode"
$env.EDITOR = "nvim"

path add "~/.local/bin"
path add $"($env.CARGO_HOME)/bin"
path add $"($env.XDG_CACHE_HOME)/.bun/bin"
path add $"($env.HOME)/.cabal/bin"
path add $"($env.XDG_DATA_HOME)/gem/ruby/3.4.0/bin"

do --env {
    let ssh_agent_file = (
        $nu.temp-dir | path join $"ssh-agent-(whoami).nuon"
    )

    if ($ssh_agent_file | path exists) {
        let ssh_agent_env = open ($ssh_agent_file)
        if ($"/proc/($ssh_agent_env.SSH_AGENT_PID)" | path exists) {
            load-env $ssh_agent_env
            return
        } else {
            rm $ssh_agent_file
        }
    }

    let ssh_agent_env = ^ssh-agent -c
        | lines
        | first 2
        | parse "setenv {name} {value};"
        | transpose --header-row
        | into record

    load-env $ssh_agent_env
    $ssh_agent_env | safe --force $ssh_agent_file
}

let mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force
