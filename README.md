# Hardening Debian 11
Aim is to reduce the attack surface, to be protected against ~88% of attacks.
Scripts are based on: CIS_Debian_Linux_11_Benchmark_v1.0.0.pdf (https://www.cisecurity.org/).

The scripts are aimed to keep the basic functionality needed for a workstation while greatly reducing the attack surface.

## Harden Debian 11
1) `sudo apt-get update`
2) `sudo apt-get install git -y`
3) `git clone https://github.com/katamb/itc8080.git`
4) `cd itc8080`
5) `sudo ./custom_hardening.sh`

## Documentation
### Section 1 - Initial setup
* 1.1.2 ...1.1.8 - running these changes among other scripts in virtual machine didn't always go smoothly, so these are not currently covered. Recommendation is to set this up while installing th OS. 
* 1.2 - manual process
* 1.3.1 - should be configured according to needs and initiated 
* 1.4.1 - requires setting password, so should be done manually
* 1.4.3 - requires setting password, should be done manually
* 1.5.4 - core dumping should be restricted if it seems needed in given environment
* 1.6.x - AppArmor should be setup for the specific environment
* 1.7.x - Does not directly help to reduce attack surface, more of a legal topic
* 1.8.x - would be reasonable to implement most of these, however only critical one seemed to be 1.8.7. Also xorg might be a better way to go, as it seems to be less resource hungry.
### Section 2 - Services
* 2.1 time synchronization - doesn't really help us reduce attack surface
* 2.2.15 Ensure mail transfer agent is configured for local-only mode - requires modifying conf file manually
### Section 3 - Networking
* 3.1.1 Ensure wireless interfaces are disabled - may cause networking issues, especially in the future
* 3.1.2 Ensure wireless interfaces are disabled - wireless is needed for most workstations
todo some stuff in 3.3 doesn't work
* 3.3.x - for some scripts reboot is required, as running configuration is not automatically updated. Also some of these audits may fail because ufw configuration overrides them.
### Section 4 - Logging and auditing
While logging and auditing is very important, it's also very system and organization specific and does not really help us achieve the goal of hardening the system against attacks in most cases. This should be configured according to needs.
### Section 5 - AAA
* 5.2.4 missing
* 5.2.14 missing
* 5.2.15 missing
* 5.2.17 missing
* 5.2.20 missing
* 5.2.21 missing
* 5.3.x missing
* 5.4.x missing
* 5.4.x missing
* 5.5.1.x missing
* 5.5.2 missing
* 5.5.4 missing
* 5.5.5 missing
### Section 6 - System maintenance
* 6.1.10 missing
* 6.1.11 missing
* 6.1.12 missing
* 6.2.x missing

--------------
## Deprecated stuff
1) `sudo apt-get update`
2) `sudo apt-get install git -y`
3) `git clone https://github.com/katamb/itc8080.git`
4) `cd itc8080`
5) `./autorun.sh`
