# Docker-monolith monitoring

Here you can find monitoring systems for the docker monolith image. The monitoring package includes Grafana, Prometheus.
# ** Before start ** 
1. Change your `docker-compose.yml` and add 2 strings into `environment`:
`METRICS_ENABLED: "true"`
`METRICS_ENDPOINTS_EXPOSE: prometheus`
2. Then change in `/monitoring/prometheus/prometheus.yml`
    `job_name: '<JOB_INSTANCE_NAME>'
    targets: [ '<MYTB_DOCKER_INSTANCE>:9090' ]`
# ** Deploy **
- to deploy monitoring systems, run the script `./docker-deploy-monitoring.sh`;

- to delete monitoring systems run the script `./docker-delete-monitoring.sh`;

If you don't need some of the components you can comment out the use of services in the docker-deploy-monitoring file.

Also you can use `docker-compose.yml` for setup Thingsboard docker monolith with Grafana, Prometheus images together
