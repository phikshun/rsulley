RSulley v0.0.1
===============

This is a port of Sulley fuzzing framework, with some improvements for embedded devices.


Installation
------------

RSulley requires Ruby 1.9 or higher.  After installing the correct Ruby, use "bundle install" from the rsulley root directory.


Usage
-----

To start a new fuzzing session, create or edit an existing "fuzzy" in the fuzzies directory.

You will be able to change the target IP address, system type, and the protocol format through a "fuzzy" file.

To start RSulley, run the following command from the rsulley directory root:

./rsulley fuzzies/ftp

State files and log files will be placed in the rsulley tmp directory.  In order to re-fuzz a target, you must delete the state file.

Be warned that existing log files will be truncated when restarting a session, so save them if necessary.
