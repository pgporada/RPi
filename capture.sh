#!/bin/bash
# By no means done, but works just fine for what I need it to do.
# Author - Phil Porada

# Thanks to http://tobrunet.ch/2013/01/follow-up-bash-script-locking-with-flock/
lock() {
  PID="/tmp/.$(basename $0)"
  # Locking to prevent multiple running instances of the same basename, RPI only has so much processor to go around
  exec 200>${PID}
  flock -n 200 || exit 1
  pid=$$
  echo $pid 1>&200
}


run() {
  # Debug stuff when you don't want to run it in the background
  FAIL="[$(tput setaf 1) FAIL $(tput sgr0)]"
  PASS="[$(tput setaf 2) PASS $(tput sgr0)]"
  INFO="[$(tput setaf 3) INFO $(tput sgr0)]"

  # Set working dir
  cd /opt/storage/
  echo -e "${PASS} Locked - ${PID}"
  echo -e "${PASS} $(basename $0) started"
  
  # Main script
  while true
  do
      # Set here because TODAY will eventually change, this thing is meant to keep running for days
      IMAGE=$(date +"%Y%m%d.%H%M%S").jpg
      TODAY=$(date +%Y_%m_%d)
   
      # Stop the script if the webcam is no longer plugged in
      if [ -e "/dev/video0" ] ; then
          fswebcam -c ".fswebcam.conf" "${TODAY}/big/big_${IMAGE}" > /dev/null 2>&1
      else
          echo -e "${FAIL} device located at /dev/vide0 not accessible"
          exit 3
      fi

      # Convert or complain
      if [ -e "${TODAY}/big/big_${IMAGE}" ] ; then
         convert ${TODAY}/big/big_${IMAGE} -resize 20% ${TODAY}/thumbnails/thumb_${IMAGE}
         echo -e "${INFO} Processed ${IMAGE}"
      else
         echo -e "${FAIL} Failed to proess ${IMAGE}"
      fi

      # Takes a picture every 6-7 seconds, it's possible to overheat your RPi if you leave this running for hours at a time.
      # If you added heatsinks, remember that you still need flowing air to remove the heat from the heatsinks.
      # You can check the RPi temperature with this command `/opt/vc/bin/vcgencmd measure_temp`
      sleep 2
  done
}

# Run the functions defined above. Makes sure locking is successful before continuing to run.
lock && run
