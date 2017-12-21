name             'yum_mirror'
maintainer       'Jay Flowers'
maintainer_email 'jay.flowers@gmail.com'
license          'Apache 2.0'
description      "Installs/Configures yum_mirror"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.2"

depends 'apache2'
depends 'selinux'
depends 'ec2'
depends 'yum', '< 5'
