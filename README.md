# Hardening Debian 11
Aim is to reduce the attack surface, to be protected against ~88% of attacks.
Scripts are based on: CIS_Debian_Linux_11_Benchmark_v1.0.0.pdf (https://www.cisecurity.org/).

The scripts are aimed to keep the basic functionality needed for a workstation while greatly reducing the attack surface.

## Harden Debian 11
1) `sudo apt-get update`
2) `sudo apt-get install git -y`
3) `git clone https://github.com/katamb/itc8080.git`
4) `cd itc8080`
5) `./custom_hardening.sh`

## Documentation
### Section 1 - Initial setup
Work in progress
### Section 2 - Services
* 2.1 time synchronization - doesn't really help us reduce attack surface
* 2.2.15 Ensure mail transfer agent is configured for local-only mode - NOT DISABLING - requires modifying conf file manually
### Section 3 - Networking
* 3.1.1 Ensure wireless interfaces are disabled - NOT DISABLING - may cause networking issues, especially in the future
* 3.1.2 Ensure wireless interfaces are disabled - NOT DISABLING - wireless is needed for most workstations
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
