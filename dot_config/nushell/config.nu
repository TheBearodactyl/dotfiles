$env.config.show_banner = false

let fish_completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {|row|
      let value = $row.value
      let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
      if ($need_quote and ($value | path exists)) {
        let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
        $'"($expanded_path | str replace --all "\"" "\\\"")"'
      } else {$value}
    }
}

let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -o 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        _ => $fish_completer
    } | do $in $spans
}

$env.config = {
    completions: {
        external: {
            enable: true
            completer: $external_completer
        }
    }
}

def rld [] {
    clear
    uwufetch -r
    eza -a --git --icons --group-directories-first
}

def mkcd --env [path: path] {
    if not ($path | path exists) {
        mkdir $path
    }

    cd $path
    rld
}

def pgrep [pattern: string]: nothing -> list<record> {
    ps | where {|x|
        $x.name | str contains $pattern
    }
}

def "init bash" [path: path] {
    if not ($path | path exists) {
        "#!/usr/bin/env bash" | save $path
    }
}

def h --env [] {
    cd
    rld
}

def j --env [] {
    cd ~/.junk
    rld
}

alias pacman = sudo pacman

use ($nu.default-config-dir | path join mise.nu)
use ($nu.default-config-dir | path join commands.nu)
use ($nu.default-config-dir | path join integrations | path join opam.nu)

try {
    rm -fr /home/emilia/.pulse-cookie
    rm -fr /home/emilia/.pki
    rm -fr /home/emilia/.nv
} catch {|e|
    $e | ignore
}

rld
