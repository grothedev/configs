here is config stuff for my data sync system which automatically backs up data from this computer to some other computer defined in the settings. 

it watches a list of specified files, and if they are changed, it runs rsync to upload to server. 

included in this folder are the relevant systemd spec files which you'll want to put in /etc/systemd/user/ , if you want it done automatically upon file change. otherwise you can always just run syncdata manually. 
you'll see that the systemd service runs /usr/local/bin/syncdata. you can find this script in my randomscripts repo. 


