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

  ec2_ebs_volume 'yum_secondary_drive' do
    aws_access_key aws[:key]
    aws_secret_access_key aws[:secret]
    volume_size 500
    volume_type "io1"
    volume_iops 500
    volume_mount_path '/var/lib/mirror'
    volume_device '/dev/sdi'
    volume_mount_point '/dev/xvdi'
    fstype :btrfs
  end
end

include_recipe 'ec2'
