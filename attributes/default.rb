default[:yum_mirror][:prevent_new_repos] = false
default[:yum_mirror][:disable_others] = false
default[:yum_mirror][:fail_for_others] = false
default[:yum_mirror][:favor] = false

default[:yum_mirror][:mirrors] = [
	{
		name: 'mirror',
		volume_mount_path: '/var/lib/mirror',
		url:  :fqdn, # or a string url, the symbol :fqdn will be replaced with a url constructed from the fqdn: https://#{fqdn}/
		volume_size: 500,
		volume_iops: 500,
		volume_device: '/dev/sdj',
		volume_mount_point: '/dev/xvdn'
	}
]
default[:yum_mirror][:basedir] = '/var/lib/mirror'
default[:yum_mirror][:repodir] = "#{node[:yum_mirror][:basedir]}/repo"
default[:yum_mirror][:repo][:apache][:customizations] = ""
default[:yum_mirror][:repositories] = nil #see the following example:
# [
# 	{
# 		name: 'centos_base',# http://ftpmirror.your.org/pub/centos/6.5/os/x86_64/
# 		repo_context: "/centos"
# 	},
# 	{
# 		name: 'centos_updates',# http://mirror.rackspace.com/CentOS/6.5/updates/x86_64/
# 		repo_context: "/centos"
# 	},
# 	{
# 		name: "rhui-REGION-rhel-server-releases",# a RHEL repo...
# 		repo_context: "/rhel"
# 	}
# ]


default[:yum_mirror][:fqdn] = nil
default[:yum_mirror][:ip] = nil
default[:yum_mirror][:local_repo][:name] = 'local'
default[:yum_mirror][:local_repo][:path] = '/var/yum_repo'
default[:yum_mirror][:local_repo][:name] = 'ecosystem'

default[:yum_mirror][:server][:data_bag] = 'servers'
default[:yum_mirror][:server][:data_bag_item] = 'yum'

default[:apache][:ssl_dir]              = '/etc/httpd/ssl'
default[:apache][:ssl_cert_file]        = "#{node[:apache][:ssl_dir]}/server.crt"
default[:apache][:ssl_cert_key_file]    = "#{node[:apache][:ssl_dir]}/server.key"
default[:apache][:ssl_cert_chain_file]  = "#{node[:apache][:ssl_dir]}/chain.crt"
default[:apache][:root_dir]             = '/var/www'

