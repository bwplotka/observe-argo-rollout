package demo

_app: [Name=string]: {
	name:     Name
	kind:     *"deployment" | "stateful" | "daemon"
	replicas: int | *1
	image:    string
	// Expose ports defines named ports that is exposed in the service
	expose: ports: [string]: int
	// Ports defines named ports that is not exposed in the service.
	ports: [string]: int
	args: [string]:  string
	// Environment variables.
	envs: [string]: string
	volume: [Name=_]: {
		name:      string | *Name
		mountPath: string
		subPath:   string | *null
		readOnly:  *false | true
		kubernetes: {}
	}

	configMap: [string]: {
	}

}

//service: [Name=_]: _base & {
// name: *Name | string
// port: [Name=_]: {
//  name:     string | *Name
//  port:     int
//  protocol: *"TCP" | "UDP"
// }
// kubernetes: {}
//}
