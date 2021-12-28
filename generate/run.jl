include("io.jl")

function color(r,g,b)
    return ( convert(UInt8, floor(r)), convert(UInt8, floor(g)) ,convert(UInt8, floor(b)))
end

function field_function( frame_index , position )
    r = (sin(frame_index*0.1+position[1]*4.0)+1)*128
    g = (sin(frame_index*0.1+position[2]*4.0)+1)*128
    b = (sin(frame_index*0.1+position[3]*4.0)+1)*128
    return color(r,g,b)
end

function twist_sharp_function( frame_index , position )
    height_theta = position[3] * frame_index * 0.1
    light_theta = atan(position[1],position[2])
    theta = height_theta + light_theta
    if cos(theta) > 0.0 
        return color(255,0,0)
    else
        return color(0,255,0)
    end
end

function linear_rainbow( v )
    r = (sin(v+1)+1)*128
    g = (sin(v+2)+1)*128
    b = (sin(v)+1)*128
    return color(r,g,b)
end

function twist_smooth_function( frame_index , position )
    height_theta = position[3] * frame_index * 0.1
    light_theta = atan(position[1],position[2])
    theta = height_theta + light_theta
    return linear_rainbow(theta)
end

fields = Dict(
    "sins" => field_function,
    "twist" => twist_sharp_function,
    "twist-smooth" => twist_smooth_function,
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