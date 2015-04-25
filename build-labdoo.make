api = 2
core = 7.x

;------------------------------
; Build Drupal core (with patches).
;------------------------------
includes[drupal] = drupal-org-core.make

;------------------------------
; Get base profile openatrium
;------------------------------
projects[openatrium][type] = profile
projects[openatrium][download][type] = git
projects[openatrium][download][tag] = 7.x-2.40-rc1
projects[openatrium][patch][makefile] = https://www.drupal.org/files/issues/fix-openatrium-makefile-for-drush-6.patch

;------------------------------
; Get profile labdoo.
;------------------------------
projects[labdoo][type] = profile
projects[labdoo][download][type] = git
projects[labdoo][download][url] = /usr/local/src/labdoo
projects[labdoo][download][branch] = openatrium
