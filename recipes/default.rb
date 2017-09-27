#
# Cookbook Name:: yum_mirror
# Recipe:: default
#
 
#
# Apache 2.0 
#

if node[:yum_mirror][:fqdn].nil?
  server = data_bag_item(node[:yum_mirror][:server][:data_bag], node[:yum_mirror][:server][:data_bag_item])
	node.override[:yum_mirror][:fqdn] = server[:fqdn]
end

if node[:yum_mirror][:ip].nil?
	server = data_bag_item(node[:yum_mirror][:server][:data_bag], node[:yum_mirror][:server][:data_bag_item])
	node.override[:yum_mirror][:ip] = server[:ip]
end

if node[:yum_mirror][:repositories].nil?
	repositories = data_bag_item('yum', 'repositories')
	node.override[:yum_mirror][:repositories] = repositories[:repositories]
end

include_recipe "yum_mirror::apache2"
include_recipe "yum_mirror::aws"

directory node[:yum_mirror][:repodir] do
	owner 'apache'
	group 'apache'
	recursive true
end

template "#{node[:yum_mirror][:basedir]}/config.json" do
  source 'rake.conf.erb'
  variables({
  	:json_config => {
  		:repositories => node[:yum_mirror][:repositories]
  	}
	})
end

cookbook_file "#{node[:yum_mirror][:basedir]}/Rakefile" do
	source 'Rakefile'
end

yum_package "yum-utils"
yum_package 'createrepo'

gem_path = File.dirname(RbConfig.ruby) + '/gem'

gem_package 'bundler' do
  gem_binary gem_path
  version '1.3.5'
  action :install
end

execute 'install_rake' do
	command "bundle install"
	cwd File.expand_path("../files/default", File.dirname(__FILE__))
	not_if "#{gem_path} list rake | grep '10.0.3'"
end


# cron 'yum_mirror' do
# 	command "cd #{node[:yum_mirror][:basedir]} && #{File.dirname(RbConfig.ruby)}/rake"
#   hour '1'
#   weekday '6'
#   action :create
# end


