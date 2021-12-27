class Autosize{
    constructor(id){
        this.el = d3.select(id);
        window.addEventListener('resize', (event)=>{ this.resized(event) });
        this.resized(null)
    }

    resized(event){
        const width = window.innerWidth;
        const height = window.innerHeight;
        this.el
            .attr("width",width)
            .attr("height",height)
            .attr("viewBox",[-width/2,-height/2,width,height].join(" "))
    }
}