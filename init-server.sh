#!/bin/bash

function installServer() {
  FEXBash './steamcmd.sh +@sSteamCmdForcePlatformBitness 64 +force_install_dir "/config" +login anonymous +app_update 1690800 -beta experimental validate +quit'
}

function main() {
  # Check if we have proper read/write permissions to /satisfactory
  if [ ! -r "/config" ] || [ ! -w "/config" ]; then
    echo 'ERROR: I do not have read/write permissions to /config! Please run "chown -R 1000:1000 config/" on host machine, then try again.'
    exit 1
  fi

  # Check for SteamCMD updates
  echo 'Checking for SteamCMD updates...'
  FEXBash './steamcmd.sh +quit'

  # Check if the server is installed
  if [ ! -f "/config/FactoryServer.sh" ]; then
    echo 'Server not found! Installing...'
    installServer
  fi
  # If auto updates are enabled, try updating
  if [ "$ALWAYS_UPDATE_ON_START" == "true" ]; then
    echo 'Checking for updates...'
    installServer
  fi

  # Fix for steamclient.so not being found
  mkdir -p /home/steam/.steam/sdk64
  ln -s /home/steam/Steam/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so

  echo 'Starting server...'

  # Go to /satisfactory
  cd /config

  # Start server
  FEXBash "./FactoryServer.sh $EXTRA_PARAMS"
}
sleep 300
main
