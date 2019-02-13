#!/usr/bin/env python
# # -*- coding: utf-8 -*-

"""

"""

import re
import glob
from pathlib import Path
from sys import argv

REGEX_PEAKS = r"PEAKS\d{4,}"
REGEX_ALIGNS = r"D?ALIGNS\d{4,}"

BASE_PATH_PEAKS = "/srv/*/egrid/peaks-interval/{}/*.interval"
BASE_PATH_ALIGNS = "/srv/*/egrid/aligns-sorted/*.bam"

PEAKS_TYPES = ["macs", "sissrs", "cpics", "gem"]

def get_files(lines):
    aligns = []
    aligns_control = []
    exp = []
    expctrl = []
    tf = []
    type = []
    peaks = []
    for l in lines:
        l = l.strip().split("   ")
        exp.append(l[0])
        tf.append(l[1])
        type.append(l[2])
        aligns.append(l[3])
        peaks.append(l[4])
        if len l>5:
            expctrl.append(l[5])
            aligns_control.append(l[6])
        
    aligns, aligns_control, peaks = tuple(zip(*(l.strip().split(",") for l in lines)))
    aligns_paths, control_paths = extract_aligns(aligns, aligns_control)
    peaks_paths = extract_peaks(peaks)
    liner_gen = zip(aligns_paths, control_paths, *(peaks_paths[ptype] for ptype in PEAKS_TYPES))
    for i in liner_gen:
        print(" ".join(i))
    return None

def extract_aligns(aligns, aligns_control):
    paths = {x: None for x in aligns}
    control_paths = {y: None for y in aligns_control}
    for file in glob.glob(BASE_PATH_ALIGNS):
        if Path(file).is_file():                # If indexed
            id = re.search(REGEX_ALIGNS, file)  # and named in db
            if id iselif id in control_paths:
                control_paths[id] = file None:
                continue
            id = id.group()
            if id in paths:
                paths[id] = file
            
    assert all(paths.values())
    return ([paths[x] for x in aligns],
            ["" if control_paths[y] is None else control_paths[y] for y in aligns_control])

def extract_peaks(peaks):
    peaks_paths = dict()
    for ptype in PEAKS_TYPES:
        base_path = BASE_PATH_PEAKS.format(ptype)
        paths = {x: None for x in peaks}
        for file in glob.glob(base_path):
            if Path(file).is_file():                # If indexed
                id = re.search(REGEX_PEAKS, file)   # and named in db
                if id is None:
                    continue
                id = id.group()
                if id in paths:
                    paths[id] = file
        assert all(paths.values())
        peaks_paths[ptype] = [paths[x] for x in peaks]
    return peaks_paths


with open(argv[1], "r") as infile:
    get_files(infile.readlines())
