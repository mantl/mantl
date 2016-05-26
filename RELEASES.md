# Mantl Development and Release Workflow

The *master* branch should always be deployable. Before any branch or pull request is merged into master, it must have passed the continuous integration build.

## Continuous Integration

When a pull request is created, a continuous integration build will be triggered. This build will run a set of integration tests by deploying Mantl onto several cloud providers. If the build fails, the pull request should not be merged.

## Features

All new features must be implemented in a feature branch. A pull request must be created when it is ready for integration so that it can be tested and reviewed. Before the pull request is merged, it must have passed the continuous integration testing suite AND received a simple acknowledgment (*lgtm*, *:thumbsup:*) from a core maintainer. The feature branch should be deleted after it is merged.

*Branch from*: master
*Branch name*: feature/some-feature-description
*Merge to*: master

## Bug Fixes

The workflow for bug fixes is exactly the same as for Features.

*Branch from*: master
*Branch name*: fix/some-bugfix-description
*Merge to*: master

## Hotfixes

Hotfixes are created to apply a fix on an upcoming release branch or an already released version. Like Features and Bug Fixes, Hotfixes are implemented in a separate branch. The difference is that when a Hotfix is successfully tested and signed off on, it should be merged into the appropriate release branch AND master. The hotfix branch can be deleted after it is merged into all appropriate branches.

Hotfixes applied against a pre-release branch will result in a new release candidate. Hotfixes applied against an existing release should result in a minor version bump (for example, 0.6.0 -> 0.6.1).

*Branch from*: release branch
*Branch name*: hotfix/hotfix-description
*Merge to*: release branch AND master

## Releases

When preparing a new release, create a new branch off of master from the commit that contains all of the changes that are going to be included in the release (for example, `release/1.1.0`).

Each release branch will undergo extensive testing &mdash; both automated through the continuous integration build and manual. An upgrade from a previous release must also be tested. During the testing process, we will progress through a series of tagged release candidates (1.1.0-RC1, 1.1.0-RC2, etc.), applying hotfixes as needed until the branch is stable and ready for release. At that point, the last commit in the release branch should be tagged with the version number and any hotfixes merged into the master branch.

Release branches (other than release candidates) are immutable and permanent. They should never be deleted.

*Branch from*: master
*Branch name*: release/0.6.1

## Version Numbers

Mantl release version numbers should follow the `major.minor.patch` scheme. Any breaking, non-backwards compatible changes result in a `major` version increase. A `minor` version bump indicates the addition of new features, improvements, and bug fixes. Critical bug fixes result in a `patch` version update.
