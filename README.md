<img src="https://docs.google.com/drawings/d/1W0qjJzcPkLhFz_h-QY-worQZxhaEfFIGPV1ElV5gSSQ/pub?w=378&amp;h=153">
=========

> The King of your Nodes - A powerful server infrastructure management platform

## Download

**Still in prototyping phase...** :smile:

## Initial Features

The King server can:

* Store applications on a Git server
  * King is a Git remote
  * Git repositories are applications 
  * Git semvar commit tags are application versions
* Stores shared configuration
* Provision stored applications out to servants
* Provision port numbers
* Send arbitrary commands to servants
* Runs a clean web UI
  * Graphs to display reporting data from each servant
* Runs a statsd server along side
* Send emails based on reporting

The Servant servers can:

* Log all stdout and stderr
  * Alert for errors 
* Auto-restart on crashes
* Auto-cluster based on CPU
* Report to the King about:
  * CPU / RAM / Disk Usage
  * Processes
  * Important events (crashes etc.)
  * Application events (using the `king` node module within an app) 


### Overview Diagram

* [Overview Diagram](https://docs.google.com/drawings/d/1MZyNft8rYvSHDf5R_ueCuiymenWsZFnufB0OLr75gP4/edit?usp=sharing)

<img src="https://docs.google.com/drawings/d/1MZyNft8rYvSHDf5R_ueCuiymenWsZFnufB0OLr75gP4/pub?w=900&amp;h=600">


## Future Features

* **Second Layer of Control**
  * Problem: King assumes relatively small infrastructure
  * Solution: Add a concept of a Foreman server, the King server no longer communicates with Servants.
    When King connects to a Foreman, all of it's Servants become visible. This allows domains of servants.
  * New problem: Even with a large number of Servants (100+), the King web server, dnode server,
    and git server would still have fairly low utilisation. The statsd server wouldn't, however.
      * Solution: Allow remote statsd Servers with a load balancer in front (possibly as a Servant Cluster, see below).
* **Force all communication to be encrypted**
  * Problem: King assumes all hosts within the VLAN can be trusted
  * Solution: Use public key encryption -> King and servants only communicate over TLS dnode, using preshared keys.
* **Add redundancy for the King server**
  * Problem: King assumes that there is only one King, and therefore, it has single point of failure:
  * Solution: King replicates it state to a Backup King, when a Servant loses connection to King and can't restore
    the connection after N retries, it will swap to the Backup King. Will require secure exchange of new keys.

* **Add auto-scaling**
  * Problem: King assumes a single application will be deployed to a single host. It would be time consuming
    if we wanted to spin up 5 instances of an application across 5 servants, with a load balancer.
  * Solution: Servant Cluster, a set of Servants, which can be viewed as a single instance.
    King could assign an application to a Servant Cluster, which could create a load balancer Servant,
    then use as many Servants as required to serve the current load.
    * Extra: A Servant Cluster would be configurable: minimum and maximum number of servants, when to
      recruit more servants based off CPU/RAM thresholds.
      * More Extra: King could also be client a cloud service using their APIs, which could start Virtual
        Machines with environment variables set to join a given cluster.

## Design Documents

* [Ideas](https://docs.google.com/document/d/12lMrzcAQOT2BrpiqchGjwtftis3f0LS8QRIFSiNqklE/edit?usp=sharing) (subject to change...)
* [Web UI Wireframe](https://docs.google.com/drawings/d/1jNrPZKfDorwkJAw64EFu2PrHPD9q9WxSKRYc3_SAgm4/edit)

### Credits

This application is built on many @substack modules and ideas, many kudos to James.

