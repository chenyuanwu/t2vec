using JSON
using Serialization
include("utils.jl")


datapath = "../data"

param = JSON.parsefile("../hyper-parameters.json")
regionps = param["region"]
cityname = regionps["cityname"]
cellsize = regionps["cellsize"]

region = SpatialRegion(cityname,
                       regionps["minlon"], regionps["minlat"],
                       regionps["maxlon"], regionps["maxlat"],
                       cellsize, cellsize,
                       regionps["minfreq"], # minfreq
                       40_000, # maxvocab_size
                       10, # k
                       4)

println("Building spatial region with:
        cityname=$(region.name),
        minlon=$(region.minlon),
        minlat=$(region.minlat),
        maxlon=$(region.maxlon),
        maxlat=$(region.maxlat),
        xstep=$(region.xstep),
        ystep=$(region.ystep),
        minfreq=$(region.minfreq)")

paramfile = "$datapath/$(region.name)-param-cell$(Int(cellsize))"
if isfile(paramfile)
    println("Reading parameter file from $paramfile")
    region = deserialize(paramfile)
    println("Loaded $paramfile into region")
else
    println("Cannot find $paramfile")
end

## Creating test files for TSNE.
start = 1_000_000+20_000
length = 100
variance = 1
do_split = false
tfile = joinpath(datapath, "len$length-var$variance-trj.t")
labelfile = joinpath(datapath, "len$length-var$variance-trj.label")

createTLabel(region, "$datapath/$cityname.h5", downsamplingDistort, start, length; do_split=do_split, tfile=tfile, labelfile=labelfile)

## Creating test files for similarity computation.
# prefix = "exp1"
# do_split = true
# start = 1_000_000+20_000
# num_query = 1000
# num_db = 100_000
# querydbfile = joinpath(datapath, "$prefix-querydb.h5")
# tfile = joinpath(datapath, "$prefix-trj.t")
# labelfile = joinpath(datapath, "$prefix-trj.label")
# vecfile = joinpath(datapath, "$prefix-trj.h5")

# createQueryDB("$datapath/$cityname.h5", start, num_query, num_db,
#               (x, y)->(x, y),
#               (x, y)->(x, y);
#               do_split=do_split,
#               querydbfile=querydbfile)
# createTLabel(region, querydbfile; tfile=tfile, labelfile=labelfile)
