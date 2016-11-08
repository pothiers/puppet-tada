class tada (
  $rsyncpwd       = hiera('rsyncpwd'),
  ) {
  include tada::install
  include tada::config
  include tada::service
}
