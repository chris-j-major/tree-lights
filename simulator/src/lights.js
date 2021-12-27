class Lights {
    constructor(element){
        this.el = element;
        this.g = {
            lights:element.append("g").attr("class", "lights")
        };
        this.lights = [];
        this.pattern = [[]];
        this.frame = 0;
        this.scale = 40;
        this.rotate = 0.1;
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
        this.frame = 0;
        this.update( { positions:false , colors:true });
    }

    xCoord(d){
        return (d[0]*Math.sin(this.rotate) + d[1]*Math.cos(this.rotate)) * this.scale
    }
    yCoord(d){
        return (d[0]*Math.cos(this.rotate) + d[1]*Math.sin(this.rotate)) * 0.1 * this.scale
            + -1 * d[2] * this.scale;
    }

    update( parts ){
        const l = this;
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

    resized(){

    }
}