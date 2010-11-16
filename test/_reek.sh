#!/usr/bin/env bash -l

# WARNING: MAKES ASSUMPTIONS BASED ON BEING INVOKED BY THE RAKEFILE

# if this breaks, its probably because you need to install reek on 1.8.7@ruby1.8.7-activerecord2.3.5
rvm use 1.8.7@ruby1.8.7-activerecord2.3.5

reek lib
