# My example recipe just install ant 1.8.0 into my home directory
dev_remote_tarball 'apache-ant-1.8.0-bin.tar.gz' do
  tarball_location '/home/mgodby/apache-ant-1.8.0-bin.tar.gz'
  source 'archive.apache.org/dist/ant/binaries/apache-ant-1.8.0-bin.tar.gz'
  sha_type '512'
end
