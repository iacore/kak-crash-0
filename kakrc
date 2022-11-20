evaluate-commands %sh{
    autoload_directory() {
        find -L "$1" -type f -name '*\.kak' \
            | sed 's/.*/try %{ source "&" } catch %{ echo -debug Autoload: could not load "&" }/'
    }

    autoload_directory /usr/share/kak/autoload
}
map global insert <c-left> '<esc>b;i'
map global insert <c-right> '<esc>w;i'
hook global ModeChange pop:insert:.* %{
    unmap window insert <tab>
    unmap window insert <s-tab>
}

hook global ModeChange push:.*:insert %{
    map window insert <tab> '<a-;><a-gt>'
    map window insert <s-tab> '<a-;><a-lt>'
}

#hook global NormalKey y %{ nop %sh{
#      printf %s "$kak_main_reg_dquote" | xsel --input --clipboard
#}}
#
#
#hook global WinSetOption filetype= %{
#    map window user P '!xsel --output --clipboard<ret>'
#    map window user p '<a-!>xsel --output --clipboard<ret>'
#    map window user R '|xsel --output --clipboard<ret>'
#}
#

source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

plug 'NNBnh/clipb.kak' config %{
    clipb-detect
}

plug "eraserhd/parinfer-rust" noload do %{
        cargo install --path .
} config %{
        hook global WinSetOption filetype=(clojure|lisp|scheme|racket|janet) %{
                    parinfer-enable-window -smart
        }
}

plug "https://gitlab.com/Screwtapello/kakoune-state-save" %{
    define-command -hidden state-save %{
        state-save-reg-save colon
        state-save-reg-save pipe
        state-save-reg-save slash
    }

    hook global KakBegin .* state-save
    hook global KakEnd .* state-save
    hook global FocusOut .* %{ state-save-reg-save dquote }
    hook global FocusIn  .* %{ state-save-reg-load dquote }
}

hook global WinSetOption filetype=.* %{
    hook -group 'clipb' window WinCreate        .* %{ clipb-get }
    hook -group 'clipb' window FocusIn          .* %{ clipb-get }
    hook -group 'clipb' window NormalKey y %{ clipb-set }
}

plug "andreyorst/kaktree" config %{
    hook global WinSetOption filetype=kaktree %{
        remove-highlighter buffer/numbers
        remove-highlighter buffer/matching
        remove-highlighter buffer/wrap
        remove-highlighter buffer/show-whitespaces
    }
    kaktree-enable
}

plug "andreyorst/kaktree" defer kaktree %{
    set-option global kaktree_double_click_duration '0.5'
    set-option global kaktree_indentation 1
    set-option global kaktree_dir_icon_open  '▾ 🗁 '
    set-option global kaktree_dir_icon_close '▸ 🗀 '
    set-option global kaktree_file_icon      '⠀⠀🖺'
} config %{...}

hook global KakBegin .* %{
    state-save-reg-load colon
    state-save-reg-load pipe
    state-save-reg-load slash
    addhl global/ number-lines -separator ''
    addhl global/ wrap
}

hook global KakEnd .* %{
    state-save-reg-save colon
    state-save-reg-save pipe
    state-save-reg-save slash
}



### kak-lsp config start
eval %sh{kak-lsp --kakoune -s $kak_session}  # Not needed if you load it with plug.kak.
lsp-enable
lsp-inlay-hints-enable global
lsp-inlay-diagnostics-enable global

# enable for all languages that we want to use the LSP, here we're enabling C++ and Zig.
hook global WinSetOption filetype=(cpp|zig) %{
    lsp-enable-window
    # the options below are optional (and self-explanatory)
    lsp-auto-hover-enable
    lsp-auto-signature-help-enable
    lsp-auto-hover-insert-mode-disable
}

