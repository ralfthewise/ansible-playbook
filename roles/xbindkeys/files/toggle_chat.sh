#!/bin/bash

CHAT_TITLE='Google Hangouts'

#Get our chat window
CHAT_WIN_ID=$(wmctrl -l | grep "$CHAT_TITLE" | awk '{print $1}')
if [ -z "$CHAT_WIN_ID" ]; then
  #Window doesn't exist, launch it and clean up any old state
  google-chrome --profile-directory=Default --app-id=knipolnnllmklapflnccelgolnpehhpl
  CHAT_WIN_ID=$(wmctrl -l | grep "$CHAT_TITLE" | awk '{print $1}')
  rm -f /tmp/chat_displayed
fi
if [ -z "$CHAT_WIN_ID" ]; then
  echo "Can't locate chat window, exiting"
  exit 1
fi

#Set it to below all others, on all windows, and not show up in task bar
wmctrl -i -r $CHAT_WIN_ID -b add,sticky,skip_taskbar

if [ -e /tmp/chat_displayed ]; then
  #Hide the chat window
  wmctrl -i -r $CHAT_WIN_ID -b add,below

  #Display the previous window
  PREVIOUS_WIN_ID=$(cat /tmp/chat_displayed)
  rm -f /tmp/chat_displayed
  wmctrl -i -a $PREVIOUS_WIN_ID
else
  #Store our active window
  ACTIVE_WIN_ID=$(xprop -root 32x '\t$0' _NET_ACTIVE_WINDOW | cut -f 2)
  echo $ACTIVE_WIN_ID > /tmp/chat_displayed

  #Display the chat window
  wmctrl -i -r $CHAT_WIN_ID -b remove,below
  wmctrl -i -a $CHAT_WIN_ID
fi
