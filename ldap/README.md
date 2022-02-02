# LDAP SERVER

This project helps to start up and LDAP server in docker with the same configuration documented in
[LDAP Scenarios](https://contrast.atlassian.net/wiki/spaces/ENG/pages/731381778/LDAP+Scenarios)


### How do I get set up? ###

*  Make sure to have docker and docker-compose


* Essentially you just need to run `run-ldap` this will load the default schema located in `data/` folder

* The users and password are documented in this [link](https://contrast.atlassian.net/wiki/spaces/ENG/pages/731381782/Some+Thoughts+on+LDAP+Testing) you just need to use your domain (localhost) instead openldap.contsec.com


* If you want to include your data you can attach your own `*.ldif*` file in data `data/`


### How to maintain this image ###


* If you want to improve this you can start reading this [documentation](https://wiki.archlinux.org/index.php/OpenLDAP)
* There are two important files that you need to check it out before start making changes

    1. `ldap.cnf` This file has the configuration to start LDAP Server. As you can see some properties has Placeholders as values since we plan to replace them with environment variables at Starting time.
    2. `entrypoint.sh` This file is executed when image is starting. It reads the values from environmet and replaces everthing in `ldap.cnf`.

    Environment variables allows us to modify preferences easily, for instance the log level. If you consider that you configuration should not be modified you can add the proerty-value directly in `ldap.cnf`
