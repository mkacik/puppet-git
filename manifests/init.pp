class git {
	include git::install

	Class['git::install'] -> Git::Repo <| |>
}
