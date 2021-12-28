include("io.jl")

function field_function( frame_index , position )
    r = (sin(frame_index*0.1+position[1]*4.0)+1)*128
    g = (sin(frame_index*0.1+position[2]*4.0)+1)*128
    b = (sin(frame_index*0.1+position[3]*4.0)+1)*128
    return ( convert(UInt8, floor(r)), convert(UInt8, floor(g)) ,convert(UInt8, floor(b)))
end

fields = Dict(
    "sins" => field_function
)

trees = Dict(
    "pcam" => load_tree("input/trees/pcam_coords.csv"),
    "matt" => load_tree("input/trees/coords_2021.csv";has_index=false)
)

for (tree_name,tree) in trees, (field_name,field) in fields
    name="$tree_name-$field_name"
    println("Writing $name")
    export_field_function(name,field,tree,100)
end