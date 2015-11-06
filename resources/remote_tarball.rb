actions :install, :update
default_action :update

attribute :tarball_location, :kind_of => String, :required => true
attribute :source, :kind_of => String, :required => true
attribute :sha_type, :kind_of => String, :default => '256', :required => false
