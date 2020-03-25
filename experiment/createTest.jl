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


prefix = "exp1"
do_split = true
start = 1_000_000+20_000
num_query = 1000
num_db = 100_000
querydbfile = joinpath(datapath, "$prefix-querydb.h5")
tfile = joinpath(datapath, "$prefix-trj.t")
labelfile = joinpath(datapath, "$prefix-trj.label")
#vecfile = joinpath(datapath, "$prefix-trj.h5")

createQueryDB("$datapath/$cityname.h5", start, num_query, num_db,
              (x, y)->(x, y),
              (x, y)->(x, y);
              do_split=do_split,
              querydbfile=querydbfile)
createTLabel(region, querydbfile; tfile=tfile, labelfile=labelfile)
