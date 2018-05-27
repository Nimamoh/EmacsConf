
(setq user-full-name "Romain Gautier")
(setq user-mail-address "romain.gautier@nimamoh.net")

;;  (if (fboundp 'gnutls-available-p)
;;      (fmakunbound 'gnutls-available-p))

(require 'cl)
(setq tls-checktrust t)

(setq python (or (executable-find "py.exe")
                 (executable-find "python")
                 ))

(let ((trustfile
       (replace-regexp-in-string
        "\\\\" "/"
        (replace-regexp-in-string
         "\n" ""
         (shell-command-to-string (concat python " -m certifi"))))))
  (setq tls-program
        (list
         (format "gnutls-cli%s --x509cafile %s -p %%p %%h"
                 (if (eq window-system 'w32) ".exe" "") trustfile)))
  (setq gnutls-verify-error t)
  (setq gnutls-trustfiles (list trustfile)))

;; Test the settings by using the following code snippet:
;;  (let ((bad-hosts
;;         (loop for bad
;;               in `("https://wrong.host.badssl.com/"
;;                    "https://self-signed.badssl.com/")
;;               if (condition-case e
;;                      (url-retrieve
;;                       bad (lambda (retrieved) t))
;;                    (error nil))
;;               collect bad)))
;;    (if bad-hosts
;;        (error (format "tls misconfigured; retrieved %s ok" bad-hosts))
;;      (url-retrieve "https://badssl.com"
;;                    (lambda (retrieved) t))))

;; http://stackoverflow.com/questions/11679700/emacs-disable-beep-when-trying-to-move-beyond-the-end-of-the-document
(defun my-bell-function ())

(setq ring-bell-function 'my-bell-function)
(setq visible-bell nil)

(require 'package)

(defvar gnu '("gnu" . "https://elpa.gnu.org/packages/"))
(defvar melpa '("melpa" . "https://melpa.org/packages/"))
(defvar melpa-stable '("melpa-stable" . "https://stable.melpa.org/packages/"))
(defvar org-elpa '("org" . "http://orgmode.org/elpa/"))

;; Add marmalade to package repos
(setq package-archives nil)
(add-to-list 'package-archives melpa-stable t)
(add-to-list 'package-archives melpa t)
(add-to-list 'package-archives gnu t)
(add-to-list 'package-archives org-elpa t)

(package-initialize)

(unless (and (file-exists-p (concat init-dir "elpa/archives/gnu"))
             (file-exists-p (concat init-dir "elpa/archives/melpa"))
             (file-exists-p (concat init-dir "elpa/archives/melpa-stable")))
  (package-refresh-contents))

(defun packages-install (&rest packages)
  (message "running packages-install")
  (mapc (lambda (package)
          (let ((name (car package))
                (repo (cdr package)))
            (when (not (package-installed-p name))
              (let ((package-archives (list repo)))
                (package-initialize)
                (package-install name)))))
        packages)
  (package-initialize)
  (delete-other-windows))

;; Install extensions if they're missing
(defun init--install-packages ()
  (message "Lets install some packages")
  (packages-install
   ;; Since use-package this is the only entry here
   ;; ALWAYS try to use use-package!
   (cons 'use-package melpa)
   ))

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))

(use-package command-log-mode
  :ensure t)
(setq global-command-log-mode 1)

(defun find-config-file ()
  (interactive)
  (find-file "~/.emacs.d/loader.org"))

(global-set-key (kbd "C-c e") 'find-config-file)

(defun config-reload ()
  "Reloads ~/.emacs.d/config.org at runtime"
  (interactive)
  (org-babel-load-file (expand-file-name "~/.emacs.d/loader.org"))
  (spaceline-compile))
(global-set-key (kbd "C-c r") 'config-reload)

(fset 'yes-or-no-p 'y-or-n-p)

(use-package counsel
    :ensure t
    :bind
    (("M-x" . counsel-M-x)
     ("M-y" . counsel-yank-pop)
     :map ivy-minibuffer-map
     ("M-y" . ivy-next-line)))

   (use-package swiper
     :pin melpa-stable
     :ensure t
     :bind*
     (("C-s" . swiper)
      ("C-c C-r" . ivy-resume)
      ("C-x C-f" . counsel-find-file)
      ("C-c h f" . counsel-describe-function)
      ("C-c h v" . counsel-describe-variable)
      ("C-c i u" . counsel-unicode-char)
      ("M-i" . counsel-imenu)
      ("C-c g" . counsel-git)
      ("C-c j" . counsel-git-grep)
      ("C-c k" . counsel-ag)
;;      ("C-c l" . scounsel-locate)
)
     :config
     (progn
       (ivy-mode 1)
       (setq ivy-use-virtual-buffers t)
       (define-key read-expression-map (kbd "C-r") #'counsel-expression-history)
       (ivy-set-actions
        'counsel-find-file
        '(("d" (lambda (x) (delete-file (expand-file-name x)))
           "delete"
           )))
       (ivy-set-actions
        'ivy-switch-buffer
        '(("k"
           (lambda (x)
             (kill-buffer x)
             (ivy--reset-state ivy-last))
           "kill")
          ("j"
           ivy--switch-buffer-other-window-action
           "other window")))))

  (use-package counsel-projectile
    :ensure t
    :config
    (counsel-projectile-mode))

  (use-package ivy-hydra :ensure t)

;; Fuzzy matching with ivy
(use-package flx
  :ensure t)
(setq ivy-re-builders-alist
      '((swiper . ivy--regex-plus)
        (t      . ivy--regex-fuzzy)))

(global-set-key (kbd "C-x k") 'kill-this-buffer)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

(use-package avy
  :ensure t
  :bind
  ("M-s" . avy-goto-char))

(defun toggle-maximize-buffer () "Maximize buffer"
  (interactive)
  (if (= 1 (length (window-list)))
      (jump-to-register '_) 
    (progn
      (window-configuration-to-register '_)
      (delete-other-windows))))

(global-set-key (kbd "C-x _") 'toggle-maximize-buffer)

(use-package switch-window
  :ensure t)
(require 'switch-window)
;; replace with switch window
(global-set-key (kbd "C-x o") 'switch-window)
(global-set-key (kbd "C-x 1") 'switch-window-then-maximize)
(global-set-key (kbd "C-x 2") 'switch-window-then-split-below)
(global-set-key (kbd "C-x 3") 'switch-window-then-split-right)
(global-set-key (kbd "C-x 0") 'switch-window-then-delete)

(global-set-key (kbd "C-x 4 d") 'switch-window-then-dired)
(global-set-key (kbd "C-x 4 f") 'switch-window-then-find-file)
(global-set-key (kbd "C-x 4 m") 'switch-window-then-compose-mail)
(global-set-key (kbd "C-x 4 r") 'switch-window-then-find-file-read-only)

(global-set-key (kbd "C-x 4 C-f") 'switch-window-then-find-file)
(global-set-key (kbd "C-x 4 C-o") 'switch-window-then-display-buffer)

(global-set-key (kbd "C-x 4 0") 'switch-window-then-kill-buffer)

;; Move a la vi
(setq switch-window-shortcut-style 'qwerty)
(setq switch-window-qwerty-shortcuts
      '("a" "s" "d" "f" "j" "k" "l" ";" "w" "e" "i" "o"))

(use-package zoom
  :ensure t)
(custom-set-variables
 '(zoom-mode t))
(custom-set-variables
 '(zoom-size '(0.618 . 0.618)))

(custom-set-variables
 '(zoom-ignored-major-modes '(dired-mode markdown-mode))
 '(zoom-ignored-buffer-names '("*command-log*")))

(use-package buffer-move
  :ensure t)
(global-set-key (kbd "<C-S-up>")     'buf-move-up)
(global-set-key (kbd "<C-S-down>")   'buf-move-down)
(global-set-key (kbd "<C-S-left>")   'buf-move-left)
(global-set-key (kbd "<C-S-right>")  'buf-move-right)

(add-hook 'org-mode-hook '(lambda ()
   (local-set-key [C-S-up]    'buf-move-up)
   (local-set-key [C-S-down]  'buf-move-down)
   (local-set-key [C-S-left]  'buf-move-left)
   (local-set-key [C-S-right] 'buf-move-right)))

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(toggle-frame-fullscreen)

(use-package nlinum
  :ensure t)
(use-package nlinum-relative
  :ensure t
  :init
  (global-nlinum-relative-mode 1))

;; (use-package exwm
;;   :ensure t)
;; (require 'exwm)
;; (require 'exwm-config)
;; (exwm-config-default)

;; (use-package dmenu
;;   :ensure t)

(use-package beacon
  :ensure t
  :init (beacon-mode 1))

(use-package dashboard
      :ensure t
      :config
      (dashboard-setup-startup-hook)
      (setq dashboard-items '(
                              (recents . 10)
                              (projects . 10)
                              (agenda . 10)
                              ))
      (setq dashboard-banner-logo-title "Nimamoh's emacs!")
      (setq dashboard-startup-banner 'logo)
      (setq dashboard-banner-logo-png "/home/rog/.emacs.d/chikungunya.png")
      )

(use-package fancy-battery
  :ensure t
  :config
  (add-hook 'after-init-hook #'fancy-battery-mode)
  :init
  (setq fancy-battery-show-percentage t))

(use-package spaceline :ensure t)

;;(spaceline-emacs-theme)
;; (spaceline-emacs-theme)
;; (spaceline-toggle-battery-on)
;; (spaceline-toggle-projectile-root-on)
;; (spaceline-toggle-minor-modes-off)

;; (setq-default
;;    powerline-default-separator 'wave
;;    spaceline-highlight-face-func 'spaceline-highlight-face-modified)
;; (spaceline-compile)


;; TODO: re enable?
;; custom mode-line
(use-package spaceline-config :ensure spaceline
  :config

  (setq-default
   mode-line-format '("%e" (:eval (spaceline-ml-main)))
   powerline-default-separator 'wave
   spaceline-highlight-face-func 'spaceline-highlight-face-modified)

  ;; custom date segment
  (spaceline-define-segment me/clock
    "A simple clock"
    ;;(shell-command-to-string "date +%B-%d%_H:%M:%S+")
    (string-trim-right
     (shell-command-to-string "echo \"`date +%d` `date +%B` `date +%H:%M`\" "))
    )

  ;; build the mode-lines
  (spaceline-install
    '((major-mode :face highlight-face)
      ((remote-host buffer-id line) :separator ":")
      ((flycheck-error flycheck-warning flycheck-info))
      ((projectile-root version-control) :separator ":")
      )
    '((global :separator ":")
      (me/clock)
      (battery)
      (org-clock)
      (buffer-encoding))))

;; Load the tomorow theme. Also set the color mode

;; tomorrow themes
(when (window-system)
  (use-package color-theme-sanityinc-tomorrow
    :ensure t
    :config
    (load-theme 'sanityinc-tomorrow-eighties t)))

;; zenburn theme
;; (use-package zenburn-theme
;;   :ensure t
;;   :config
;;   (load-theme 'zenburn t))


;; doom theme
;; (use-package all-the-icons
;;   :ensure t)
;; (use-package doom-themes
;;   :ensure t
;;   :config
;;   (setq doom-themes-enable-bold t)
;;   (setq doom-themes-enable-italic t)
;;   (load-theme 'doom-one)
;;   (doom-themes-visual-bell-config)
;;   (doom-themes-neotree-config)
;;   (doom-themes-org-config))


;; Moe theme
;; (use-package moe-theme
;;   :ensure t)
;; (moe-dark)
;; (moe-theme-set-color 'orange)
;; (powerline-moe-theme)

;; Darktooth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package darktooth-theme ;;
;;   :ensure t)                 ;;
;; (load-theme 'darktooth)      ;;
;; (darktooth-modeline)         ;;
;; (darktooth-modeline-one)     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(when (window-system)
  (set-default-font "Hack"))

(use-package s
  :ensure t)

(use-package hydra
  :ensure t)

(global-prettify-symbols-mode 1)

(use-package paredit
  :ensure t
  :config
  (add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
  (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
  (add-hook 'scheme-mode-hook           #'enable-paredit-mode)
  :bind (("C-c d" . paredit-forward-down))
  )

;; Ensure paredit is used EVERYWHERE!
(use-package paredit-everywhere
  :ensure t
  :config
  (add-hook 'list-mode-hook #'paredit-everywhere-mode))

(use-package highlight-parentheses
  :ensure t
  :config
  (add-hook 'emacs-lisp-mode-hook
            (lambda()
              (highlight-parentheses-mode)
              )))

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'lisp-mode-hook
            (lambda()
              (rainbow-delimiters-mode)
              )))

(global-highlight-parentheses-mode)

(use-package yasnippet
  :ensure t
  :config
  (yas/global-mode 1)
  (add-to-list 'yas-snippet-dirs (concat init-dir "snippets")))

(use-package clojure-snippets
  :ensure t)

(use-package company
  :ensure t
  :config
    (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 2)
  (global-company-mode)
)

(with-eval-after-load 'company
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  )

(use-package magit
  :ensure t)

(use-package diff-hl
  :ensure t
  :init
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (global-diff-hl-mode 1))

(use-package cider
  :ensure t
  :pin melpa-stable
  :config
  (add-hook 'cider-repl-mode-hook #'company-mode)
  (add-hook 'cider-mode-hook #'company-mode)
  (add-hook 'cider-mode-hook #'eldoc-mode)
  (add-hook 'cider-mode-hook #'cider-hydra-mode)
  (add-hook 'clojure-mode-hook #'paredit-mode)
  (setq cider-repl-use-pretty-printing t)
  (setq cider-repl-display-help-banner nil)
  (setq cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))")

  :bind
  ;; TODO: bindings
   ;; (("M-r" . cider-namespace-refresh)
   ;;        ("C-c r" . cider-repl-reset)
   ;;        ("C-c ." . cider-reset-test-run-tests))
  )

(use-package clj-refactor
  :ensure t
  :config
  (add-hook 'clojure-mode-hook (lambda ()
                                 (clj-refactor-mode 1)
                                 ;; insert keybinding setup here
                                 ))
  (cljr-add-keybindings-with-prefix "C-c C-m")
  (setq cljr-warn-on-eval nil)
  :bind ("C-c '" . hydra-cljr-help-menu/body)
  )

;; HYDRA
;; (load-library (concat init-dir "cider-hydra.el"))
;; (require 'cider-hydra)

(use-package dockerfile-mode
  :ensure t)
