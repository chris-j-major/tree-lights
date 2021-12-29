include("io.jl")

function color(r,g,b)
    return ( convert(UInt8, floor(r)), convert(UInt8, floor(g)) ,convert(UInt8, floor(b)))
end

include("sims/sir.jl")

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

simulations = Dict(
    "sir" => create_sir
)

trees = Dict(
    "pcam" => (file="input/trees/pcam_coords.csv",has_index=true),
    "matt" => (file="input/trees/coords_2021.csv",has_index=false)
)

struct VisualTree
    file::String
    patterns::Dict{String,String}
end

tree_details = Dict{String,VisualTree}()

function add_tree_pattern( tree_name , tree_file , pattern_name , file_name )
    if !haskey(tree_details,tree_name)
        tree_details[tree_name] = VisualTree( tree_file , Dict{String,String}() )
    end
    tree_details[tree_name].patterns[pattern_name] = file_name
end

for (tree_name,tree_spec) in trees
    local tree = load_tree( tree_spec.file; has_index=tree_spec.has_index)
    for (field_name,field) in fields
        name="$tree_name-$field_name"
        filename="input/patterns/$name.csv"
        println("Writing field $name")
        export_field_function(filename,field,tree,100)
        add_tree_pattern( tree_name , tree_spec.file , field_name , filename )
    end
    for (sim_name,sim) in simulations
        name="$tree_name-$sim_name"
        filename="input/patterns/$name.csv"
        println("Writing simulation $name")
        export_simulation(filename,sim,tree,100)
        add_tree_pattern( tree_name , tree_spec.file , sim_name , filename )
    end
end

println(tree_details)