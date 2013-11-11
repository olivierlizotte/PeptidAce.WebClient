<%@page import="org.neo4j.shell.util.json.JSONArray"%><%@page import="org.neo4j.shell.util.json.JSONObject"%><%@page import="java.io.File" %><%@page import="org.neo4j.graphdb.PropertyContainer"%><%@ page language="java" contentType="text/html; charset=ISO-8859-1"    pageEncoding="ISO-8859-1"%><%@ page import="org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import="org.neo4j.graphdb.Direction" %><%@ page import="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import="org.neo4j.graphdb.Node" %><%@ page import="org.neo4j.graphdb.DynamicRelationshipType" %><%@ page import="org.neo4j.graphdb.Relationship" %><%@ page import="org.neo4j.graphdb.RelationshipType" %><%@ page import="org.neo4j.graphdb.Transaction" %><%@ page import="org.neo4j.graphdb.index.Index" %><%@ page import="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@ page import="java.util.*" %><%@ page import="java.io.*" %><%@ page import="graphDB.explore.*" %><%
if(session.getAttribute("user") != null)
{		
	//This jsp will add a comment and send back the new list of comments as a result
	String nodeID    = request.getParameter("id");
	String nodeType  = request.getParameter("type");
    
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	
	try
	{				
		
		Node theNode = graphDb.getNodeById(Long.valueOf(nodeID));				
		Transaction tx = graphDb.beginTx();

		Node newNode = graphDb.createNode();
		newNode.setProperty("type", nodeType);
		
		RelationshipType newNodeRel = DynamicRelationshipType.withName("Link");
		theNode.createRelationshipTo(newNode, newNodeRel);
		Long tempNodeID = newNode.getId();
		tx.success();
		tx.finish();		
		out.println(tempNodeID);	
	}
	catch(Exception e)
	{
		e.printStackTrace();
		//out.println("-=" + userID + "=-");	
	}
}
%>