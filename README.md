iperfsensor for PRTG
====================

[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)
[![GitHub release](https://img.shields.io/github/release/rkagerer/iperfsensor.svg)](https://github.com/rkagerer/iperfsensor/blob/master/iperfsensor.sh)

This script runs [iPerf][1] to measure bandwidth between two nodes of a network, and reports the results in a format
compatible with PRTG's [SSH Script Advanced][2] sensor.

It has minimal dependancies and even works on a router flashed with the open-source [Tomato][3] firmware.

![Gauges](http://i.imgur.com/h8ybAzj.png)

### Prerequisites

1.  Ensure iPerf is installed on at least two hosts in your network.  If you only have one, you might try testing against
    a [public server][4].  For Tomato, [install Entware][5] first then run `opkg install iperf`.

2.  Ensure the neccessary firewall ports are open (default is 5001).

3.  Test iPerf manually to check connectivity.

4.  Ensure the machine which is your iPerf client:

    - has SSH is running, and that PRTG probe can connect to it
    - is set up in PRTG as a device
   
    Note your PRTG probe does not need connectivity to the computer that will act as the iPerf server.  Also if you have
    several SSH-based PRTG sensors sampling a Tomato router at high frequency, you may need to relax the SSH connection
    rate throttling (under *Administration* | *Admin Access* | *Admin Restrictions* | *Limit Connection Attempts*).

### Installation

1.  Place iperfsensor.sh on the computer that will act as the client, e.g.:

    ```sh
    cd /var/prtg/scriptsxml
    wget http://rawgit.com/rkagerer/iperfsensor/master/iperfsensor.sh`)
    chmod +x iperfsensor.sh
    ```

2.  Add an *SSH Script Advanced* sensor in PRTG, and pick _iperfsensor.sh_.

3.  Under _Parameters_, enter the parameters to be passed to iPerf, just as if you were running it from the command line.
    e.g.:

    ```
    -c iperf.scottlinux.com -p 5201
    ```

4.  _Shell Timeout_ should be longer than *twice* your iPerf test duration.  This is because both an up and down test
    is performed.  By default, each test lasts 10 seconds, but you can change this using the `-t` parameter.

### Bandwidth Disclaimer

Automated iPerf testing can eat up a lot of bandwidth.  The best way to use this tool is between two internal nodes of
your network (e.g. to monitor a point to point Wifi link).  If you use it across a WAN link, be sure you have sufficient
bandwidth and budget for the traffic that will be generated!

Also keep in mind that other, parallel traffic loads on your network will affect the results.

### Changelog

  - 2015-Sep-20: Initial release

### Bling

![Gauges](http://i.imgur.com/6txm9dZ.png)

![Grids](http://i.imgur.com/Bm2fX2Z.png)

[1]: https://github.com/esnet/iperf
[2]: https://www.paessler.com/manuals/prtg/ssh_script_advanced_sensor
[3]: http://tomato.groov.pl/
[4]: https://www.google.com/search?q=public+iperf+servers
[5]: https://gist.github.com/dferg/833aade513965d78b43d
