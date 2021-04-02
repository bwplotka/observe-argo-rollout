package demo

// Define Argo-rollouts application.
_app: "argo-rollouts": {
	kind:  "deployment"
	image: "argoproj/argo-rollouts:v0.10.2"
	ports: m_http: 8090
	volume: "config-volume": {
		mountPath: "/etc/prometheus"
		spec: configMap: name: "prometheus"
	}

	rolloutStrategy: {
		type: "Recreate"
	}
}

// Define Prometheus application.
_app: monitor: {
	kind:  "stateful"
	image: "prom/prometheus:v2.26.0"
	args: {
		"--config.file":      "/etc/prometheus/prometheus.yml"
		"--web.external-url": "https://localhost:\(monitor.expose.ports.m_http)"
	}
	expose: ports: m_http: 9090
	volume: "config-volume": {
		mountPath: "/etc/prometheus"
		spec: configMap: name: "prometheus"
	}

	// rolloutStrategy: {
	//  type: "RollingUpdate"
	//  rollingUpdate: {
	//   maxSurge:       0
	//   maxUnavailable: 1
	//  }
	// }
}
