# CTS Safenet for SAP Systems (SAP Transport Management System)

An SAP system runs many batch jobs at a time. Most of them are planned periodicly and the system takes care of them. But sometimes a little bug occurs, that has to be fixed by a transport that is sent to the system. In most cases the batch reports are not built to dump at any given time. And if the program changes, while it is running, nothing can be done to prevent the dump of the program.
So I've seen many problems with data that was halfway written. And many of the problems come up weeks or months, after the incident.

For this cases you need a safenet, that checks, if the program is to be altered in the next minutes.

So I developed a class and a batch report, that search for transports that are started and contain some parts of the programs.
* The batch report can be planned in the batchjob one step ahead of the report to protect. So the only report dumping (and killing the batch job) is the safenet, not the critical report.
* The class can be implemented in the INITIALIZATION phase of a report and if some relevant transports are found, the report can stop in a special way.


After this is a usable PoC:
* Maybe add classes as searchable objects
* Maybe add some other options to react on a found transport
* Maybe the batchjob logic can be too: "IF a transport is NOT found, raise system event ..." to plan the critical job as event driven and see only real problems in SM37

If you find it useful and extend it, please fork and give some code back to the community!
