#!/usr/bin/env python
# simple show tech support parser
from os import mkdir
from sys import exit
from re import compile, findall, split


def makeDir(*args):
    newDataDir = input(
        "what is the full path to where you would like the files to be placed?: "
    )
    mkdir(newDataDir + args[0])
    return newDataDir + args[0]


def nameDirectory():
    newDirectory = input("what is the name of this device?: ")
    return newDirectory


def nameShowTech():
    newShowTech = input("what is the full path to the show tech file?: ")
    return newShowTech


def openTechFile(*args):
    with open(args[0], "r") as f:
        data = f.read()
    regex = compile("`.*`")
    keys = findall(regex, data)
    values = split(regex, data)
    values.pop(0)
    return dict(zip(keys, values))


def segmentData(*args):
    for k, v in args[1].items():
        cmd = k[1:-1]
        fname = args[0] + "/" + cmd.replace(" ", "_") + ".md"
        title = "# %s" % cmd
        body = title + "\n\n---\n\n```" + v + "\n```\n"
        writeFiles(fname, body)


def writeFiles(*args):
    with open(args[0], "w") as f:
        f.write(args[1])


if __name__ == "__main__":
    directory = nameDirectory()
    showTech = nameShowTech()
    data = openTechFile(showTech)
    finalOutput = makeDir(directory)
    segmentData(finalOutput, data)
    exit(0)
