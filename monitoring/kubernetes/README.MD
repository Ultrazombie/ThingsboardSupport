# Kubernetes monitoring

Here you can find monitoring systems for the cybernetes cluster. The monitoring package includes Grafana, Prometheus, Loki, Promtail, Node-exporter, State-metrics.

- to deploy monitoring systems, run the script `./k8s-deploy-monitoring.sh`;

- to delete monitoring systems run the script `./k8s-delete-monitoring.sh`;

If you don't need some of the components you can comment out the use of services in the k8s-deploy-monitoring file.
