;;; todo-chan.el --- Todo-Chan

;; Author: Tonjiru <gudakusan@tonjiru.org>
;; Keywords: convenience todo-chan

;; Copyright (c) 2009, 2018 Tonjiru <gudakusan@tonjiru.org>
;; Permission to use, copy, modify, distribute, and sell this software and its
;; documentation for any purpose is hereby granted without fee, provided that the
;; above copyright notice appear in all copies and that both that copyright notice
;; and this permission notice appear in supporting documentation.  No
;; representations are made about the suitability of this software for any purpose.
;; It is provided "as is" without express or implied warranty.

;; Copyright (c) 2009, 2018 Tonjiru <gudakusan@tonjiru.org>
;; 本プログラムはフリー・ソフトウェアです。あなたは，Free Software Foundation が公表
;; した GNU 一般公有使用許諾の「バージョン ２」或いはそれ以降の各バージョンの中から
;; いずれかを選択し，そのバージョンが定める条項に従って本プログラムを再頒布または変
;; 更することができます。本プログラムは有用とは思いますが，頒布にあたっては，市場性
;; 及び特定目的適合性についての暗黙の保証を含めて，いかなる保証も行ないません。詳細
;; については GNU 一般公有使用許諾書をお読みください。

;;; Commentary:

;; About:
;; 海に帰してあげなきゃいけないトドちゃんを数えます。
;; 元ネタは 2006-08-18 のエントリーなのでトドちゃんはもうすぐ 12歳です。(2018-03-31 時点)
;; トド (雄) の寿命は 20年ほどなので人間で言うと...
;; もうトドちゃんというよりトドさんです。
;;
;; 元ネタ: [結] 2006年8月 - 結城浩の日記<http://www.hyuki.com/d/200608.html#i20060818100343>

;; Installation:
;; load-pathの通っているディレクトリにtodo-chan.elを入れてください。

;; Configuration:
;; 以下の行を.emacsに追加してください。
;; ----
;; (load "todo-chan")
;; ----
;;
;; キーの設定は適当に
;; ----
;; (global-set-key "\C-ctd" 'todo-chan)
;; ----
;;
;; find-file-hookに追加するのもありかもしれません。
;; ----
;; (add-hook 'find-file-hooks
;;           '(lambda ()
;;              (todo-chan t)) t)
;; ----
;; ただし、hook内の他の処理がメッセージ等を出力した場合、上書きされます。
;;
;; トドちゃんがいない(0頭)の場合は出力を抑止できるようにしました。

;;; Code:

;; TODO: 完了とみなすパターンと未完了 (未着手, 作業中等) とみなすパターンが管理できるように。
;; TODO: 英語的に complete/incomplete より finished/unfinished の方がいいっぽい。(comp... は完全/不完全という意味がある。一方 fin... は終わってるかどうかで完全/不完全は問わないっぽい。)

(defvar todo-chan-pattern-alist
  '((c-mode . "\\<\\(TODO\\|FIXME\\|XXX\\)\\>")
    (emacs-lisp-mode . ";; *\\(TODO\\|FIXME\\|XXX\\)"))
  "ToDo pattern each major-mode.")

(defvar todo-chan-default-pattern
  "\\<TODO\\>"
  "Default ToDo patern.")

;; major-mode毎のToDoのテンプレート
(defvar todo-chan-template-alist
  '((c-mode . "// TODO: ")
    (lisp-interaction-mode . ";; TODO: ")
    (emacs-lisp-mode . ";; TODO: "))
  "\
major-mode毎のToDoのテンプレート。")

;; デフォルトのタスクとみなすパターン
(defvar todo-chan-default-regexp
  "^[ \t]*\\[\\([^*-]\\)\\][ \t]*"
  "\
major-mode 毎のタスクとみなすパターン")

