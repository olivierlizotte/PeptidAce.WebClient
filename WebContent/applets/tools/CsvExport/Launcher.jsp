<%@ page import="org.neo4j.graphdb.DynamicRelationshipType"%>
<%@ page import="graphDB.explore.*" %>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import ="org.neo4j.graphdb.Direction" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.RelationshipType" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Map.Entry"%>
<html>
	<head>
	
	<script type="text/javascript"><%
	String paramId = request.getParameter("id");	
	long currentID = Long.valueOf(paramId);
	StringBuilder nodeTypesOptions = new StringBuilder();
	String properties;

    String dbName = session.getAttribute("database").toString();    
    GraphDatabaseService graph = DefaultTemplate.graphDb(dbName);
    try
    {
	    Transaction tx = graph.beginTx();
		HashMap<String, Integer> typesRelated = NodeHelper.getRelatedNodeTypes(graph.getNodeById(currentID));
		tx.success();
		tx.close();
		
		for (String nodeType : typesRelated.keySet()){
			nodeTypesOptions.append("<option value= \""+nodeType+"\">"+nodeType+"</option>\n");
		}
    }
	catch(Exception e)
	{
		e.printStackTrace();
	}
%>
	function changeProperties(){
		nodeType = document.getElementById("nodeType").value;
		document.getElementById(('nodeProperties')).value=properties[nodeType];
	}

	function trim (myString)
	{
		return myString.replace(/^\s+/g,'').replace(/\s+$/g,'');
	} 
	function Launch()
	{
		document.getElementById("wait").innerHTML="<img src=../../../icons/waiting.gif width=\"150\" height=\"20\" />";
		var form = document.createElement("form");
	    form.setAttribute("method", "post");
	    form.setAttribute("action", "applets/tools/CsvExport/Executable.jsp");

        var hiddenField1 = document.createElement("input");
        hiddenField1.setAttribute("type", "hidden"); // 'hidden' is the less annoying html data control
        hiddenField1.setAttribute("name", "id");
        hiddenField1.setAttribute("value",  <%= paramId %>);
        form.appendChild(hiddenField1); // append the newly created control to the form

        var hiddenField2 = document.createElement("input");
        hiddenField2.setAttribute("type", "hidden"); // 'hidden' is the less annoying html data control
        hiddenField2.setAttribute("name", "nodeType");
        hiddenField2.setAttribute("value", document.getElementById('nodeType').value);
        form.appendChild(hiddenField2); // append the newly created control to the form
                	 
	    document.body.appendChild(form); // inject the form object into the body section
	    form.submit();	    
	}
	
	

	</script>
	
	<script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>

	</head>
	<body>
	<jsp:include page="Description.txt"/>
	Node type you want to export:
	<select id="nodeType" onChange=changeProperties()>
	<%=nodeTypesOptions.toString()%>
	</select>
	<input type="hidden" id="nodeProperties" value=""/>
	<br>
	<button onclick="Launch()">Launch!</button>
	<div id="wait"></div>
	</body>
</html>
