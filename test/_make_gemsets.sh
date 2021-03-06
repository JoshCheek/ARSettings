#!/usr/bin/env bash -l

IFS="-"
for rvm_set in 1.8.6-2.3.3 1.8.6-2.3.5 1.8.6-2.3.8 1.8.7-2.3.3 1.8.7-2.3.5 1.8.7-2.3.8 1.9.1-2.3.3 1.9.1-2.3.5 1.9.1-2.3.8 1.9.2-2.3.3 1.9.2-2.3.5 1.9.2-2.3.8 1.9.2-3.0.1 ; do
  arr=( $rvm_set )
  ruby_version=${arr[0]}
  ar_version=${arr[1]}
  rvm use "$ruby_version@ruby$ruby_version-activerecord$ar_version" --create
  gem install activerecord -v "$ar_version" --no-ri --no-rdoc
  gem install sqlite3-ruby -v 1.3.1 --no-ri --no-rdoc
done
