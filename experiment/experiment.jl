using HDF5
using DelimitedFiles
using Distances
include("utils.jl")

datapath = "../data"

## create querydb
prefix = "exp1"
do_split = true
start = 1_000_000+20_000
num_query = 1000
num_db = 100_000
labelfile = joinpath(datapath, "$prefix-trj.label")
vecfile = joinpath(datapath, "$prefix-trj.h5")

## load vectors and labels
vecs = h5open(vecfile, "r") do f
    read(f["layer3"])
end
label = readdlm(labelfile, Int)

query, db = vecs[:, 1:num_query], vecs[:, num_query+1:end]
queryLabel, dbLabel = label[1:num_query], label[num_query+1:end]
query, db = [query[:, i] for i in 1:size(query, 2)], [db[:, i] for i in 1:size(db, 2)];

dbsizes = [20_000, 40_000, 60_000, 80_000, 100_000]
for dbsize in dbsizes
    ranks = ranksearch(query, queryLabel, db[1:dbsize], dbLabel[1:dbsize], euclidean)
    println("mean rank: $(mean(ranks)) with dbsize: $dbsize")
end

