include("io.jl")

tree = load_tree("input/trees/pcam_coords.csv")

function field_function( frame_index , position )
    return (255,0,0)
end

for frame_index = 1:100
    println("Processing $frame_index")
    colors = map( p->field_function(frame_index,p) , tree )
    println(colors)
end