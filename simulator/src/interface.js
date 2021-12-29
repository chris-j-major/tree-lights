class Interface{
    constructor(element,data,display){
        this.data = {};
        this.display = display;
        this.element = d3.select(element);

        this.tree = this.element.append("select");
        this.tree.on("change",()=>{
            this.selectTree( this.tree.node().value );
        });
        this.pattern = this.element.append("select");
        this.pattern.on("change",()=>{
            this.selectPattern( this.pattern.node().value );
        });

        d3.json(data).then( (data)=>{
            this.data = data;
            this.populateTrees();
            this.selectTree( Object.keys(data)[0] ); // pick the first tree
        });
    }

    selectTree( treeName ){
        this.treeName = treeName;
        this.treeDetails = this.data[treeName];
        console.log("Loading tree "+treeName);

        this.populatePatterns();
        d3.text("../"+this.treeDetails.file).then((text)=>{
            // This is because the light positions don't have a header row
            const data = d3.csvParseRows(text).map((row)=>{
                //row.splice(0,1)
                return row.map( value => +value )
            })
            console.log("Loaded tree "+treeName);
            this.display.lightPositions(data); 
        });
    }

    populateTrees(){
        const treelist = Object.keys(this.data)
        this.tree.selectAll("option").data(treelist).join( (enter)=>enter.append("option") , (update)=>{} , (remove)=>remove.remove() );
        this.tree.selectAll("option").text( (d)=>d )
    }

    populatePatterns(){
        const patternList = Object.keys(this.treeDetails.patterns)
        this.pattern.selectAll("option").data(patternList).join( (enter)=>enter.append("option") , (update)=>{} , (remove)=>remove.remove() );
        this.pattern.selectAll("option").text( (d)=>d )
    }

    selectPattern( pattern ){
        this.patternDetails = this.treeDetails.patterns[pattern];
        console.log("Loading pattern "+this.patternDetails)
        d3.csv("../"+this.patternDetails).then( (data)=>{
            console.log("Loaded pattern "+this.patternDetails)
            display.lightPattern(data);
        });
    }
}