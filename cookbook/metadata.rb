name             'redguide'
maintainer       'Aleksey Hariton'
maintainer_email 'Aleksey.Hariton@gmail.com'
license          'MIT'
description      'Cookbook for RedGuide installation'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

# Microservice installation
depends 'rvm', '~> 0.9.4'
depends 'mysql', '~> 8.0'
depends 'nginx', '~> 2.7.6'
depends 'selinux'
depends 'apt'
