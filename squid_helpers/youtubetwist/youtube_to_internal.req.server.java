#rights=ADMIN
//------------------------------------------------------------------- 
// ==ServerScript==
// @name            youtube_to_internal
// @status on
// @description     
// @include        http://.*\.c\.youtube\.com/videoplayback\?.*id\=.*
// @exclude
// @responsecode    200        
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
    String url = httpMessage.getUrl();
    String response = "nochange";
     debug( "\r\n+++++request url++++\r\n");
    debug( url );

    

     
    if ( getvid(url).startsWith("id=") ){
            setvid(url, getvid(url));
            response = "http://youtube.squid.internal/" + getvid(url);
            
       } 
     debug( "\r\n+++++response url++++\r\n");
     debug( response.toString() );
     debug( "\r\n+++++response url++++\r\n");
     if( !response.startsWith("nochange")){
        httpMessage.setUrl(response);
     debug( "\r\n+++++  url was changed   ++++\r\n");
     }

    debug("++rewrittenurl++\r\n"+httpMessage.getUrl() +"\r\n");
  
   //  httpMessage.setUrl();
  debug( "+++end internal to youtube+++\r\n" + httpMessage.getRequestHeaders()+"\r\n");
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
         String url = "empty";
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
    
    
    
    
    /*
    * @param url
    * @param vid
    */
     public static void setvid(String url,String vid) throws Exception {
//        System.out.println(url);
//        System.out.println(vid);
         
         PreparedStatement pst = null;
         Connection con = getMySqlConnection();
//      the procedure takes the first value as vid and the second as url
         String query = "CALL seturl ('" + vid.toString() 
                 + "', '" + url.toString()+ "');";
         pst = con.prepareStatement(query);
         pst.executeQuery();
         con.close();
            
    }   
     
      public static Connection getMySqlConnection() throws Exception {
          String driver = "org.gjt.mm.mysql.Driver";
          String url = "jdbc:mysql://sql1/ytcache";
          String username = "ytcache";
          String password = "ytcache";

          Class.forName(driver);
          Connection conn = DriverManager.getConnection(url, username, password);
          return conn;
   }
