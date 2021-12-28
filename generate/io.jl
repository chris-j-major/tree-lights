function load_tree( filename; has_index::Bool = true )
    lines = readlines(filename) 
    range = has_index ? (2:4) : (1:3)
    function parse_line(line)
        parts = split(line, ","; limit=4, keepempty=true)[range]
        return map( (x)->parse(Float64,x) , parts )
    end
    return map( parse_line , lines)
end