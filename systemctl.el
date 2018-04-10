;;; systemctl.el --- Functions to control systemd units   -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Daniel Kraus

;; Author: Daniel Kraus <daniel@kraus.my>
;; Version: 0.1
;; Package-Requires: ((emacs "24.4"))
;; Keywords: system
;; URL: https://github.com/dakra/systemctl

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Functions to control systemd units.

;; These functions are helpers to be used in other Lisp code
;; to easily start/stop/toggle systemd units.

;; An example usage from my config with `hydra' is:

;; (use-package systemctl
;;   :commands hydra-systemctl/body
;;   :config
;;   (defun systemctl-hydra-status (unit)
;;     "Return a checkbox indicating the status of UNIT."
;;     (if (equal (type-of unit) 'string)
;;         (if (systemctl-is-active-p unit)
;;             "[x]" "[ ]")
;;       (if (-all-p 'systemctl-is-active-p unit)
;;           "[x]" "[ ]")))
;;
;;   (defhydra hydra-systemctl (:hint none)
;;     "
;; Presets                    Services
;; -------                    --------
;; _1_: ?1? mysql/rdb/redis     ?p? _p_ostgres
;; _2_: ?2? postgres/redis      ?r? _r_edis
;; _3_: ?3? docker              ?m? _m_ysql
;;                            ?t? re_t_hinkdb
;;                            ?d? _d_ocker
;; _o_: offline (stop all)      ?c? _c_ups
;; _g_: Refresh Hydra  _q_: quit"
;;     ;; Environments
;;     ("1" (mapc 'systemctl-start '("mysqld" "redis" "rethinkdb@default.service"))
;;      (systemctl-hydra-status '("mysqld" "redis" "rethinkdb@default.service")))
;;     ("2" (mapc 'systemctl-start '("postgresql" "redis"))
;;      (systemctl-hydra-status '("postgresql" "redis")))
;;     ("3" (systemctl-toggle "docker")
;;      (systemctl-hydra-status "docker"))
;;     ;; Stop all
;;     ("o" (mapc 'systemctl-stop'("postgresql" "mysqld" "redis" "rethinkdb@default.service"
;;                                 "docker" "org.cups.cupsd")))
;;     ;; Services
;;     ("p" (systemctl-toggle "postgresql") (systemctl-hydra-status "postgresql"))
;;     ("r" (systemctl-toggle "redis") (systemctl-hydra-status "redis"))
;;     ("m" (systemctl-toggle "mysqld") (systemctl-hydra-status "mysqld"))
;;     ("t" (systemctl-toggle "rethinkdb@default.service") (systemctl-hydra-status "rethinkdb@default.service"))
;;     ("d" (systemctl-toggle "docker") (systemctl-hydra-status "docker"))
;;     ("c" (systemctl-toggle "org.cups.cupsd") (systemctl-hydra-status "org.cups.cupsd"))
;;
;;     ("g" (message "Hydra refreshed"))
;;     ("q" (message "Abort") :exit t)))


;;; Code:

(defun systemctl-command (command unit)
  "Run systemctl COMMAND on UNIT as root."
  (let ((default-directory "/sudo::/tmp"))
    (start-file-process (format "systemctl %s %s" command unit) nil
                        (executable-find "systemctl")
                        command unit)))

(defun systemctl-is-active-p (unit)
  "Check if UNIT is active."
  (equal (shell-command-to-string
          (concat "systemctl is-active "
                  (shell-quote-argument unit)))
         "active\n"))

(defun systemctl-start (unit)
  "Start UNIT when not already started."
  (unless (systemctl-is-active-p unit)
    (systemctl-command "start" unit)))

(defun systemctl-stop (unit)
  "Stop UNIT when not already stopped."
  (when (systemctl-is-active-p unit)
    (systemctl-command "stop" unit)))

(defun systemctl-toggle (unit)
  "Start or stop a systemctl UNIT."
  (if (systemctl-is-active-p unit)
      (systemctl-stop unit)
    (systemctl-start unit)))

(provide 'systemctl)
;;; systemctl.el ends here
