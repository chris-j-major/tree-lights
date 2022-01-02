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

loaded_images = Dict()
using Images, FileIO

function load_year( year )
    # specify the path to your local image file
    img_path = "./data-download/$year.jpg"
    return load(img_path)
end

function global_temp( frame_index , position )
    if !haskey(loaded_images,frame_index)
        loaded_images[frame_index] = load_year( frame_index + 1885)
    end
    image = loaded_images[frame_index]
    (height,width) = size(image)
    (x,y) = project(position,width,height)
    c = image[y,x]
    return (red(c)*255, green(c)*255, blue(c)*255)
end

to_degrees(x) = 180.0*x/π

function clamp(x,min,max)
    if x > max
        return max
    end
    if x < min
        return min
    end
    return x
end

function project( position , width , height )
    long = atan( position[1],position[2])   # -2π -> 0 -> 2π
    lat = atan( (position[3]-1.0), norm(position[1],position[2]) )  # -π -> 0 -> π 

    lat_adjusted = clamp(lat * 2.0,-2π,2π)
    curve_correction = clamp( 1.0 - abs(lat_adjusted*0.2), 0.5 , 1.0)
    long_adjusted = clamp( long*curve_correction ,-π,π)

    xo = (long_adjusted / 2π + 0.5)
    yo = -lat_adjusted / 2π   + 0.5

    x = 1+convert(Int,round((width*xo+width)%(width-1)))
    y = 1+convert(Int,round((height*yo+height)%(height-1)))

    return (x,y)
end

function build_light_map_image( positions , frame_index)
    if !haskey(loaded_images,frame_index)
        loaded_images[frame_index] = load_year( 20 + 1885)
    end
    image = loaded_images[frame_index]
    (height,width) = size(image)
    for position in positions
        (x,y) = project(position,width,height)
        image[y,x] = RGB24(0)
    end
    save("out.png",image)
end

fields = Dict(
    "sins" => (field_function,100),
    "twist" => (twist_sharp_function,100),
    "twist-smooth" => (twist_smooth_function,100),
    "global-temp" => (global_temp,2020-1885)
)

simulations = Dict(
    "sir" => (create_sir,500)
)

interpolation = Dict(
    "global-temp-slow" => ( "global-temp", 10 ),
    "sir-slow" => ( "sir", 10 )
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

function interpolate( a , b , factor )
    inverse_factor = 1.0 - factor
    return (a .* inverse_factor) .+ (b .* factor)
end

function interpolate_file( output_name , input_name , multiplier )
    open(output_name,"w") do o
        line_index = 0
        values = Dict{Int64,Vector{Int16}}()
        function parse_line(line)
            if line_index == 0
                println(o,line) # header
            else
                safe_line = replace(line,r"[^0-9.,-]+" => "")
                parts = split(safe_line, ","; keepempty=true)
                values[line_index] = map( (x)->parse(Int16,strip(x)) , parts )
            end
            line_index += 1
        end
        foreach( parse_line , eachline(input_name) )
        output_frame = 0
        for x in 1:(line_index-2)
            for y in 1:multiplier
                row = interpolate( values[x] , values[x+1] , y/multiplier)
                row[1] = output_frame # overwrite the frame number, no need to interpolate
                line = join(map( (x) -> string( convert(Int,floor(x))) , row),",")
                println(o,line)
                output_frame += 1
            end
        end
    end
end

for (tree_name,tree_spec) in trees
    local tree = load_tree( tree_spec.file; has_index=tree_spec.has_index)
    for (field_name,(field,length)) in fields
        name="$tree_name-$field_name"
        filename="input/patterns/$name.csv"
        println("Writing field $name")
        export_field_function(filename,field,tree,length)
        add_tree_pattern( tree_name , tree_spec.file , field_name , filename )
    end
    for (sim_name,(sim,length)) in simulations
        name="$tree_name-$sim_name"
        filename="input/patterns/$name.csv"
        println("Writing simulation $name")
        export_simulation(filename,sim,tree,length)
        add_tree_pattern( tree_name , tree_spec.file , sim_name , filename )
    end
    for (name,(original,multiplier)) in interpolation
        name="$tree_name-$name"
        filename="input/patterns/$name.csv"
        println("Interpolation $name")
        interpolate_file( filename , tree_details[tree_name].patterns[original] , multiplier )
        add_tree_pattern( tree_name , tree_spec.file , name , filename )

    end
end

write_tree_details(tree_details);

# build_light_map_image( load_tree("input/trees/coords_2021.csv"; has_index=false) , 50)
