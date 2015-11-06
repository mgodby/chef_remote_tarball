require 'digest'
require 'fileutils'
require 'open-uri'
require 'net/http'

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

def check_tarball_cache(tarball_cache, rem_shasum, sha_type)
  #First we need to determine the sha
  if sha_type == '512'
    tarball_cache_shasum = Digest::SHA512.hexdigest ::File.read tarball_cache
  else
    tarball_cache_shasum = Digest::SHA256.hexdigest ::File.read tarball_cache
  end

  #Compare and abort if necessary
  if tarball_cache_shasum != rem_shasum
    raise RuntimeError, 'remote shasum does not match shasum of downloaded file'
    exit 1
  end

  return tarball_cache_shasum
end


# This function checks to see if tarball is already installed and
#  whether or not it needs to be updated if it is
def initial_prep(dest_dir, stat_file, rem_shasum)
  if ::File.exists?(stat_file)

    # Perform
    if rem_shasum == open(stat_file) {|f| f.read.chomp}
      local_stat = 'match'
    else
      local_stat = 'update'
    end

  else
    # If the status file doesn't exist, make sure destination directory does
    FileUtils::mkdir_p dest_dir
    local_stat = 'install'
  end

  return local_stat
end


# Just a safety check to make sure a supported sha type has been passed
def is_sha_type_valid(sha_type)
  if sha_type != '256' && sha_type != '512'
    raise RuntimeError, 'sha type ' + sha_type + ' is not supported. Please use "256" or "512".'
    exit 1
  end
end


def retrieve_file(url, file_enddest, filecache)

  # Parse url to easily consume host and path separately
  mtch = url.match(/(^[^\/]+)(\/.*)/)
  rem_host = mtch[1]
  rem_path = mtch[2]

  # Create directory into which the tarball will be cached
  FileUtils::mkdir_p /(\/.*\/)([^\/]+$)/.match(filecache)[1]

  # Retrieve the tarball
  Net::HTTP.start(rem_host) do |http|
    resp = http.get(rem_path)
    open(filecache, "w+") do |f|
      f.write(resp.body)
    end
  end

end


action :update do

  require 'fileutils'

  tarball_location = new_resource.tarball_location
  sha_type = new_resource.sha_type
  source = new_resource.source

  # Might as well make this into separate variables since consumed by multiple functions
  dest_dir = /(\/.*\/)([^\/]+$)/.match(tarball_location)[1]
  dest_file = /(\/.*\/)([^\/]+$)/.match(tarball_location)[2]
  stat_file = dest_dir + ".chef_" + dest_file + ".sha" + sha_type

  rem_shasum = open("http://".concat(source).concat(".sha").concat(sha_type)) {|f| f.read.chomp }
  tarball_cache = Chef::Config[:file_cache_path] + tarball_location

  # Safety check of sha_type parameter
  is_sha_type_valid(sha_type)

  local_stat = initial_prep(dest_dir, stat_file, rem_shasum)

  if local_stat == 'match'
    # If the remote shasum matches the stat_file, nothing needs to be done
  elsif local_stat == 'update' || local_stat == 'install'
    retrieve_file(source, tarball_location, tarball_cache)
    tarball_cache_shasum = check_tarball_cache(tarball_cache, rem_shasum, sha_type)
    `tar -xzf #{tarball_cache} -C #{dest_dir}`
    ::File.open(stat_file, 'w') {|f| f.write(tarball_cache_shasum)}

  else
    raise RuntimeError, 'local status ' + local_stat + ' is not a valid local status.'
    exit 1

  end

end

action :install do

  tarball_location = new_resource.tarball_location
  sha_type = new_resource.sha_type
  source = new_resource.source

  # Might as well make this into separate variables since consumed by multiple functions
  dest_dir = /(\/.*\/)([^\/]+$)/.match(tarball_location)[1]
  dest_file = /(\/.*\/)([^\/]+$)/.match(tarball_location)[2]
  stat_file = dest_dir + ".chef_" + dest_file + ".sha" + sha_type

  rem_shasum = open("http://".concat(source).concat(".sha").concat(sha_type)) {|f| f.read.chomp }
  tarball_cache = Chef::Config[:file_cache_path] + tarball_location

  # Safety check of sha_type parameter
  is_sha_type_valid(sha_type)

  local_stat = initial_prep(dest_dir, stat_file, rem_shasum)


  if local_stat == 'match' || local_stat == 'update'
    # Do not perform actions if tarball is already installed
  elsif local_stat == 'install'
    retrieve_file(source, tarball_location, tarball_cache)
    tarball_cache_shasum = check_tarball_cache(tarball_cache, rem_shasum, sha_type)
    `tar -xzf #{tarball_cache} -C #{dest_dir}`
    File.open(stat_file, 'w') {|f| f.write(tarball_cache_shasum)}

  else
    raise RuntimeError, 'local status ' + local_stat + ' is not a valid local status.'
    exit 1

  end

end

