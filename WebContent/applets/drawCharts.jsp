<%@ page import="java.io.File"%>
<%@ page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import ="org.neo4j.graphdb.Direction" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.RelationshipType" %>
<%@ page import ="org.neo4j.graphdb.DynamicRelationshipType" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="graphDB.explore.*" %>
<%@ page import="javax.servlet.jsp.JspWriter"%>
<%!

/* store the data in a Ext.data.JsonStore:
window.store1 = Ext.create('Ext.data.JsonStore', {
	fields: ['name', 'data1'],
	data: [{name: 1, data1:2},
			{name: 2, data1:14},
				{name: 3, data1:56},
			{name: 4, data1:8},]
});
*/
public void CreateJsonStore(String jsonData, int graphNumber, JspWriter out){
	try{
		out.println("window.store"+graphNumber+"= Ext.create('Ext.data.JsonStore', "+
		    jsonData+");");
	}catch (IOException e) 	{
		e.printStackTrace();
	}
}

public void CreateExtJsChart(String chartName, String storeName, String title, JspWriter out, 
		String AxeY, String xfield, String yfield, String maxYaxis) {
	try {
	out.println("var "+chartName+"= Ext.create('Ext.chart.Chart', {"+
        "style: 'background:#fff',\n"+
        "animate: true,\n"+
        "shadow: true,\n"+
        "store: "+storeName+",\n"+
        "axes: [{\n"+
            "type: 'Numeric',\n"+
            "position: 'left',\n"+
            "fields: "+yfield+",\n"+
            "label: {\n"+
            "    renderer: Ext.util.Format.numberRenderer('0,0')\n"+
            "},\n"+
            "title: '" + AxeY + "',\n"+
            "minimum: 0\n,"+
            "maximum: "+maxYaxis+",\n"+
            "adjustMaximumByMajorUnit : true \n"+
        "}, {\n"+
            "type: 'Category',\n"+
            "position: 'bottom',\n"+
            "fields: "+xfield+",\n"+
            "title: '"+title+"'\n"+
        "}],\n"+
        "series: [{\n"+
            "type: 'column',\n"+
            "axis: 'left',\n"+
            "gutter:0,\n"+
            "stacked: true,"+
            "highlight: true,\n"+
            "tips: {\n"+
              "trackMouse: true,\n"+
              "width:140,"+
              "renderer: function(storeItem, item) {\n"+
                   "this.setTitle('Decoy/(Target+Decoy): \\n'+storeItem.get('ratio'));\n"+ 
                		   //+ ': ' + item.value[1]);\n"+
              "}\n"+
            "},\n"+
            "label: {\n"+
              "display: 'insideEnd',\n"+
              "'text-anchor': 'middle',\n"+
                "field: "+yfield+",\n"+
                "contrast: true,\n"+
                "renderer: Ext.util.Format.numberRenderer('0'),\n"+
                "orientation: 'vertical',\n"+
                "color: '#333'\n"+
            "},\n"+
            "xField: "+xfield+",\n"+
            "yField: "+yfield+"\n"+
        "}],\n"+
        "legend:{ \n"+
        "visible: true, \n"+
        "position: 'right', \n"+
        "}"+
	"});");
	}catch	(IOException e) {
		e.printStackTrace();
	}
}
%>
<%
//EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
try{
		//registerShutdownHook2(graphDb);
	//String nodeID = request.getParameter("id");
	
	DefaultNode theNode = (DefaultNode)session.getAttribute("currentNode");
	
	if ("Charts".equals(NodeHelper.getType(theNode.NODE()))){
		int graphNumber=1;
		Node chartsNode = theNode.NODE();
		String jsonData = chartsNode.getProperty("data").toString();
		String strAxeY = "Number of Peptides";
		if(chartsNode.hasProperty("AxeY"))
			strAxeY = chartsNode.getProperty("AxeY").toString();
		// x axis field name in the Json data
		String xfield = chartsNode.getProperty("xfield").toString();
		// y axis field name in the Json data
		String yfield = chartsNode.getProperty("yfield").toString();
		// max value of the y axis. Needed to scale the chart
		String maxYaxis = chartsNode.getProperty("maxYaxis").toString();
		CreateJsonStore(jsonData, graphNumber, out);
		CreateExtJsChart("chart" + graphNumber, "store"+graphNumber, chartsNode.getProperty("Name").toString(), out,
						 strAxeY, xfield, yfield, maxYaxis);
		out.println("charts["+(graphNumber-1)+"] = " + "chart" + graphNumber);
	}
	else
	{
		int graphNumber=0;
		for (Relationship chartsRel : theNode.NODE().getRelationships(DynamicRelationshipType.withName("Tool_output"), Direction.OUTGOING))
		{
			Node chartsNode = chartsRel.getOtherNode(theNode.NODE());
			if(NodeHelper.getType(chartsNode).equals("Chart"))
			{
				graphNumber++;
				String jsonData = chartsNode.getProperty("data").toString();
				//Format from D3 JS (Scatter)
				%>
				    var chart<%=graphNumber%> = nv.models.lineChart();
		    		var newChart = Ext.create('Ext.container.Container', 
		    		{
				        title: 'Chart',
				        layout: {
				            type: 'vbox',   
				            align: 'stretch'    
				        },
                        xtype: 'container',
                        minHeight: 100,
                        minWidth: 100,
                        layout: 'fit',       
                        border: true,
                        preventHeader: true,
                        id: 'idGraph<%=graphNumber%>',
                        html: "<div id='chart<%=graphNumber%>' class='charts'><svg></svg></div>",
                        listeners: {            
                        	afterrender: {
                				//element: 'el', //bind to the underlying el property on the panel
                				fn: function()
                				{                        
				                    nv.addGraph(function()
				                    {
				                    	chart<%=graphNumber%>.xAxis.tickFormat( d3.format(',.2f'));
				                    	/*function(d) 
				                    		{
				                    			if(d < 0) return 'A';
				                    			if(d < 15) return 'B';
				                    			if(d < 45) return 'C';
				                    			if(d < 75) return 'D';
				                    			if(d < 105) return 'E';
				                    			if(d < 135) return 'F';
				                    			if(d < 165) return 'G';
				                    			if(d < 195) return 'H';
				                    			if(d < 225) return 'I';
				                    			if(d < 255) return 'J';
				                    			if(d < 285) return 'K';
				                    			if(d < 315) return 'L';
				                    			if(d < 345) return 'M';
				                    			if(d < 375) return 'N'; 
				                    			return 'X';
				                    			return d3.format(',.2f');
				                    		});//*/
				                    	chart<%=graphNumber%>.yAxis.tickFormat(d3.format(',.2f'));
				                    	d3.select('#chart<%=graphNumber%> svg').datum(<%=jsonData%>).transition().duration(500).call(chart<%=graphNumber%>);
				                    	nv.utils.windowResize(chart<%=graphNumber%>.update);
				                    	return chart<%=graphNumber%>;
				                    }); 
                    			}
            				},            				
              				resize: {
                  				fn: function(el) 
                  				{
                  					ResizeNavPanel();
                  					if(chart<%=graphNumber%> && chart<%=graphNumber%>.update)
                  						chart<%=graphNumber%>.update();
                  				}
              				}
        				}
                    });                    
                <%
				out.println("charts["+(graphNumber-1)+"] = newChart;");				
			}
			else if(chartsNode.hasProperty("data") && chartsNode.hasProperty("Name") )
			{
				graphNumber++;
				String jsonData = chartsNode.getProperty("data").toString();
				String strAxeY = "Number of Peptides";
				if(chartsNode.hasProperty("AxeY"))
					strAxeY = chartsNode.getProperty("AxeY").toString();
				// x axis field name in the Json data
				String xfield = chartsNode.getProperty("xfield").toString();
				// y axis field name in the Json data
				String yfield = chartsNode.getProperty("yfield").toString();
				// max value of the y axis. Needed to scale the chart
				String maxYaxis = chartsNode.getProperty("maxYaxis").toString();
				CreateJsonStore(jsonData, graphNumber, out);
				CreateExtJsChart("chart" + graphNumber, "store"+graphNumber, chartsNode.getProperty("Name").toString(), out,
								 strAxeY, xfield, yfield, maxYaxis);
				out.println("charts["+(graphNumber-1)+"] = " + "chart" + graphNumber);
			}
		}
	}	
}
catch(Exception e)
{
	e.printStackTrace();
}
finally
{
	//graphDb.shutdown();
}
%>
