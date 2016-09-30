pkg_name=linkbot
pkg_origin=robbkidd
pkg_maintainer="Robb Kidd <robb@thekidds.org>"
pkg_license=('mit')
pkg_source=_source_found_locally_

pkg_deps=(
  core/bundler
  core/libffi
  core/libiconv
  core/libxml2
  core/libxslt
  core/libyaml
  core/ruby
  core/sqlite
  core/zlib
)

pkg_build_deps=(
  core/coreutils
  core/gcc
  core/make
  core/patchelf
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

pkg_version() {
  ruby -I$PLAN_CONTEXT/../lib/linkbot -rversion -e 'puts Linkbot::VERSION'
}


do_download() {
  update_pkg_version

  cd $PLAN_CONTEXT/..
  # Build then unpack the gem to the source cache path to limit the
  # files packaged to those defined as included in the gemspec
  gem build $pkg_name.gemspec
}

do_verify() {
  # No download to verify.
  return 0
}

do_unpack() {
  gem unpack $PLAN_CONTEXT/../$pkg_name-$pkg_version.gem --target=$HAB_CACHE_SRC_PATH
}

# The configure scripts for some RubyGems that build native extensions
# use `/usr/bin` paths for commands. This is not going to work in a
# studio where we don't have any of those commands. But we're kind of
# stuck because the native extension is going to be built during
# `bundle install`.
#
# We clean this link up in `do_install`.
do_prepare() {
  build_line "Setting link for /usr/bin/env to 'coreutils'"
  if [[ ! -r /usr/bin/env ]]; then
    ln -sv $(pkg_path_for coreutils)/bin/env /usr/bin/env
    _clean_env=true
  fi
  return 0
}

do_setup_environment() {
  set_runtime_env GEM_HOME "${pkg_prefix}"
  set_runtime_env GEM_PATH "${pkg_prefix}:$(pkg_path_for "core/bundler"):$(pkg_path_for "core/ruby")/lib/ruby/gems/2.4.0"
}

do_build() {
  export CPPFLAGS="${CPPFLAGS} ${CFLAGS}"

  local _libxml2_dir=$(pkg_path_for libxml2)
  local _libxslt_dir=$(pkg_path_for libxslt)
  local _sqlite_dir=$(pkg_path_for sqlite)
  local _zlib_dir=$(pkg_path_for zlib)

  export BUNDLE_SILENCE_ROOT_WARNING=1 GEM_PATH

  # don't let bundler split up the nokogiri config string (it breaks
  # the build), so specify it as an env var instead
  export NOKOGIRI_CONFIG="--use-system-libraries --with-zlib-dir=${_zlib_dir} --with-xslt-dir=${_libxslt_dir} --with-xml2-include=${_libxml2_dir}/include/libxml2 --with-xml2-lib=${_libxml2_dir}/lib"
  bundle config build.nokogiri '${NOKOGIRI_CONFIG}'

  export SQLITE3_CONFIG="--with-sqlite3-include=${_sqlite_dir}/include --with-sqlite3-lib=${_sqlite_dir}/lib --with-sqlite3-dir=${_sqlite_dir}/bin"
  bundle config build.sqlite3 '${SQLITE3_CONFIG}'

  bundle install --jobs "$(nproc)" --retry 5 --standalone \
      --without development,test \
      --path vendor/bundle \
      --binstubs
}

do_install() {
  cp -R . ${pkg_prefix}

  fix_interpreter "${pkg_prefix}/bin/*" core/ruby ruby
}

do_end() {
  # Clean up the `env` link, if we set it up. 
  if [[ -n "$_clean_env" ]]; then
    rm -fv /usr/bin/env
  fi
  return 0
}
