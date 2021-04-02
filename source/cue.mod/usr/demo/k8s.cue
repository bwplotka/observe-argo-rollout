package demo

import (
	apps_v1 "k8s.io/api/apps/v1"
)

kubernetes: [string]: [...]

// Generate actual k8s objects:
for Name, App in _app {
	kubernetes: "\(Name)": [
		if App.kind == "stateful" {
			apps_v1.#StatefulSet & _kubeSpec & {
				apiVersion: "apps/v1beta1"
				kind:       "StatefulSet"
				spec: replicas: app.replicas
			}
		},
	]
}

//}if len(spec.expose.port) > 0 {
// service: "\(k)": {
//  // Copy over all ports exposed from containers.
//  for Name, Port in spec.expose.port {
//   port: "\(Name)": {
//    // Set default external port to Port. targetPort must be
//    // the respective containerPort (Port) if it differs from port.
//    port: int | *Port
//    if port != Port {
//     targetPort: Port
//    }
//   }
//  }
//
//  // Copy over the labels
//  label: spec.label
// }
//}

// _k8sSpec injects Kubernetes definitions into a deployment
// Unify the deployment at X and read out kubernetes to obtain
// the conversion.
_kubeSpec: {
	metadata: name: App.name
	metadata: labels: component: App.name
	spec: template: {
		metadata: labels: App.metadata.labels
		spec: containers: [{
			name:  App.name
			image: App.image
			args:  *[ for k, v in App.args {"-\(k)=\(v)"}] | [...string]
			if len(App.envs) > 0 {
				env: [ for k, v in App.envs {name: k: value: v}]
			}
			ports: [ for k, p in App.expose.ports & App.ports {
				name:          k
				containerPort: p
			}]
		}]
	}
	// Volumes.
	spec: template: spec: {
		if len(App.volume) > 0 {
			volumes: [
				for v in App.volume {
					v.kubernetes
					name: v.name
				},
			]
		}
		containers: [{
			if len(App.volume) > 0 {
				volumeMounts: [
					for v in App.volume {
						name:      v.name
						mountPath: v.mountPath
						if v.subPath != null {
							subPath: v.subPath
						}
						if v.readOnly {
							readOnly: v.readOnly
						}
					},
				]
			}
		}]
	}
}
