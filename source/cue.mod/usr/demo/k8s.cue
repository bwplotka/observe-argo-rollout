package demo

_app: [Namespace=string]: [Name=string]: {
	name:     Name
	kind:     *"deployment" | "stateful" | "daemon"
	replicas: int | *1
	image:    string
	// Expose ports defines named ports that is exposed in the service
	expose: ports: [string]: int
	// Ports defines named ports that is not exposed in the service.
	ports: [string]: int
	arg: [string]:   string
	args: *[ for k, v in arg {"-\(k)=\(v)"}] | [...string]
	// Environment variables.
	env: [string]: string
	envSpec: [string]: {}
	envSpec: {
		for k, v in env {
			"\(k)": value: v
		}
	}
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

service: [Name=_]: _base & {
	name: *Name | string
	port: [Name=_]: {
		name:     string | *Name
		port:     int
		protocol: *"TCP" | "UDP"
	}
	kubernetes: {}
}

kubernetes: prometheus: [a, b, c]

// Generate actual k8s objects:
for k, app in _app if len(spec.expose.port) > 0 {
	service: "\(k)": {
		// Copy over all ports exposed from containers.
		for Name, Port in spec.expose.port {
			port: "\(Name)": {
				// Set default external port to Port. targetPort must be
				// the respective containerPort (Port) if it differs from port.
				port: int | *Port
				if port != Port {
					targetPort: Port
				}
			}
		}

		// Copy over the labels
		label: spec.label
	}
}
