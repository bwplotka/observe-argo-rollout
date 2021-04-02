package demo

// Define Prometheus application.
_app: monitor: {
	kind:  "stateful"
	image: "prom/prometheus:v2.26.0"
	args: {
		"--config.file":      "/etc/prometheus/prometheus.yml"
		"--web.external-url": "https://localhost:\(monitor.expose.ports.http)"
	}

	expose: ports: http: 9090
	volume: "config-volume": {
		mountPath: "/etc/prometheus"
		spec: configMap: name: "prometheus"
	}
	kubernetes: spec: selector: matchLabels: app: "prometheus"
	kubernetes: spec: strategy: {
		type: "RollingUpdate"
		rollingUpdate: {
			maxSurge:       0
			maxUnavailable: 1
		}
	}
	kubernetes: spec: template: metadata: annotations: "prometheus.io.scrape": "true"
}
