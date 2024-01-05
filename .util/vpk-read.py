#!/usr/bin/env python3
import vpk # sudo pip3 install vpk
import os
import sys
import random

# Made for linux
if os.name == 'nt':
    print('This script is made for linux.')
    print('Windows version maybe at some point lol.')
    exit()

if len(sys.argv) < 2:
    # Exit if file path isn't given
    exit()
if not os.path.isfile(sys.argv[1]):
    # Exit if it isn't a file path
    exit()
if not sys.argv[1].endswith('.vpk'):
    # Exit if it isn't a VPK file
    exit()

def mktree(path):
    path = os.path.split(path)[0]
    if not path: return
    os.makedirs(path, exist_ok = True)

def savefile(file, path):
    mktree(path)
    file.save(path)

tmp_num = random.randint(0, 2147483647)
tmp_path = '/tmp/vpk-tmp' + str(tmp_num)
pak = vpk.open(os.getcwd() + '/' + sys.argv[1])
os.makedirs(tmp_path, exist_ok = True)
for filepath in pak:
    print(filepath)
    file = pak[filepath]
    savefile(file, tmp_path + '/' + filepath)
os.system('dolphin ' + tmp_path)
