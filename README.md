King
=========

> The king of your nodes - A powerful command and control center for your server infrastructure

### In planning phase - No code yet :smile:

## Features

The King server can:

* Store applications on a Git server
  * Git branches store individual applications
* Stores shared configuration
* Provision stored applications out to servants
* Provision port numbers
* Send arbitrary commands to servants
* Runs a clean web UI
  * Graphs to display reporting data from each servant
* Runs a statsd server along side
* Send emails based on reporting

The Servant servers can:

* Auto-restart on crashes
* Auto-cluster based on CPU
* Report to the King about:
  * CPU / RAM / Disk Usage
  * Processes
  * Important events (crashes etc.)
  * Application events
