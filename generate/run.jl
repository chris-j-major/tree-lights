include("io.jl")

function field_function( frame_index , position )
    return (255,0,0)
end

tree = load_tree("input/trees/pcam_coords.csv")

export_field_function("field",field_function,tree,100)