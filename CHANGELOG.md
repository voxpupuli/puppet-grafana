# Change log

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not impact the functionality of the module.

## [v3.1.0](https://github.com/voxpupuli/puppet-grafana/tree/v3.1.0) (2017-07-04)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- Support custom plugins [\#44](https://github.com/voxpupuli/puppet-grafana/pull/44) ([bastelfreak](https://github.com/bastelfreak))

**Closed issues:**

- Usable for Grafana 4.x? [\#37](https://github.com/voxpupuli/puppet-grafana/issues/37)

**Merged pull requests:**

- Always use jessie apt repo when osfamily is Debian. [\#41](https://github.com/voxpupuli/puppet-grafana/pull/41) ([furhouse](https://github.com/furhouse))

## [v3.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v3.0.0) (2017-03-29)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.3...v3.0.0)

**Implemented enhancements:**

- implement package\_ensure param for archlinux [\#34](https://github.com/voxpupuli/puppet-grafana/pull/34) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- implement package\\_ensure param for archlinux [\#34](https://github.com/voxpupuli/puppet-grafana/pull/34) ([bastelfreak](https://github.com/bastelfreak))
- FIX configuration file ownership [\#30](https://github.com/voxpupuli/puppet-grafana/pull/30) ([cassianoleal](https://github.com/cassianoleal))

**Closed issues:**

- Configured grafana debian repo should contain current distribution [\#27](https://github.com/voxpupuli/puppet-grafana/issues/27)
- Error while creating dashboard [\#25](https://github.com/voxpupuli/puppet-grafana/issues/25)

**Merged pull requests:**

- Bump version, Update changelog [\#38](https://github.com/voxpupuli/puppet-grafana/pull/38) ([dhoppe](https://github.com/dhoppe))
- Debian and RedHat based operating systems should use the repository by default [\#36](https://github.com/voxpupuli/puppet-grafana/pull/36) ([dhoppe](https://github.com/dhoppe))
- Add support for archlinux [\#32](https://github.com/voxpupuli/puppet-grafana/pull/32) ([bastelfreak](https://github.com/bastelfreak))
- Fix grafana\_dashboards [\#31](https://github.com/voxpupuli/puppet-grafana/pull/31) ([cassianoleal](https://github.com/cassianoleal))
- supoort jessie for install method repo [\#28](https://github.com/voxpupuli/puppet-grafana/pull/28) ([roock](https://github.com/roock))
- Use operatinsystemmajrelease fact in repo url [\#24](https://github.com/voxpupuli/puppet-grafana/pull/24) ([mirekys](https://github.com/mirekys))
- The puppet 4-only release will start at 3.0.0 [\#21](https://github.com/voxpupuli/puppet-grafana/pull/21) ([rnelson0](https://github.com/rnelson0))

## [v2.6.3](https://github.com/voxpupuli/puppet-grafana/tree/v2.6.3) (2017-01-18)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.2...v2.6.3)

## [v2.6.2](https://github.com/voxpupuli/puppet-grafana/tree/v2.6.2) (2017-01-18)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.1...v2.6.2)

**Merged pull requests:**

- release 2.6.2 \(optimistic, i know ;\) [\#20](https://github.com/voxpupuli/puppet-grafana/pull/20) ([igalic](https://github.com/igalic))

## [v2.6.1](https://github.com/voxpupuli/puppet-grafana/tree/v2.6.1) (2017-01-18)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.0...v2.6.1)

**Merged pull requests:**

- release 2.6.1 [\#18](https://github.com/voxpupuli/puppet-grafana/pull/18) ([bastelfreak](https://github.com/bastelfreak))

## [v2.6.0](https://github.com/voxpupuli/puppet-grafana/tree/v2.6.0) (2017-01-18)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.5.0...v2.6.0)

**Closed issues:**

- config.ini.erb key sort issue [\#10](https://github.com/voxpupuli/puppet-grafana/issues/10)

**Merged pull requests:**

- Update metadata.json [\#16](https://github.com/voxpupuli/puppet-grafana/pull/16) ([goya151](https://github.com/goya151))
- Add changelog entries for changes since 2.5.0 [\#14](https://github.com/voxpupuli/puppet-grafana/pull/14) ([igalic](https://github.com/igalic))
- modulesync 0.16.8 [\#13](https://github.com/voxpupuli/puppet-grafana/pull/13) ([bastelfreak](https://github.com/bastelfreak))
- Update config.ini.erb [\#11](https://github.com/voxpupuli/puppet-grafana/pull/11) ([doomnuggets](https://github.com/doomnuggets))
- fix datasource provider [\#6](https://github.com/voxpupuli/puppet-grafana/pull/6) ([andyroyle](https://github.com/andyroyle))
- Bump min version\_requirement for Puppet + deps [\#5](https://github.com/voxpupuli/puppet-grafana/pull/5) ([juniorsysadmin](https://github.com/juniorsysadmin))

## [v2.5.0](https://github.com/voxpupuli/puppet-grafana/tree/v2.5.0) (2015-11-01)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.1.0...v2.5.0)

## [v2.1.0](https://github.com/voxpupuli/puppet-grafana/tree/v2.1.0) (2015-08-07)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.0.2...v2.1.0)

## [v2.0.2](https://github.com/voxpupuli/puppet-grafana/tree/v2.0.2) (2015-04-23)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v1.0.1...v2.0.2)

## [v1.0.1](https://github.com/voxpupuli/puppet-grafana/tree/v1.0.1) (2015-02-27)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v1.0.0) (2014-12-16)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v0.2.2...v1.0.0)

## [v0.2.2](https://github.com/voxpupuli/puppet-grafana/tree/v0.2.2) (2014-10-28)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v0.2.1...v0.2.2)

## [v0.2.1](https://github.com/voxpupuli/puppet-grafana/tree/v0.2.1) (2014-10-14)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v0.1.3...v0.2.1)

## [v0.1.3](https://github.com/voxpupuli/puppet-grafana/tree/v0.1.3) (2014-07-04)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v0.1.2...v0.1.3)

## [v0.1.2](https://github.com/voxpupuli/puppet-grafana/tree/v0.1.2) (2014-06-30)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*