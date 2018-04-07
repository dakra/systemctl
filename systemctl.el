;;; systemctl.el --- Functions to control systemctl units   -*- lexical-binding: t; -*-

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

;; Functions to control systemctl units

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
