link-memo.el -- 指定されたディレクトリ内のファイルへのリンクをはる elisp です。

# About

海に帰してあげなきゃいけないトドちゃんを数えます。  
元ネタは 2006-08-18 のエントリーなのでトドちゃんはもうすぐ 12歳です。(2018-03-31 時点)  
トド (雄) の寿命は 20年ほどなので人間で言うと...  
もうトドちゃんというよりトドさんです。

元ネタ: [結] 2006年8月 - 結城浩の日記<http://www.hyuki.com/d/200608.html#i20060818100343>

# Installation & Configuration

load-pathの通っているディレクトリにtodo-chan.elを入れてください。

以下の行を emacs.d/init.el (or .emacs) に追加してください。

``` elisp
(load "todo-chan")
```

キーの設定は適当に
``` elisp
(global-set-key "\C-ctd" 'todo-chan)
```

`find-file-hook` に追加するのもありかもしれません。
``` elisp
(add-hook 'find-file-hooks
          '(lambda ()
             (todo-chan t)) t)
```

