public class PM_GetProductImageResponseWraper {
    
    public String quoteItemId;
    public String body;
    public String contentType;
    public String status;
    //public String[] error;
    public String error;
    
    // parse response
    public static PM_getProductImageResponseWraper parse(String json){
        return (PM_getProductImageResponseWraper) System.JSON.deserialize(json, PM_getProductImageResponseWraper.class);
    }
}