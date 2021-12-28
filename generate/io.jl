function load_tree( filename; has_index::Bool = true )
    lines = readlines(filename) 
    range = has_index ? (2:4) : (1:3)
    function parse_line(line)
        parts = split(line, ","; limit=4, keepempty=true)[range]
        return map( (x)->parse(Float64,x) , parts )
    end
    return map( parse_line , lines)
end


function generate_light_colors( frame_index , tree , f)
    return map( p->f(frame_index,p) , tree )
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

function export_field_function(filename,f,tree,frames)
    open("input/patterns/$filename.csv","w") do io
        println(io,header(length(tree)))
        for frame_index = 1:frames
            colors = generate_light_colors( frame_index , tree , f )
            output_line = convert_colors_to_line( frame_index , colors )
            println(io,output_line)
        end
    end
end
