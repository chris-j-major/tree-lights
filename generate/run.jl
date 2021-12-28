include("io.jl")

tree = load_tree("input/trees/pcam_coords.csv")

function field_function( frame_index , position )
    return (255,0,0)
end

function generate_light_colors( frame_index )
    return map( p->field_function(frame_index,p) , tree )
end

function color_to_csv( color )
    return "$(color[1]),$(color[2]),$(color[3])"
end

function convert_colors_to_line( frame_index , colors )
    line = join(map( color_to_csv , colors),",")
    return "$(frame_index-1),$(line)"
end

function header(light_count)
    lights = join([ "R_$i,G_$i,B_$i" for i = 0:(light_count-1)],",")
    return "FRAME_ID,$(lights)"
end

open("input/patterns/field.csv","w") do io
    println(io,header(length(tree)))
    for frame_index = 1:100
        colors = generate_light_colors( frame_index )
        output_line = convert_colors_to_line( frame_index , colors )
        println(io,output_line)
    end
end