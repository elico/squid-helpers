#rights=ADMIN
//------------------------------------------------------------------- 
// ==ServerScript==
// @name            internal_to_youtube
// @status on
// @description     
// @include        http://youtube\.squid\.internal/.*
// @exclude        
// ==/ServerScript==
// --------------------------------------------------------------------
// Note: use httpMessage object methods to manipulate HTTP Message
// use debug(String s) method to trace items in service log (with log level >=FINE)
// ---------------
 
// ---------------
//import java.util.Scanner;
/*import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ParameterMetaData;
import java.sql.ResultSet;*/
import java.sql.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

 public void main(HttpMessage httpMessage){
     //start your code from here  
       try{
     
     debug(httpMessage.getRequestHeaders());
    String url = httpMessage.getUrl().toString();
    String vid = getvid(url.toString());
    String response = "nochange";
   debug( "+++\r\n" + url.toString() + "+++\r\n " );
    debug( "+++\r\n" + vid.toString() + "+++\r\n " );

    if (!vid.startsWith("no")){
   debug( "+++\r\n getting url from db +++\r\n " );
     response  =  geturl( vid.toString());
   debug( "+++\r\n got url from db +++\r\n " );
      debug( "+++\r\n" + response.toString() + "+++\r\n" );
     httpMessage.setUrl(response);
    }
    
    
  
   debug( "+++\r\n" + url.toString() + " " + vid.toString() );
  
   //  httpMessage.setUrl();
  debug( "+++++++++++++\r\n" + httpMessage.getRequestHeaders());
        
         }catch(Exception e){
         e.printStackTrace();
         }
}    
     
 



     
    
    public static String getvid(String url){
          String vid = "no";
          
          if(getid(url).toString() != "no"){
              vid = getid(url)  ;
          }
          if(getitag(url).toString() != "no"){
              vid = vid.toString() + "&" +getitag(url) ;
          }
          if(getrange(url).toString() != "no"){
              vid = vid.toString() + "&" + getrange(url);
          }
          
          
          return vid;
    }
    
    private static String getid(String url){
        
        Pattern pid = Pattern.compile(".*(id\\=[a-zA-Z0-9]+).*");
        Matcher mid = pid.matcher(url);
        if (mid.find())
        {
            return mid.group(1).toString();
                    
        }
        return "no";
    }   
            
    private static String getrange(String url){
            
            Pattern pr = Pattern.compile(".*(range\\=[a-zA-Z0-9\\-]+).*");
            Matcher mr = pr.matcher(url);
            if (mr.find())
            {
                return mr.group(1).toString();
                        
            }
            return "no";                        
                                                
    }                           
      
      
    private static String getitag(String url){
        
        Pattern pit = Pattern.compile(".*(itag\\=[0-9]+).*");
        Matcher mit = pit.matcher(url);
        if (mit.find())
        {
            return mit.group(1).toString();
                    
        }
        return "no";
    }


        public static String geturl(String vid) throws Exception {
        String url = "nourl";
        PreparedStatement pst = null;
        Connection con = getMySqlConnection();

        String query = "CALL geturl ('" + vid.toString() + "' );";
        pst = con.prepareStatement(query);
      
        ResultSet result = pst.executeQuery();
        if (result.next())
        {
             url = result.getString(1);
    
        }
                        
        con.close();
        
        return url;
                
    }
 
     
     
     
     
    
     
     public static Connection getMySqlConnection() throws Exception {
            String driver = "org.gjt.mm.mysql.Driver";
            String url = "jdbc:mysql://192.168.10.201/ytcache";
            String username = "root";
            String password = "da777777";

            Class.forName(driver);
            Connection conn = DriverManager.getConnection(url, username, password);
            return conn;
     }
     
     
