#!/bin/bash

echo "---"
echo "1.1.9 Disable Automounting"
if [[ "$(systemctl is-enabled autofs 2>&1)" != "enabled" ]]; then
  echo -e "Automounting disabled\n"
else
  echo -e "Automounting not disabled, disabling\n"

  echo "Remediating"
  systemctl stop autofs
  systemctl mask autofs
fi
echo -e "---\n"
