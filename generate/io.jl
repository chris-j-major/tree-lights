using JSON

function load_tree( filename; has_index::Bool = true )
    println("Loading $filename")
    range = has_index ? (2:4) : (1:3)
    function parse_line(line)
        safe_line = replace(line,r"[^0-9.,-]+" => "")
        parts = split(safe_line, ","; limit=4, keepempty=true)[range]
        return map( (x)->parse(Float64,strip(x)) , parts )
    end
    return map( parse_line , eachline(filename) )
end


function generate_light_colors( frame_index , tree , f)
    return map( p->f(frame_index,p) , tree )
end

function color_to_csv( color )::String
    return "$(color[1]),$(color[2]),$(color[3])"
end

function convert_colors_to_line( frame_index , colors )::String
    line = join(map( color_to_csv , colors),",")
    return "$(frame_index-1),$(line)"
end

function header(light_count)
    lights = join([ "R_$i,G_$i,B_$i" for i = 0:(light_count-1)],",")
    return "FRAME_ID,$(lights)"
end

function export_field_function(filename,f,tree,frames)
    open(filename,"w") do io
        println(io,header(length(tree)))
        for frame_index = 1:frames
            colors = generate_light_colors( frame_index , tree , f )
            output_line = convert_colors_to_line( frame_index , colors )
            println(io,output_line)
        end
    end
end

function export_simulation(filename,s,tree,frames)
    sim = s(tree,frames)
    open(filename,"w") do io
        println(io,header(length(tree)))
        for frame_index = 1:frames
            simulation_tick(sim, frame_index , tree)
            colors = simulation_colors( sim , frame_index , tree )
            output_line = convert_colors_to_line( frame_index , colors )
            println(io,output_line)
        end
    end
end

function write_tree_details(details)
    open("input/index.json","w") do io
        println(io,JSON.json(details,2))
    end
end