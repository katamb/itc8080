# Hardening Debian 11
Aim is to reduce the attack surface, to be protected against ~80% of attacks.
Scripts are based on: CIS_Debian_Linux_11_Benchmark_v1.0.0.pdf

## Harden Debian 11
1) `sudo apt-get update`
2) `sudo apt-get install git -y`
3) `git clone https://github.com/katamb/itc8080.git`
4) `cd itc8080`
5) `./custom_hardening.sh`

## Documentation
### Section 1
### Section 2 - services
* 2.1 time synchronization - doesn't really help us reduce attack surface
### Section 3 - networking
* 3.1.1 Ensure wireless interfaces are disabled - NOT DISABLING - may cause networking issues, especially in the future
* 3.1.2 Ensure wireless interfaces are disabled - NOT DISABLING - wireless is needed for most workstations

## Deprecated stuff
1) `sudo apt-get update`
2) `sudo apt-get install git -y`
3) `git clone https://github.com/katamb/itc8080.git`
4) `cd itc8080`
5) `./autorun.sh`
