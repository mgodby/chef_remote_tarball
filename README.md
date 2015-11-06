# chef_remote_tarball
Crappy resource and provider for pulling and updating http-served tarballs


Just copy-and-paste the resource and provider into your resources/ and providers/
  cookbook directories respectively.


The http-hosted file must have a sha256 or sha512 file of the same name + .sha256 or
  .sha512 extension appended. The file should contain only the shasum itself. See 
  recipe 'example' for a http-hosted file that meets these requirements.

The recommended way to implement automatic updates is to pass links to the most
  up-to-date version of whatever tarball you want to keep around. This will result in a
  change in remote shasum, and therefore an updated.


Disclaimer: I don't think that this method is particularly good, and I am open to
  suggested improvements in methodology if you wish for me to update this code. This
  is because the primary purpose here was just to demonstrate to myself that I can write
  effective chef resources and providers.
