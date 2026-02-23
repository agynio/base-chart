# service-base

`service-base` is a Helm library chart that provides common templates for
service workloads. It is designed to be included by service charts rather than
installed directly.

## Usage

Add the library chart as a dependency:

```yaml
# Chart.yaml
dependencies:
  - name: service-base
    version: 0.1.0
    repository: oci://ghcr.io/agynio/helm
```

Then include the templates in your chart:

```yaml
# templates/deployment.yaml
{{- include "service-base.deployment" . }}
```

```yaml
# templates/service.yaml
{{- include "service-base.service" . }}
```

Other available templates:

- `service-base.ingress`
- `service-base.hpa`
- `service-base.pdb`
- `service-base.serviceAccount`
- `service-base.rbac`
- `service-base.config` (volume mounts helper)
- `service-base.metrics`

## Values

Key values (see `values.yaml` for full list):

- `image.repository` (required)
- `image.tag` (defaults to `.Chart.AppVersion`)
- `global.imageRegistry` and `image.registry` (registry resolution)
- `global.imagePullSecrets` and `image.pullSecrets` (merged in PodSpec)
- `service.ports[]` for service ports
- `ingress.ingressClassName` and `ingress.hosts[].paths[]`
- `autoscaling` for HPA targets/behavior
- `pdb` for PodDisruptionBudget settings
- `configMounts[].sourceName` to mount existing ConfigMaps/Secrets
- `metrics.serviceMonitor` for Prometheus Operator ServiceMonitors

### Example values for a service chart

```yaml
image:
  repository: ghcr.io/agynio/my-service

service:
  ports:
    - name: http
      port: 8080
      targetPort: http

ingress:
  enabled: true
  hosts:
    - host: api.example.com
      paths:
        - path: /
          pathType: Prefix
          servicePort: http

configMounts:
  - name: my-service-config
    sourceName: my-service-config
    type: configMap
    mountPath: /etc/service/config.yaml
    subPath: config.yaml
```
