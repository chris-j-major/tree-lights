include("io.jl")

function field_function( frame_index , position )
    r = (sin(frame_index*0.1+position[1]*4.0)+1)*128
    g = (sin(frame_index*0.1+position[2]*4.0)+1)*128
    b = (sin(frame_index*0.1+position[3]*4.0)+1)*128
    return ( convert(UInt8, floor(r)), convert(UInt8, floor(g)) ,convert(UInt8, floor(b)))
end

tree = load_tree("input/trees/pcam_coords.csv")

export_field_function("field",field_function,tree,100)