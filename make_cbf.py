import cbf
import sys

if len(sys.argv) != 4:
    print("make_cbf.exe: Make a cbf-wrapped leapfrog file.")
    print("Syntax: make_cbf.exe <mem> <inpath> <outpath>")
    print("Mem options: low/high/superhigh")
    sys.exit(1)

cbf.create(mem=sys.argv[1], opath=sys.argv[3], ipath=sys.argv[2])
