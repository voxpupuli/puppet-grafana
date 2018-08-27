source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place, fake_version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

group :test do
  gem 'puppetlabs_spec_helper', '~> 2.6',                           :require => false
  gem 'rspec-puppet', '~> 2.5',                                     :require => false
  gem 'rspec-puppet-facts',                                         :require => false
  gem 'rspec-puppet-utils',                                         :require => false if RUBY_VERSION >= '2.0.0'
  gem 'puppet-lint-leading_zero-check',                             :require => false
  gem 'puppet-lint-trailing_comma-check',                           :require => false
  gem 'puppet-lint-version_comparison-check',                       :require => false
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check',  :require => false
  gem 'puppet-lint-unquoted_string-check',                          :require => false
  gem 'puppet-lint-variable_contains_upcase',                       :require => false
  gem 'metadata-json-lint',                                         :require => false if RUBY_VERSION >= '2.0.0'
  gem 'redcarpet',                                                  :require => false
  gem 'rubocop', '~> 0.49.1',                                       :require => false if RUBY_VERSION >= '2.3.0'
  gem 'rubocop-rspec', '~> 1.15.0',                                 :require => false if RUBY_VERSION >= '2.3.0'
  gem 'mocha', '~> 1.4.0',                                          :require => false
  if RUBY_VERSION < '2.0.0'
    gem 'metadata-json-lint', '~> 0.0.11',                          :require => false
    gem 'tins', '~> 1.6.0',                                         :require => false
    gem 'term-ansicolor', '~> 1.3.2',                               :require => false
    gem 'parallel_tests', '~> 2.9.0',                               :require => false
    gem 'rspec-puppet-utils', '~> 2.2.1',                           :require => false 
  end
  gem 'coveralls',                                                  :require => false
  gem 'simplecov-console',                                          :require => false
  gem 'rack', '~> 1.0',                                             :require => false if RUBY_VERSION < '2.2.2'
  gem 'parallel_tests',                                             :require => false if RUBY_VERSION > '1.9.3'
  gem 'toml',                                                       :require => false
  gem 'overcommit', '>= 0.39.1',                                    :require => false if RUBY_VERSION > '1.9.3'
end

group :development do
  gem 'travis',                   :require => false
  gem 'travis-lint',              :require => false
  if rake_version = ENV['RAKE_VERSION']
    gem 'rake', *location_for(rake_version)
  else
    gem 'rake',                   :require => false
  end
  gem 'guard-rake',               :require => false
end

group :system_tests do
  gem 'winrm',                              :require => false
  if beaker_version = ENV['BEAKER_VERSION']
    gem 'beaker', *location_for(beaker_version)
  else
    gem 'beaker', '>= 3.9.0', :require => false
  end
  if RUBY_VERSION < '2.0.0'
    gem 'beaker-rspec', '~> 5.6.0',              :require => false
  else
    gem 'beaker-rspec',                          :require => false
  end
  gem 'serverspec',                         :require => false
  gem 'beaker-hostgenerator', '>= 1.1.10',  :require => false
  gem 'beaker-docker',                      :require => false
  gem 'beaker-puppet',                      :require => false
  gem 'beaker-puppet_install_helper',       :require => false
  gem 'beaker-module_install_helper',       :require => false
  gem 'rbnacl', '>= 4',                     :require => false if RUBY_VERSION >= '2.2.6'
  gem 'rbnacl-libsodium',                   :require => false if RUBY_VERSION >= '2.2.6'
  gem 'bcrypt_pbkdf',                       :require => false
end

group :release do
  gem 'github_changelog_generator',  :require => false, :git => 'https://github.com/skywinder/github-changelog-generator' if RUBY_VERSION >= '2.2.2'
  if RUBY_VERSION < '2.0.0'
    gem 'puppet-blacksmith', '~> 4.0.0',            :require => false
  else
    gem 'puppet-blacksmith',           :require => false
  end
  gem 'voxpupuli-release',           :require => false, :git => 'https://github.com/voxpupuli/voxpupuli-release-gem'
  gem 'puppet-strings', '>= 1.0',    :require => false
end



if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion.to_s, :require => false, :groups => [:test]
else
  gem 'facter', :require => false, :groups => [:test]
end

ENV['PUPPET_VERSION'].nil? ? puppetversion = '~> 5.0' : puppetversion = ENV['PUPPET_VERSION'].to_s
gem 'puppet', puppetversion, :require => false, :groups => [:test]

# vim: syntax=ruby
