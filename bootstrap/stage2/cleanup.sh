#!/bin/bash



find /usr/{lib,libexec} -name \*.la -delet

rm -rf /usr/share/{info,man,doc}