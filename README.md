# ThingsboardSupport

Here are our best practices to help solve service support needs.

We have scripts:
- databases - for database backup and restore (Casandra, Postgres, Postgres + Timescale)
- logs - for parsing the logs to find out the average and maximum number of messages in the queues
- telemetry - to test sending telemetry to test devices
- yml - for migrate your configuration from thingsboard.yml to thingsboard.conf file. It makes upgrading easier because you can use the standard yml file and keep all your settings in conf. That way you can find the settings you need more quickly, or you can override the default settings just by adding the necessary parameters. We also saved all popular thingsboard.yml files in the yml directory
