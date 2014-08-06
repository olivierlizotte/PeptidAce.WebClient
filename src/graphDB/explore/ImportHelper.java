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
	        String[] headerNodes = read.split(":")[1].split(",");
	        int indexRequest = -1;
	        for(int i = 0; i < headerNodes.length; i++)
	        	if(headerNodes[i] == "Request")
	        		indexRequest = i;
	        //Number of nodes
	        read = br.readLine();
	        int nbNodes = Integer.parseInt(read.substring(6));
	            
	        GraphDatabaseService graphDb = DefaultTemplate.graphDb(dbName);
	        try(Transaction tx = graphDb.beginTx())
	        {
	        	//Read all nodes
	            read = br.readLine();
	        	int nodesDoneIndex = 0;
	        	while(read != null && nodesDoneIndex < nbNodes) {
	                String[] splits = read.split(",");
	                Node node = graphDb.createNode();
	                for(int i = 0; i < splits.length; i++)
	                	if(splits[i].length() > 0)
	                	{
	                		if(indexRequest == i)
	                		{
	    	                	String[] splitRequest = splits[indexRequest].split("|");
	    	                	StringBuilder request = new StringBuilder( "<a href=SendRequest(\"");
	    	                	request.append(splitRequest[0]);
    	                		request.append("\",[");
	    	                	if(splitRequest.length > 1)
	    	                	{
	    	                		request.append(splitRequest[1]);	    	                	
	    	                		for(int j = 2; j < splitRequest.length; j++)
	    	                		{
	    	                			request.append(",\"");
	    	                			request.append(splitRequest[j]);
	    	                			request.append("\"");
	    	                		}
	    	                	}
	    	                	request.append("]);>view</a>");
	    	                		
	    	                	node.setProperty(headerNodes[i], request.toString());
	                		}
	                		else
	                			node.setProperty(headerNodes[i], splits[i]);
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
            String[] headerLinks = read.split(":")[1].split(",");
	        int indexRequest = -1;
	        for(int i = 0; i < headerLinks.length; i++)
	        	if(headerLinks[i] == "Request")
	        		indexRequest = i;
            //Number of nodes
            read = br.readLine();
            int nbLinks = Integer.parseInt(read.substring(6));
            GraphDatabaseService graphDb = DefaultTemplate.graphDb(dbName);
            try(Transaction tx = graphDb.beginTx())
            {
            	//Read all links
	            read = br.readLine();
            	int linksDoneIndex = 0;
            	while(read != null && linksDoneIndex < nbLinks) {
                    String[] splits = read.split(",");
                    long indexNodeSource = Long.parseLong(splits[0]);
	                Node source = graphDb.getNodeById(indexNodeSource);
                    long indexNodeDestination = Long.parseLong(splits[1]);
	                Node destination = graphDb.getNodeById(indexNodeDestination);
	                String typeOfLink = splits[2];
	    			RelationshipType relType = DynamicRelationshipType.withName( typeOfLink );	
	    			Relationship currentRelationship = source.createRelationshipTo(destination, relType);
	                for(int i = 3; i < splits.length; i++)
	                	if(splits[i].length() > 0)
	                		if(indexRequest == i)
	                		{
	    	                	String[] splitRequest = splits[indexRequest].split("|");
	    	                	StringBuilder request = new StringBuilder( "<a href=SendRequest(\"");
	    	                	request.append(splitRequest[0]);
	    	                	request.append("\"");
	    	                	for(int j = 1; j < splitRequest.length; j++)
	    	                	{
	    	                		request.append(",\"");
	    	                		request.append(splitRequest[j]);
		    	                	request.append("\"");
	    	                	}
	    	                	request.append(");>view</a>");
	    	                		
	    	                	currentRelationship.setProperty(headerLinks[i], request.toString());
	                		}
	                		else
	                			currentRelationship.setProperty(headerLinks[i], splits[i]);

	                linksDoneIndex++;
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
