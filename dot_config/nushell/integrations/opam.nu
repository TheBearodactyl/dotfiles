export-env {
    $env.OPAM_SHELL = "nu"
    let opam_hook = {
        condition: { "OPAM_SHELL" in $env }
        code: { update-opam-env }
    }

    add-hook hooks.pre_prompt $opam_hook
}

def --env add-hook [field: cell-path new_hook: any] {
    let old_config = $env.config? | default {}
    let old_hooks = $old_config | get --optional $field | default []
    let new_hooks = $old_hooks ++ [$new_hook]
    $env.config = $old_config | upsert $field $new_hooks
}

def --env update-env [] {
    for $opam in $in {
        if $opam.var == "PATH" {
            $env.PATH = ($opam.val | split row (char esep))
        } else {
            load-env {($opam.var): $opam.val}
        }
    }
}

def --env update-opam-env [] {
    ^"/usr/bin/env" opam env --shell=sh --switch=5.4.0 --set-switch
        | parse "{var}='{val}'; export {var2};"
        | update-env
}
