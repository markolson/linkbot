pkg_name=linkbot
pkg_origin=robbkidd
pkg_version=$(grep "VERSION" $PLAN_CONTEXT/../lib/linkbot/version.rb | awk -F\" '{ print $2 }')
pkg_maintainer="Robb Kidd <robb@thekidds.org>"
pkg_license=('mit')
pkg_source=_source_found_locally_
pkg_filename="${pkg_name}-${pkg_version}.gem"

pkg_deps=(
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

do_setup_environment() {
  push_runtime_env GEM_PATH "${pkg_prefix}/vendor"
}

do_download() {
  ( cd $PLAN_CONTEXT/..
    # Build then unpack the gem to the source cache path to limit the
    # files packaged to those defined as included in the gemspec
    gem build $pkg_name.gemspec
    mv ${pkg_filename} "${HAB_CACHE_SRC_PATH}/${pkg_filename}"
  )
}

do_verify() {
  # No download to verify.
  return 0
}

do_unpack() {
  gem unpack "${HAB_CACHE_SRC_PATH}/${pkg_filename}" --target=$HAB_CACHE_SRC_PATH
}

# The configure scripts for some RubyGems that build native extensions
# use `/usr/bin` paths for commands. This is not going to work in a
# studio where we don't have any of those commands. But we're kind of
# stuck because the native extension is going to be built during
# `bundle install`.
#
# We clean this link up in `do_install`.
do_prepare() {
  export GEM_HOME=$pkg_prefix/vendor
  export CPPFLAGS="${CPPFLAGS} ${CFLAGS}"

  ( cd "$CACHE_PATH"
    bundle config --local build.nokogiri "--use-system-libraries \
        --with-zlib-dir=$(pkg_path_for zlib) \
        --with-xslt-dir=$(pkg_path_for libxslt) \
        --with-xml2-include=$(pkg_path_for libxml2)/include/libxml2 \
        --with-xml2-lib=$(pkg_path_for libxml2)/lib"
    local _sqlite_dir=$(pkg_path_for sqlite)
    bundle config --local build.sqlite3 "--with-sqlite3-include=${_sqlite_dir}/include \
        --with-sqlite3-lib=${_sqlite_dir}/lib \
        --with-sqlite3-dir=${_sqlite_dir}/bin"
    bundle config --local jobs "$(nproc)"
    bundle config --local without development test
    bundle config --local retry 5
    bundle config --local silence_root_warning 1
  )

  build_line "Setting link for /usr/bin/env to 'coreutils'"
  if [[ ! -r /usr/bin/env ]]; then
    ln -sv $(pkg_path_for coreutils)/bin/env /usr/bin/env
    _clean_env=true
  fi
}


do_build() {
  build_line "** install matching version of bundler"
  gem install bundler -v "$(grep -A1 "BUNDLED WITH" Gemfile.lock | tail -n1)" --no-document

  build_line "** bundle installing dependencies"
  bundle install --binstubs
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
