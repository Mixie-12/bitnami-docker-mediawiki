#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load MediaWiki environment
. /opt/bitnami/scripts/mediawiki-env.sh

# Load PHP environment for 'php_conf_set' (after 'mediawiki-env.sh' so that MODULE is not set to a wrong value)
. /opt/bitnami/scripts/php-env.sh

# Load web server environment and functions (after MediaWiki environment file so MODULE is not set to a wrong value)
. /opt/bitnami/scripts/libwebserver.sh

# Load libraries
. /opt/bitnami/scripts/libmediawiki.sh
. /opt/bitnami/scripts/libfile.sh
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libphp.sh

# Ensure the MediaWiki base directory exists and has proper permissions
info "Configuring file permissions for MediaWiki"
for dir in "$MEDIAWIKI_BASE_DIR" "$MEDIAWIKI_VOLUME_DIR"; do
    ensure_dir_exists "$dir"
    configure_permissions_ownership "$dir" -d "775" -f "664"
done

# Configure required PHP options for application to work properly, based on build-time defaults
info "Configuring default PHP options for MediaWiki"
php_conf_set memory_limit "$PHP_DEFAULT_MEMORY_LIMIT"

# Install required PHP extensions for SMTP support
pear install mail net_smtp

# Enable default web server configuration for MediaWiki
info "Creating default web server configuration for MediaWiki"
web_server_validate
ensure_web_server_app_configuration_exists "mediawiki" --type php --apache-extra-directory-configuration "
RewriteEngine On
RewriteRule ^/?wiki(/.*)?$ %{DOCUMENT_ROOT}/index.php [L]
"
