<%@page import="scala.util.parsing.json.JSONObject"%><%@page import="scala.util.parsing.json.JSONArray"%><%@page import="java.io.File" %><%@page import="org.neo4j.graphdb.PropertyContainer"%><%@ page language="java" contentType="text/html; charset=ISO-8859-1"    pageEncoding="ISO-8859-1"%><%@ page import="org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import="org.neo4j.graphdb.Direction" %><%@ page import="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import="org.neo4j.graphdb.Node" %><%@ page import="org.neo4j.graphdb.DynamicRelationshipType" %><%@ page import="org.neo4j.graphdb.Relationship" %><%@ page import="org.neo4j.graphdb.RelationshipType" %><%@ page import="org.neo4j.graphdb.Transaction" %><%@ page import="org.neo4j.graphdb.index.Index" %><%@ page import="java.util.*" %><%@ page import="java.io.*" %><%@ page import="graphDB.explore.*" %><%
if(session.getAttribute("user") != null)
{	
	//Retrieve the list of nodes (in json) following a set of params
	
	String dbName 	  = request.getParameter("database");
	String nodeId     = request.getParameter("id");

	try{
		Transaction tr = DefaultTemplate.graphDb(dbName).beginTx();
		DefaultNode theNode = new DefaultNode(nodeId, dbName);
		theNode.printAttributeJSON(out);
		tr.success();
		tr.close();
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}			
}
%>