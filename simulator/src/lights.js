class Lights {
    constructor(element){
        this.el = element;
        this.g = {
            lights:element.append("g").attr("class", "lights")
        };
        this.lights = [];
        this.pattern = [[]];
        this.frame = 0;
        this.frames = 1;
        this.scale = 240;
        this.rotate = 0.1;
        this.rotate_speed = 0.1;
        this.x_offset = 0;
        this.y_offset = 150;
    }

    lightPositions(data){
        console.log("Light positions loaded");
        this.lights = data;
        this.update( { positions:true , colors:true });
    }

    lightPattern(data){
        console.log("Light pattern loaded");
        this.pattern = data.map( (row)=>{
            const colors = [];
            let i = 0;
            while( row["R_"+i] ){
                const c = "rgb("+row["R_"+i]+","+row["G_"+i]+","+row["B_"+i]+")";
                colors[i] = c;
                i++;
            }
            return colors;
        });
        this.frames = this.pattern.length;
        this.frame = 0;
        this.update( { positions:false, colors:true, slider:true });
    }

    xCoord(d){
        return this.x_offset + (d[0]*Math.sin(this.rotate) + d[1]*Math.cos(this.rotate)) * this.scale
    }
    yCoord(d){
        return this.y_offset + (d[0]*Math.cos(this.rotate) - d[1]*Math.sin(this.rotate)) * 0.4 * this.scale
            + -1 * d[2] * this.scale;
    }

    update( parts ){
        const l = this;
        if ( parts.slider ){
            if (this.frame_slider ){
                this.frame_slider.max = l.frames -1;
                this.frame_slider.value = l.frame;
            }
            if (this.rotate_slider ){
                this.rotate_slider.max = Math.PI*2;
                this.rotate_slider.value = (l.rotate)%(Math.PI*2);
            }
        }
        if ( parts.positions ){
            function setPositions(e){
                e.attr("cx",(d)=>l.xCoord(d))
                 .attr("cy",(d)=>l.yCoord(d))
                 .attr("r",1);
            }
            this.g.lights.selectAll("circle")
                .data(this.lights)
                .join( 
                    (enter)=>{
                        enter.append("circle");
                    }, 
                    (update)=>{
                    }, 
                    (exit)=>{
                        exit.remove();
                    }
                );
            this.all_lights = this.g.lights.selectAll("circle").call(setPositions);
        }
        if ( parts.colors ){
            function setColor(el){
                el.attr("fill",(_,i)=>l.pattern[l.frame][i])
            }
            this.all_lights.call(setColor);
        }
    }

    play(){
        const l = this;
        if ( !this.timer ){
            this.timer = window.setInterval(()=>{
                l.rotate += l.rotate_speed;
                l.frame  = (l.frame+1) % l.frames;
                l.update( { positions:true , colors:true , slider:true });
            }, 100);
        }
    }

    stop(){
        if ( this.timer ){
            window.clearInterval(this.timer);
        }
        this.timer = null;
    }

    attachFrameSlider(element){
        this.frame_slider = element;
        element.oninput = ()=>{
            this.frame = parseInt(this.frame_slider.value);
            this.update( { positions:false , colors:true , slider:false });
        }
    }

    attachRotateSlider(element){
        this.rotate_slider = element;
        element.oninput = ()=>{
            this.rotate = parseFloat(this.rotate_slider.value);
            this.update( { positions:true , colors:false , slider:false });
        }
    }

    resized(){

    }
}