package demo

import (
	"k8s.io/api/core/v1"
	apps_v1 "k8s.io/api/apps/v1"
)

kubernetes: [string]: [...]

// Generate actual k8s objects:
for Name, App in _app {
	kubernetes: "\(Name)": [
		// TODO: daemon set.
		if App.kind == "deployment" {
			(_kubeSpec & {X: App}).X.kubernetes & apps_v1.#Deployment & {
				apiVersion: "apps/v1"
				kind:       "Deployment"
				spec: replicas: App.replicas
			}
		},
		if App.kind == "stateful" {
			(_kubeSpec & {X: App}).X.kubernetes & apps_v1.#StatefulSet & {
				apiVersion: "apps/v1beta1"
				kind:       "StatefulSet"
				spec: replicas:    App.replicas
				spec: serviceName: App.name
			}
		},
		if App.kind == "daemon" {
			(_kubeSpec & {X: App}).X.kubernetes & apps_v1.#DaemonSet & {
				apiVersion: "extensions/v1beta1"
				kind:       "DaemonSet"
			}
		},
		if len(App.expose.ports) > 0 {
			(_kubeSvc & {X: App}).X.kubernetes & v1.#Service & {
				apiVersion: "v1"
				kind:       "Service"
			}
		},
	]
}

_kubeObj: X: kubernetes: {
	metadata: name: X.name
	metadata: labels: {
		"app.kubernetes.io/component": X.component
		"app.kubernetes.io/name":      X.name
	}
}

_kubeSvc: X: kubernetes: (_kubeObj & {X: X}).X.kubernetes & {
	spec: ports: [
		for Name, Port in X.expose.port {
			name:       Name
			port:       Port
			protocol:   *"TCP" | "UDP"
			targetPort: Port
		},
	]
}

// _k8sSpec injects Kubernetes definitions into a deployment
// Unify the deployment at X and read out kubernetes to obtain
// the conversion.
_kubeSpec: X: kubernetes: (_kubeObj & {X: X}).X.kubernetes & {
	spec: selector: matchLabels: "app.kubernetes.io/name": X.name
	spec: template: {
		metadata: labels: kubernetes.metadata.labels
		spec: containers: [{
			name:            X.name
			image:           X.image
			imagePullPolicy: "Always"
			args:            *[ for k, v in X.args {"-\(k)=\(v)"}] | [...string]
			if len(X.envs) > 0 {
				env: [ for k, v in X.envs {name: k: value: v}]
			}
			ports: [ for k, p in X.expose.ports & X.ports {
				name:          k
				containerPort: p
			}]
		}]
	}

	//    securityContext:
	//        runAsNonRoot: true ??

	// Volumes.
	spec: template: spec: {
		if len(X.volume) > 0 {
			volumes: [
				for v in X.volume {
					name: v.name
				},
			]
		}
		containers: [{
			if len(X.volume) > 0 {
				volumeMounts: [
					for v in X.volume {
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
