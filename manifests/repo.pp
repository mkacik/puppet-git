define git::repo (
	$source,
	$path,
	$owner,
	$branch = 'master',
	$git_tag = undef,
	$update = false,
) {
  if ($update != false) and ($git_tag != undef) {
    fail('Forcing update is not possible for git tags')
  }

	if $source =~ /^\/\w[\w\/]*/ {
		fail('Cloning from local source is not supported')
	} else {
		include git

		if ! defined(File[$path]) {
			file {
				$path:
					ensure => directory,
					owner => $owner,
			}
		}

		exec {
			"clone git repository from ${source} into ${path}":
				command => "git clone -b ${branch} ${source} .",
				user => $owner,
				cwd => $path,
				creates => "${path}/.git",
				path => ['/usr/bin'],
				require => File[$path]
		}

		if $git_tag { # git tag should take precedence over any branch spec
			exec {
				"checkout git tag ${git_tag} in ${path}":
					command => "git fetch && git checkout ${git_tag}",
					user => $owner,
					cwd => $path,
					unless => "git describe --tags | grep -x '${git_tag}'",
					path => ['/usr/bin'],
					require => Exec["clone git repository from ${source} into ${path}"]
			}
		} else {
			exec {
				"checkout git branch ${branch} in ${path}":
					command => "git fetch && git checkout ${branch}",
					user => $owner,
					cwd => $path,
					unless => "git rev-parse --abbrev-ref HEAD | grep -x '${branch}",
					path => ['/usr/bin'],
					require => Exec["clone git repository from ${source} into ${path}"]
			}
			if $update == true {
				exec {
					"pull new changes from branch ${branch} in ${path}":
						command => "git fetch && git reset --hard HEAD && git checkout ${branch} && git pull origin ${branch}",
						user => $owner,
						cwd => $path,
						unless => "git diff --no-color --exit-code",
						path => ['/usr/bin'],
						require => Exec["clone git repository from ${source} into ${path}"]
				}
			}
		}
	}
}
