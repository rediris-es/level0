

This is an long introduction to the "level 0" script , not only how the scripts  works, but also a description of the main concepts behind the script. it assumes that you are using Best Practical "Request Tracker for incident Response" to handle the security incidents, and also it assumes that most of the incidents came directly to your "incident & report queue by email.

This project has three main blocks:

1. A library, based on Perl module RT::Client::REST to interacts with a remote RT installation

2. A language, to define how to handle a Incident Report and what actions to perform with it.

3. A command line tool (level0) to intectact with a remote RTIR installation.


