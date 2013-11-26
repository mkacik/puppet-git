class git::install {
	$packages = 'git'

	package {
		$packages:
			ensure => installed
	}
}
