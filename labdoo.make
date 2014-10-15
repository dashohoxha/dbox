api = 2
core = 7.x

defaults[projects][subdir] = contrib

;--------------------
; Bootstrap Theme
;--------------------

projects[bootstrap] = 2.2
projects[jquery_update] = 2.4

libraries[bootstrap][directory_name] = bootstrap
libraries[bootstrap][download][type] = get
libraries[bootstrap][download][url] = https://github.com/twbs/bootstrap/archive/v3.0.0.zip

;--------------------
; Contrib
;--------------------

;;; Extensions
projects[xautoload] = 5.2
projects[rules] = 2.9

; ;;; User interface
; projects[context] = 3.6
; projects[homebox] = 2.0-rc1
; projects[boxes] = 1.2
projects[edit_profile] = 1.0-beta2

;;; Security
projects[captcha] = 1.3
projects[recaptcha] = 2.0
projects[honeypot] = 1.19
projects[user_restrictions] = 1.0

;;; Features
projects[features_extra] = 1.0
projects[node_export] = 3.0

;;; Admin Utils
projects[] = l10n_update
projects[] = drush_language
projects[] = drush_remake
projects[] = delete_all
projects[] = menu_import

;;; Performance
projects[] = boost
projects[] = memcache

;--------------------
; Sending Emails
;--------------------

;projects[mailsystem] = 2.34
;projects[mimemail] = 1.0-beta4
projects[reroute_email] = 1.2

;projects[phpmailer] = 3.x-dev
projects[phpmailer][download][revision] = 8f7c632
projects[phpmailer][download][branch] = 7.x-3.x

libraries[phpmailer][directory_name] = phpmailer
libraries[phpmailer][download][type] = get
libraries[phpmailer][download][url] = https://github.com/PHPMailer/PHPMailer/archive/v5.2.9.zip
