#!/bin/bash

echo "---"
echo "1.3.1 Ensure AIDE is installed"
needs_init=false
if [ "$(dpkg-query -W -f='${db:Status-Status}' aide 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "AIDE is not installed, remediating\n"
  apt install aide -y
  needs_init=true
else
  echo -e "AIDE is installed\n"
fi
if [ "$(dpkg-query -W -f='${db:Status-Status}' aide-common 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "AIDE-common is not installed, remediating\n"
  apt install aide-common -y
  needs_init=true
else
  echo -e "AIDE-common is installed\n"
fi
if [ "$needs_init" == true ]; then
  aideinit
  mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
fi
echo -e "---\n"

echo "---"
echo "1.3.2 Ensure filesystem integrity is regularly checked"
needs_init=false
if [ "$(grep -Prs '^([^#\n\r]+\h+)?(\/usr\/s?bin\/|^\h*)aide(\.wrapper)?\h+(--check|([^#\n\r]+\h+)?\$AIDEARGS)\b' /etc/cron.* /etc/crontab /var/spool/cron/ | wc -l)" -gt 0 ]; then
  echo -e "AIDE runs regularly\n"
else
  echo -e "AIDE cronjob missing, remediating\n"
  #crontab -u root -e
  crontab -l > mycron
  echo "0 5 * * * /usr/bin/aide.wrapper --config /etc/aide/aide.conf --check" >> mycron
  crontab mycron
  rm mycron
fi
echo -e "---\n"
