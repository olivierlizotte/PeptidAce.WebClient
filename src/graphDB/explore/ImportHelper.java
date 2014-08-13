package graphDB.explore;
import java.io.BufferedReader;
import javax.servlet.jsp.JspWriter;
import org.neo4j.graphdb.*;

public class ImportHelper {

	public static void SaveNodes(JspWriter out, BufferedReader br, String dbName)
	{
		try{
	        //Node headers:
	        String read = br.readLine();
	        String[] headerNodes = read.substring(read.indexOf(":") + 1).split(",");
	        int indexRequest = -1;
	        for(int i = 0; i < headerNodes.length; i++)
	        	if(headerNodes[i].equals("Request"))
	        		indexRequest = i;
	        //Number of nodes
	        //read = br.readLine();
	        //int nbNodes = Integer.parseInt(read.substring(6));
	            
	        GraphDatabaseService graphDb = DefaultTemplate.graphDb(dbName);
	        try(Transaction tx = graphDb.beginTx())
	        {
	        	//Read all nodes
	            read = br.readLine();
	        	int nodesDoneIndex = 0;
	        	while(read != null) {
	                String[] splits = read.split(",");
	                Node node = graphDb.createNode();
	                for(int i = 0; i < splits.length; i++)
	                	if(splits[i].length() > 0)
	                	{
	                		if(indexRequest == i)
	                		{
	    	                	String[] splitRequest = splits[i].split("\\|");
	    	                	if(splitRequest.length > 0)
	    	                	{
	    	                		StringBuilder request = new StringBuilder( "<a href=\"#\" onclick=\\'SendRequest(\"");	    
		    	                	request.append(splitRequest[0]);
	    	                		request.append("\",");
	    	                		request.append(node.getId());
	    	                		request.append(",[");
		    	                	if(splitRequest.length > 1)
		    	                	{
	    	                			//request.append("\\'");
		    	                		request.append(splitRequest[1]);	    	
	    	                			//request.append("\\'");                	
		    	                		for(int j = 2; j < splitRequest.length; j++)
		    	                		{
		    	                			request.append(",");//,\\'");
		    	                			request.append(splitRequest[j]);
		    	                			//request.append("\\'");
		    	                		}
		    	                	}
		    	                	request.append("]);\\'>view</a>");
		    	                	//request.append("]");
		    	                		
		    	                	node.setProperty(headerNodes[i], request.toString());
	    	                	}
	                		}
	                		else
	                			node.setProperty(headerNodes[i], splits[i].replace('~', ','));
	                	}
	
	                	
	                out.println(nodesDoneIndex + ":" + node.getId());
	                nodesDoneIndex++;
	                
	                read = br.readLine();		                
	            }
	            tx.success();
	        }
		}
		catch(Exception ex) {
			System.out.println(ex);
		}
	}
	public static void SaveLinks(JspWriter out, BufferedReader br, String dbName)
	{
		try
		{  
            //Link headers
            String read = br.readLine();
	        String[] headerLinks = read.substring(read.indexOf(":") + 1).split(",");
	        int indexRequest = -1;
	        for(int i = 0; i < headerLinks.length; i++)
	        	if(headerLinks[i].equals("Request"))
	        		indexRequest = i;
            GraphDatabaseService graphDb = DefaultTemplate.graphDb(dbName);
            try(Transaction tx = graphDb.beginTx())
            {
            	//Read all links
	            read = br.readLine();
            	while(read != null) {
                    String[] splits = read.split(",");
                    long indexNodeSource = Long.parseLong(splits[0]);
	                Node source = graphDb.getNodeById(indexNodeSource);
                    long indexNodeDestination = Long.parseLong(splits[1]);
	                Node destination = graphDb.getNodeById(indexNodeDestination);
	                String typeOfLink = splits[2];
	    			RelationshipType relType = DynamicRelationshipType.withName( typeOfLink );	
	    			Relationship currentRelationship = source.createRelationshipTo(destination, relType);
	                for(int i = 3; i < splits.length; i++)
	                {
	                	if(splits[i].length() > 0){
	                		if(indexRequest == i)
	                		{
	    	                	String[] splitRequest = splits[i].split("\\|");
	    	                	if(splitRequest.length > 0)
	    	                	{
	    	                		StringBuilder request = new StringBuilder( "<a href=\"#\" onclick=\\'SendRequest(\"");	    
		    	                	request.append(splitRequest[0]);
	    	                		request.append("\",");
	    	                		request.append(indexNodeDestination);
	    	                		request.append(",[");
		    	                	if(splitRequest.length > 1)
		    	                	{
	    	                			//request.append("\\'");
		    	                		request.append(splitRequest[1]);	    	
	    	                			//request.append("\\'");                	
		    	                		for(int j = 2; j < splitRequest.length; j++)
		    	                		{
		    	                			request.append(",");//,\\'");
		    	                			request.append(splitRequest[j]);
		    	                			//request.append("\\'");
		    	                		}
		    	                	}
		    	                	request.append("]);\\'>view</a>");
		    	                	//request.append("]");
		    	                		
		    	                	currentRelationship.setProperty(headerLinks[i], request.toString());
		    	                }
	                		}
	                		else
	                			currentRelationship.setProperty(headerLinks[i], splits[i].replace('~', ','));
	                	}
	                }
	                read = br.readLine();		                
	            }
	            tx.success();
            }
		}
		catch(Exception ex) {
			System.out.println(ex);
		}
	}
}
