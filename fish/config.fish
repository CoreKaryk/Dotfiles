function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

end

starship init fish | source

alias S 'paru -S'
alias Syu 'paru -Syyu'
alias R 'paru -Rns'
alias pamcan pacman
alias ls 'eza --icons'
alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias q 'qs -c ii'

# function fish_prompt
#   set_color cyan; echo (pwd)
#   set_color green; echo '> '
# end

# Created by `pipx` on 2025-09-04 14:42:48
set PATH $PATH $HOME/.local/bin

fastfetch
set -x QT_QPA_PLATFORMTHEME qt5ct
