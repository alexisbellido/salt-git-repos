=================================================
Salt for cloning Git Repositories
=================================================

Salt formula to clone and update a set of git repositories.

Add public key to the repositories you will need, this includes both the main Django project and any applications you may need. This is how to easily create your private and public keys locally without a prompt or passphrase:

  ``echo -e 'y\n' | ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''``

Your public key, which you should add to Github, should be in:

  ``cat ~/.ssh/id_rsa.pub`` 

A quick way to add a publick key to a host with Ubuntu is:

  ``ssh-copy-id user@host`` 

Optionally, if you want avoid the prompt when cloning this repository from Github (which happens when running the quick install script), you can add the fingerprint like this:

  ``ssh-keyscan github.com >> ~/.ssh/known_hosts``

  ``\curl -sSL https://raw.githubusercontent.com/alexisbellido/salt-git-repos/master/scripts/install-prerequisites-amazon-linux.sh | sudo bash -s full|master|minion "Joe Doe" name@example.com``

You need three arguments:

The first one defines the type of installation: "full" to install both salt-master and salt-minion, "master" to install only salt-master, or "minion" to install only salt-minion.
The second and third arguments are used to setup git --global user.name and user.email.

An installation of type full or master will also copy basic top.sls to /srv/salt/top.sls and /srv/pillar/* and files and point to them from /etc/salt/master.