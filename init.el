(package-initialize)

(require 'org)
(require 'ob-tangle)

(setq init-dir (file-name-directory (or load-file-name (buffer-file-name))))
(org-babel-load-file (expand-file-name "loader.org" init-dir))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (auto-dim-other-buffers magit to buffer-move zoom command-log-mode mode-icons dockerfile-mode clj-refactor cider clojure-snippets highlight-parentheses paredit-everywhere paredit ace-jump-mode ace-window yasnippet-snippets which-key use-package symon switch-window sudo-edit spacemacs-theme spaceline solarized-theme smex rainbow-delimiters pretty-mode popup-kill-ring org-bullets oceanic-theme nimbus-theme material-theme mark-multiple lsp-ui lsp-java ivy-hydra ido-vertical-mode hungry-delete google-translate exwm expand-region eterm-256color dmenu dimmer diminish dashboard counsel-projectile company-lsp company-irony color-theme-sanityinc-tomorrow beacon avy arjen-grey-theme)))
 '(zoom-ignored-buffer-names (quote ("*command-log*")))
 '(zoom-ignored-major-modes (quote (dired-mode markdown-mode)))
 '(zoom-mode t nil (zoom))
 '(zoom-size (quote (0.618 . 0.618))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
