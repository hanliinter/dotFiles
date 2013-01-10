(setq debug-on-error t)
;(Sete-fontset-font (frame-parameter nil 'font)  
 ;                 'unicode '("STHeiti" . "unicode-bmp")) 



;; UTF-8 settings
(set-language-environment "UTF-8")
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(modify-coding-system-alist 'process "*" 'utf-8)

(setq default-process-coding-system
      '(chinese-gbk . chinese-gbk))
(setq-default pathname-coding-system 'chinese-gbk)

;; font
(set-frame-font "Monaco-14") ;; for Mac

;; toolbar
;(tool-bar-mode nil)

;;menu-bar
;(menu-bar-mode nil)

(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setq exec-path(append exec-path ' ("/usr/local/bin")))

(add-to-list 'load-path "~/.emacs.d/")
(add-to-list 'load-path "~/.emacs.d/site-lisp/color-theme/")
;(add-to-list 'load-path "~/.emacs.d/site-lisp/color-theme/emacs-color-theme-solarized/")
(load-file "~/.emacs.d/color-theme-molokai.el")

(add-to-list 'load-path "~/.emacs.d/site-lisp/yasnippet/")
(add-to-list 'load-path "~/.emacs.d/site-lisp/")
(load-file  "~/code/cedet-1.1/common/cedet.el")

;(require 'txl-mode)
;(setq auto-mode-alist (cons (quote ("\\.\\([tT]xl\\|[gG]rm\\|[gG]rammar\\|[rR]ul\\(es\\)?\\|[mM]od\\(ule\\)?\\)$" . txl-mode)) auto-mode-alist))

;line numbers
(global-linum-mode t)

(require 'xcscope)

;;color-scheme
;(require 'color-theme)
;(color-theme-initialize)
;(color-theme-clarity)
;(color-theme-molokai)
;(require 'color-theme-solarized)
;(color-theme-solarized-light)
;;yasnippet

(require 'yasnippet)
;(setq yas/trigger-key (kbd "C-c <kp-multiply>"))
(yas/initialize)
(yas/load-directory "~/.emacs.d/site-lisp/yasnippet/snippets")

;;do not set Tab to yasnippet because use ac-complete,so the yasnippet is used indirectly


;;cedet
(require 'cedet)
(global-ede-mode t)
(semantic-load-enable-gaudy-code-helpers)
;(semantic-load-enable-semantic-debugging-helpers)
;(setq semantic-default-submodes '(global-semantic-idle-scheduler-mode
;				  global-semanticdb-minor-mode
;				  global-semantic-idle-summary-mode
;				  global-semantic-mru-bookmark-mode))

;(semantic-mode 1)

;(defconst cedet-user-include-dirs
 ; (list ".." "../include" "../inc" "../common" "../public"
;	"../.." "../../include" "../..inc" "../../common" "../../public"))

;(defconst cedet-win32-include-dirs
 ;  (list "D:/Program Files/Microsoft Visual Studio 10.0/VC/include"))

;(require 'semantic-c nil 'noerror)
;(let ((include-dirs cedet-user-include-dirs))
 ; (when (eq system-type 'windows-nt)
  ;  (setq include-dirs (append include-dirs cedet-win32-include-dirs)))
 ; (mapc(lambda (dir)
;	 (semantic-add-system-include dir 'c++-mode)
;	 (semantic-add-system-include dir 'c-mode))
;	 include-dirs))

;meta-up & down from textmate

 (global-set-key [(meta up)] 'move-line-up)
(global-set-key [(meta down)] 'move-line-down) 
(defun move-line (&optional n)
 "Move current line N (1) lines up/down leaving point in place."
 (interactive "p")
 (when (null n)
    (setq n 1))
 (let ((col (current-column)))
    (beginning-of-line)
    (next-line 1)
    (transpose-lines n)
    (previous-line 1)
    (forward-char col)))
(defun move-line-up (n)
 "Moves current line N (1) lines up leaving point in place."
 (interactive "p")
 (move-line (if (null n) -1 (- n)))) 
(defun move-line-down (n)
 "Moves current line N (1) lines down leaving point in place."
 (interactive "p")
 (move-line (if (null n) 1 n)))

;vi-open-next-line
(global-set-key [(control o)] 'vi-open-next-line)
(defun vi-open-next-line (arg)
 "Move to the next line (like vi) and then opens a line."
 (interactive "p")
 (end-of-line)
 (open-line arg)
 (next-line 1)
 (indent-according-to-mode))

;parent-match
(global-set-key "%" 'match-paren)
(defun match-paren (arg)
 "Go to the matching parenthesis if on parenthesis otherwise insert %."
 (interactive "p")
 (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))


(global-set-key (kbd "<f7>") 'compile)


(defun smart-compile-is-root-dir(try-dir)
  (or
   ;; windows root dir for a driver or Unix root
   (string-match "\\`\\([a-zA-Z]:\\)?/$" try-dir)
   ;; tramp root-dir
   (and (featurep 'tramp)
        (string-match (concat tramp-file-name-regexp ".*:/$") try-dir))))
(defun smart-compile-throw-final-path(try-dir)
  (cond
   ;; tramp root-dir
   ((and (featurep 'tramp)
         (string-match tramp-file-name-regexp try-dir))
    (with-parsed-tramp-file-name try-dir foo
        foo-localname))
   (t try-dir)))

(defun smart-compile-find-make-dir( try-dir)
  "return a directory contain makefile. try-dir is absolute path."
  (if (smart-compile-is-root-dir try-dir)
      nil ;; return nil if failed to find such directory.
    (let ((candidate-make-file-name `("GNUmakefile" "makefile" "Makefile")))
      (or (catch 'break
            (mapc (lambda (f)
                    (if (file-readable-p (concat (file-name-as-directory try-dir) f))
                        (throw 'break (smart-compile-throw-final-path try-dir))))
                  candidate-make-file-name)
            nil)
          (smart-compile-find-make-dir
           (expand-file-name (concat (file-name-as-directory try-dir) "..")))))))


(defun wcy-tramp-compile (arg-cmd)
  "reimplement the remote compile."
  (interactive "scompile:")
  (with-parsed-tramp-file-name default-directory foo
    (let* ((key (format "/plink:%s@%s:" foo-user foo-host))
           (passwd (password-read "PASS:" key))
           (cmd (format "plink %s -l %s -pw %s \"(cd %s ; %s)\""
                         foo-host foo-user
                         passwd
                         (file-name-directory foo-localname)
                         arg-cmd)))
      (password-cache-add key passwd)
      (save-some-buffers nil nil)
      (compile-internal cmd "No more errors")
      ;; Set comint-file-name-prefix in the compilation buffer so
      ;; compilation-parse-errors will find referenced files by ange-ftp.
      (with-current-buffer compilation-last-buffer
        (set (make-local-variable 'comint-file-name-prefix)
             (format "/plink:%s@%s:" foo-user foo-host))))))
(defun smart-compile-test-tramp-compile()
  (or (and (featurep 'tramp)
           (string-match tramp-file-name-regexp (buffer-file-name))
           (progn
             (if (not (featurep 'tramp-util)) (require 'tramp-util))
             'wcy-tramp-compile))
      'compile))
(defun smart-compile-get-local-file-name(file-name)
  (if (and
       (featurep 'tramp)
       (string-match tramp-file-name-regexp file-name))
      (with-parsed-tramp-file-name file-name foo
        foo-localname)
    file-name))
(defun smart-compile ()
  (interactive)
  (let* ((compile-func (smart-compile-test-tramp-compile))
         (dir (smart-compile-find-make-dir (expand-file-name "."))))
    (funcall compile-func
             (if dir
                 (concat "make -C " dir (if (eq compile-func 'tramp-compile) "&" ""))
               (concat
                (cond
                 ((eq major-mode 'c++-mode) "g++ -g -o ")
                 ((eq major-mode 'c-mode) "gcc -g -o "))
                (smart-compile-get-local-file-name (file-name-sans-extension (buffer-file-name)))
                " "
                (smart-compile-get-local-file-name (buffer-file-name)))))))


(setq column-number-mode t)

(setq frame-title-format "Hanli.W's @%b")

(setq default-tab-width 4)
;(setq-default indent-tab-mode nil)

(require 'auto-complete)
(global-auto-complete-mode t)



; for python IDE


;for slime
(setq inferior-lisp-program "/usr/local/bin/sbcl") ;use sbcl
(add-to-list 'load-path "~/code/slime"); slime directory
(require 'slime-autoloads)
(slime-setup)



(add-to-list 'load-path "~/.emacs.d/python-mode/")
(setq py-install-directory "~/.emacs.d/python-mode/")
(require 'python-mode)

(add-to-list 'load-path "~/.emacs.d/Pymacs/Pymacs/")
(add-to-list 'load-path "~/.emacs.d/Pymacs/")
;(add-to-list 'load-path "~/.emacs.d/python-mode/Pymacs/")

(require 'pymacs)
;(setenv "PYMACS_PYTHON" "python")
(autoload 'python-mod "python-mode" "Python Mode.")
(add-to-list 'auto-mode-alist '("\\.py\\\'" . python-mode))
(add-to-list 'interpreter-mode-alist '("python" . python-mode))
;; Initialize Pymacs
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)
(autoload 'pymacs-autoload "pymacs")
;; Initialize Rope
;(pymacs-load "ropemacs" "rope-")
;(setq ropemacs-enable-autoimport t)

;(add-to-list 'load-path "~/.emacs.d/emacs-w3m-1.4.4")
;(require 'w3m-load)


(defun prefix-list-elements (list prefix)
  (let (value)
    (nreverse
     (dolist (element list value)
      (setq value (cons (format "%s%s" prefix element) value))))))
(defvar ac-source-rope
  '((candidates
     . (lambda ()
         (prefix-list-elements (rope-completions) ac-target))))
  "Source for Rope")
(defun ac-python-find ()
  "Python `ac-find-function'."
  (require 'thingatpt)
  (let ((symbol (car-safe (bounds-of-thing-at-point 'symbol))))
S    (if (null symbol)
        (if (string= "." (buffer-substring (- (point) 1) (point)))
            (point)
          nil)
      symbol)))
(defun ac-python-candidate ()
  "Python `ac-candidates-function'"
  (let (candidates)
    (dolist (source ac-sources)
      (if (symbolp source)
          (setq source (symbol-value source)))
      (let* ((ac-limit (or (cdr-safe (assq 'limit source)) ac-limit))
             (requires (cdr-safe (assq 'requires source)))
             cand)
        (if (or (null requires)
                (>= (length ac-target) requires))
            (setq cand
                  (delq nil
                        (mapcar (lambda (candidate)
                                  (propertize candidate 'source source))
                                (funcall (cdr (assq 'candidates source)))))))
        (if (and (> ac-limit 1)
                 (> (length cand) ac-limit))
            (setcdr (nthcdr (1- ac-limit) cand) nil))
        (setq candidates (append candidates cand))))
    (delete-dups candidates)))
(add-hook 'python-mode-hook
          (lambda ()
                 (auto-complete-mode 1)
                 (set (make-local-variable 'ac-sources)
                      (append ac-sources '(ac-source-rope) '(ac-source-yasnippet)))
                 (set (make-local-variable 'ac-find-function) 'ac-python-find)
                 (set (make-local-variable 'ac-candidate-function) 'ac-python-candidate)
                 (set (make-local-variable 'ac-auto-start) nil)))

;;Ryan's python specific tab completion                                                                        
(defun ryan-python-tab ()
  ; Try the following:                                                                                         
  ; 1) Do a yasnippet expansion                                                                                
  ; 2) Do a Rope code completion                                                                               
  ; 3) Do an indent                                                                                            
  (interactive)
  (if (eql (ac-start) 0)
      (indent-for-tab-command)))

(defadvice ac-start (before advice-turn-on-auto-start activate)
  (set (make-local-variable 'ac-auto-start) t))
(defadvice ac-cleanup (after advice-turn-off-auto-start activate)
  (set (make-local-variable 'ac-auto-start) nil))

(define-key python-mode-map "\t" 'ryan-python-tab)

 ;; My Own General Tab Completion
(defun ac-yasnippet-candidate ()
  (let ((table (yas/get-snippet-tables major-mode)))
    (if table
      (let (candidates (list))
            (mapcar (lambda (mode)          
              (maphash (lambda (key value)    
                (push key candidates))          
              (yas/snippet-table-hash mode))) 
            table)
        (all-completions ac-prefix candidates)))))

(defface ac-yasnippet-candidate-face
  '((t (:background "sandybrown" :foreground "black")))
  "Face for yasnippet candidate.")

(defface ac-yasnippet-selection-face
  '((t (:background "coral3" :foreground "white"))) 
  "Face for the yasnippet selected candidate.")

(defvar ac-source-yasnippet
  '((candidates . ac-yasnippet-candidate)
    (action . yas/expand)
    (limit . 3)
    (candidate-face . ac-yasnippet-candidate-face)
    (selection-face . ac-yasnippet-selection-face)) 
  "Source for Yasnippet.")

(provide 'auto-complete-yasnippet)


(defun hanli-tab(arg)
  ;1 Yasnippet
  ;2 Senator
  ;3 indent
  "Indent according to mode or Completion by Default"
  (interactive "*p")
  (if (and
	   (or (bobp) (= ?w (char-syntax(char-before))))
	   (or (eobp) (not (= ?w (char-syntax (char-after))))))
	  (ac-yasnippet-candidate)
	 (indent-according-to-mode)))
(defun tab-hook()
  (local-set-key [backtab] 'hanli-tab)
  (local-set-key [tab] 'yas/expand))

(add-hook 'c-mode-hook 'tab-hook)
(add-hook 'c++-mode-hook 'tab-hook)


;; VI Style Open New line by Ctrl-O
(local-set-key [(control o)] 'vi-open-next-line)
(defun vi-open-next-line (arg)
 "Move to the next line (like vi) and then opens a line."
 (interactive "p")
 (end-of-line)
 (open-line arg)
 (next-line 1)
 (indent-according-to-mode))


(local-set-key "%" 'match-paren)
(defun match-paren (arg)
 "Go to the matching parenthesis if on parenthesis otherwise insert %."
 (interactive "p")
 (cond ((looking-at "//s/(") (forward-list 1) (backward-char 1))
        ((looking-at "//s/)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-enabled-themes (quote (wombat)))
 '(display-battery-mode t)
 '(size-indication-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
