#
# Cookbook Name:: yum_mirror
# Recipe:: apache2
#

if node[:yum_mirror][:fqdn].nil?
  Chef::Application.fatal!("Yum mirror server's fqdn attribute is nil!")
end

fqdn = node[:yum_mirror][:fqdn]

include_recipe "selinux::permissive"

node.override[:apache].deep_merge!({
  default_site_enabled: false,
  package: 'httpd',
  listen: [
    "*:443"
  ]
})

node.include_attribute('apache2')

include_recipe 'apache2'
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_headers"

directory node[:apache][:ssl_dir] do
  owner node[:apache][:user]
  group node[:apache][:group]
  recursive true
  action :create
end

ssl_certs fqdn do
  notifies :restart, 'service[apache2]'
end

web_app 'yum_apache_config' do
  template "apache.conf.erb"
  server_name fqdn
  document_root node[:yum_mirror][:repodir]
  customizations node[:yum_mirror][:repo][:apache][:customizations]
  repo_dir node[:yum_mirror][:repodir]
  ssl_cert_file node[:apache][:ssl_cert_file]
  ssl_cert_key_file node[:apache][:ssl_cert_key_file]
  ssl_cert_chain_file node[:apache][:ssl_cert_chain_file] if node[:apache].has_key?(:ssl_cert_chain_file)
end
