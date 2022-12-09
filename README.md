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
* 1.8.x - would be reasonable to implement most of these, however the script would depend on the desktop environment. From personal experience, xorg might be a better way to go, as it seems to be less resource hungry.
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
### Section 5 - Access, Authentication, Authorization
* 5.2.14 - Strong MAC algorithms come by default with Debian 11. SSH gives a warning when a weak MAC is used.
* 5.2.15 - Strong Key Exchange alorithms come by default with Debian 11.
* 5.2.17 - Banner configuration does not give any extra protection measures. Organizations that legally require to have a banner, usually have a customized version of it (e.g. with the name of the company)
* 5.2.20 - Max session timeout can cause problems for servers with high automated/script usage. This setting should be configured manually as to not interfere with main business processes.
* 5.3.1  - Sudo comes by default
* 5.4.2  - Account lockout mechanisms need to be used carefully. Malicious actors can abuse this setting and interefere with users authentication attempts. 
* 5.4.4  - Strong password hashing algorithms are used by default by Debain 11
* 5.5.1.x - Password changes and password expiry settings are very organizational specific (e.g. for servers with numerous scripted SSH connections).
* 5.5.2 - Any suspicious accounts identified should undergo a more thorough analysis and investigation. Just disabling them might not be a sufficient containment strategy.
* 5.5.4 - Usermask configuration could break the functionality of scripts, should be done manually instead.
* 5.5.5 - Shell timeout needs to be set in accordance with organizational requirements.
### Section 6 - System maintenance
* 6.1.10 - Unowned files/directories do not pose any direct threats, and critical/important files can be left after a certain user is deleted. Unowned files should be manually reviewed.
* 6.1.11 - Ungroped files/directories do not pose any direct threats, and critical/important files can be left after a certain user is deleted. Ungrouped files should be manually reviewed
* 6.1.12 - SUID executables pose a serious privilege escalation threat, and should be treated carefully. Any unknown SUID files and related activity need to undergo a thorough manual analysis.
* 6.2.3 - Inconsistency with Groups should be analyzed manually to eradicate any possibilities of malicious exploitation.  


--------------
## Deprecated stuff
1) `sudo apt-get update`
2) `sudo apt-get install git -y`
3) `git clone https://github.com/katamb/itc8080.git`
4) `cd itc8080`
5) `./autorun.sh`
