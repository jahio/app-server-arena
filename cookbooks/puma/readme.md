# Puma configuration changes for Engine Yard Cloud

This recipe simply changes Puma's configuration to work with sockets instead of through
ports. nginx is configured to throw things through a Unix socket and puma will bind
to sockets instead.