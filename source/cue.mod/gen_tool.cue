package demo

import "encoding/yaml"

_outputDir: "../../manifests-cue-gen"

kubernetes: prometheus: ["a", "b", "c"]

// https://pkg.go.dev/cuelang.org/go@v0.2.2/pkg/tool4
command: gen: {
	task: pwd: {
		$id: "tool/os.Getenv"
		PWD: string
	}
	for name, objs in kubernetes {
		let genTask = "\(name)-gen"
		task: "\(genTask)": {
			$id:         "tool/file.Create"
			filename:    "\(_outputDir)/\(name).yaml"
			permissions: 0o644
			contents:    yaml.MarshalStream(objs)
			$after:      task.pwd
		}
		task: "\(name)-print": {
			$id:    "tool/cli.Print"
			text:   "Generated \(name) in \(task.pwd["PWD"])\(task[genTask].filename)"
			$after: task[genTask]
		}
	}
}
