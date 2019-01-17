;;; shell-history.el --- access history from shell-mode

;;; requires

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'helm)
(require 'dash)

;;; Code:

(defvar shell-history-cache)

(defun shell-history-parse-history (history)
  "Gets a list of commands in raw formart and remove leading white spaces and history number"
  (-map (lambda (h)
          (replace-regexp-in-string "[[:space:]]*[0-9][[:space:]]*"
                                    ""
                                    h))
        history))

(defun shell-history-get-history! (&optional refresh)
  "Executes a shell command to get the history"
  (if (-> refresh not (and shell-history-cache))
    shell-history-cache
    (let ((history (-> "HISTFILE=~/.bash_history && set -o history && history"
                       shell-command-to-string
                       (split-string "\n")
                       shell-history-parse-history)))
      (setq shell-history-cache history))))

(defun shell-history-build-helm-source (history)
  (helm-build-sync-source "Shell history: "
    :fuzzy-match t
    :candidates history
    :action (lambda (cmd) (insert cmd))))

(defun shell-history ()
  "Open shell history and insert the selected command in the buffer"
  (interactive)
  (let* ((src (-> (shell-history-get-history!)
                  shell-history-build-helm-source)))
    (helm :sources src)))

(provide 'shell-history)

;;; shell-history.el ends here
