# == Class: letsencrypt::plugin::nginx
#
#   This class installs and configures the Let's Encrypt nginx plugin.
#
# === Parameters:
#
# [*manage_package*]
#   Manage the plugin package.
# [*package_name*]
#   The name of the package to install when $manage_package is true.
#
class letsencrypt::plugin::nginx (
  Boolean $manage_package          = $letsencrypt::nginx_manage_package,
  String $package_name             = $letsencrypt::nginx_package_name,
) {

  if $manage_package {
    package { $package_name:
      ensure          => installed,
      install_options => $operatingsystemmajrelease ? {
        '8'     => '--enablerepo=powertools',
        default => undef,
      },
    }

    case $facts['os']['family'] {
        'RedHat': {
            $options_ssl_nginx_conf_path = $operatingsystemmajrelease ? {
                '8'     => '/usr/lib/python3.6/site-packages/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf',
                '9'     => '/usr/lib/python3.9/site-packages/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf',
            }
            $dhparams_path = $operatingsystemmajrelease ? {
                '8'     => '/usr/lib/python3.6/site-packages/certbot/ssl-dhparams.pem',
                '9'     => '/usr/lib/python3.9/site-packages/certbot/ssl-dhparams.pem',
            }
        }
        'Debian': {
            $options_ssl_nginx_conf_path = '/usr/lib/python3/dist-packages/certbot_nginx/options-ssl-nginx.conf'
            $dhparams_path = '/usr/lib/python3/dist-packages/certbot/ssl-dhparams.pem'
        }
    }

    file { '/etc/letsencrypt/options-ssl-nginx.conf':
      ensure  => link,
      target  => $options_ssl_nginx_conf_path,
      require => Package[$package_name],
    }

  }  # if $manage_package

}  # class letsencrypt::plugin::nginx
