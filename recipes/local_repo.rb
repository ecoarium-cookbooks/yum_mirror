

ruby_block 'bootstrap_yum_repo' do
  block do
    begin
      package 'yum-utils'
    rescue
      %w{
        yum-utils
        deltarpm
        python-deltarpm
        createrepo
      }.each {|rpm|
        rpm_source_path = Dir.glob("#{node[:yum_mirror][:local_repo][:path]}/**/#{rpm}*.rpm").sort!.first

        raise "unable to find rpm for install that is required for yum repo management: #{rpm_source_path}" if rpm_source_path.nil?

        yum = Chef::Resource::YumPackage.new(rpm, run_context)
        yum.source rpm_source_path
        yum.provider_for_action(:install).run_action
      }
    end
  end
  not_if 'rpm -q yum-utils'
end

execute "createrepo #{node[:yum_mirror][:local_repo][:path]}/" do
	creates "#{node[:yum_mirror][:local_repo][:path]}/repodata/repomd.xml"
end

file "/etc/yum/pluginconf.d/priorities.conf" do
	action :create
	content <<-EOS
[main]
enabled = 1
check_obsoletes=1
EOS
end

yum_repository node[:yum_mirror][:local_repo][:name] do
  description "local repository to avoid internet access"
  url "file://#{node[:yum_mirror][:local_repo][:path]}/"
  priority '1'
  gpgcheck false
  action :add
end
