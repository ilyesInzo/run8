public class PM_GetProductImageHelper {
    public Static String TABLE_NAME_FULLPATH = 'fullpath';
    public static Document buildDocument(String contentBase64, String docName, Id folId){
        
        //Blob blobData = Blob.valueOf(contentBase64.replace('data:image/png;base64,',''));
        //String b64Data = EncodingUtil.base64Decode(blobData);
        //String cleanb64Data = contentBase64.replace('data:image/png;base64,','');
        Blob blobData = EncodingUtil.base64Decode(contentBase64);
        //Blob pngblobData = Blob.valueOf(b64Data);
        List<Document> docs = [SELECT Id, Name, ContentType, FolderId, IsPublic
                               FROM Document
                               WHERE Name = :docName AND ContentType='image/png' AND FolderId= :folId 
                              ];
        // delete if exist
        if(!docs.isEmpty() && (contentBase64 !=null || contentBase64 !='') ) {
            delete docs.get(0);
        }
        Document doc = new Document();
        doc.Name = docName;
        doc.ContentType='image/png';   
        doc.FolderId= folId;
        doc.IsPublic = false;
        doc.Body = blobData;
        
        insert doc;
        return doc;
    }
    
    public static String getProductToken(){
        String token = '';
        try{
            ////////////  Get access token /////////
            HttpResponse resAuth = PM_MM_Webservices.getAccessToken();
            System.debug(' ############## PM_GetProductImageHelper.getProductToken resAuth= '+resAuth);
            System.debug(' ############## PM_GetProductImageHelper.getProductToken resAuth.getStatusCode= '+resAuth.getStatusCode());
            System.debug(' ############## PM_GetProductImageHelper.getProductToken resAuth.getBody= '+resAuth.getBody());
            System.debug(' ############## PM_GetProductImageHelper.getProductToken resAuth.getStatus= '+resAuth.getStatus());
            
            if(resAuth.getStatusCode() == 200){
                //Test de-serialize json to PM_getProductImageResponseWraper
                PM_AuthResponseWraper authResponseWrapper = PM_AuthResponseWraper.parse(resAuth.getBody());  
                System.debug(' ############## PM_GetProductImageHelper.getProductToken authResponseWrapper= '+authResponseWrapper);
                token = authResponseWrapper.token;
            }else{
                token = '';
            }
            
        }catch(Exception ex){
            // log exception
            System.debug(' ############## PM_GetProductImageHelper.getProductToken ex.getMessage= '+ex.getMessage());
            System.debug(' ############## PM_GetProductImageHelper.getProductToken ex.getStackTraceString= '+ex.getStackTraceString());
            // get simple message to show to the user
            token = '';
        }
        return token;
    }
    
    public static String getProductImage(PM_selected_Tubes_config__c selectedTubeConfig){
        String resp = '';
        String token = '';
        
        QuoteLineItem qli = new QuoteLineItem(
            Id = selectedTubeConfig.Quote_item__c,
            Product_Final_Look__c = Label.ImageCurrentlyNotAvailable
        );  
        
        // call Mix&Match Webservice to get product image
        try{    
            PM_MM_Webservices.PM_TubesProductConfigWrapper tubeconfigWrap = new PM_MM_Webservices.PM_TubesProductConfigWrapper();
            // fill product config
            tubeconfigWrap.QuoteItemId = selectedTubeConfig.quote_Item__c;
            tubeconfigWrap.config = fillTubesConfigWrapperFromTubesConfig(selectedTubeConfig);
            System.debug(' ############## PM_GetProductImageHelper.getProductImage tubeconfigWrap= '+tubeconfigWrap);
            // if config not complete don't call webservice
            if(tubeconfigWrap.config.eurocaps == null){            
                update selectedTubeConfig;          
                update qli;
                return 'Please complete the product configuration and try again';
            }
            ////////////  Get access token /////////
            token = getProductToken();
            //////////////////////////////////////////////////////
            
            if(token != null ||token != '' ){
                
                HttpResponse res = PM_MM_Webservices.getProductImage(tubeconfigWrap, token);
                System.debug(' ############## PM_GetProductImageHelper.getProductImage res= '+res);
                System.debug(' ############## PM_GetProductImageHelper.getProductImage res.getStatusCode= '+res.getStatusCode());
                System.debug(' ############## PM_GetProductImageHelper.getProductImage res.getBody= '+res.getBody());
                System.debug(' ############## PM_GetProductImageHelper.getProductImage res.getStatus= '+res.getStatus());
                
                if(res.getStatusCode() == 200){
                    PM_getProductImageResponseWraper prodImgResWrap = PM_getProductImageResponseWraper.parse(res.getBody());
                    System.debug(' ############## PM_GetProductImageHelper.getProductImage prodImgResWrap= '+prodImgResWrap);
                    if(prodImgResWrap.error == null && (prodImgResWrap.body != '' && prodImgResWrap.body != null ) ){
                        ////////////  Save Product image to document/////////
                        // Get product image folder 
                        Folder fl = [SELECT AccessType, DeveloperName, Id, IsReadonly, Name, NamespacePrefix, Type 
                                     FROM Folder 
                                     WHERE DeveloperName='PricematriX_Product_Images' 
                                     AND IsReadonly=true AND Type='Document' LIMIT 1];
                        // build document record
                        Document doc = PM_GetProductImageHelper.buildDocument(prodImgResWrap.body, 'productImage-'+selectedTubeConfig.Quote_item__c+'.png',fl.Id);
                        //QuoteLineItem qli = new QuoteLineItem();
                        qli.Id = selectedTubeConfig.Quote_item__c;
                        qli.Product_Final_Look__c = doc.Id;
                        //update qli;
                        //////////////////////////////////////////////////////
                    }else{
                        //resp = String.join(prodImgResWrap.error == null ? new List<String>() : prodImgResWrap.error, ' , ' );
                        resp = (prodImgResWrap.error == null ? '' : prodImgResWrap.error);
                        resp = (prodImgResWrap.status == null)? resp : 'Status: '+prodImgResWrap.status +' \n'+ resp;
                    }
                }else{
                    resp = 'Remote Server error code('+res.getStatusCode()+')' ;
                }
            }else{
                resp = 'Authentification failed ';
            }
            selectedTubeConfig.Error_message__c = resp;
            update selectedTubeConfig;          
            update qli;
        }catch(Exception ex){
            // log exception
            System.debug(' ############## PM_GetProductImageHelper.getProductImage ex.getMessage= '+ex.getMessage());
            System.debug(' ############## PM_GetProductImageHelper.getProductImage ex.getStackTraceString= '+ex.getStackTraceString());
            // get simple message to show to the user
            resp = ex.getMessage();
            // TODO: Update PM_Selected_Tubes_Config
            selectedTubeConfig.Error_message__c = resp;
            update selectedTubeConfig;
            update qli; 
        }
        
        return resp;
    }
    
    public static String mapPMConfigRegion(String location){
        String region = 'Europe';
        if(location == 'EU'){region =  'Europe';}
        if(location == 'US'){region =  'Americas';}
        return region;
    }
    public static String mapPMConfigTechnology(PM_selected_Tubes_config__c stc){
        String techno = 'Plastic';
        if(stc.Product_Segment__c == 'Plastic Tubes'){techno =  'Plastic';}
        if(stc.Product_Segment__c == 'Laminate Tubes'){techno =  'Laminate';}
        if(stc.Product_Segment__c == 'Plastic Tubes' && stc.Purefoil_Segment__c ){techno =  'Purefoil';}
        return techno;
    }
    
    public static String mapPMConfigDiameter(PM_selected_Tubes_config__c stc){
        String diam = '';
        if(stc.location__c == 'EU'){
            diam =  ''+stc.diameter_mm__c;
        }
        if(stc.location__c == 'US'){diam =  ''+stc.diameter_inches__c;
                                   }
        return diam;
    }
    
//    public static PM_MM_Webservices.PM_Sleeve mapPMSleeve(PM_selected_Tubes_config__c stc, PM_Tubes_config__c capcityLength){
    public static PM_MM_Webservices.PM_Sleeve mapPMSleeve(PM_selected_Tubes_config__c stc){
        // PM_Config.sleeve (PM_Sleeve)
        PM_MM_Webservices.PM_Sleeve sleeveWrap = new PM_MM_Webservices.PM_Sleeve();
        // PM_Sleeve.name (String)
//        sleeveWrap.name = '';
        // PM_Sleeve.technology (String) //Plastic
        sleeveWrap.technology = mapPMConfigTechnology(stc);
        
        //PM_Sleeve.shape (String) // Cylindrical
        sleeveWrap.shape = stc.shape__c;
        //PM_Sleeve.diameter (String) // 25
        sleeveWrap.diameter = mapPMConfigDiameter(stc);
        //PM_Sleeve.fill_capacity (String) // 30
        sleeveWrap.fill_capacity = ''+stc.Fill_Capacity_ml__c; //'30';
        //PM_Sleeve.length_value (String) // 100
        sleeveWrap.length_value = ''+stc.sleeve_length_mm__c;

        //PM_Sleeve.material (String) // Mono
        sleeveWrap.material = (mapPMConfigTechnology(stc) == 'Purefoil')?stc.Sleeve_Material_Mix__c:stc.Sleeve_Material__c;
        //PM_Sleeve. (String) // HDPE/LDPE 30/70% 
        //FIXME: Illegal value for primitive
        sleeveWrap.material_mix = stc.Sleeve_Material_Mix__c;
        //sleeveWrap.material_mix = 'HDPE/LDPE 30/70%'; //'PEHD/PEBD 30/70%'; //        


        return sleeveWrap;
    }
    
    public static PM_MM_Webservices.PM_Dispensing mapPMDispensing(PM_selected_Tubes_config__c stc){
        // PM_Config.dispensing (PM_Dispensing)
        PM_MM_Webservices.PM_Dispensing dispensingWrap = new PM_MM_Webservices.PM_Dispensing();
        // TODO: Mapping to check ; remove later
        if(stc.Dispensing_System_Family__c == 'Twist-off'){
            dispensingWrap.dispensing_system_family_name = 'Twist-off head';
        }else{
            dispensingWrap.dispensing_system_family_name = stc.Dispensing_System_Family__c; //'Airless pump';            
        }

        return dispensingWrap;
    }
    
    
    public static PM_MM_Webservices.PM_Head mapPMHead(PM_selected_Tubes_config__c stc){
        // PM_Config (PM_Head)
        PM_MM_Webservices.PM_Head headWrap = new PM_MM_Webservices.PM_Head();
        headWrap.head_name= stc.head_name__c; //'PREC4';
        return headWrap;
    }
    
    
     public static PM_MM_Webservices.PM_Cap mapPMCap(PM_selected_Tubes_config__c stc){
        // PM_Config (PM_Cap)
        PM_MM_Webservices.PM_Cap capWrap = new PM_MM_Webservices.PM_Cap();
        capWrap.cap_name= stc.cap_name__c; //'Snap on cap';
        return capWrap;
    }

    public static PM_MM_Webservices.PM_AirlessPump mapPMAirlessPump(PM_selected_Tubes_config__c stc){
        PM_MM_Webservices.PM_AirlessPump airlessPumpWrap = new PM_MM_Webservices.PM_AirlessPump();
        // TODO: Mapping to check ; remove later
        if(stc.Dispensing_System_Family__c == 'Twist-off'){
            airlessPumpWrap.dispensing_system_family_name = 'Twist-off head';
        }else{
            airlessPumpWrap.dispensing_system_family_name = stc.Dispensing_System_Family__c; //'Airless pump';
            //airlessPumpWrap.airless_pump_name = 'Plastic NEA';
            //airlessPumpWrap.airless_pump_dose_id= '150';   
        }
        
        return airlessPumpWrap;
    } 

    
    public static PM_MM_Webservices.PM_Applicator mapPMApplicator(PM_selected_Tubes_config__c stc){
        PM_MM_Webservices.PM_Applicator applicatorWrap = new PM_MM_Webservices.PM_Applicator();
        applicatorWrap.applicator_name = stc.Dispensing_System_Name__c; //Dome 
        

        return applicatorWrap;
    }

    /*
* Fill tubes master methods
* 
*/
    public static PM_MM_Webservices.PM_config fillTubesConfigWrapperFromTubesConfig(PM_selected_Tubes_config__c stc){
        
        System.debug('################### stc.Product_segment__c: '+stc.Product_segment__c);
                System.debug('################### stc.diameter_mm__c: '+stc.diameter_mm__c);
        System.debug('################### stc.Dispensing_System_Family__c: '+stc.Dispensing_System_Family__c);
        System.debug('################### stc.head_name__c: '+stc.head_name__c);
        System.debug('################### stc.cap_name__c: '+stc.cap_name__c);
        System.debug('################### stc.Cap_Eurocode__c: '+stc.Cap_Eurocode__c);
        /*       
        List<PM_Tubes_config__c> fullpaths = new List<PM_Tubes_config__c>();

        if(stc.location__c == 'EU'){
            fullpaths = [Select Id, Generic_code__c, eurocode__c, Mixandmatch_id__c
                         FROM PM_Tubes_config__c
                         WHERE Location__c= :stc.location__c AND Tubes_segment__c = :mapPMConfigTechnology(stc)
                             AND Table_name__c=:TABLE_NAME_FULLPATH 
                             AND Diameter_mm__c = :stc.diameter_mm__c AND Dispensing_System_Family__c = :stc.Dispensing_System_Family__c 
                             AND Head__c = :stc.head_name__c AND Cap_name__c= :stc.cap_name__c 
                         LIMIT 1];
        }
        System.debug('################### fullpaths: '+fullpaths);
        */
        PM_MM_Webservices.PM_config tubeConfigWrap = new PM_MM_Webservices.PM_config();
        // PM_Config.region (String)
        tubeConfigWrap.region = mapPMConfigRegion(stc.location__c);
        // PM_Config.sleeve (PM_Sleeve)
        //tubeConfigWrap.sleeve = mapPMSleeve(stc, capcityLength);
        tubeConfigWrap.sleeve = mapPMSleeve(stc);
        
        //  PM_Head head;
        if(stc.head_name__c != null || stc.head_name__c != ''){
            tubeConfigWrap.head = mapPMHead(stc);
        }
        if(stc.cap_name__c != null || stc.cap_name__c != ''){
            //PM_Cap cap;
            tubeConfigWrap.cap = mapPMCap(stc);
        }
        
        
        if(stc.Dispensing_System_Family__c != null || stc.Dispensing_System_Family__c != ''){
            // PM_Dispensing dispensing;
            tubeConfigWrap.dispensing = mapPMDispensing(stc);

            
            if(stc.Dispensing_System_Family__c == 'Airless pump'){
                // PM_AirlessPump airless_pump;
                tubeConfigWrap.airless_pump = mapPMAirlessPump(stc);
            }else if(stc.Dispensing_System_Family__c == 'Applicator'){            
                // PM_Applicator applicator;
                if(stc.Dispensing_System_Name__c != null || stc.Dispensing_System_Name__c != ''){
                    tubeConfigWrap.applicator = mapPMApplicator(stc);           
                }

            }
        }
        tubeConfigWrap.eurocaps = stc.Cap_Eurocode__c;
        
        return tubeConfigWrap;
    }
}