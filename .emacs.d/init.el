
;; Keep track of loading time
(defconst emacs-start-time (current-time))
;; initalize all ELPA packages
(require 'package)

(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)
(setq package-enable-at-startup nil)
(let ((elapsed (float-time (time-subtract (current-time)
                                          emacs-start-time))))
  (message "Loaded packages in %.3fs" elapsed))

;; Dvorak nicety, regardless of loading settings
(define-key key-translation-map "\C-t" "\C-x")
;; Load use-package, used for loading packages
(require 'use-package)

;; keep customize settings in their own file
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

(defvar my/background 'light)
;;(defvar my/background 'dark)

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

(global-font-lock-mode t)

(setq gc-cons-threshold 20000000)

(setq echo-keystrokes 0.1)

(setq large-file-warning-threshold (* 25 1024 1024))

(transient-mark-mode t)

(setq-default indicate-empty-lines nil)
(setq-default indicate-buffer-boundaries nil)

(when (functionp 'menu-bar-mode)
  (menu-bar-mode -1))
(when (functionp 'set-scroll-bar-mode)
  (set-scroll-bar-mode 'nil))
(when (functionp 'mouse-wheel-mode)
  (mouse-wheel-mode -1))
(when (functionp 'tooltip-mode)
  (tooltip-mode -1))
(when (functionp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (functionp 'blink-cursor-mode)
  (blink-cursor-mode -1))

(setq ring-bell-function (lambda()))
(setq inhibit-startup-message t
      initial-major-mode 'fundamental-mode)

(line-number-mode 1)
(column-number-mode 1)

(setq read-file-name-completion-ignore-case t)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq line-move-visual t)

(setq make-pointer-invisible t)

(setq-default fill-column 80)
(setq-default default-tab-width 2)
(setq-default indent-tabs-mode nil)

(setq-default find-file-visit-truename nil)

(setq require-final-newline t)

(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'post-forward-angle-brackets))

(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "M-%") 'query-replace-regexp)

(setq sentence-end-double-space nil)

(setq split-height-threshold nil)
(setq split-width-threshold 180)

(whitespace-mode t)

(set-default 'indicate-empty-lines t)
(setq show-trailing-whitespace t)

(set-default 'imenu-auto-rescan t)

(random t)

(setq diff-switches "-u")

(add-hook 'text-mode-hook 'turn-on-auto-fill)

(setq calc-display-sci-low -5)

(defadvice kill-buffer (around kill-buffer-around-advice activate)
  (let ((buffer-to-kill (ad-get-arg 0)))
    (if (equal buffer-to-kill "*scratch*")
        (bury-buffer)
      ad-do-it)))

(global-auto-revert-mode 1)

(setq vc-follow-symlinks t)
(setq auto-revert-check-vc-info t)

(when (functionp 'set-fringe-style)
  (set-fringe-style 0))

(when (eq system-type 'gnu/linux)
  (use-package notificatons)
  (defun yank-to-x-clipboard ()
    (interactive)
    (if (region-active-p)
        (progn
          (shell-command-on-region (region-beginning) (region-end) "xsel -i -b")
          (message "Yanked region to clipboard!")
          (deactivate-mark))
      (message "No region active; can't yank to clipboard!")))

  (global-set-key (kbd "C-M-w") 'yank-to-x-clipboard))

(when (eq system-type 'darwin)
  (setq ns-use-native-fullscreen nil)
  (setq insert-directory-program "gls")
  (setq dired-listing-switches "-aBhl --group-directories-first")
  (defun copy-from-osx ()
    (shell-command-to-string "/usr/bin/pbpaste"))

  (defun paste-to-osx (text &optional push)
    (let ((process-connection-type nil))
      (let ((proc (start-process "pbcopy" "*Messages*" "/usr/bin/pbcopy")))
        (process-send-string proc text)
        (process-send-eof proc))))
  (setq interprogram-cut-function 'paste-to-osx
        interprogram-paste-function 'copy-from-osx))

(setq x-select-enable-clipboard t)
;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; savehist
(setq savehist-additional-variables
      ;; also save my search entries
      '(search-ring regexp-search-ring)
      savehist-file "~/.emacs.d/savehist")
(savehist-mode t)
(setq-default save-place t)

;; delete-auto-save-files
(setq delete-auto-save-files t)
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(when (cl-equalp "DUMB" (getenv "TERM"))
  (setenv "PAGER" "cat"))

(use-package eshell
  :config
  (progn
    (defalias 'emacs 'find-file)
    (setenv "TERM" "xterm-256color")
    (setenv "PAGER" "cat")
    (use-package esh-opt
      :config
      (progn
        ;; (set-face-attribute 'eshell-prompt nil :foreground "turquoise1")
        (use-package em-cmpl)
        (use-package em-prompt)
        (use-package em-term)))))

(setq-default ispell-program-name "aspell")
(setq ispell-personal-dictionary "~/.flydict"
      ispell-extra-args '("--sug-mode=ultra" "--ignore=3"))
(add-to-list 'ispell-skip-region-alist '("[^\000-\377]+"))

;; flyspell
(use-package flyspell
  :config
  (define-key flyspell-mode-map (kbd "M-n") 'flyspell-goto-next-error)
  (define-key flyspell-mode-map (kbd "M-.") 'ispell-word))

(use-package view
  :bind
  (("C-M-n" . View-scroll-half-page-forward)
   ("C-M-p" . View-scroll-half-page-backward))
  :config
  (progn
    ;; When in view-mode, the buffer is read-only:
    (setq view-read-only t)

    (defun View-goto-line-last (&optional line)
      "goto last line"
      (interactive "P")
      (goto-line (line-number-at-pos (point-max))))

    ;; less like
    (define-key view-mode-map (kbd "N") 'View-search-last-regexp-backward)
    (define-key view-mode-map (kbd "?") 'View-search-regexp-backward?)
    (define-key view-mode-map (kbd "g") 'View-goto-line)
    (define-key view-mode-map (kbd "G") 'View-goto-line-last)
    (define-key view-mode-map (kbd "b") 'View-scroll-page-backward)
    (define-key view-mode-map (kbd "f") 'View-scroll-page-forward)
    ;; vi/w3m like
    (define-key view-mode-map (kbd "h") 'backward-char)
    (define-key view-mode-map (kbd "j") 'next-line)
    (define-key view-mode-map (kbd "k") 'previous-line)
    (define-key view-mode-map (kbd "l") 'forward-char)
    (define-key view-mode-map (kbd "[") 'backward-paragraph)
    (define-key view-mode-map (kbd "]") 'forward-paragraph)
    (define-key view-mode-map (kbd "J") 'View-scroll-line-forward)
    (define-key view-mode-map (kbd "K") 'View-scroll-line-backward)))

(use-package doc-view
  :config
  (define-key doc-view-mode-map (kbd "j")
    'doc-view-next-line-or-next-page)
  (define-key doc-view-mode-map (kbd "k")
    'doc-view-previous-line-or-previous-page))

(use-package dired
  :bind ("C-x C-j" . dired-jump)
  :config
  (progn
    (use-package dired-x)
    (put 'dired-find-alternate-file 'disabled nil)
    (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
    (setq ls-lisp-dirs-first t)
    (setq dired-recursive-copies 'always)
    (setq dired-recursive-deletes 'always)
    (define-key dired-mode-map (kbd "C-M-u") 'dired-up-directory)
    (add-hook 'dired-mode-hook (lambda () (hl-line-mode)))))

;; Disabled, I actually start up a background emacs --daemon for this

(use-package recentf
  :init
  (progn
    (setq recentf-max-saved-items 300
          recentf-exclude '("/auto-install/" ".recentf" "/repos/" "/elpa/"
                            "\\.mime-example" "\\.ido.last" "COMMIT_EDITMSG"
                            ".gz")
          recentf-auto-cleanup 600)
    (when (not noninteractive) (recentf-mode 1))))

(add-hook 'prog-mode-hook
          (lambda ()
            (use-package column-marker)
            (use-package idle-highlight-mode
              :init (idle-highlight-mode t))
            (setq show-trailing-whitespace t)
            (subword-mode t)))

(defun my/add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIXME\\|TODO\\|NOCOMMIT\\)\\>"
          1 '((:foreground "#d7a3ad") (:weight bold)) t))))

(add-hook 'prog-mode-hook 'my/add-watchwords)

;; custom test locations instead of foo_test.clj, use test/foo.clj
(defun my-clojure-test-for (namespace)
  (let* ((namespace (clojure-underscores-for-hyphens namespace))
         (segments (split-string namespace "\\."))
         (before (subseq segments 0 1))
         (after (subseq segments 1))
         (test-segments (append before (list "test") after)))
    (format "%stest/%s.clj"
            (locate-dominating-file buffer-file-name "src/")
            (mapconcat 'identity test-segments "/"))))

(defun my-clojure-test-implementation-for (namespace)
  (let* ((namespace (clojure-underscores-for-hyphens namespace))
         (segments (split-string namespace "\\."))
         (before (subseq segments 0 1))
         (after (subseq segments 2))
         (impl-segments (append before after)))
    (format "%s/src/%s.clj"
            (locate-dominating-file buffer-file-name "src/")
            (mapconcat 'identity impl-segments "/"))))

(defun nrepl-popup-tip-symbol-at-point ()
  "show docs for the symbol at point -- AWESOMELY"
  (interactive)
  (popup-tip (ac-nrepl-documentation (symbol-at-point))
             :point (ac-nrepl-symbol-start-pos)
             :around t
             :scroll-bar t
             :margin t))

(use-package clojure-mode
  :config
  (add-hook
   'clojure-mode-hook
   (lambda ()
     ;; enable eldoc
     (eldoc-mode t)
     (subword-mode t)
     ;; use my test layout fns
     (setq clojure-test-for-fn 'my-clojure-test-for)
     (setq clojure-test-implementation-for-fn 'my-clojure-test-implementation-for)
     ;; compile faster
     (setq font-lock-verbose nil)
     (global-set-key (kbd "C-c t") 'clojure-jump-between-tests-and-code)
     (paredit-mode 1))))

(defun set-auto-complete-as-completion-at-point-function ()
  (setq completion-at-point-functions '(auto-complete)))

(defun setup-clojure-cider ()
  (lambda ()
    (define-key cider-mode-map (kbd "C-c C-d")
      'ac-nrepl-popup-doc)
    (paredit-mode 1)
    (setq cider-history-file "~/.nrepl-history"
          cider-hide-special-buffers t
          cider-repl-history-size 10000
          cider-popup-stacktraces-in-repl t)
    (set-auto-complete-as-completion-at-point-function)))

(use-package cider
  :config
  (progn
    (add-hook 'cider-mode-hook 'setup-clojure-cider)
    (add-hook 'cider-repl-mode-hook 'setup-clojure-cider)
    (use-package ac-nrepl
      :config
      (progn
        (add-hook 'cider-mode-hook 'ac-nrepl-setup)
        (add-hook 'cider-repl-mode-hook 'ac-nrepl-setup)
        (add-hook 'auto-complete-mode-hook
                  'set-auto-complete-as-completion-at-point-function)
        (add-to-list 'ac-modes 'cider-repl-mode)))))

(add-hook 'sh-mode-hook
          (lambda ()
            (show-paren-mode -1)
            (setq whitespace-line-column 140)
            (flycheck-mode -1)
            (setq blink-matching-paren nil)))

(add-to-list 'auto-mode-alist '("\\.zsh$" . shell-script-mode))

;;; Shell mode
(setq ansi-color-names-vector ; better contrast colors
      ["black" "red4" "green4" "yellow4"
       "blue3" "magenta4" "cyan4" "white"])
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(add-hook 'shell-mode-hook 
     '(lambda () (toggle-truncate-lines 1)))
(setq comint-prompt-read-only t)

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'emacs-lisp-mode-hook (lambda () (paredit-mode 1)))
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

(use-package eldoc
  :config
  (progn
    (setq eldoc-idle-delay 0.2)
    (set-face-attribute 'eldoc-highlight-function-argument nil
                        :underline t :foreground "green"
                        :weight 'bold)))

(set-face-foreground 'font-lock-regexp-grouping-backslash "#ff1493")
(set-face-foreground 'font-lock-regexp-grouping-construct "#ff8c00")

(defun ielm-other-window ()
  "Run ielm on other window"
  (interactive)
  (switch-to-buffer-other-window
   (get-buffer-create "*ielm*"))
  (call-interactively 'ielm))

(define-key emacs-lisp-mode-map (kbd "C-c C-z") 'ielm-other-window)
(define-key lisp-interaction-mode-map (kbd "C-c C-z") 'ielm-other-window)

(use-package elisp-slime-nav)

(add-hook 'emacs-lisp-mode-hook 'elisp-slime-nav-mode)
(add-hook 'lisp-interaction-mode-hook 'elisp-slime-nav-mode)

(use-package lisp-mode
  :config
  (add-hook 'lisp-mode (lambda () (paredit-mode 1))))

(use-package python
  :config
  (progn
    (define-key python-mode-map (kbd "C-c C-z") 'run-python)
    (define-key python-mode-map (kbd "<backtab>") 'python-back-indent)
    (use-package jedi
      :config
      (progn
        (jedi:setup)
        (jedi:ac-setup)
        (setq jedi:setup-keys t)
        (setq jedi:complete-on-dot t)
        (define-key python-mode-map (kbd "C-c C-d") 'jedi:show-doc)
        (setq jedi:tooltip-method nil)
        (set-face-attribute 'jedi:highlight-function-argument nil
                            :foreground "green")
        (define-key python-mode-map (kbd "C-c C-l") 'jedi:get-in-function-call)))
    (add-hook 'python-mode-hook (lambda () (jedi-mode t)))))

(defun setup-java ()
  (interactive)
  (define-key java-mode-map (kbd "M-,") 'pop-tag-mark)
  (defconst eclipse-java-style
    '((c-basic-offset . 4)
      (c-comment-only-line-offset . (0 . 0))
      ;; the following preserves Javadoc starter lines
      (c-offsets-alist . ((inline-open . 0)
                          (topmost-intro-cont    . +)
                          (statement-block-intro . +)
                          (knr-argdecl-intro     . 5)
                          (substatement-open     . +)
                          (substatement-label    . +)
                          (label                 . +)
                          (statement-case-open   . +)
                          (statement-cont        . ++)
                          (arglist-intro  . ++)
                          (arglist-close  . ++)
                          (arglist-cont-nonempty . ++)
                          (access-label   . 0)
                          (inher-cont     . ++)
                          (func-decl-cont . ++))))
    "Eclipse Java Programming Style")

  ;; eclim things
  (use-package eclim
    :config
    (progn
      (setq help-at-pt-display-when-idle t)
      (setq help-at-pt-timer-delay 0.1)
      (help-at-pt-set-timer)
      (use-package company-emacs-eclim
        :config
        (company-emacs-eclim-setup))))

  ;; Malabar things
  (use-package malabar-mode
    :config
    (progn
      (use-package malabar-mode
        :config
        (progn
          (use-package cedet)
          (use-package semantic
            :config
            (progn
              (load "semantic/loaddefs.el")
              (semantic-mode 1)))))))
  ;; Generic java stuff things
  (setq whitespace-line-column 140)
  (use-package column-marker
    :config
    (progn
      (column-marker-1 140)
      (column-marker-2 80)))
  (c-add-style "ECLIPSE" eclipse-java-style)
  (customize-set-variable 'c-default-style
                          (quote ((java-mode . "eclipse")
                                  (awk-mode . "awk")
                                  (other . "gnu"))))
  (c-set-offset 'arglist-cont-nonempty '++))

(add-hook 'java-mode-hook 'setup-java)

(use-package haskell-mode
  :config
  (progn
    ;;(ghc-init)
    ;; for auto-complete
    ;;(add-to-list 'ac-sources 'ac-source-ghc-mod)
    ))

(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)

(defun my/c-mode-init ()
  (c-set-style "k&r")
  (c-toggle-electric-state -1)
  (define-key c-mode-map (kbd "C-c o") 'ff-find-other-file)
  (define-key c++-mode-map (kbd "C-c o") 'ff-find-other-file)
  (hs-minor-mode 1)
  (setq c-basic-offset 4))

(add-hook 'c-mode-hook #'my/c-mode-init)
(add-hook 'c++-mode-hook #'my/c-mode-init)

(defun html-mode-insert-br ()
  (interactive)
  (insert "<br />"))

(defvar html-mode-map nil "keymap used in html-mode")
(unless html-mode-map
  (setq html-mode-map (make-sparse-keymap))
  (define-key html-mode-map (kbd "C-c b") 'html-mode-insert-br))

(use-package zencoding-mode)
(use-package css-mode)

(add-hook 'sgml-mode-hook 'zencoding-mode)
(add-hook 'html-mode-hook 'zencoding-mode)

(defalias 'javascript-generic-mode 'js-mode)
(setq-default js-auto-indent-flag nil)
(setq-default js-indent-level 2)

(use-package tern)
;;(add-hook 'js-mode-hook (lambda () (tern-mode t)))

(when (file-exists-p "~/src/elisp/es-mode")
  (add-to-list 'load-path "~/src/elisp/es-mode")
  (require 'es-mode)
  (require 'ob-elasticsearch)
  (use-package org
    :config
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((elasticsearch . t)))))

(when (eq window-system 'ns)
  (set-fontset-font "fontset-default" 'symbol "Monaco")
  (set-default-font "Inconsolata")
  (set-face-attribute 'default nil :height 115)
  (set-face-attribute 'fixed-pitch nil :height 115))
(when (eq window-system 'mac)
  (set-fontset-font "fontset-default" 'symbol "Monaco")
  (set-default-font "Anonymous Pro")
  (set-face-attribute 'default nil :height 125))
(when (eq window-system 'x)
  ;; Font family
  (set-fontset-font "fontset-default" 'symbol "Bitstream Vera Sans Mono")
  (set-default-font "Bitstream Vera Sans Mono")
  ;; Font size
  ;; 100 is too small, 105 is too big, 103 is juuuuuust right
  (set-face-attribute 'default nil :height 90))
;; Anti-aliasing
(setq mac-allow-anti-aliasing t)

(setq ns-use-srgb-colorspace t)

;; Emacs 24.4 requires these faces to be defined :-/
(defface clojure-parens '() "")
(defface clojure-keyword '() "")
(defface clojure-braces '() "")
(defface clojure-brackets '() "")
(defface clojure-namespace '() "")
(defface clojure-java-call '() "")
(defface clojure-special '() "")
(defface clojure-double-quote '() "")

(defmacro defclojureface (name color desc &optional others)
  `(defface
     ,name '((((class color)) (:foreground ,color ,@others)))
     ,desc :group 'faces))

(defun dakrone-dark ()
  (interactive)
  (if (window-system)
      (progn
        ;; https://github.com/dakrone/dakrone-theme
        ;;(load-theme 'dakrone t)
        ;; (set-background-color "#262626")

        ;; https://github.com/cryon/subatomic
        ;;(load-theme 'subatomic t)

        ;; https://github.com/kuanyui/moe-theme.el
        (use-package moe-theme
          :init (moe-dark)
          :config
          (progn
            ;;(setq moe-theme-mode-line-color 'orange)
            ;;(powerline-moe-theme)
            ))
        )
    (progn
      ;; https://github.com/d11wtq/subatomic256
      ;;(load-theme 'subatomic256 t)

      (load-theme 'dakrone t)

      ;; (use-package moe-theme
      ;;   :init (moe-dark)
      ;;   :config
      ;;   (progn
      ;;     ;;(setq moe-theme-mode-line-color 'orange)
      ;;     ;;(powerline-moe-theme)
      ;;     ))
      )))

(defun dakrone-light ()
  (interactive)
  ;; https://github.com/fniessen/emacs-leuven-theme
  (load-theme 'leuven t)
  ;;(load-theme 'flatui t)
  ;; (use-package moe-theme
  ;;   :init (moe-light))
  (defclojureface clojure-parens       "#696969"   "Clojure parens")
  (defclojureface clojure-braces       "#696969"   "Clojure braces")
  (defclojureface clojure-brackets     "#4682b4"   "Clojure brackets")
  (defclojureface clojure-keyword      "DarkCyan"  "Clojure keywords")
  (defclojureface clojure-namespace    "#c476f1"   "Clojure namespace")
  (defclojureface clojure-java-call    "#008b8b"   "Clojure Java calls")
  (defclojureface clojure-special      "#006400"   "Clojure special")
  (defclojureface clojure-double-quote "#006400"   "Clojure special")
  (if (window-system)
      (set-face-foreground 'region nil)))

;; Define faces in clojure code
(defun tweak-clojure-syntax ()
  "Tweaks syntax for Clojure-specific faces."
  (mapcar (lambda (x) (font-lock-add-keywords nil x))
          '((("#?['`]*(\\|)"       . 'clojure-parens))
            (("#?\\^?{\\|}"        . 'clojure-brackets))
            (("\\[\\|\\]"          . 'clojure-braces))
            ((":\\w+"              . 'clojure-keyword))
            (("nil\\|true\\|false\\|%[1-9]?" . 'clojure-special))
            (("(\\(\\.[^ \n)]*\\|[^ \n)]+\\.\\|new\\)\\([ )\n]\\|$\\)" 1
              'clojure-java-call)))))

;; (add-hook 'clojure-mode-hook 'tweak-clojure-syntax)

(if (eq my/background 'dark)
    (dakrone-dark)
  (dakrone-light))

(defun my/load-github-flavored-markdown ()
  (interactive)
  (when (file-exists-p "~/.emacs.d/ox-gfm.el")
    (load-file "~/.emacs.d/ox-gfm.el")))

(use-package org
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c b" . org-iswitchb)
         ("C-c c" . org-capture)
         ("C-c M-p" . org-babel-previous-src-block)
         ("C-c M-n" . org-babel-next-src-block)
         ("C-c S" . org-babel-previous-src-block)
         ("C-c s" . org-babel-next-src-block))
  :config
  (progn
    (use-package org-install)
    ;; load github-flavored-markdown
    (add-hook 'org-mode-hook 'turn-on-auto-fill)
    (setq org-directory "~/org"
          org-startup-indented t
          org-return-follows-link t
          ;; allow changing between todo stats directly by hotkey
          org-use-fast-todo-selection t
          org-src-fontify-natively t
          org-fontify-whole-heading-line t
          org-completion-use-ido t
          org-edit-src-content-indentation 0
          ;; Imenu should use 3 depth instead of 2
          org-imenu-depth 3
          org-agenda-start-on-weekday nil
          ;; Use sticky agenda's so they persist
          org-agenda-sticky t
          ;; show 4 agenda days
          org-agenda-span 4
          org-special-ctrl-a/e t
          org-special-ctrl-k t
          org-yank-adjusted-subtrees nil
          org-src-window-setup 'current-window
          ;; Overwrite the current window with the agenda
          org-agenda-window-setup 'current-window
          ;; Use full outline paths for refile targets - we file directly with IDO
          org-refile-use-outline-path t
          ;; Targets complete directly with IDO
          org-outline-path-complete-in-steps nil
          ;; Allow refile to create parent tasks with confirmation
          org-refile-allow-creating-parent-nodes (quote confirm)
          ;; Use IDO for both buffer and file completion and ido-everywhere to t
          ido-everywhere t
          ido-max-directory-size 100000
          ;; Use cider as the clojure backend
          org-babel-clojure-backend 'cider
          ;; don't run stuff automatically on export
          org-export-babel-evaluate nil
          ;; always enable noweb, results as code and exporting both
          org-babel-default-header-args
          (cons '(:noweb . "yes")
                (assq-delete-all :noweb org-babel-default-header-args))
          org-babel-default-header-args
          (cons '(:exports . "both")
                (assq-delete-all :exports org-babel-default-header-args))
          ;; I don't want to be prompted on every code block evaluation
          org-confirm-babel-evaluate nil
          ;; Do not dim blocked tasks
          org-agenda-dim-blocked-tasks nil
          ;; Compact the block agenda view
          org-agenda-compact-blocks t
          ;; Mark entries as done when archiving
          org-archive-mark-done nil
          org-archive-location "%s_archive::* Archived Tasks"
          ;; Sorting order for tasks on the agenda
          org-agenda-sorting-strategy
          (quote ((agenda habit-down
                          time-up
                          priority-down
                          user-defined-up
                          effort-up
                          category-keep)
                  (todo priority-down category-up effort-up)
                  (tags priority-down category-up effort-up)
                  (search priority-down category-up)))

          ;; Enable display of the time grid so we can see the marker for the current time
          org-agenda-time-grid (quote ((daily today remove-match)
                                       #("----------------" 0 16 (org-heading t))
                                       (0900 1100 1300 1500 1700)))
          org-agenda-include-diary t
          org-agenda-diary-file "~/diary"
          org-agenda-insert-diary-extract-time t
          org-agenda-repeating-timestamp-show-all t
          ;; Show all agenda dates - even if they are empty
          org-agenda-show-all-dates t)

    ;; Agenda org-mode files
    (setq org-agenda-files
          '("~/org/todo.org"
            "~/org/elasticsearch.org"
            "~/org/oss.org"
            "~/org/book.org"
            "~/org/notes.org"
            "~/org/journal.org"
            "~/org/refile.org"))
    ;; Org todo keywords
    (setq org-todo-keywords
          (quote
           ((sequence "SOMEDAY(s)" "TODO(t)" "INPROGRESS(i)" "WAITING(w@/!)" "NEEDSREVIEW(n@/!)"
                      "|" "DONE(d)")
            (sequence "WAITING(w@/!)" "HOLD(h@/!)"
                      "|" "CANCELLED(c@/!)"))))
    ;; Org faces
    (setq org-todo-keyword-faces
          (quote (("TODO" :foreground "red" :weight bold)
                  ("INPROGRESS" :foreground "deep sky blue" :weight bold)
                  ("SOMEDAY" :foreground "purple" :weight bold)
                  ("NEEDSREVIEW" :foreground "#edd400" :weight bold)
                  ("DONE" :foreground "forest green" :weight bold)
                  ("WAITING" :foreground "orange" :weight bold)
                  ("HOLD" :foreground "magenta" :weight bold)
                  ("CANCELLED" :foreground "forest green" :weight bold))))
    ;; add or remove tags on state change
    (setq org-todo-state-tags-triggers
          (quote (("CANCELLED" ("CANCELLED" . t))
                  ("WAITING" ("WAITING" . t))
                  ("HOLD" ("WAITING") ("HOLD" . t))
                  (done ("WAITING") ("HOLD"))
                  ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                  ("INPROGRESS" ("WAITING") ("CANCELLED") ("HOLD"))
                  ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))
    ;; refile targets all level 1 headers in todo.org and notes.org
    (setq org-refile-targets '((nil :maxlevel . 2)
                               (org-agenda-files :maxlevel . 2)))
    ;; quick access to common tags
    (setq org-tag-alist
          '(("oss" . ?o)
            ("home" . ?h)
            ("work" . ?w)
            ("book" . ?b)
            ("support" . ?s)
            ("docs" . ?d)))
    ;; capture templates
    (setq org-capture-templates
          (quote
           (("t" "Todo" entry (file "~/org/refile.org")
             "* TODO %?\n%U\n")
            ("n" "Notes" entry (file+headline "~/org/notes.org" "Notes")
             "* %? :NOTE:\n%U\n")
            ("j" "Journal" entry (file+datetree "~/org/journal.org")
             "* %?\n%U\n"))))
    ;; Custom agenda command definitions
    (setq org-agenda-custom-commands
          (quote
           (("N" "Notes" tags "NOTE"
             ((org-agenda-overriding-header "Notes")
              (org-tags-match-list-sublevels t)))
            (" " "Agenda"
             ((agenda "" nil)
              ;; All items with the "REFILE" tag, everything in refile.org
              ;; automatically gets that applied
              (tags "REFILE"
                    ((org-agenda-overriding-header "Tasks to Refile")
                     (org-tags-match-list-sublevels nil)))
              ;; All "INPROGRESS" todo items
              (todo "INPROGRESS"
                    ((org-agenda-overriding-header "Current work")))
              ;; All headings with the "support" tag
              (tags "support/!"
                    ((org-agenda-overriding-header "Support cases")))
              ;; All "NEESREVIEW" todo items
              (todo "NEEDSREVIEW"
                    ((org-agenda-overriding-header "Waiting on reviews")))
              ;; All "WAITING" items without a "support" tag
              (tags "WAITING-support"
                    ((org-agenda-overriding-header "Waiting for feedback")))
              ;; All TODO items
              (todo "TODO"
                    ((org-agenda-overriding-header "Task list")
                     (org-agenda-sorting-strategy '(category-keep))))
              ;; Everything on hold
              (todo "HOLD"
                    ((org-agenda-overriding-header "On-hold")))
              ;; Everything that's done and archivable
              (todo "DONE"
                    ((org-agenda-overriding-header "Tasks for archive")
                     (org-agenda-skip-function 'bh/skip-non-archivable-tasks))))
             nil))))

    (ido-mode (quote both))

    ;; Exclude DONE state tasks from refile targets
    (defun my/verify-refile-target ()
      "Exclude todo keywords with a done state from refile targets"
      (not (member (nth 2 (org-heading-components)) org-done-keywords)))
    (setq org-refile-target-verify-function 'my/verify-refile-target)

    (define-key org-mode-map (kbd "C-M-<return>") 'org-insert-todo-heading)
    (define-key org-mode-map (kbd "C-c t") 'org-todo)
    (define-key org-mode-map (kbd "M-G") 'org-plot/gnuplot)
    (local-unset-key (kbd "M-S-<return>"))

    (add-hook 'org-mode-hook
              (lambda ()
                (turn-on-flyspell)
                (define-key org-mode-map [C-tab] 'other-window)
                (define-key org-mode-map [C-S-tab]
                  (lambda ()
                    (interactive)
                    (other-window -1)))))

    ;; org-babel stuff
    (require 'ob-clojure)
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       (clojure . t)
       (sh . t)
       (ruby . t)
       (python . t)
       (gnuplot . t)))

    ;; ensure this variable is defined
    (unless (boundp 'org-babel-default-header-args:sh)
      (setq org-babel-default-header-args:sh '()))

    ;; add a default shebang header argument shell scripts
    (add-to-list 'org-babel-default-header-args:sh
                 '(:shebang . "#!/usr/bin/env zsh"))

    ;; add a default shebang header argument for python
    (add-to-list 'org-babel-default-header-args:python
                 '(:shebang . "#!/usr/bin/env python"))

    ;; Clojure-specific org-babel stuff
    (defvar org-babel-default-header-args:clojure
      '((:results . "silent")))

    (defun org-babel-execute:clojure (body params)
      "Execute a block of Clojure code with Babel."
      (let ((result-plist
             (nrepl-send-string-sync
              (org-babel-expand-body:clojure body params) nrepl-buffer-ns))
            (result-type  (cdr (assoc :result-type params))))
        (org-babel-script-escape
         (cond ((eq result-type 'value) (plist-get result-plist :value))
               ((eq result-type 'output) (plist-get result-plist :value))
               (t (message "Unknown :results type!"))))))

    ;; Function declarations
    (defun bh/skip-non-archivable-tasks ()
      "Skip trees that are not available for archiving"
      (save-restriction
        (widen)
        ;; Consider only tasks with done todo headings as archivable candidates
        (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
              (subtree-end (save-excursion (org-end-of-subtree t))))
          (if (member (org-get-todo-state) org-todo-keywords-1)
              (if (member (org-get-todo-state) org-done-keywords)
                  (let* ((daynr (string-to-int (format-time-string "%d" (current-time))))
                         (a-month-ago (* 60 60 24 (+ daynr 1)))
                         (last-month
                          (format-time-string
                           "%Y-%m-"
                           (time-subtract (current-time) (seconds-to-time a-month-ago))))
                         (this-month (format-time-string "%Y-%m-" (current-time)))
                         (subtree-is-current
                          (save-excursion
                            (forward-line 1)
                            (and (< (point) subtree-end)
                                 (re-search-forward
                                  (concat last-month "\\|" this-month)
                                  subtree-end t)))))
                    (if subtree-is-current
                        subtree-end ; Has a date in this month or last month, skip it
                      nil))  ; available to archive
                (or subtree-end (point-max)))
            next-headline))))))

(use-package org
  :config
  (setq org-publish-project-alist
        '(("emacs dotfiles"
           :base-directory "~/.emacs.d/"
           :base-extension "org\\|zsh\\|html"
           :publishing-directory "/ssh:hinmanph@writequit:~/public_html/wq/paste/org/"
           :publishing-function org-html-publish-to-html
           :with-toc t
           :html-preamble t)
          ("org-pastebin"
           :base-directory "~/org/"
           :base-extension "org\\|zsh\\|html"
           :publishing-directory "/ssh:hinmanph@writequit:~/public_html/wq/paste/org/"
           :publishing-function org-html-publish-to-html
           :with-toc t
           :html-preamble t)
          ("org-pastebin-db"
           :base-directory "~/Dropbox/org/"
           :base-extension "org\\|zsh\\|html"
           :publishing-directory "/ssh:hinmanph@writequit:~/public_html/wq/paste/org/"
           :publishing-function org-html-publish-to-html
           :with-toc t
           :html-preamble t)
          ("org-es-pastebin"
           :base-directory "~/org/es/"
           :base-extension "org\\|zsh\\|html"
           :publishing-directory "/ssh:hinmanph@writequit:~/public_html/wq/paste/org/"
           :publishing-function org-html-publish-to-html
           :with-toc t
           :html-preamble t)
          ("org-es-pastebin-db"
           :base-directory "~/Dropbox/org/es/"
           :base-extension "org\\|zsh\\|html"
           :publishing-directory "/ssh:hinmanph@writequit:~/public_html/wq/paste/org/"
           :publishing-function org-html-publish-to-html
           :with-toc t
           :html-preamble t)
          ("org-book-pastebin"
           :base-directory "~/org/book/"
           :base-extension "org\\|zsh\\|html"
           :publishing-directory "/ssh:hinmanph@writequit:~/public_html/wq/paste/org/book/"
           :publishing-function org-html-publish-to-html
           :with-toc t
           :html-preamble t)
          ("org-book-pastebin-db"
           :base-directory "~/Dropbox/org/book/"
           :base-extension "org\\|zsh\\|html"
           :publishing-directory "/ssh:hinmanph@writequit:~/public_html/wq/paste/org/book/"
           :publishing-function org-html-publish-to-html
           ;; :exclude "PrivatePage.org"   ;; regexp
           ;; :headline-levels 3
           ;; :section-numbers nil
           :with-toc t
           ;; :html-head "<link rel=\"stylesheet\"
           ;;               href=\"../other/mystyle.css\" type=\"text/css\"/>"
           :html-preamble t))))

(use-package org-toc
  :init (add-hook 'org-mode-hook 'org-toc-enable))

(use-package org-trello
  :disabled t)

(setq tls-program
      '("openssl s_client -connect %h:%p -no_ssl2 -ign_eof -cert ~/host.pem"
        "gnutls-cli --priority secure256 --x509certfile ~/host.pem -p %p %h"
        "gnutls-cli --priority secure256 -p %p %h"))

;; ERC is only loaded for GUI emacs
(defun setup-irc ()
  (interactive)
  (when (file-exists-p "~/.ercpass")
    (load-file "~/.ercpass"))

  ;; Only track my nick(s)
  (defadvice erc-track-find-face
      (around erc-track-find-face-promote-query activate)
    (if (erc-query-buffer-p)
        (setq ad-return-value (intern "erc-current-nick-face"))
      ad-do-it))

  (use-package erc
    :config
    (progn
      (setq erc-fill-column 100
            erc-server-coding-system '(utf-8 . utf-8)
            erc-hide-list '("JOIN" "PART" "QUIT" "NICK")
            erc-track-exclude-types (append '("324" "329" "332" "333"
                                              "353" "477" "MODE")
                                            erc-hide-list)
            erc-nick '("dakrone" "dakrone_" "dakrone__")
            erc-autojoin-timing :ident
            erc-flood-protect nil
            erc-pals '("hiredman" "danlarkin" "drewr" "pjstadig" "scgilardi"
                       "joegallo" "jimduey" "leathekd" "zkim" "imotov"
                       "technomancy" "yazirian" "danielglauser")
            erc-pal-highlight-type 'nil
            erc-keywords '("dakrone" "dakrone_" "clj-http" "cheshire"
                           "clojure-opennlp" "opennlp" "circuit breaker")
            erc-ignore-list '()
            erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
                                      "324" "329" "332" "333" "353" "477")
            erc-button-url-regexp
            (concat "\\([-a-zA-Z0-9_=!?#$@~`%&*+\\/:;,]+\\.\\)+[-a-zA-Z0-9_=!?#"
                    "$@~`%&*+\\/:;,]*[-a-zA-Z0-9\\/]")
            erc-log-matches-types-alist
            '((keyword . "ERC Keywords")
              (current-nick . "ERC Messages Addressed To You"))
            erc-log-matches-flag t
            erc-prompt-for-nickserv-password nil
            erc-server-reconnect-timeout 5
            erc-server-reconnect-attempts 4
            erc-fill-function 'erc-fill-static
            erc-fill-static-center 22
            ;; update ERC prompt with room name
            erc-prompt (lambda ()
                         (if (and (boundp 'erc-default-recipients)
                                  (erc-default-target))
                             (erc-propertize (concat (erc-default-target) ">")
                                             'read-only t 'rear-nonsticky t
                                             'front-nonsticky t)
                           (erc-propertize (concat "ERC>") 'read-only t
                                           'rear-nonsticky t
                                           'front-nonsticky t))))
      (use-package erc-hl-nicks
        :init (add-to-list 'erc-modules 'hl-nicks))
      (use-package erc-services
        :init
        (progn
          (add-to-list 'erc-modules 'spelling)
          (erc-services-mode 1)
          (erc-spelling-mode 1)))
      (erc-update-modules)))

  (defun start-irc ()
    "Connect to IRC."
    (interactive)
    (erc-tls :server "freenode" :port 31425
             :nick "dakrone" :password znc-pass)))

(defun mail ()
  (interactive)
  (add-to-list 'load-path "~/src/mu-0.9.9.5/mu4e")
  (use-package mu4e
    :config
    (progn
      ;; gpg stuff
      (use-package epa-file
        :init (epa-file-enable))

      ;; Various mu4e settings
      (setq mu4e-mu-binary "/usr/local/bin/mu"
            smtpmail-smtp-server "smtp.example.org"
            ;;mu4e-sent-messages-behavior 'delete
            ;; save attachments to the Downloads folder
            mu4e-attachment-dir "~/Downloads"
            ;; attempt to show images
            mu4e-view-show-images t
            mu4e-view-image-max-width 800
            ;; start in non-queuing mode
            smtpmail-queue-mail nil
            smtpmail-queue-dir "~/.mailqueue/"
            mml2015-use 'epg
            pgg-default-user-id "3acecae0"
            epg-gpg-program "/usr/local/bin/gpg"
            message-kill-buffer-on-exit t ;; kill sent msg buffers
            ;; use msmtp
            message-send-mail-function 'message-send-mail-with-sendmail
            sendmail-program   "/usr/local/bin/msmtp"
            ;; Look at the from header to determine the account from which
            ;; to send. Might not be needed b/c of kdl-msmtp
            mail-specify-envelope-from t
            mail-envelope-from 'header
            message-sendmail-envelope-from 'header
            ;; emacs email defaults
            user-mail-address  "lee@writequit.org"
            user-full-name     "Lee Hinman"
            mail-host-address  "writequit.org"
            ;; mu4e defaults
            mu4e-maildir       "~/.mail"
            ;; misc mu settings
            ;; Unicode FTW
            mu4e-use-fancy-chars nil
            ;; use the python html2text shell command to strip html
            ;; brew/apt-get install html2text
            mu4e-html2text-command "/usr/local/bin/elinks -dump"
            ;; mu4e-html2text-command "/usr/local/bin/html2text -nobs"
            ;; mu4e-html2text-command
            ;; "/usr/bin/html2markdown | fgrep -v '&nbsp_place_holder;'"
            ;; check for new messages ever 600 seconds (10 min)
            mu4e-update-interval 600)

      (add-hook 'dired-mode-hook 'turn-on-gnus-dired-mode)
      (use-package gnus-dired
        :config
        (progn
          ;; make the `gnus-dired-mail-buffers' function also work on
          ;; message-mode derived modes, such as mu4e-compose-mode
          (defun gnus-dired-mail-buffers ()
            "Return a list of active message buffers."
            (let (buffers)
              (save-current-buffer
                (dolist (buffer (buffer-list t))
                  (set-buffer buffer)
                  (when (and (derived-mode-p 'message-mode)
                             (null message-sent-message-via))
                    (push (buffer-name buffer) buffers))))
              (nreverse buffers)))

          (setq gnus-dired-mail-mode 'mu4e-user-agent)))

      ;; Vars used below
      (defvar kdl-mu4e-new-mail nil
        "Boolean to represent if there is new mail.")

      (defvar kdl-mu4e-url-location-list '()
        "Stores the location of each link in a mu4e view buffer")

      ;; This is also defined in init.el, but b/c ESK runs all files in the
      ;; user-dir before init.el it must also be defined here
      (defvar message-filter-regexp-list '()
        "regexps to filter matched msgs from the echo area when message is called")

      ;; Multi-account support
      (defun kdl-mu4e-current-account (&optional msg ignore-message-at-point)
        "Figure out what the current account is based on the message being
composed, the message under the point, or (optionally) the message
passed in. Also supports ignoring the msg at the point."
        (let ((cur-msg (or msg
                           mu4e-compose-parent-message
                           (and (not ignore-message-at-point)
                                (mu4e-message-at-point t)))))
          (when cur-msg
            (let ((maildir (mu4e-msg-field cur-msg :maildir)))
              (string-match "/\\(.*?\\)/" maildir)
              (match-string 1 maildir)))))

      (defun is-gmail-account? (acct)
        (if (or (equal "elasticsearch" acct) (equal "gmail" acct))
            t nil))

      ;; my elisp is bad and I should feel bad
      (defun mlh-folder-for (acct g-folder-name other-folder-name)
        (if (or (equal "elasticsearch" acct) (equal "gmail" acct))
            (format "/%s/[Gmail].%s" acct g-folder-name)
          (format "/%s/INBOX.%s" acct other-folder-name)))

      ;; Support for multiple accounts
      (setq mu4e-sent-folder   (lambda (msg)
                                 (mlh-folder-for (kdl-mu4e-current-account msg)
                                                 "Sent Mail" "Sent"))
            mu4e-drafts-folder (lambda (msg)
                                 (mlh-folder-for (kdl-mu4e-current-account msg)
                                                 "Drafts" "Drafts"))
            mu4e-trash-folder  (lambda (msg)
                                 (mlh-folder-for (kdl-mu4e-current-account msg)
                                                 "Trash" "Trash"))
            mu4e-refile-folder (lambda (msg)
                                 (mlh-folder-for (kdl-mu4e-current-account msg)
                                                 "All Mail" "Archive"))
            ;; The following list represents the account followed by key /
            ;; value pairs of vars to set when the account is chosen
            kdl-mu4e-account-alist
            '(("gmail"
               (user-mail-address   "matthew.hinman@gmail.com")
               (msmtp-account       "gmail")
               (mu4e-sent-messages-behavior delete))
              ("elasticsearch"
               (user-mail-address   "lee.hinman@elasticsearch.com")
               (msmtp-account       "elasticsearch")
               (mu4e-sent-messages-behavior delete))
              ;; ("writequit"
              ;;  (user-mail-address   "lee@writequit.org")
              ;;  (msmtp-account       "writequit")
              ;;  (mu4e-sent-messages-behavior sent))
              )
            ;; These are used when mu4e checks for new messages
            mu4e-my-email-addresses
            (mapcar (lambda (acct) (cadr (assoc 'user-mail-address (cdr acct))))
                    kdl-mu4e-account-alist))

      (defun kdl-mu4e-choose-account ()
        "Prompt the user for an account to use"
        (completing-read (format "Compose with account: (%s) "
                                 (mapconcat #'(lambda (var) (car var))
                                            kdl-mu4e-account-alist "/"))
                         (mapcar #'(lambda (var) (car var))
                                 kdl-mu4e-account-alist)
                         nil t nil nil (caar kdl-mu4e-account-alist)))

      (defun kdl-mu4e-set-compose-account ()
        "Set various vars when composing a message. The vars to set are
  defined in kdl-mu4e-account-alist."
        (let* ((account (or (kdl-mu4e-current-account nil t)
                            (kdl-mu4e-choose-account)))
               (account-vars (cdr (assoc account kdl-mu4e-account-alist))))
          (when account-vars
            (mapc #'(lambda (var)
                      (set (car var) (cadr var)))
                  account-vars))))
      (add-hook 'mu4e-compose-pre-hook 'kdl-mu4e-set-compose-account)

      ;; Send mail through msmtp (setq stuff is below)
      (defun kdl-msmtp ()
        "Add some arguments to the msmtp call in order to route the message
  through the right account."
        (if (message-mail-p)
            (save-excursion
              (let* ((from (save-restriction (message-narrow-to-headers)
                                             (message-fetch-field "from"))))
                (setq message-sendmail-extra-arguments (list "-a" msmtp-account))))))
      (add-hook 'message-send-mail-hook 'kdl-msmtp)

      ;; Notification stuff
      (setq global-mode-string
            (if (string-match-p "kdl-mu4e-new-mail"
                                (prin1-to-string global-mode-string))
                global-mode-string
              (cons
               ;;         '(kdl-mu4e-new-mail "✉" "")
               '(kdl-mu4e-new-mail "Mail" "")
               global-mode-string)))

      (defun kdl-mu4e-unread-mail-query ()
        "The query to look for unread messages in all account INBOXes.
  More generally, change this code to affect not only when the
  envelope icon appears in the modeline, but also what shows up in
  mu4e under the Unread bookmark"
        (mapconcat
         (lambda (acct)
           (let ((name (car acct)))
             (format "%s"
                     (mapconcat (lambda (fmt)
                                  (format fmt name))
                                '("flag:unread AND maildir:/%s/INBOX")
                                " "))))
         kdl-mu4e-account-alist
         " OR "))

      (defun kdl-mu4e-new-mail-p ()
        "Predicate for if there is new mail or not"
        (not (eq 0 (string-to-number
                    (replace-regexp-in-string
                     "[ \t\n\r]" "" (shell-command-to-string
                                     (concat "mu find "
                                             (kdl-mu4e-unread-mail-query)
                                             " | wc -l")))))))

      (defun kdl-mu4e-notify ()
        "Function called to update the new-mail flag used in the mode-line"
        ;; This delay is to give emacs and mu a chance to have changed the
        ;; status of the mail in the index
        (run-with-idle-timer
         1 nil (lambda () (setq kdl-mu4e-new-mail (kdl-mu4e-new-mail-p)))))

      ;; I put a lot of effort (probably too much) into getting the
      ;; 'new mail' icon to go away by showing or hiding it:
      ;; - periodically (this runs even when mu4e isn't running)
      (setq kdl-mu4e-notify-timer (run-with-timer 0 500 'kdl-mu4e-notify))
      ;; - when the index is updated (this runs when mu4e is running)
      (add-hook 'mu4e-index-updated-hook 'kdl-mu4e-notify)
      ;; - after mail is processed (try to make the icon go away)
      (defadvice mu4e-mark-execute-all
          (after mu4e-mark-execute-all-notify activate) 'kdl-mu4e-notify)
      ;; - when a message is opened (try to make the icon go away)
      (add-hook 'mu4e-view-mode-hook 'kdl-mu4e-notify)
      ;; wrap lines
      (add-hook 'mu4e-view-mode-hook 'visual-line-mode)

      (defun kdl-mu4e-quit-and-notify ()
        "Bury the buffer and check for new messages. Mainly this is intended
  to clear out the envelope icon when done reading mail."
        (interactive)
        (bury-buffer)
        (kdl-mu4e-notify))

      ;; Make 'quit' just bury the buffer
      (define-key mu4e-headers-mode-map "q" 'kdl-mu4e-quit-and-notify)
      (define-key mu4e-main-mode-map "q" 'kdl-mu4e-quit-and-notify)

      ;; View mode stuff
      ;; Make it possible to tab between links
      (defun kdl-mu4e-populate-url-locations (&optional force)
        "Scans the view buffer for the links that mu4e has identified and
  notes their locations"
        (when (or (null kdl-mu4e-url-location-list) force)
          (make-local-variable 'kdl-mu4e-url-location-list)
          (let ((pt (next-single-property-change (point-min) 'face)))
            (while pt
              (when (equal (get-text-property pt 'face) 'mu4e-view-link-face)
                (add-to-list 'kdl-mu4e-url-location-list pt t))
              (setq pt (next-single-property-change pt 'face)))))
        kdl-mu4e-url-location-list)

      (defun kdl-mu4e-move-to-link (pt)
        (if pt
            (goto-char pt)
          (error "No link found.")))

      (defun kdl-mu4e-forward-url ()
        "Move the point to the beginning of the next link in the buffer"
        (interactive)
        (let* ((pt-list (kdl-mu4e-populate-url-locations)))
          (kdl-mu4e-move-to-link
           (or (some (lambda (pt) (when (> pt (point)) pt)) pt-list)
               (some (lambda (pt) (when (> pt (point-min)) pt)) pt-list)))))

      (defun kdl-mu4e-backward-url ()
        "Move the point to the beginning of the previous link in the buffer"
        (interactive)
        (let* ((pt-list (reverse (kdl-mu4e-populate-url-locations))))
          (kdl-mu4e-move-to-link
           (or (some (lambda (pt) (when (< pt (point)) pt)) pt-list)
               (some (lambda (pt) (when (< pt (point-max)) pt)) pt-list)))))

      (define-key mu4e-view-mode-map (kbd "TAB") 'kdl-mu4e-forward-url)
      (define-key mu4e-view-mode-map (kbd "<backtab>") 'kdl-mu4e-backward-url)

      ;; Misc
      ;; The bookmarks for the main screen
      (setq mu4e-bookmarks
            `((,(kdl-mu4e-unread-mail-query) "New messages"         ?b)
              ("date:today..now"             "Today's messages"     ?t)
              ("date:7d..now"                "Last 7 days"          ?W)
              ;;("maildir:/writequit/INBOX"    "Writequit"            ?w)
              ("subject:[elasticsearch]"     "ES Issues"            ?e)
              ("maildir:/elasticsearch/INBOX" "Elasticsearch"       ?s)
              ("maildir:/gmail/INBOX"        "Gmail"                ?g)
              ;; ("maildir:/writequit/INBOX OR maildir:/elasticsearch/INBOX OR maildir:/gmail/INBOX"
              ;;  "All Mail" ?a)
              ("maildir:/elasticsearch/INBOX OR maildir:/gmail/INBOX" "All Mail" ?a)))

      ;; Skip the main mu4e screen and go right to unread
      (defun kdl-mu4e-view-unread ()
        "Open the Unread bookmark directly"
        (interactive)
        (mu4e~start)
        (mu4e-headers-search-bookmark (mu4e-get-bookmark-query ?b)))

      (global-set-key (kbd "C-c 2") 'kdl-mu4e-view-unread)

      ;; Don't echo some mu4e messages
      (add-to-list 'message-filter-regexp-list "mu4e.*Indexing.*processed")
      (add-to-list 'message-filter-regexp-list "mu4e.*Retrieving mail")
      (add-to-list 'message-filter-regexp-list "mu4e.*Started")

      ;; Start it up
      (when (eq window-system 'ns)
        ;; start mu4e
        (mu4e~start)
        ;; check for unread messages
        (kdl-mu4e-notify))

      (add-to-list 'mu4e-view-actions
                   '("ViewInBrowser" . mu4e-action-view-in-browser) t)

      (define-key mu4e-view-mode-map (kbd "j") 'next-line)
      (define-key mu4e-view-mode-map (kbd "k") 'previous-line)

      (define-key mu4e-headers-mode-map (kbd "J") 'mu4e~headers-jump-to-maildir)
      (define-key mu4e-headers-mode-map (kbd "j") 'next-line)
      (define-key mu4e-headers-mode-map (kbd "k") 'previous-line)

      (when (eq my/background 'light)
        (set-face-background 'mu4e-header-highlight-face "#e0e0e0"))))

  (global-set-key (kbd "C-c m") 'mu4e))

(use-package ace-jump-mode
  :bind (("C-c SPC" . ace-jump-mode)
         ("C-c M-SPC" . ace-jump-line-mode)))

(use-package smooth-scrolling
  :config
  (setq smooth-scroll-margin 4))

(use-package yasnippet
  :diminish ""
  :idle (yas-reload-all))

(add-hook 'emacs-lisp-mode-hook 'yas-minor-mode-on)
(add-hook 'org-mode-hook 'yas-minor-mode-on)
(add-hook 'clojure-mode-hook 'yas-minor-mode-on)

(use-package helm-config
  :config
  (use-package yasnippet
    :bind ("M-=" . yas-insert-snippet)
    :config
    (progn
      (defun my-yas/prompt (prompt choices &optional display-fn)
      (let* ((names (loop for choice in choices
                          collect (or (and display-fn
                                           (funcall display-fn choice))
                                      coice)))
             (selected (helm-other-buffer
                        `(((name . ,(format "%s" prompt))
                           (candidates . names)
                           (action . (("Insert snippet" . (lambda (arg)
                                                            arg))))))
                        "*helm yas/prompt*")))
        (if selected
            (let ((n (position selected names :test 'equal)))
              (nth n choices))
          (signal 'quit "user quit!"))))
      (custom-set-variables '(yas/prompt-functions '(my-yas/prompt))))))

(use-package paredit
  :diminish "()"
  :config
  (progn
    (define-key paredit-mode-map (kbd "M-)") 'paredit-forward-slurp-sexp)
    (define-key paredit-mode-map (kbd "C-(") 'paredit-forward-barf-sexp)
    (define-key paredit-mode-map (kbd "C-)") 'paredit-forward-slurp-sexp)
    (define-key paredit-mode-map (kbd ")") 'paredit-close-parenthesis)))

(add-hook 'cider-repl-mode-hook (lambda () (paredit-mode t)))

(use-package smartparens
  :config
  (progn
    (use-package smartparens-config)
    (add-hook 'sh-mode-hook
              (lambda ()
                ;; Remove when https://github.com/Fuco1/smartparens/issues/257
                ;; is fixed
                (setq sp-autoescape-string-quote nil)))

    ;; Remove the M-<backspace> binding that smartparens adds
    (let ((disabled '("M-<backspace>")))
      (setq sp-smartparens-bindings
            (cl-remove-if (lambda (key-command)
                            (member (car key-command) disabled))
                          sp-smartparens-bindings)))

    (define-key sp-keymap (kbd "C-(") 'sp-forward-barf-sexp)
    (define-key sp-keymap (kbd "C-)") 'sp-forward-slurp-sexp)
    (define-key sp-keymap (kbd "M-(") 'sp-forward-barf-sexp)
    (define-key sp-keymap (kbd "M-)") 'sp-forward-slurp-sexp)
    (define-key sp-keymap (kbd "C-M-f") 'sp-forward-sexp)
    (define-key sp-keymap (kbd "C-M-b") 'sp-backward-sexp)
    (define-key sp-keymap (kbd "C-M-f") 'sp-forward-sexp)
    (define-key sp-keymap (kbd "C-M-b") 'sp-backward-sexp)
    (define-key sp-keymap (kbd "C-M-d") 'sp-down-sexp)
    (define-key sp-keymap (kbd "C-M-a") 'sp-backward-down-sexp)
    (define-key sp-keymap (kbd "C-S-a") 'sp-beginning-of-sexp)
    (define-key sp-keymap (kbd "C-S-d") 'sp-end-of-sexp)
    (define-key sp-keymap (kbd "C-M-e") 'sp-up-sexp)
    (define-key emacs-lisp-mode-map (kbd ")") 'sp-up-sexp)
    (define-key sp-keymap (kbd "C-M-u") 'sp-backward-up-sexp)
    (define-key sp-keymap (kbd "C-M-t") 'sp-transpose-sexp)
    ;; (define-key sp-keymap (kbd "C-M-n") 'sp-next-sexp)
    ;; (define-key sp-keymap (kbd "C-M-p") 'sp-previous-sexp)
    (define-key sp-keymap (kbd "C-M-k") 'sp-kill-sexp)
    (define-key sp-keymap (kbd "C-M-w") 'sp-copy-sexp)
    (define-key sp-keymap (kbd "M-D") 'sp-splice-sexp)
    (define-key sp-keymap (kbd "C-]") 'sp-select-next-thing-exchange)
    (define-key sp-keymap (kbd "C-<left_bracket>") 'sp-select-previous-thing)
    (define-key sp-keymap (kbd "C-M-]") 'sp-select-next-thing)
    (define-key sp-keymap (kbd "M-F") 'sp-forward-symbol)
    (define-key sp-keymap (kbd "M-B") 'sp-backward-symbol)
    (define-key sp-keymap (kbd "H-t") 'sp-prefix-tag-object)
    (define-key sp-keymap (kbd "H-p") 'sp-prefix-pair-object)
    (define-key sp-keymap (kbd "H-s c") 'sp-convolute-sexp)
    (define-key sp-keymap (kbd "H-s a") 'sp-absorb-sexp)
    (define-key sp-keymap (kbd "H-s e") 'sp-emit-sexp)
    (define-key sp-keymap (kbd "H-s p") 'sp-add-to-previous-sexp)
    (define-key sp-keymap (kbd "H-s n") 'sp-add-to-next-sexp)
    (define-key sp-keymap (kbd "H-s j") 'sp-join-sexp)
    (define-key sp-keymap (kbd "H-s s") 'sp-split-sexp)

    (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil)
    ;; Remove '' pairing in elisp because quoting is used a ton
    (sp-local-pair 'emacs-lisp-mode "'" nil :actions nil)

    (sp-with-modes '(html-mode sgml-mode)
      (sp-local-pair "<" ">"))

    (sp-with-modes sp--lisp-modes
      (sp-local-pair "(" nil :bind "C-("))))


(add-hook 'prog-mode-hook
          (lambda ()
            (smartparens-global-mode t)
            (show-smartparens-global-mode t)))

(use-package flycheck
  :bind (("M-g M-n" . flycheck-next-error)
         ("M-g M-p" . flycheck-previous-error)
         ("M-g M-=" . flycheck-list-errors))
  :idle (global-flycheck-mode)
  :config
  (progn
    (setq-default flycheck-disabled-checkers
                  '(emacs-lisp-checkdoc))
    (use-package flycheck-tip
      :config
      (add-hook 'flycheck-mode-hook
                (lambda ()
                  (global-set-key (kbd "C-c C-n") 'flycheck-tip-cycle)
                  (global-set-key (kbd "C-c C-p") 'flycheck-tip-cycle-reverse))))))

(use-package expand-region
  :bind (("C-c e" . er/expand-region)
         ("C-M-@" . er/contract-region)))

(use-package magit
  :bind ("M-g M-g" . magit-status)
  :config
  (progn
    (when (eq system-type 'darwin)
      (setq magit-emacsclient-executable "/usr/local/Cellar/emacs/HEAD/bin/emacsclient"))
    (defun magit-browse ()
      (interactive)
      (let ((url (with-temp-buffer
                   (unless (zerop (call-process-shell-command "git remote -v" nil t))
                     (error "Failed: 'git remote -v'"))
                   (goto-char (point-min))
                   (when (re-search-forward "github\\.com[:/]\\(.+?\\)\\.git" nil t)
                     (format "https://github.com/%s" (match-string 1))))))
        (unless url
          (error "Can't find repository URL"))
        (browse-url url)))

    (define-key magit-mode-map (kbd "C-c C-b") 'magit-browse)
    (define-key magit-status-mode-map (kbd "W") 'magit-toggle-whitespace)
    ;; faces
    ;; (set-face-attribute 'magit-branch nil
    ;;                     :foreground "yellow" :weight 'bold :underline t)
    (when (eq my/background 'dark)
      (add-hook 'magit-mode-hook
                (lambda ()
                  (set-face-attribute 'magit-item-highlight nil
                                      :background "#262626"))))
    (custom-set-variables '(magit-set-upstream-on-push (quote dontask)))))

(use-package projectile
  :bind (;;("C-x f" . projectile-find-file)
         ("C-c p s" . projectile-switch-project))
  :config
  (progn
    (defconst projectile-mode-line-lighter " P")))

(use-package prodigy
  :bind ("C-x P" . prodigy)
  :config
  (progn
    (prodigy-define-service
      :name "Elasticsearch 1.3.0"
      :cwd "~/ies/elasticsearch-1.3.0/"
      :command "~/ies/elasticsearch-1.3.0/bin/elasticsearch"
      :tags '(work test es)
      :port 9200)

    (prodigy-define-service
      :name "Elasticsearch 1.2.2"
      :cwd "~/ies/elasticsearch-1.2.2/"
      :command "~/ies/elasticsearch-1.2.2/bin/elasticsearch"
      :tags '(work test es)
      :port 9200)

    (prodigy-define-service
      :name "Elasticsearch 1.1.2"
      :cwd "~/ies/elasticsearch-1.1.2/"
      :command "~/ies/elasticsearch-1.1.2/bin/elasticsearch"
      :tags '(work test es)
      :port 9200)

    (prodigy-define-service
      :name "Elasticsearch 1.0.3"
      :cwd "~/ies/elasticsearch-1.0.3/"
      :command "~/ies/elasticsearch-1.0.3/bin/elasticsearch"
      :tags '(work test es)
      :port 9200)

    (prodigy-define-service
      :name "Elasticsearch 0.90.13"
      :cwd "~/ies/elasticsearch-0.90.13/"
      :command "~/ies/elasticsearch-0.90.13/bin/elasticsearch"
      :args '("-f")
      :tags '(work test es)
      :port 9200)))

(use-package git-gutter
  :bind (;;("C-x C-a" . git-gutter:toggle)
         ("C-x =" . git-gutter:popup-hunk)
         ("C-c P" . git-gutter:previous-hunk)
         ("C-c N" . git-gutter:next-hunk)
         ("C-x p" . git-gutter:previous-hunk)
         ("C-x n" . git-gutter:next-hunk)
         ("C-c G" . git-gutter:popup-hunk)))

(add-hook 'prog-mode-hook (lambda () (git-gutter-mode t)))

(use-package highlight-symbol
  :bind (("M-n" . highlight-symbol-next)
         ("M-p" . highlight-symbol-prev)))

(use-package anzu
  :bind ("M-%" . anzu-query-replace-regexp)
  :config
  (progn
    (use-package thingatpt)
    (setq anzu-mode-lighter "")
    (set-face-attribute 'anzu-mode-line nil :foreground "yellow")))

(add-hook 'prog-mode-hook (lambda () (global-anzu-mode t)))

(defun isearch-yank-symbol ()
  (interactive)
  (isearch-yank-internal (lambda () (forward-symbol 1) (point))))

(define-key isearch-mode-map (kbd "C-M-w") 'isearch-yank-symbol)

(use-package easy-kill
  :init (global-set-key [remap kill-ring-save] 'easy-kill))

(use-package helm
  :bind
  (("C-M-z" . helm-resume)
   ("C-h b" . helm-descbinds)
   ("C-x C-r" . helm-mini)
   ("C-x M-o" . helm-occur)
   ("C-x C-o" . helm-occur)
   ("M-y" . helm-show-kill-ring)
   ("C-h a" . helm-apropos)
   ("C-h m" . helm-man-woman)
   ("M-g >" . helm-ag-this-file)
   ("M-g ," . helm-ag-pop-stack)
   ("M-g ." . helm-do-grep)
   ("C-x C-i" . helm-semantic-or-imenu)
   ("C-c M-x" . helm-M-x)
   ("C-x C-b" . helm-buffers-list)
   ;;("C-x b" . helm-buffers-list)
   ("C-x b" . helm-mini)
   ("C-h t" . helm-world-time)
   ("C-h s" . helm-simple-call-tree))
  :idle (helm-mode 1)
  :config
  (progn
    (use-package helm-config)
    (use-package helm-files)
    (use-package helm-grep)
    (use-package helm-eshell)
    (use-package helm-man)
    (use-package helm-misc)
    (use-package helm-aliases)
    (use-package helm-elisp)
    (use-package helm-imenu)
    (use-package helm-semantic)
    (use-package helm-call-tree)
    (use-package helm-ring)
    (use-package helm-projectile
      :bind (("C-x f" . helm-projectile)))
    (setq helm-idle-delay 0.1
          helm-exit-idle-delay 0.1
          helm-input-idle-delay 0
          helm-candidate-number-limit 500
          helm-buffers-fuzzy-matching t
          helm-grep-default-command
          ;;"ggrep -a -d skip %e -n%cH -e %p %f"
          "grep -a -d skip %e -n%cH -e %p %f"
          helm-grep-default-recurse-command
          ;;"ggrep -a -d recurse %e -n%cH -e %p %f"
          "grep -a -d recurse %e -n%cH -e %p %f"
          )
    (setq display-time-world-list '(("PST8PDT" "Los Altos")
                                    ("America/Denver" "Denver")
                                    ("EST5EDT" "Boston")
                                    ("UTC" "UTC")
                                    ("Europe/London" "London")
                                    ("Europe/Amsterdam" "Amsterdam")
                                    ("Asia/Tokyo" "Tokyo")
                                    ("Australia/Sydney" "Sydney")))
    (define-key helm-map (kbd "C-p")   'helm-previous-line)
    (define-key helm-map (kbd "C-n")   'helm-next-line)
    (define-key helm-map (kbd "C-M-n") 'helm-next-source)
    (define-key helm-map (kbd "C-M-p") 'helm-previous-source)

    ;; Start of not-my-config stuff
    ;; taken from https://tuhdo.github.io/helm-intro.html#sec-6
    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to do persistent action
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
    (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

    (define-key helm-grep-mode-map (kbd "<return>")  'helm-grep-mode-jump-other-window)
    (define-key helm-grep-mode-map (kbd "n")  'helm-grep-mode-jump-other-window-forward)
    (define-key helm-grep-mode-map (kbd "p")  'helm-grep-mode-jump-other-window-backward)

    (setq helm-google-suggest-use-curl-p t
          helm-scroll-amount 4 ; scroll 4 lines other window using M-<next>/M-<prior>
          helm-quick-update t ; do not display invisible candidates
          helm-idle-delay 0.01 ; be idle for this many seconds, before updating in delayed sources.
          helm-input-idle-delay 0.01 ; be idle for this many seconds, before updating candidate buffer
          helm-ff-search-library-in-sexp t ; search for library in `require' and `declare-function' sexp.

          ;; you can customize helm-do-grep to execute ack-grep
          ;; helm-grep-default-command "ack-grep -Hn --smart-case --no-group --no-color %e %p %f"
          ;; helm-grep-default-recurse-command "ack-grep -H --smart-case --no-group --no-color %e %p %f"
          helm-split-window-default-side 'other ;; open helm buffer in another window
          helm-split-window-in-side-p t ;; open helm buffer inside current window, not occupy whole other window
          helm-buffers-favorite-modes (append helm-buffers-favorite-modes
                                              '(picture-mode artist-mode))
          helm-candidate-number-limit 200 ; limit the number of displayed canidates
          helm-M-x-requires-pattern 0     ; show all candidates when set to 0
          helm-boring-file-regexp-list
          '("\\.git$" "\\.hg$" "\\.svn$" "\\.CVS$" "\\._darcs$" "\\.la$" "\\.o$" "\\.i$") ; do not show these files in helm buffer
          helm-ff-file-name-history-use-recentf t
          helm-move-to-line-cycle-in-source t ; move to end or beginning of source
                                        ; when reaching top or bottom of source.
          ido-use-virtual-buffers t     ; Needed in helm-buffers-list
          helm-buffers-fuzzy-matching t ; fuzzy matching buffer names when non--nil
                                        ; useful in helm-mini that lists buffers
          )

    (define-key helm-map (kbd "C-x 2") 'helm-select-2nd-action)
    (define-key helm-map (kbd "C-x 3") 'helm-select-3rd-action)
    (define-key helm-map (kbd "C-x 4") 'helm-select-4rd-action)

    ;; helm-mini instead of recentf
    (global-set-key (kbd "C-x C-r") 'helm-mini)
    (global-set-key (kbd "C-x C-f") 'helm-find-files)
    (global-set-key (kbd "C-c h s") 'helm-semantic-or-imenu)
    (global-set-key (kbd "C-c h m") 'helm-man-woman)
    (global-set-key (kbd "C-c h g") 'helm-do-grep)
    (global-set-key (kbd "C-c h f") 'helm-find)
    (global-set-key (kbd "C-c h l") 'helm-locate)
    (global-set-key (kbd "C-c h o") 'helm-occur)
    (global-set-key (kbd "C-c h r") 'helm-resume)
    (define-key 'help-command (kbd "C-f") 'helm-apropos)
    (define-key 'help-command (kbd "r") 'helm-info-emacs)

    ;; use helm to list eshell history
    (add-hook 'eshell-mode-hook
              #'(lambda ()
                  (define-key eshell-mode-map (kbd "M-l")  'helm-eshell-history)))

    ;; Save current position to mark ring
    (add-hook 'helm-goto-line-before-hook 'helm-save-current-pos-to-mark-ring)

    (defvar helm-httpstatus-source
      '((name . "HTTP STATUS")
        (candidates . (("100 Continue") ("101 Switching Protocols")
                       ("102 Processing") ("200 OK")
                       ("201 Created") ("202 Accepted")
                       ("203 Non-Authoritative Information") ("204 No Content")
                       ("205 Reset Content") ("206 Partial Content")
                       ("207 Multi-Status") ("208 Already Reported")
                       ("300 Multiple Choices") ("301 Moved Permanently")
                       ("302 Found") ("303 See Other")
                       ("304 Not Modified") ("305 Use Proxy")
                       ("307 Temporary Redirect") ("400 Bad Request")
                       ("401 Unauthorized") ("402 Payment Required")
                       ("403 Forbidden") ("404 Not Found")
                       ("405 Method Not Allowed") ("406 Not Acceptable")
                       ("407 Proxy Authentication Required") ("408 Request Timeout")
                       ("409 Conflict") ("410 Gone")
                       ("411 Length Required") ("412 Precondition Failed")
                       ("413 Request Entity Too Large")
                       ("414 Request-URI Too Large")
                       ("415 Unsupported Media Type")
                       ("416 Request Range Not Satisfiable")
                       ("417 Expectation Failed") ("418 I'm a teapot")
                       ("422 Unprocessable Entity") ("423 Locked")
                       ("424 Failed Dependency") ("425 No code")
                       ("426 Upgrade Required") ("428 Precondition Required")
                       ("429 Too Many Requests")
                       ("431 Request Header Fields Too Large")
                       ("449 Retry with") ("500 Internal Server Error")
                       ("501 Not Implemented") ("502 Bad Gateway")
                       ("503 Service Unavailable") ("504 Gateway Timeout")
                       ("505 HTTP Version Not Supported")
                       ("506 Variant Also Negotiates")
                       ("507 Insufficient Storage") ("509 Bandwidth Limit Exceeded")
                       ("510 Not Extended")
                       ("511 Network Authentication Required")))
        (action . message)))

    (defvar helm-clj-http-source
      '((name . "clj-http options")
        (candidates
         .
         ((":accept - keyword for content type to accept")
          (":as - output coercion: :json, :json-string-keys, :clojure, :stream, :auto or string")
          (":basic-auth - string or vector of basic auth creds")
          (":body - body of request")
          (":body-encoding - encoding type for body string")
          (":client-params - apache http client params")
          (":coerce - when to coerce response body: :always, :unexceptional, :exceptional")
          (":conn-timeout - timeout for connection")
          (":connection-manager - connection pooling manager")
          (":content-type - content-type for request")
          (":cookie-store - CookieStore object to store/retrieve cookies")
          (":cookies - map of cookie name to cookie map")
          (":debug - boolean to print info to stdout")
          (":debug-body - boolean to print body debug info to stdout")
          (":decode-body-headers - automatically decode body headers")
          (":decompress-body - whether to decompress body automatically")
          (":digest-auth - vector of digest authentication")
          (":follow-redirects - boolean whether to follow HTTP redirects")
          (":form-params - map of form parameters to send")
          (":headers - map of headers")
          (":ignore-unknown-host? - whether to ignore inability to resolve host")
          (":insecure? - boolean whether to accept invalid SSL certs")
          (":json-opts - map of json options to be used for form params")
          (":keystore - file path to SSL keystore")
          (":keystore-pass - password for keystore")
          (":keystore-type - type of SSL keystore")
          (":length - manually specified length of body")
          (":max-redirects - maximum number of redirects to follow")
          (":multipart - vector of multipart options")
          (":oauth-token - oauth token")
          (":proxy-host - hostname of proxy server")
          (":proxy-ignore-hosts - set of hosts to ignore for proxy")
          (":proxy-post - port for proxy server")
          (":query-params - map of query parameters")
          (":raw-headers - boolean whether to return raw headers with response")
          (":response-interceptor - function called for each redirect")
          (":retry-handler - function to handle HTTP retries on IOException")
          (":save-request? - boolean to return original request with response")
          (":socket-timeout - timeout for establishing socket")
          (":throw-entire-message? - whether to throw the entire response on errors")
          (":throw-exceptions - boolean whether to throw exceptions on 5xx & 4xx")
          (":trust-store - file path to trust store")
          (":trust-store-pass - password for trust store")
          (":trust-store-type - type of trust store")))
        (action . message)))

    (defun helm-httpstatus ()
      (interactive)
      (helm-other-buffer '(helm-httpstatus-source) "*helm httpstatus*"))

    (defun helm-clj-http ()
      (interactive)
      (helm-other-buffer '(helm-clj-http-source) "*helm clj-http flags*"))

    (global-set-key (kbd "C-c M-C-h") 'helm-httpstatus)
    (global-set-key (kbd "C-c M-h") 'helm-clj-http)

    (use-package helm-descbinds
      :init (helm-descbinds-mode t))
    (use-package helm-ag
      :bind ("C-M-s" . helm-ag-this-file))
    (use-package helm-swoop
      :bind (("M-i" . helm-swoop)
             ("M-I" . helm-swoop-back-to-last-point)
             ("C-c M-i" . helm-multi-swoop))
      :config
      (progn
        ;; When doing isearch, hand the word over to helm-swoop
        (define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
        ;; From helm-swoop to helm-multi-swoop-all
        (define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)
        ;; Save buffer when helm-multi-swoop-edit complete
        (setq helm-multi-swoop-edit-save t
              ;; If this value is t, split window inside the current window
              helm-swoop-split-with-multiple-windows nil
              ;; Split direcion. 'split-window-vertically or 'split-window-horizontally
              helm-swoop-split-direction 'split-window-vertically
              ;; If nil, you can slightly boost invoke speed in exchange for text color
              helm-swoop-speed-or-color nil)))))

(use-package markdown-mode
  :config
  (progn
    (define-key markdown-mode-map (kbd "C-M-f") 'forward-symbol)
    (define-key markdown-mode-map (kbd "C-M-b") 'backward-symbol)
    (define-key markdown-mode-map (kbd "C-M-u") 'my/backward-up-list)

    (define-key markdown-mode-map (kbd "C-c C-n") 'outline-next-visible-heading)
    (define-key markdown-mode-map (kbd "C-c C-p") 'outline-previous-visible-heading)
    (define-key markdown-mode-map (kbd "C-c C-f") 'outline-forward-same-level)
    (define-key markdown-mode-map (kbd "C-c C-b") 'outline-backward-same-level)
    (define-key markdown-mode-map (kbd "C-c C-u") 'outline-up-heading)

    (defvar markdown-imenu-generic-expression
      '(("title"  "^\\(.+?\\)[\n]=+$" 1)
        ("h2-"    "^\\(.+?\\)[\n]-+$" 1)
        ("h1"   "^#\\s-+\\(.+?\\)$" 1)
        ("h2"   "^##\\s-+\\(.+?\\)$" 1)
        ("h3"   "^###\\s-+\\(.+?\\)$" 1)
        ("h4"   "^####\\s-+\\(.+?\\)$" 1)
        ("h5"   "^#####\\s-+\\(.+?\\)$" 1)
        ("h6"   "^######\\s-+\\(.+?\\)$" 1)
        ("fn"   "^\\[\\^\\(.+?\\)\\]" 1) ))))

(use-package editorconfig)

(use-package auto-complete
  :disabled t
  :defer t
  :init (progn
          (use-package popup)
          (use-package fuzzy)
          (use-package auto-complete-config)
          ;; Enable auto-complete mode other than default enable modes
          (add-to-list 'ac-modes 'cider-repl-mode)
          (global-auto-complete-mode t)
          (ac-config-default))
  :config
  (progn
    (define-key ac-complete-mode-map (kbd "M-n") 'ac-next)
    (define-key ac-complete-mode-map (kbd "M-p") 'ac-previous)
    (define-key ac-complete-mode-map (kbd "C-s") 'ac-isearch)
    (define-key ac-completing-map (kbd "<tab>") 'ac-complete)))

(use-package company
  :diminish ""
  :config
  (progn
    (setq company-idle-delay 0.2
          ;; min prefix of 3 chars
          company-minimum-prefix-length 3)))

(add-hook 'prog-mode-hook 'global-company-mode)

(use-package smart-tab
  :diminish ""
  :config
  (progn
    (add-to-list 'smart-tab-disabled-major-modes 'mu4e-compose-mode)
    (add-to-list 'smart-tab-disabled-major-modes 'erc-mode)
    (add-to-list 'smart-tab-disabled-major-modes 'shell-mode)))

(add-hook 'prog-mode-hook (lambda () (global-smart-tab-mode 1)))

(use-package undo-tree
  :init (global-undo-tree-mode)
  :diminish ""
  :config
  (progn
    (define-key undo-tree-map (kbd "C-x u") 'undo-tree-visualize)
    (define-key undo-tree-map (kbd "C-/") 'undo-tree-undo)))

(use-package popwin
  :bind ("C-'" . popwin:keymap)
  :config
  (progn
    (defvar popwin:special-display-config-backup popwin:special-display-config)
    (setq display-buffer-function 'popwin:display-buffer)

    ;; basic
    (push '("*Help*" :stick t :noselect t) popwin:special-display-config)
    (push '("*helm world time*" :stick t :noselect t) popwin:special-display-config)

    ;; magit
    (push '("*magit-process*" :stick t) popwin:special-display-config)

    ;; quickrun
    (push '("*quickrun*" :stick t) popwin:special-display-config)

    ;; dictionaly
    (push '("*dict*" :stick t) popwin:special-display-config)
    (push '("*sdic*" :stick t) popwin:special-display-config)

    ;; popwin for slime
    (push '(slime-repl-mode :stick t) popwin:special-display-config)

    ;; man
    (push '(Man-mode :stick t :height 20) popwin:special-display-config)

    ;; Elisp
    (push '("*ielm*" :stick t) popwin:special-display-config)
    (push '("*eshell pop*" :stick t) popwin:special-display-config)

    ;; pry
    (push '(inf-ruby-mode :stick t :height 20) popwin:special-display-config)

    ;; python
    (push '("*Python*"   :stick t) popwin:special-display-config)
    (push '("*Python Help*" :stick t :height 20) popwin:special-display-config)
    (push '("*jedi:doc*" :stick t :noselect t) popwin:special-display-config)

    ;; Haskell
    (push '("*haskell*" :stick t) popwin:special-display-config)
    (push '("*GHC Info*") popwin:special-display-config)

    ;; sgit
    (push '("*sgit*" :position right :width 0.5 :stick t)
          popwin:special-display-config)

    ;; git-gutter
    (push '("*git-gutter:diff*" :width 0.5 :stick t)
          popwin:special-display-config)

    ;; direx
    (push '(direx:direx-mode :position left :width 40 :dedicated t)
          popwin:special-display-config)

    (push '("*Occur*" :stick t) popwin:special-display-config)

    ;; prodigy
    (push '("*prodigy*" :stick t) popwin:special-display-config)

    ;; malabar-mode
    (push '("*Malabar Compilation*" :stick t :height 30)
          popwin:special-display-config)

    ;; org-mode
    (push '("*Org tags*" :stick t :height 30)
          popwin:special-display-config)))

(use-package paren-face
  :init (global-paren-face-mode))

(use-package ido
  :init (ido-mode 1)
  :config
  (progn
    (setq ido-use-virtual-buffers nil
          ido-enable-prefix nil
          ido-enable-flex-matching t
          ido-auto-merge-work-directories-length nil
          ido-create-new-buffer 'always
          ido-use-filename-at-point 'guess
          ido-max-prospects 10)))

(use-package flx-ido
  :init (flx-ido-mode 1)
  :config
  (setq ido-use-faces nil))

(use-package ido-vertical-mode
  :init (ido-vertical-mode t))

(use-package ido-ubiquitous)

(use-package toggle-quotes
  :bind ("M-\"" . toggle-quotes))

;; this has to go before the (require 'visible-mark)
(defface visible-mark-active
  '((((type tty) (class mono)))
    (t (:background "magenta"))) "")

(use-package visible-mark
  :init (global-visible-mark-mode 1)
  :disabled t
  :config
  (progn
    (setq visible-mark-max 2)
    (setq visible-mark-faces `(visible-mark-face1 my-visible-mark-face2))))

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package twittering-mode
  :defer t
  :config
  (progn
    (setq twittering-icon-mode t
        twittering-use-master-password t)))

(use-package scpaste
  :config
  (setq scpaste-http-destination "http://p.writequit.org"
        scpaste-scp-destination "writequit:public_html/wq/paste/"))

(use-package smex
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands)))

(use-package color-identifiers-mode)

(defun my/enable-color-identifiers ()
  (interactive)
  (color-identifiers-mode t))

(add-hook 'java-mode-hook 'my/enable-color-identifiers)
;;(add-hook 'prog-mode-hook 'my/enable-color-identifiers)

(use-package iedit
  :bind ("C-;" . iedit-mode))

(use-package hideshow
  :bind (("C-c TAB" . hs-toggle-hiding)
         ("C-\\" . hs-toggle-hiding)
         ("M-\\" . hs-hide-all)
         ("M-|" . hs-show-all))
  :config
  (progn
    (defvar hs-special-modes-alist
      (mapcar 'purecopy
              '((c-mode "{" "}" "/[*/]" nil nil)
                (c++-mode "{" "}" "/[*/]" nil nil)
                (bibtex-mode ("@\\S(*\\(\\s(\\)" 1))
                (java-mode "{" "}" "/[*/]" nil nil)
                (js-mode "{" "}" "/[*/]" nil)
                (javascript-mode  "{" "}" "/[*/]" nil))))))

(defun my/enable-hs-minor-mode ()
  (interactive)
  (hs-minor-mode t))

;; (add-hook 'javascript-mode-hook 'my/enable-hs-minor-mode)
;; (add-hook 'js-mode-hook 'my/enable-hs-minor-mode)
;; (add-hook 'java-mode-hook 'my/enable-hs-minor-mode)
(add-hook 'prog-mode-hook 'my/enable-hs-minor-mode)

(use-package indent-guide)

(add-hook 'prog-mode-hook (lambda () (indent-guide-mode t)))

(use-package abbrev
  :config
  (define-abbrev-table 'global-abbrev-table
    '(("elasticsearhc" "elasticsearch" nil 0)
      ("elastiscearch" "elasticsearch" nil 0)
      ("elastiscearhc" "elasticsearch" nil 0)
      ("elatsicsearch" "elasticsearch" nil 0))))

(defun my/enable-abbrev-mode ()
  (interactive)
  (abbrev-mode t))

(add-hook 'prog-mode-hook 'my/enable-abbrev-mode)
(add-hook 'org-mode-hook 'my/enable-abbrev-mode)

(use-package smart-mode-line
  :disabled t
  :init
  (progn
    (setq sml/no-confirm-load-theme t)
    (setq sml/mode-width 'full)
    (sml/setup)
    (sml/apply-theme my/background)))

(use-package powerline
  :disabled t
  :init
  (progn
    (powerline-default-theme)))

(defun amit-modeline ()
  "Set up Amit's modeline, currently only set up for dark backgrounds"
  (interactive)
  ;; Mode line setup
  (setq-default
   mode-line-format
   '(;; Position, including warning for 80 columns
     (:propertize "%5l:" face mode-line-position-face)
     (:eval (propertize "%3c" 'face
                        (if (>= (current-column) 80)
                            'mode-line-80col-face
                          'mode-line-position-face)))
     ;; emacsclient [default -- keep?]
     mode-line-client
     " "
     ;; read-only or modified status
     (:eval
      (cond (buffer-read-only
             (propertize " RO " 'face 'mode-line-read-only-face))
            ((buffer-modified-p)
             (propertize " ** " 'face 'mode-line-modified-face))
            (t " ")))
     " "
     ;; directory and buffer/file name
     (:propertize (:eval (shorten-directory default-directory 30))
                  face mode-line-folder-face)
     (:propertize "%b"
                  face mode-line-filename-face)
     ;; narrow [default -- keep?]
     " %n "
     ;; mode indicators: vc, recursive edit, major mode, minor modes, process, global
     (vc-mode vc-mode)
     " %["
     (:propertize mode-name
                  face mode-line-mode-face)
     "%] "
     (:eval (propertize (format-mode-line minor-mode-alist)
                        'face 'mode-line-minor-mode-face))
     (:propertize mode-line-process
                  face mode-line-process-face)
     (global-mode-string global-mode-string)
     " "
     ;; nyan-mode uses nyan cat as an alternative to %p
     (:eval (when nyan-mode (list (nyan-create))))
     ))

  ;; Helper function
  (defun shorten-directory (dir max-length)
    "Show up to `max-length' characters of a directory name `dir'."
    (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
          (output ""))
      (when (and path (equal "" (car path)))
        (setq path (cdr path)))
      (while (and path (< (length output) (- max-length 4)))
        (setq output (concat (car path) "/" output))
        (setq path (cdr path)))
      (when path
        (setq output (concat ".../" output)))
      output))

  ;; Extra mode line faces
  (make-face 'mode-line-read-only-face)
  (make-face 'mode-line-modified-face)
  (make-face 'mode-line-folder-face)
  (make-face 'mode-line-filename-face)
  (make-face 'mode-line-position-face)
  (make-face 'mode-line-mode-face)
  (make-face 'mode-line-minor-mode-face)
  (make-face 'mode-line-process-face)
  (make-face 'mode-line-80col-face)

  (set-face-attribute 'mode-line nil
                      :foreground "gray60" :background "gray10"
                      :inverse-video nil
                      :box '(:line-width 1 :color "gray60" :style nil))
  (set-face-attribute 'mode-line-inactive nil
                      :foreground "gray60" :background "gray20"
                      :inverse-video nil
                      :box '(:line-width 1 :color "gray10" :style nil))
  (set-face-attribute 'mode-line-read-only-face nil
                      :inherit 'mode-line-face
                      :foreground "#4271ae"
                      :box '(:line-width 1 :color "#4271ae"))
  (set-face-attribute 'mode-line-modified-face nil
                      :inherit 'mode-line-face
                      :foreground "#c82829"
                      :background "#ffffff"
                      :box '(:line-width 1 :color "#c82829"))
  (set-face-attribute 'mode-line-folder-face nil
                      :inherit 'mode-line-face
                      :foreground "gray60")
  (set-face-attribute 'mode-line-filename-face nil
                      :inherit 'mode-line-face
                      :foreground "#eab700"
                      :weight 'bold)
  (set-face-attribute 'mode-line-position-face nil
                      :inherit 'mode-line-face
                      :height 100)
  (set-face-attribute 'mode-line-mode-face nil
                      :inherit 'mode-line-face
                      :foreground "gray80")
  (set-face-attribute 'mode-line-minor-mode-face nil
                      :inherit 'mode-line-mode-face
                      :foreground "gray40"
                      :height 110)
  (set-face-attribute 'mode-line-process-face nil
                      :inherit 'mode-line-face
                      :foreground "#718c00")
  (set-face-attribute 'mode-line-80col-face nil
                      :inherit 'mode-line-position-face
                      :foreground "black" :background "#eab700"))

;; Only set up Amit's modeline when using a dark background
(when (eq my/background 'dark)
  (amit-modeline))

(global-set-key (kbd "C-h e") 'popwin:messages)
(global-set-key (kbd "C-h C-p") 'popwin:special-display-config)
(global-set-key (kbd "C-x +") 'balance-windows-area)

;; M-g mapping
(global-set-key (kbd "M-g M-f") 'ffap)

;; some navigation helpers
(global-set-key "\M-9" 'backward-sexp)
(global-set-key "\M-0" 'forward-sexp)

(global-set-key (kbd "C-x C-l") 'toggle-truncate-lines)

;; join on killing lines
(defun kill-and-join-forward (&optional arg)
  "If at end of line, join with following; otherwise kill line.
Deletes whitespace at join."
  (interactive "P")
  (if (and (eolp) (not (bolp)))
      (delete-indentation t)
    (kill-line arg)))

(global-set-key (kbd "C-k") 'kill-and-join-forward)

;; You know, like Readline.
(global-set-key (kbd "C-M-h") 'backward-kill-word)

;; Completion that uses many different methods to find options.
(global-set-key (kbd "M-/") 'hippie-expand)

;; Perform general cleanup.
(global-set-key (kbd "C-c n") 'cleanup-buffer)

;; Font size
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; Use regex searches by default.
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)

(global-set-key (kbd "C-c y") 'bury-buffer)
(global-set-key (kbd "C-c r") 'revert-buffer)

;; Start eshell or switch to it if it's active.
(global-set-key (kbd "C-x m") 'eshell)

;; Start a new eshell even if one is active.
(global-set-key (kbd "C-x M") (lambda () (interactive) (eshell t)))

;; Start a regular shell if you prefer that.
(global-set-key (kbd "C-x C-m") 'shell)

;; If you want to be able to M-x without meta (phones, etc)
(global-set-key (kbd "C-c C-x") 'execute-extended-command)

;; So good!
(global-set-key (kbd "C-c g") 'magit-status)

;; Activate occur easily inside isearch
(define-key isearch-mode-map (kbd "C-o")
  (lambda () (interactive)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string (regexp-quote isearch-string))))))

;; ==== Window switching ====
(global-set-key (kbd "M-'") 'other-window)
(global-set-key (kbd "H-'") 'other-window)
(global-set-key [C-tab] 'other-window)
(global-set-key [C-S-tab]
                (lambda ()
                  (interactive)
                  (other-window -1)))

;; ==== transpose buffers ====
(defun transpose-buffers (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

(global-set-key (kbd "C-x 4 t") 'transpose-buffers)

;; lisp stuff
(define-key lisp-mode-shared-map (kbd "RET") 'reindent-then-newline-and-indent)

(defun find-agent ()
  (first (split-string
          (shell-command-to-string
           (concat
            "ls -t1 "
            "$(find /tmp/ -uid $UID -path \\*ssh\\* -type s 2> /dev/null)"
            "|"
            "head -1")))))

(defun fix-agent ()
  (interactive)
  (let ((agent (find-agent)))
    (setenv "SSH_AUTH_SOCK" agent)
    (message agent)))

(defun beautify-json ()
  (interactive)
  (let ((b (if mark-active (min (point) (mark)) (point-min)))
        (e (if mark-active (max (point) (mark)) (point-max))))
    (shell-command-on-region b e
                             "python -mjson.tool" (current-buffer) t)))

(defun byte-recompile-init-files ()
  "Recompile all of the startup files"
  (interactive)
  (byte-recompile-directory "~/.emacs.d" 0))

(defun add-to-path (path-element)
  "Add the specified path element to the Emacs PATH"
  (interactive "DEnter directory to be added to path: ")
  (if (file-directory-p path-element)
      (setenv "PATH"
              (concat (expand-file-name path-element)
                      path-separator (getenv "PATH")))))

(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

(defun browse-last-url-in-brower ()
  (interactive)
  (save-excursion
    (let ((ffap-url-regexp
           (concat
            "\\("
            "news\\(post\\)?:\\|mailto:\\|file:"
            "\\|"
            "\\(ftp\\|https?\\|telnet\\|gopher\\|www\\|wais\\)://"
            "\\).")))
      (ffap-next t t))))

(global-set-key (kbd "C-c u") 'browse-last-url-in-brower)

(defun number-rectangle (start end format-string from)
  "Delete (don't save) text in the region-rectangle, then number it."
  (interactive
   (list (region-beginning) (region-end)
         (read-string "Number rectangle: "
                      (if (looking-back "^ *") "%d. " "%d"))
         (read-number "From: " 1)))
  (save-excursion
    (goto-char start)
    (setq start (point-marker))
    (goto-char end)
    (setq end (point-marker))
    (delete-rectangle start end)
    (goto-char start)
    (loop with column = (current-column)
          while (and (<= (point) end) (not (eobp)))
          for i from from   do
          (move-to-column column t)
          (insert (format format-string i))
          (forward-line 1)))
  (goto-char start))

(global-set-key (kbd "C-x r N") 'number-rectangle)

(defun my/insert-lod ()
  "Well. This is disappointing."
  (interactive)
  (insert "ಠ_ಠ"))

(global-set-key (kbd "C-c M-d") 'my/insert-lod)

(defun my/search-es-docs (text)
  "Search ES docs for `text'."
  (interactive (list (read-string "Search for: ")))
  (use-package w3m)
  (w3m-goto-url-new-session
   (url-encode-url
    (format "http://www.elasticsearch.org/?s=%s" text))))

(global-set-key (kbd "C-c d") 'my/search-es-docs)
(global-set-key (kbd "C-x d") 'my/search-es-docs)

;; Message how long it took to load everything (minus packages)
(let ((elapsed (float-time (time-subtract (current-time)
                                          emacs-start-time))))
  (message "Loading settings...done (%.3fs)" elapsed))
