using LinearAlgebra

mutable struct SirLightState
    current::Int32 # Controls the state: 0 suseptiable, 1-10 infectious, 11+ recovered
end

struct SirState
    states::Vector{SirLightState}
    edges::Vector{Vector{Tuple{Int16,Float64}}}
end


function create_sir(tree,frames)::SirState
    initial = [ SirLightState(0) for pos in tree]
    initial[40].current = 1
    edges = [ Vector{Tuple{Int16,Float64}}() for pos in tree]
    for i in 1:length(tree), j in 1:length(tree)
        pi = tree[i]
        pj = tree[j]
        d = norm(pi .- pj)
        if ( d < 0.4 )
            t = (j,0.9+0.1*(d/0.4))
            push!(edges[i] , t)
        end
    end
    return SirState( initial , edges )
end

function simulation_tick(state::SirState,frame_index,tree)
    for i in 1:length(state.states)
        s = state.states[i]
        if 0 < s.current < 30
            s.current += 1
            e = state.edges[i]
            # See if we ca infect something
            for (j,prob) in e
                if state.states[j].current == 0 && rand() > prob
                    state.states[j].current = 1
                end
            end
        end
    end
end

function state_color( s::SirLightState )
    if s.current == 0
        return [0,0,128]
    elseif s.current < 30
        n = (255.0/30.0)*s.current
        return [n,n,n]
    else
        return [0,128,10]
    end
end

function simulation_colors(state::SirState,frame_index,tree)
    return [ state_color(s) for s in state.states]
end