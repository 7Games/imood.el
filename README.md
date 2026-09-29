# imood.el

Update [imood](https://imood.com) through Emacs.

## How to install

Copy the script somewhere Emacs can reach and add this to your .emacs/init.el

```lisp
(load-file "path/to/imood.el")
```

Then you'll need to set your email and password

```lisp
(setq imood//email "user@example.com")
(setq imood//password "password123")
```

I'd recommend you keep them in a separate elisp file and load it in just like imood itself, just so you don't accidentally leak anything.

```lisp
(load-file "path/to/imood.el")
;; (setq imood//email "user@example.com") ;; bad
;; (setq imood//password "password123")   ;; very bad
(load-file "path/to/secrets.el")
```

## How to use

To see your own mood type

```
M-x imood//whats-my-mood RET
```

To update your mood type

```
M-x imood//update-mood RET
```

You can pick from a list of all the available faces and moods then enter your personal mood

## License

This repo is licenced under the [Unlicence](https://unlicense.org/)
