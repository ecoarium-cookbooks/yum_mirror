#
# Cookbook Name:: yum_mirror
# Recipe:: repo
#

if !node[:yum_mirror][:repositories].nil? and !node[:yum_mirror][:repositories].empty?
  if node[:yum_mirror][:fqdn].nil?
    server = data_bag_item(node[:yum_mirror][:server][:data_bag], node[:yum_mirror][:server][:data_bag_item])
  	node.override[:yum_mirror][:fqdn] = server[:fqdn]
  end

  if node[:yum_mirror][:fqdn].nil?
    Chef::Application.fatal!("Yum mirror server's fqdn attribute is nil!")
  end

  fqdn = node[:yum_mirror][:fqdn]

  node[:yum_mirror][:repositories].each{|hosted_repo_info|
    node.override[:yum_mirror][:mirrors].delete_if{|remote_repo_info|
      remote_repo_info[:url] == "https://#{fqdn}#{hosted_repo_info[:repo_context]}"
    }
  }
end

repo_names = node[:yum_mirror][:mirrors].collect{|repo_info| repo_info[:name]}

if node[:yum_mirror][:disable_others]
	skip = true
	`yum repolist enabled`.split("\n").each { |line|
		if skip
			skip = line.start_with?('repo id') == false
			next
		end
		repo_name = line.split("\s")[0]
		if !repo_names.include?(repo_name)
			execute "yum-config-manager --disable #{repo_name}"
			execute "yum clean all"
		end
	}
end

if node[:yum_mirror][:favor]
	yum_package "yum-utils"
  yum_package 'yum-plugin-priorities'

	file "/etc/yum/pluginconf.d/priorities.conf" do
		action :create
		content <<-EOS
[main]
enabled = 1
check_obsoletes=1
EOS
	end
end

node[:yum_mirror][:mirrors].each{|repo_info|
	repo_url = repo_info[:url]
	yum_repository repo_info[:name] do
	  description repo_info[:name]
	  url repo_url
	  priority '1'
    gpgcheck false
    sslverify false
	  action :add

    if !repo_info[:custom_config].nil?
      repo_info[:custom_config].each{|attribute,value|
        eval "#{attribute} #{value}"
      }
    end

	end
}

ruby_block 'fail_if_other_repositories_are_used' do
	block do
		Chef::Provider::Package::Yum::YumCache.instance.instance_eval{
			def allowed_repoid
		    @allowed_repoid
		  end

		  def allowed_repoid=(repoid)
		    @allowed_repoid = repoid
		  end

  		def package_repository(package_name, desired_version, arch=nil)
        package(package_name, arch, true, false) do |pkg|
        	if desired_version == pkg.version.to_s
        		if !self.allowed_repoids.include?(pkg.repoid)
        			raise Chef::Exceptions::Package, "the recipe yum_mirror::repo has been configured to fail when a repo other than #{self.allowed_repoids} is used, attempting to install #{package_name}-#{desired_version}#{arch} from repo #{pkg.repoid}"
        		end
	          return pkg.repoid
	        end
        end

        return nil
      end
    }
    Chef::Provider::Package::Yum::YumCache.instance.allowed_repoids = repo_names
	end
	only_if {node[:yum_mirror][:fail_for_others]}
end
