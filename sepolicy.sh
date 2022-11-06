# debug
magiskpolicy --live "dontaudit system_server system_file file write"
magiskpolicy --live "allow     system_server system_file file write"

# context
magiskpolicy --live "type vendor_file"
magiskpolicy --live "type vendor_configs_file"
magiskpolicy --live "dontaudit { vendor_file vendor_configs_file } labeledfs filesystem associate"
magiskpolicy --live "allow     { vendor_file vendor_configs_file } labeledfs filesystem associate"
magiskpolicy --live "dontaudit init { vendor_file vendor_configs_file } dir relabelfrom"
magiskpolicy --live "allow     init { vendor_file vendor_configs_file } dir relabelfrom"
magiskpolicy --live "dontaudit init { vendor_file vendor_configs_file } file relabelfrom"
magiskpolicy --live "allow     init { vendor_file vendor_configs_file } file relabelfrom"

# file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } vendor_display_prop file { read open getattr }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } vendor_display_prop file { read open getattr }"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } dalvikcache_data_file file write"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } dalvikcache_data_file file write"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } unlabeled file { read open execute }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } unlabeled file { read open execute }"