(defun todo-chan (&optional quiet)
  "Count Todo-Chan."
  (interactive)
  (let ((todo (or (cdr (assoc major-mode todo-chan-pattern-alist))
		  todo-chan-default-pattern))
	(count 0)
	(case-fold-search nil))
    (save-excursion
      (save-restriction
	(widen)
	(beginning-of-buffer)
	(while (re-search-forward todo nil t)
	  (setq count (1+ count)))
	(if (or (not quiet)
		(> count 0))
	    (message (format "ε(　　　　 v ﾟωﾟ)　＜　%S の TODO 残り %d 頭" (buffer-name) count)))
	))))


;; 空のToDoアイテムを挿入
(defun todo-chan-insert-task ()
  "空のToDoアイテムを挿入"
  (interactive)
  (let ((todo (or (cdr (assoc major-mode todo-chan-template-alist))
		  (format "[ ] %s " (format-time-string "%m/%d")) ;; default
		  )))
    ;; (beginning-of-line)
    ;; (open-line 1)
    ;; (funcall indent-line-function)
    (insert todo)
    ;; (goto-char (1- (point)))
    ))

;; タスクの状態の設定
;; タスクの状態の設定
(defun set-todo-chan-status (status &optional forward)
  "タスクの状態を設定する。"
  (let ((base-point))
    (save-excursion
      (end-of-line)
      (search-backward-regexp "\\[\\(.\\)\\]")
      (goto-char (match-beginning 1))
      (delete-char 1)
      (insert status))
    (when forward (forward-line 1))))

;; タスクの終了
(defun todo-chan-complete-task ()
  "タスクの終了"
  (interactive)
  (set-todo-chan-status "x"))

;; 切り取ってファイル末尾に貼り付け
(defun todo-chan-byebye ()
  "kill-region. Go to EOF and yank."
  (interactive)
  (let ((base-point (point)))
    (save-excursion
      (kill-region (point) (mark))
      (goto-char (point-max))
      (yank)
      (goto-char base-point)
      )
    ))

;; タスクを作業中にする
(defun todo-chan-touch-task ()
  "タスクを作業中にする"
  (interactive)
  (set-todo-chan-status "+"))

;; タスクを削除する
(defun todo-chan-delete-task ()
  "タスクを削除する"
  (interactive)
  (set-todo-chan-status "-"))

;; タスクを一時中断する
(defun todo-chan-suspend-task ()
  "タスクを一時中断する"
  (interactive)
  (set-todo-chan-status "."))

;; タスクの状態をクリアする
(defun todo-chan-clear-task ()
  "タスクの状態をクリアする"
  (interactive)
  (set-todo-chan-status " "))

;; 次のタスクへ移動
(defun todo-chan-forward-task ()
  "次のタスクへ移動"
  (interactive)
  (let ((todo (or (cdr (assoc major-mode todo-chan-pattern-alist))
		  todo-chan-default-regexp)))
    (progn
      (end-of-line)
      (if (re-search-forward todo nil t)
	  (goto-char (match-end 0))
	(error "end of buffer")))))

;; 前のタスクへ移動
(defun todo-chan-backward-task ()
  "前のタスクへ移動"
  (interactive)
  (let ((todo (or (cdr (assoc major-mode todo-chan-pattern-alist))
		  todo-chan-default-regexp)))
    (progn
      (beginning-of-line)
      (if (re-search-backward todo nil t)
	  (goto-char (match-end 0))
	(error "begining of buffer")))))

(global-set-key "\C-c\C-t\C-i" 'todo-chan-insert-task)
(global-set-key "\C-c\C-t\C-w" 'todo-chan-touch-task)
(global-set-key "\C-c\C-t\C-d" 'todo-chan-delete-task)
(global-set-key "\C-c\C-t\C-s" 'todo-chan-suspend-task)
(global-set-key "\C-c\C-t\C-c" 'todo-chan-complete-task)
(global-set-key "\C-c\C-t\C-e" 'todo-chan-byebye)

(global-set-key "\C-c\C-t\C-p" 'todo-chan-backward-task)
(global-set-key "\C-c\C-t\C-n" 'todo-chan-forward-task)

;;; todo-chan.el ends here
