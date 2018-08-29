# LeakGuard

## I. DESCRIPTION:

Batch file to monitor and terminate a process should it surpass the specified memory limit.

Copyright (c) 2018 Frostbyte <frostbytegr@gmail.com>

## II. USAGE:

* Edit the LeakGuard.bat file and adjust the settings to your liking.
  - processToMonitor: Which process to monitor for abnormal memory usage, file extension must be included.
  - processMemoryLimit: How much memory the process is allowed to allocate before the batch terminates it.
  - warningThreshold: Percentage (related to processMemoryLimit) on which to issue a high memory usage warning.
* Run it. (Batch will run in a loop, use CTRL+C to exit)
