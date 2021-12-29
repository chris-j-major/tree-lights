
struct SirLightState
    current::Int32
end

struct SirState
    states::Vector{SirLightState}
    edges::Vector{Vector{Int16}}
end


function create_sir(tree,frames)::SirState
    initial = [ SirLightState(0) for pos in tree]
    edges = [ Vector{Int16}() for pos in tree]
    return SirState( initial , edges )
end

function simulation_tick(state::SirState,frame_index,tree)
end

function simulation_colors(state::SirState,frame_index,tree)
    return [ color(0,0,0) for p in tree]
end