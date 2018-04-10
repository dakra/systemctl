# systemctl - Functions to control systemd units.

These functions are helpers to be used in other Lisp code
to easily start/stop/toggle systemd units.

An example usage from my config with `hydra` is:

``` emacs-lisp
(use-package systemctl
  :commands hydra-systemctl/body
  :config
  (defun systemctl-hydra-status (unit)
    "Return a checkbox indicating the status of UNIT."
    (if (equal (type-of unit) 'string)
        (if (systemctl-is-active-p unit)
            "[x]" "[ ]")
      (if (-all-p 'systemctl-is-active-p unit)
          "[x]" "[ ]")))
  (defhydra hydra-systemctl (:hint none)
    "
Presets                    Services
-------                    --------
_1_: ?1? mysql/rdb/redis     ?p? _p_ostgres
_2_: ?2? postgres/redis      ?r? _r_edis
_3_: ?3? docker              ?m? _m_ysql
                           ?t? re_t_hinkdb
                           ?d? _d_ocker
_o_: offline (stop all)      ?c? _c_ups
_g_: Refresh Hydra  _q_: quit"
    ;; Environments
    ("1" (mapc 'systemctl-start '("mysqld" "redis" "rethinkdb@default.service"))
     (systemctl-hydra-status '("mysqld" "redis" "rethinkdb@default.service")))
    ("2" (mapc 'systemctl-start '("postgresql" "redis"))
     (systemctl-hydra-status '("postgresql" "redis")))
    ("3" (systemctl-toggle "docker")
     (systemctl-hydra-status "docker"))
    ;; Stop all
    ("o" (mapc 'systemctl-stop'("postgresql" "mysqld" "redis" "rethinkdb@default.service"
                                "docker" "org.cups.cupsd")))
    ;; Services
    ("p" (systemctl-toggle "postgresql") (systemctl-hydra-status "postgresql"))
    ("r" (systemctl-toggle "redis") (systemctl-hydra-status "redis"))
    ("m" (systemctl-toggle "mysqld") (systemctl-hydra-status "mysqld"))
    ("t" (systemctl-toggle "rethinkdb@default.service") (systemctl-hydra-status "rethinkdb@default.service"))
    ("d" (systemctl-toggle "docker") (systemctl-hydra-status "docker"))
    ("c" (systemctl-toggle "org.cups.cupsd") (systemctl-hydra-status "org.cups.cupsd"))
    ("g" (message "Hydra refreshed"))
    ("q" (message "Abort") :exit t)))
```
