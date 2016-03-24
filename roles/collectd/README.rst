Collectd
========

Collectd role for deploying Collectd.

Variables
---------

This role has the following global settings:

.. data ::  Hostname  

   Hostname to append to metrics                    
   
   Default: ``{{ ansible_hostname }}``

.. data ::  Interval  

   Global interval for sampling and sending metrics

   Default: ``10 seconds``

This role enables the following Collectd plugins and settings:

.. data ::  cpu        

   Type: read
   Description: amount of time spent by the CPU in various states

.. data ::  disk

   Type: read 
   Description: performance statistics for block devices and partitions

.. data ::  df 

   Type: read  
   Description : file system usage information
   Default: exclude all system and obsure file system types

.. data ::  interface  

   Type: read  
   Description: network interface throughput, packets/s, errors                                                            
.. data ::  load

   Type: read  
   Description: system load                                                                                                
.. data ::  memory     

   Type: read  
   Description: physical memory utilization                                                                                
.. data ::  processes  

   Type: read  
   Description: number of processes grouped by state                                                                       
.. data ::  swap       

   Type: read  
   Description: amount of memory currently written to swap disk                                                            
.. data ::  uptime     

   Type: read  
   Description: system uptime                                                                                              
.. data ::  users      

   Type: read  
   Description: counts the number of users currently logged into the system                                                
.. data ::  network    

   Type: write 
   Description: send metrics to collectd compatible receiver                
   Default: ``Server "localhost" "25826"``

.. data ::  syslog     

   Type: write 
   Description: write collectd logs to syslog                               
   Default: ``LogLevel "err"``

SELinux Policy
--------------

If your cluster is built with SELinux enabled and enforcing, a custom SELinux
policy will be installed to support the collectd docker plugin. The TE file
looks like this:

.. literalinclude:: ../../roles/collectd/files/collectd_docker_plugin.te
   :language: shell

and is included in ``roles/collectd/files/collectd_docker_plugin.te``.

It was built with the following commands:

.. code-block:: shell

   checkmodule -M -m -o collectd_docker_plugin.mod collectd_docker_plugin.te
   semodule_package -o collectd_docker_plugin.pp -m collectd_docker_plugin.mod
