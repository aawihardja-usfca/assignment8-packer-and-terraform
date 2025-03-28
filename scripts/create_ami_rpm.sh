#!/bin/bash

sudo dnf update -y
sudo dnf install -y docker

sudo usermod -aG docker ec2-user