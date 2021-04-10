// Copyright (c) bwplotka/mimic Authors
// Licensed under the Apache License 2.0.

package main

import (
	"time"

	"github.com/bwplotka/mimic/lib/abstr/kubernetes/volumes"
	"github.com/go-openapi/swag"
	"github.com/grafana/tempo/cmd/tempo/app"
	"github.com/grafana/tempo/modules/compactor"
	"github.com/grafana/tempo/modules/distributor"
	"github.com/grafana/tempo/modules/ingester"
	"github.com/grafana/tempo/modules/storage"
	"github.com/grafana/tempo/tempodb"
	"github.com/grafana/tempo/tempodb/backend"
	"github.com/grafana/tempo/tempodb/backend/local"
	"github.com/grafana/tempo/tempodb/encoding"
	"github.com/grafana/tempo/tempodb/pool"
	"github.com/grafana/tempo/tempodb/wal"
	"github.com/weaveworks/common/server"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/intstr"
)

func getTempo(name string) (appsv1.StatefulSet, corev1.Service, corev1.ConfigMap) {
	const (
		configVolumeName  = "tempo-config"
		configVolumeMount = "/etc/tempo"
		dataPath          = "/data"
		httpPort          = 9090
	)
	configAndMount := volumes.ConfigAndMount{
		ObjectMeta: metav1.ObjectMeta{
			Name:   configVolumeName,
			Labels: map[string]string{selectorName: name},
		},
		VolumeMount: corev1.VolumeMount{Name: configVolumeName, MountPath: configVolumeMount},
		Data: map[string]string{
			"tempo.yaml": EncodeYAML(app.Config{
				AuthEnabled: false,
				Server: server.Config{
					HTTPListenPort: httpPort,
				},
				Ingester: ingester.Config{
					MaxTraceIdle: 10 * time.Second,
					// Normally it should be larger, around 10GB. For quick demo purposes, let's make it small to fit Katacoda environment.
					MaxBlockBytes:    1e6,
					MaxBlockDuration: 5 * time.Minute,
				},
				Distributor: distributor.Config{
					Receivers: map[string]interface{}{
						"jaeger": map[string]interface{}{
							"protocols": map[string]interface{}{
								"grpc":        nil,
								"thrift_http": nil,
							},
						},
						"otlp": map[string]interface{}{
							"protocols": map[string]interface{}{
								"grpc": nil,
							},
						},
					},
				},
				Compactor: compactor.Config{
					Compactor: tempodb.CompactorConfig{
						MaxCompactionRange:      1 * time.Hour,
						MaxBlockBytes:           1e6,
						BlockRetention:          1 * time.Hour,
						CompactedBlockRetention: 10 * time.Minute,
					},
				},
				StorageConfig: storage.Config{
					Trace: tempodb.Config{
						Backend: "local",
						Block: &encoding.BlockConfig{
							BloomFP:              .05,
							IndexDownsampleBytes: 1024 * 1024,
							Encoding:             backend.EncZstd,
						},
						WAL:   &wal.Config{Filepath: "/data/wal"},
						Local: &local.Config{Path: "/data/blocks"},
						Pool: &pool.Config{
							MaxWorkers: 100,
							QueueDepth: 10000,
						},
					},
				},
			}),
		},
	}

	srv := corev1.Service{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Service",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:   name,
			Labels: map[string]string{selectorName: name},
		},
		Spec: corev1.ServiceSpec{
			Type:     corev1.ServiceTypeNodePort,
			Selector: map[string]string{selectorName: name},
			Ports: []corev1.ServicePort{
				{
					Name:       "http",
					Port:       httpPort,
					TargetPort: intstr.FromInt(httpPort),
					NodePort:   30555,
				},
			},
		},
	}

	dataVM := volumes.VolumeAndMount{
		VolumeMount: corev1.VolumeMount{
			Name:      name,
			MountPath: dataPath,
		},
	}

	container := corev1.Container{
		Name:  "tempo",
		Image: "grafana/tempo:v0.6.0",
		Args: []string{
			"-config.file=/etc/tempo/tempo.yaml",
		},
		ImagePullPolicy: corev1.PullAlways,
		ReadinessProbe: &corev1.Probe{
			Handler: corev1.Handler{
				HTTPGet: &corev1.HTTPGetAction{
					Port: intstr.FromInt(httpPort),
					Path: "/metrics",
				},
			},
			SuccessThreshold: 3,
		},
		Ports:        []corev1.ContainerPort{{Name: "m-http", ContainerPort: httpPort}},
		VolumeMounts: volumes.VolumesAndMounts{configAndMount.VolumeAndMount(), dataVM}.VolumeMounts(),
		SecurityContext: &corev1.SecurityContext{
			RunAsNonRoot: swag.Bool(false),
			RunAsUser:    swag.Int64(1000),
		},
	}

	set := appsv1.StatefulSet{
		TypeMeta: metav1.TypeMeta{
			Kind:       "StatefulSet",
			APIVersion: "apps/v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:   name,
			Labels: map[string]string{selectorName: name},
		},
		Spec: appsv1.StatefulSetSpec{
			Replicas:    swag.Int32(1),
			ServiceName: name,
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: map[string]string{selectorName: name},
				},
				Spec: corev1.PodSpec{
					Containers: []corev1.Container{container},
					Volumes:    volumes.VolumesAndMounts{configAndMount.VolumeAndMount(), dataVM}.Volumes(),
				},
			},
			Selector: &metav1.LabelSelector{
				MatchLabels: map[string]string{selectorName: name},
			},
		},
	}

	return set, srv, configAndMount.ConfigMap()
}
