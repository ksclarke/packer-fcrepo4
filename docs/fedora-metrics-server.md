# Configuring Fedora to Use Send Graphite Metrics

Graphite is an enterprise-scale monitoring (and graphing) tool that runs well on cheap hardware. Fedora has built in support for sending metrics to Graphite, and this Packer build of Fedora is configured to use an external Graphite server if one is available. If you are interested in a Packer build for a Graphite server, one is available at https://github.com/ksclarke/packer-graphite.   How Fedora finds your Graphite server will depend on which platform you're running on.

### Docker

If you're running on Docker, you will need to use the `graphite_server_host_name` variable to indicate where the Graphite server is running.  If it is running in a container on your localhost, you're fine with the default 'localhost' setting.  If it is running on another server, you will need to put that server's name, or IP address, in the `graphite_server_host_name` variable so that Fedora will know where to look for it.  It is assumed Graphite is listening on its default port, 2003. Once this variable is configured for the build, it can not be changed.  It is expected you'll build a development machine using a different configuration from your production instance.

### AWS EC2

If you're running on an AWS EC2 instance or a Digital Ocean host, you have a little more flexibility.  You can still choose to configure the `graphite_server_host_name` variable with the static domain name or IP address for your Graphite server, but you also have the option of passing in the location of the Graphite server to the Fedora server through 'user-data'. Each time a new cloud instance of Graphite is started it may have a different IP address.  If you haven't configured an Elastic IP address for your Graphite server, you can pass it's new location into the Fedora server, before you start it up, through the 'user-data' option.

This can be done through the AWS EC2 API or through the Web console.  To do it through the console, go to the stopped Fedora instance that you want to pass 'user-data' into. Then select 'Actions', 'Instance Settings', and 'View/Change User Data'.

![](images/user-data.png?raw=true)

Once you've done that you will be presented with a text box.  Confirm that it's set for 'Plain text' instead of 'Input is already base64 encoded' and input the domain name or IP address of the Graphite server.

![](images/user-data-text-box.png?raw=true)

Once this has been configured, you can restart your Fedora instance and it will attempt to connect to your Graphite server.  It's worth mentioning that your Graphite server's security group also has to be configured to allow incoming connections from your Fedora instance.

### Digital Ocean

Digital Ocean also allows the passing in of 'user-data' into their Droplets.  This done at the point you create the Droplet.  You will see the 'user-data' text box after you've clicked "Enable User Data".

![](images/do-user-data.png?raw=true)

Digital Ocean's Web interface attempts to simply instance management so I do not believe it has the same concept of "security groups".  Once a port is open it is open to the world.
