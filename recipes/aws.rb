#############################################################################
# yum_mirror::aws
#


if in_ec2?()
  aws = data_bag_item('aws', 'api')

  ec2_elastic_ip 'associate_yum_elastic_ip' do
    aws_access_key aws[:key]
    aws_secret_access_key aws[:secret]
    ip node[:yum_mirror][:ip]
    action :associate
  end

  node[:yum_mirror][:mirrors].each{|repo_info|

    next if repo_info[:volume_size].nil?

    ec2_ebs_volume repo_info[:name] do
      aws_access_key aws[:key]
      aws_secret_access_key aws[:secret]
      volume_size repo_info[:volume_size]
      volume_type 'io1'
      volume_iops repo_info[:volume_iops]
      volume_mount_path repo_info[:volume_mount_path]
      volume_device repo_info[:volume_device]
      volume_mount_point repo_info[:volume_mount_point]
    end
  }
end

include_recipe 'ec2'
