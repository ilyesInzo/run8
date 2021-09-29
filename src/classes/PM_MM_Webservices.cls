public class PM_MM_Webservices {
    
    public class PM_TubesProductConfigWrapper{
        public String QuoteItemId; 
        //public String token; 
        public PM_config config;
    }
    
    public class PM_config{
        public String region; // Europe
        public PM_Sleeve sleeve; 
        public PM_Head head;
        public PM_Cap cap;
        public PM_Dispensing dispensing;
        public PM_AirlessPump airless_pump;
        public PM_Applicator applicator;
        public String eurocaps; //NEA25plastic
        
    }
    public class PM_Sleeve {
        public String technology; //Plastic
        public String shape; // Cylindrical
        public String diameter; // 25
        public String length_value; // 100
        public String fill_capacity; // 30
        public String material; // Mono
        public String material_mix; // HDPE/LDPE 30/70%
        public String aspect;
        public String finish;
    }
    
    public class PM_Dispensing {
        public String dispensing_system_family_name; // Airless pump
    }
    
    public class PM_Head {
        public String head_name; // PREC4
        public String aspect;
    }
    
    public class PM_AirlessPump{
        public String dispensing_system_family_name; // Airless pump
        //public String airless_pump_name; // Plastic NEA
    }
    
    public class PM_Cap{
        public String cap_name; //Snap on cap
        public String aspect;
        public String finish;
    }
    
    public class PM_Applicator{
        public String applicator_name; //Dome 
    }
    
    public static String generateBasicAuthToken(){
        Blob targetBlob = Blob.valueOf(Label.PM_MM_Login+':'+Label.PM_MM_Password);
        String base64Token = EncodingUtil.base64Encode(targetBlob);
        return 'Basic '+base64Token;   
    }
    
    public static HttpResponse getAccessToken(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.PM_MM_Auth_Endpoint);
        req.setMethod('GET');
        req.setTimeout(60000); // timeout 60s
        req.setHeader('Authorization',generateBasicAuthToken());
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
    
    
    public static HttpResponse getProductImage(PM_TubesProductConfigWrapper tubesProdConfigWrap, String token){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.PM_MM_GetProductImage_Endpoint);
        req.setMethod('POST');
        req.setTimeout(60000); // timeout 60s
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token', token);
        String body = JSON.serialize(tubesProdConfigWrap);
        String fixedBody = stripJsonNulls(JSON.serialize(tubesProdConfigWrap)); // strip apex issue while generating json firmat (null ...)
        req.setBody(fixedBody);
       	/*
        String bodyTest = '{';
        bodyTest = bodyTest+'"config":{"region":"Europe","sleeve":{"name":"","technology":"Plastic","parts":[{"color":"#52e597","color_locked":"0","aspect":"Transparent","aspect_locked":"0","finish":"Gloss","finish_locked":"0","file_3d_name":"SLVD25L100A30"}],"shape":"Cylindrical","diameter":"25","length_value":"100","hot_stamp":"","fill_capacity":"30","material":"Mono","material_mix":"HDPE/LDPE 30/70%"},"dispensing":{"dispensing_system_family_name":"Airless pump"},"head":{"head_name":"PREC4","parts":[{"color":"#eeeeee","color_locked":"0","aspect":"Opaque","aspect_locked":"0","file_3d_name":"HEDD25PREC4P131A013","orifice_value":"0.00","finish":""}],"show":"NO"},"peel_seal":{"id":""},"airless_pump":{"dispensing_system_family_name":"Airless pump","airless_pump_name":"Plastic NEA","airless_pump_dose_id":"150","parts":[{"file_3d_name":"DISD25M002510-1","aspect":"Opaque","aspect_locked":"0","finish":"Gloss","finish_locked":"1","color":"#ffd4a1","color_locked":"0","part_id":"1"},{"file_3d_name":"DISD25M002510-2","aspect":"Opaque","aspect_locked":"0","finish":"Matte","finish_locked":"1","color":"#eeeeee","color_locked":"0","part_id":"3"}]},"cap":{"cap_name":"Snap on cap","parts":[{"file_3d_name":"CAPD25M002510-3","aspect":"Opaque","aspect_locked":"0","finish":"Gloss","finish_locked":"1","color":"#fffff8","color_locked":"0","part_id":"1"}],"orifice":""},"generic_code":"NEA25plastic","parties":"5"}';
        bodyTest = bodyTest+',"QuoteItemId":"'+tubesProdConfigWrap.QuoteItemId+'"';
        bodyTest = bodyTest+'}';
        
        req.setBody(bodyTest);
        */
        System.debug(' ############## PM_MM_Webservices.getProductImage req.toString= '+req.toString());
        System.debug(' ############## PM_MM_Webservices.getProductImage req.body= '+body);
        System.debug(' ############## PM_MM_Webservices.getProductImage req.fixedBody= '+fixedBody);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
    
    public static string stripJsonNulls(string JsonString){
        
        if(JsonString != null){
            JsonString = JsonString.replaceAll('\"[^\"]*\":null',''); //basic removeal of null values
            JsonString = JsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
            JsonString = JsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
            JsonString = JsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
            JsonString = JsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
            JsonString = JsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it
        }
        
        return JsonString;
    }
    
    
}