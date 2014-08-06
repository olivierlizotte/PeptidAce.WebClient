<%@page import="java.io.File" %>
<%@page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import="org.neo4j.graphdb.Direction" %>
<%@ page import="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import="org.neo4j.graphdb.Node" %>
<%@ page import="org.neo4j.graphdb.DynamicRelationshipType" %>
<%@ page import="org.neo4j.graphdb.Relationship" %>
<%@ page import="org.neo4j.graphdb.RelationshipType" %>
<%@ page import="org.neo4j.graphdb.Transaction" %>
<%@ page import="org.neo4j.graphdb.index.Index" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="graphDB.explore.*" %>

<%

String dbName = session.getAttribute("database").toString();
try(Transaction tx = DefaultTemplate.graphDb(dbName).beginTx())
{
	final RelationshipType relType = DynamicRelationshipType.withName( "Comment" );
	Node theUser = DefaultTemplate.graphDb(dbName).getNodeById(1l);
	for(Relationship otherRelation : theUser.getRelationships(relType))
		otherRelation.delete();
	tx.success();
}
%>