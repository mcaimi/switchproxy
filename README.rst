===========
Switchproxy
===========
A simple tool to set transient proxies in terminal sessions.
I just needed a way to handle multiple upstream proxies in different bash instances and wanted to write something in ruby for once.
The script works by setting custom environment variables and then spawns a new shell instance in a ruby Thread.
Usage
=====
Setup
-----
Write a proxy spec under the 'specs/' folder:
.. code:: bash
   # cat specs/proxy.yaml
   ---
   proxyspec:
    name: Default
    http_proxy: 192.168.1.1:3128
    https_proxy: 192.168.1.1:3128
Recognized keyword are:
- name: The profile identifier, used to select this spec
- http_proxy, https_proxy, ftp_proxy: key,value pair of the proxy environment variables to set in the shell instance
Todo
====
- A little polish here and there (once I have a firmer grasp on the Ruby lang.)
