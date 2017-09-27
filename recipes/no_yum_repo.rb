#
# Cookbook Name:: yum_mirror
# Recipe:: repo
#
 
#
# Apache 2.0 
#

ruby_block 'dont_add_new_yum_repositories' do
	block do
		Chef::Resource::YumRepository.class_eval{
			def run_action(action, notification_type=nil, notifying_resource=nil)
				Chef::Log.info "A monkey patch has been applied from the recipe yum_mirror::no_yum_repo that prevents new yum repos from beeing added."
			end
		}
	end
end
