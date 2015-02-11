RSulley
=======

This is a partial port of Sulley fuzzing framework, written for testing embedded devices.  Sulley has PCAP capture, Windows debugging features and much more.  Sulley was written by Pedram Amini, and this code is derived from his work.  If you require all the features of Sulley, it is maintained in [this repo](https://github.com/OpenRCE/sulley).


Installation
------------

RSulley requires Ruby 1.9 or higher (now Ruby 2.1 compatible).  After installing the correct Ruby, use "bundle install" from the rsulley root directory.


Usage
-----

To start a new fuzzing session, create or edit an existing "fuzzy" in the fuzzies directory.

You will be able to change the target IP address, system type, and the protocol format through a "fuzzy" file.

To start RSulley, run the following command from the rsulley directory root:

`./rsulley fuzzies/ftp`

State files and log files will be placed in the rsulley tmp directory.  In order to re-fuzz a target, you must delete the state file.

Be warned that existing log files will be truncated when restarting a session, so save them if necessary.


Limitations
-----------

Not even close to all of the functionality of Sulley has been ported.  I started this port to make programming and running fuzz tests for embedded devices really simple.  The DSL used for fuzz case generation feels very natural and I quite like it.  For more advanced fuzzing, use Peach fuzzer (I currently use Peach for most projects).
