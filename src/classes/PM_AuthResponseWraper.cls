public class PM_AuthResponseWraper {
    public String expireDate;
    public String token; //38d6ec4aeb0718415e04714423098661eec3347db5a92312808e23ecf49112d8
    
    // parse response
    public static PM_AuthResponseWraper parse(String json){
        // avoid date because it's a reserved word
        json = json.replace('"date":', '"expireDate":'); 
        return (PM_AuthResponseWraper) System.JSON.deserialize(json, PM_AuthResponseWraper.class);
    }
}