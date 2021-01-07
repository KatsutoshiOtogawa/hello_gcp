#!/bin/bash

# doesnt update grub
echo grub-pc hold | dpkg --set-selections
apt update && apt upgrade -y

apt -y install nginx