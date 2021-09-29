public with sharing class Catalog_Controller {

    // Primarily Catalog variables
    public List<CatalogProduct__c> productsInFamily {get;set;}
    public String backgroundURL {get;set;}

    // Primarily Cart variables
    public Set<String> productSet {get;set;}
    public String productToDelete {get;set;}
    private final Account acct;
    public String accId {get;set;}
    public Integer productQuantity {get;set;}
    public Order myOrder {get;set;}
    public List<OrderItem> myLineItems {get;set;}

    //Navigation Parameters
    public Integer step {get;set;}
    public String filterZone {get;set;}
    public String filterSegment {get;set;}
    public String queryFilters {get;set;}
    public String queryString {get;set;}
    public List<String> families1{get;set;}
    public List<String> families2{get;set;}

    public String selectedFamily1{get;set;}
    public String selectedFamily2{get;set;}
    public String selectedProduct{get;set;}

    //Advanced Filter Page Parameters
    public boolean filterScreen{get;set;}
    public String selectedFilter{get;set;}
    public set<String> filters{get;set;}
    public List<String> filtersList{get;set;}

    // Profile 
    public String profileName{get;set;}
   

    public CatalogProduct__c selectedProductDisplay{get;set;}



    public Catalog_Controller(ApexPages.StandardController stdController) {
        system.debug('initialization : step = ' + step);
        Id profileId=userinfo.getProfileId();
        profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        system.Debug('account : ' + (Account)stdController.getRecord());
        this.acct = (Account)stdController.getRecord();
        if(step != 1 && step != 2 && step != 3){
            if((Account)stdController.getRecord() != new Account()){
                Account acc = [Select Id, Country__r.Zone__c, Persona_Letter__c, Customer_Size_PM__c from Account Where Id = :acct.Id limit 1];
                accId = acc.Id;
                filterZone = acc.Country__r.Zone__c;
                filterSegment = acc.Persona_Letter__c;
                queryFilters = '';

                //Segment is not filtered for global and key accounts
                Boolean isGlobal = false;
                if(acc.Customer_Size_PM__c == 'Global Account' || acc.Customer_Size_PM__c == 'Key Account'){
                    isGlobal = true;
                }

                if(isGlobal){
                    filterSegment = '';
                }

                if(filterZone != null && filterZone != ''){
                    queryFilters += 'and Area_of_Sales__c INCLUDES(\'' + filterZone + '\') ';
                }
                if(filterSegment != null && filterSegment != ''){
                    queryFilters += 'and Customer_Segment__c INCLUDES(\'' + filterSegment + '\') ';
                }

            }
            else{
                filterZone = '';
                filterSegment = '';
                queryFilters = '';
            }
            system.debug('filterZone : ' + filterZone + ' filterSegment : ' + filterSegment);
            prepareCatalog();
            prepareCart();
            system.debug('Catalog initialized');
            step = 0;
            filterScreen = false;
            filters = new set<String>();
            filtersList = new List<String>(filters);

        }

    }

    /*
     *  prepareCatalog()
     *  This method contains all initialization for the catalog, and notably aids in 
     *  navigation with the FamilyMap (used in the category nav on the first page). 
     */
    public pageReference prepareCatalog() {
        system.debug('Catalog Preparation');

        families1 = new List<String>();
        set<String> families1unsort = new set<String>();
        set<String> families1sort = new set<String>();

        for(Catalog_Categories__mdt mdt : [SELECT MasterLabel FROM Catalog_Categories__mdt Where Level__c = 1 order by MasterLabel asc]){
            families1unsort.add(mdt.MasterLabel);
        }

        if(families1unsort.contains('Color Cosmetics')){
            families1sort.add('Color Cosmetics');
        }
        if(families1unsort.contains('Skin Care')){
            families1sort.add('Skin Care');
        }
        if(families1unsort.contains('Personal Care')){
            families1sort.add('Personal Care');
        }
        if(families1unsort.contains('Fragrance')){
            families1sort.add('Fragrance');
        }        
        if(families1unsort.contains('Oral Care')){
            families1sort.add('Oral Care');
        }
        if(families1unsort.contains('Pharmacy')){
            families1sort.add('Pharmacy');
        }
        if(families1unsort.contains('Other Markets')){
            families1sort.add('Other Markets');
        }
        families1sort.addAll(families1unsort);
        families1.addAll(families1sort);


        return null;
    }

    /* 
     *  prepareCart()
     *  Additional constructor helper method for initializing Cart variables. 
     */
    public pageReference prepareCart() {
        system.debug('Cart Preparation');

        productSet = new Set<String>();
        myOrder = new Order();
        myLineItems = new List<OrderItem>();

        return null;
    }


    /* 
     *  addToCart()
     *  Handles the complexity of adding a product as a line item to the Order from Actionfunction
     */
    public pageReference addToCart() {
        system.debug('AddToCart starts');

        if(selectedProduct == null) {}

        else {

            if(productSet.contains(selectedProductDisplay.id)){}

            else {
                // Here is where we add the ID to the set...
                productSet.add(selectedProductDisplay.id);
                // ...and to the Order.
                OrderItem li =  new OrderItem();
                li.Product__c = selectedProductDisplay.id;
                //li.OrderId = myOrder.Id;
                li.Quantity = 1;
                li.UnitPrice = 0;
                li.Tech_Product_Name__c = selectedProductDisplay.Name;
                li.Tech_Main_Image__c = selectedProductDisplay.Tech_Image_1__c;
                myLineItems.add(li);
            }
        }

        return null;
    }

    /* 
     *  deleteFromCart()
     *  Handles the complexity of deleting a product as a line item from the Order
     */
    public PageReference deleteFromCart() {
        system.debug('Delete from Cart starts : ' + productToDelete);

        if( productToDelete == null || productToDelete == '') {system.debug('Empty delete.'); return null;}
        else {
            productSet.remove(productToDelete);
            for(Integer i = 0; i < myLineItems.size(); i++){
                if(myLineItems[i].product__c == productToDelete){
                    myLineItems.remove(i);
                }
            }
        }

        productToDelete = '';

        return null;
    }
    

    public PageReference nextSlide() {
        system.debug('nextSlide starts');


        system.debug('selectedProduct : ' + Apexpages.currentPage().getParameters().get('selectedProduct'));
        system.debug('Step : ' + step);

        if(step == 0){

            selectedFamily1 = Apexpages.currentPage().getParameters().get('family1');

            families2 = new List<String>();
            for (Catalog_Categories__mdt mdt : [SELECT MasterLabel FROM Catalog_Categories__mdt Where Level__c = 2 and Parent_Category__c = :selectedFamily1 order by MasterLabel asc]){
                families2.add(mdt.MasterLabel);
            }


            //Update Mosaïc
            productsInFamily = new List<CatalogProduct__c>();

            String familyquery = '';

            for(String family2 : families2){
                if(familyquery == ''){
                    familyquery += 'AND ((Product_Application__c INCLUDES (\'' + family2 + '\') ';
                }
                else{
                    familyquery += 'or Product_Application__c INCLUDES (\'' + family2 + '\') ';
                }                
            }
            if(familyquery != ''){
                familyquery += ') or End_Markets__c INCLUDES (\'' + selectedFamily1 + '\')) ';
            }
            else{
                familyquery += 'AND End_Markets__c INCLUDES (\'' + selectedFamily1 + '\') ';
            }

            if(familyquery != ''){
                queryString = 'SELECT Id,Name,Product_Application__c,Plant_commercial_reference__c,Tech_Image_1__c,Rank__c ' +
                    'FROM CatalogProduct__c ' +
                    'WHERE Active_product__c = true '+ familyquery +
                    queryFilters +
                    'ORDER BY Name DESC NULLS FIRST';

                set<String> productsInFamilyIds = new set<String>();

                if(Database.query(queryString).size()>0){
                    for(CatalogProduct__c prd : Database.query(queryString)){
                        productsInFamily.add(prd);
                        productsInFamilyIds.add(prd.id);
                    }
                }

                //Look for the main image in attachments
                if(productsInFamilyIds.size() > 0){
                    for(ContentDocumentLink cdl : [Select ContentDocument.LatestPublishedVersionId, ContentDocument.Title from ContentDocumentLink Where LinkedEntityId IN :productsInFamilyIds]){
                        for(CatalogProduct__c prd : productsInFamily){
                            if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_1')){
                                prd.Tech_Image_1__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                            }
                        }
                    }
                }
            }           

            step = step + 1;

        }

        else if(step == 1){

            selectedFamily2 = Apexpages.currentPage().getParameters().get('family2');
            //Update Mosaïc
            productsInFamily = new List<CatalogProduct__c>();

            queryString = 'SELECT Id,Name,Product_Application__c,Plant_commercial_reference__c,Tech_Image_1__c,Rank__c ' +
                    'FROM CatalogProduct__c ' +
                    'WHERE Active_product__c = true AND Product_Application__c INCLUDES(\'' + selectedFamily2 + '\') ' +
                    queryFilters +
                    'ORDER BY Name DESC NULLS FIRST';

            set<String> productsInFamilyIds = new set<String>();

            if(Database.query(queryString).size()>0){
                for(CatalogProduct__c prd : Database.query(queryString)){
                    productsInFamily.add(prd);
                    productsInFamilyIds.add(prd.id);
                }
            }

            //Look for the main image in attachments
            if(productsInFamilyIds.size() > 0){
                for(ContentDocumentLink cdl : [Select ContentDocument.LatestPublishedVersionId, ContentDocument.Title from ContentDocumentLink Where LinkedEntityId IN :productsInFamilyIds]){
                    for(CatalogProduct__c prd : productsInFamily){
                        if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_1')){
                            prd.Tech_Image_1__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                        }
                    }
                }
            }

            step = step + 1;
        }

        else if(step == 2){

        }


        system.debug('Selected Family 1 : ' + selectedFamily1);
        system.debug('Selected Family 2 : ' + selectedFamily2);
        system.Debug('step : ' + step);
        system.debug(families2);
        system.debug(productsInFamily);
        system.debug('selectedProductDisplay : ' + selectedProductDisplay);

        filterScreen = false;

        return null;
    }

    public PageReference gotoProduct() {
        system.debug('gotoProduct starts product = ' + Apexpages.currentPage().getParameters().get('productId'));
        selectedProductDisplay = new CatalogProduct__c();
        //Update Product
        if([SELECT Id,Name,Link_to_PDF__c,Product_Application__c,Description__c,Decoration_Options__c,Default_Price__c,Inventory__c,Active_product__c FROM CatalogProduct__c WHERE Active_product__c = true AND Id = :Apexpages.currentPage().getParameters().get('productId') ORDER BY Name DESC NULLS FIRST].size()>0){
            CatalogProduct__c prd = [SELECT Id,Name,Link_to_PDF__c,Product_Application__c,Rank__c,Tech_Image_1__c,Tech_Image_2__c,Tech_Image_3__c,Tech_Image_4__c,MOQ_packing_in_k__c,Lead_Time__c,Lead_time_DDP_Europe__c,Lead_time_DDP_US__c,PricematriX__c,Mix_Match__c,Assembled_product_Length_mm__c,Filling_capacity_ml__c,Orifice_dimension_head_cap_mm__c,Number_of_pans__c,Assembled_product_Width_mm__c,Pan_well_size__c,Assembled_product_Diameter_mm__c,Cup_size__c,Assembled_product_height_mm__c,Tube_length_mm__c,Plant_commercial_reference__c,Flag_image__c,Description__c,Product_Attributes__c,Filling_Information__c,Formula_Type__c,Decoration_Options__c,Manufacturing_area_or_Made_in__c,Materials__c,More_Info__c,Default_Price__c,Inventory__c,Product_Category__c,Active_product__c FROM CatalogProduct__c WHERE Active_product__c = true AND Id=:Apexpages.currentPage().getParameters().get('productId')  ORDER BY Name DESC NULLS FIRST limit 1];
            
            //New and Award not displayed in the app
            prd.Product_Attributes__c = (prd.Product_Attributes__c!=null)?prd.Product_Attributes__c.replace('New;',''):null;
            prd.Product_Attributes__c = (prd.Product_Attributes__c!=null)?prd.Product_Attributes__c.replace('New',''):null;
            prd.Product_Attributes__c = (prd.Product_Attributes__c!=null)?prd.Product_Attributes__c.replace('Award;',''):null;
            prd.Product_Attributes__c = (prd.Product_Attributes__c!=null)?prd.Product_Attributes__c.replace('Award',''):null;

            prd.Product_Attributes__c = (prd.Product_Attributes__c!=null)?prd.Product_Attributes__c.replace(';','<br/>'):null;
            prd.Product_Application__c = (prd.Product_Application__c!=null)?prd.Product_Application__c.replace(';','<br/>'):null;
            prd.Filling_Information__c = (prd.Filling_Information__c!=null)?prd.Filling_Information__c.replace(';','<br/>'):null;
            prd.Formula_Type__c = (prd.Formula_Type__c!=null)?prd.Formula_Type__c.replace(';','<br/>'):null;
            prd.Decoration_Options__c = (prd.Decoration_Options__c!=null)?prd.Decoration_Options__c.replace(';','<br/>'):null;
            prd.Manufacturing_area_or_Made_in__c = (prd.Manufacturing_area_or_Made_in__c!=null)?prd.Manufacturing_area_or_Made_in__c.replace(';','<br/>'):null;
            prd.Materials__c = (prd.Materials__c!=null)?prd.Materials__c.replace(';','<br/>'):null;
            prd.Assembled_product_Diameter_mm__c = (prd.Assembled_product_Diameter_mm__c!=null)?prd.Assembled_product_Diameter_mm__c.replace(';',' / '):null;
            prd.Filling_capacity_ml__c = (prd.Filling_capacity_ml__c!=null)?prd.Filling_capacity_ml__c.replace(';',' / '):null;
            prd.Product_Category__c = (prd.Product_Category__c!=null)?prd.Product_Category__c.replace(';',' / '):null;
            prd.More_Info__c = (prd.More_Info__c!=null)?prd.More_Info__c.replace(';','<br/>'):null;

            //Look for the images in attachments
            for(ContentDocumentLink cdl : [Select ContentDocument.LatestPublishedVersionId, ContentDocument.Title from ContentDocumentLink Where LinkedEntityId = :prd.Id]){
                if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_1')){
                    prd.Tech_Image_1__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                }
                if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_2')){
                    prd.Tech_Image_2__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                }
                if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_T1')){
                    prd.Tech_Image_3__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                }
                if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_T2')){
                    prd.Tech_Image_4__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                }
            }

            selectedProductDisplay=prd;

        }

        step = 3;

        return null;
    }

    public void gotoHome() {
        system.debug('gotoHome starts');
        system.debug('reset step');
        step = 0;
        selectedFamily1 = '';
        selectedFamily2 = '';
        selectedProduct = '';
        filterScreen = false;
        filters = new set<String>();
        filtersList = new List<String>(filters);
        selectedProductDisplay = new CatalogProduct__c();

    }

    public PageReference goPrevious() {
        system.debug('goPrevious starts');

        system.debug('Selected Family 1 : ' + selectedFamily1);
        system.debug('Selected Family 2 : ' + selectedFamily2);
        system.debug('selectedProduct : ' + Apexpages.currentPage().getParameters().get('selectedProduct'));
        system.debug('Step : ' + step);


        if(step == 1){

        gotoHome();

        }

        else if(step == 2){
            families2 = new List<String>();
            for (Catalog_Categories__mdt mdt : [SELECT MasterLabel FROM Catalog_Categories__mdt Where Level__c = 2 and Parent_Category__c = :selectedFamily1 order by MasterLabel asc]){
                families2.add(mdt.MasterLabel);
            }

            //Update Mosaïc
            productsInFamily = new List<CatalogProduct__c>();

            String familyquery = '';

            for(String family2 : families2){
                if(familyquery == ''){
                    familyquery += 'AND ((Product_Application__c INCLUDES (\'' + family2 + '\') ';
                }
                else{
                    familyquery += 'or Product_Application__c INCLUDES (\'' + family2 + '\') ';
                }                
            }
            if(familyquery != ''){
                familyquery += ') or End_Markets__c INCLUDES (\'' + selectedFamily1 + '\')) ';
            }
            else{
                familyquery += 'AND End_Markets__c INCLUDES (\'' + selectedFamily1 + '\') ';
            }

            queryString = 'SELECT Id,Name,Product_Application__c,Plant_commercial_reference__c,Tech_Image_1__c,Rank__c ' +
                    'FROM CatalogProduct__c ' +
                    'WHERE Active_product__c = true ' + familyquery +
                    queryFilters +
                    'ORDER BY Name DESC NULLS FIRST';


            set<String> productsInFamilyIds = new set<String>();

            if(Database.query(queryString).size()>0){
                for(CatalogProduct__c prd : Database.query(queryString)){
                    productsInFamily.add(prd);
                    productsInFamilyIds.add(prd.id);
                }
            }

            //Look for the main image in attachments
            if(productsInFamilyIds.size() > 0){
                for(ContentDocumentLink cdl : [Select ContentDocument.LatestPublishedVersionId, ContentDocument.Title from ContentDocumentLink Where LinkedEntityId IN :productsInFamilyIds]){
                    for(CatalogProduct__c prd : productsInFamily){
                        if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_1')){
                            prd.Tech_Image_1__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                        }
                    }
                }
            }

            selectedFamily2 = null;
            step = step - 1;
            proceedFilter();
        }

        else if(step == 3) {
            if (selectedFamily2 != null && selectedFamily2 != '') {
                    //Update Mosaïc
                productsInFamily = new List<CatalogProduct__c>();

                queryString = 'SELECT Id,Name,Product_Application__c,Plant_commercial_reference__c,Tech_Image_1__c,Rank__c ' +
                        'FROM CatalogProduct__c ' +
                        'WHERE Active_product__c = true AND Product_Application__c INCLUDES(\'' + selectedFamily2 + '\') ' +
                        queryFilters +
                        'ORDER BY Name DESC NULLS FIRST';

                set<String> productsInFamilyIds = new set<String>();

                if(Database.query(queryString).size()>0){
                    for(CatalogProduct__c prd : Database.query(queryString)){
                        productsInFamily.add(prd);
                        productsInFamilyIds.add(prd.id);
                    }
                }

                //Look for the main image in attachments
                if(productsInFamilyIds.size() > 0){
                    for(ContentDocumentLink cdl : [Select ContentDocument.LatestPublishedVersionId, ContentDocument.Title from ContentDocumentLink Where LinkedEntityId IN :productsInFamilyIds]){
                        for(CatalogProduct__c prd : productsInFamily){
                            if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_1')){
                                prd.Tech_Image_1__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                            }
                        }
                    }
                }

                    step = step - 1 ;
                }

            else{

                families2 = new List<String>();
                for (Catalog_Categories__mdt mdt : [SELECT MasterLabel FROM Catalog_Categories__mdt Where Level__c = 2 and Parent_Category__c = :selectedFamily1 order by MasterLabel asc]){
                    families2.add(mdt.MasterLabel);
                }

                //Update Mosaïc
                productsInFamily = new List<CatalogProduct__c>();

                String familyquery = '';

                for(String family2 : families2){
                    if(familyquery == ''){
                        familyquery += 'AND ((Product_Application__c INCLUDES (\'' + family2 + '\') ';
                    }
                    else{
                        familyquery += 'or Product_Application__c INCLUDES (\'' + family2 + '\') ';
                    }                
                }
                if(familyquery != ''){
                    familyquery += ') or End_Markets__c INCLUDES (\'' + selectedFamily1 + '\')) ';
                }
                else{
                    familyquery += 'AND End_Markets__c INCLUDES (\'' + selectedFamily1 + '\') ';
                }

                if(familyquery != ''){
                    queryString = 'SELECT Id,Name,Product_Application__c,Plant_commercial_reference__c,Tech_Image_1__c,Rank__c ' +
                        'FROM CatalogProduct__c ' +
                        'WHERE Active_product__c = true '+ familyquery +
                        queryFilters +
                        'ORDER BY Name DESC NULLS FIRST';


                    set<String> productsInFamilyIds = new set<String>();

                    if(Database.query(queryString).size()>0){
                        for(CatalogProduct__c prd : Database.query(queryString)){
                            productsInFamily.add(prd);
                            productsInFamilyIds.add(prd.id);
                        }
                    }

                    //Look for the main image in attachments
                    if(productsInFamilyIds.size() > 0){
                        for(ContentDocumentLink cdl : [Select ContentDocument.LatestPublishedVersionId, ContentDocument.Title from ContentDocumentLink Where LinkedEntityId IN :productsInFamilyIds]){
                            for(CatalogProduct__c prd : productsInFamily){
                                if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_1')){
                                    prd.Tech_Image_1__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                                }
                            }
                        }
                    }
                }

                selectedFamily2 = null;
                selectedProductDisplay = null;
                filterScreen = false;
                proceedFilter();
                step = step - 2;
            }

        }

        //For the cart, just search what was the previous screen and go to it
        else if(step == 4){
            if(selectedProductDisplay != null){
                system.debug('from Cart to ProductPage');
                step = 3;
            }
            else if(selectedFamily2 != null){
                system.debug('from Cart to Page 3');
                step = 2;
            }
            else if(selectedFamily1 != null){
                system.debug('from Cart to Page 2');
                step = 1;
            }
            else{
                system.debug('from Cart to HomePage');
                step = 0;
            }
        }

        system.debug('step : ' + step);
        system.debug(families2);
        system.debug(productsInFamily);
        system.debug('selectedProductDisplay : ' + selectedProductDisplay);
        return null;

    }



    public pageReference unfilter() {
        system.debug('unfilter starts');

        filterSegment = '';
        queryFilters='';
        if(filterZone != null && filterZone != ''){
            queryFilters += 'and Area_of_Sales__c INCLUDES(\'' + filterZone + '\') ';
        }
        if(filterSegment != null && filterSegment != ''){
            queryFilters += 'and Customer_Segment__c INCLUDES(\'' + filterSegment + '\') ';
        }

        gotoHome();


        return null;

    }

    public pageReference filterScreen() {
        system.debug('filterScreen starts');

        filterScreen = true;

        return null;

    }

    public pageReference clickFilter() {
        system.debug('clickFilter starts');
        system.debug('filters : ' + filters);
        system.debug('filter number : ' + selectedFilter);


        if(filters == null){
            filters = new set<String>();
            filtersList = new List<String>(filters);
        }

        if(filters.contains(selectedFilter)){
            filters.remove(selectedFilter);
            filtersList = new List<String>(filters);
        }
        else{
            filters.add(selectedFilter);
            filtersList = new List<String>(filters);
        }

        return null;

    }

    public pageReference proceedFilter() {
        system.debug('proceedFilter starts');

        //Update Mosaïc
            productsInFamily = new List<CatalogProduct__c>();

            string queryfieldsfilter = '';

            String field1 = '';
            String field2 = '';
            String field3 = '';
            String field4 = '';
            String field5 = '';


            map<String, String> queryMap = new Map<String, String>();
            queryMap.put('1', '(The_ref_is_a_FS_product__c = false and Cosmetic_Accessories__c = \'\') ');
            queryMap.put('2', 'The_ref_is_a_FS_product__c = true ');
            queryMap.put('3', 'Cosmetic_Accessories__c != \'\' ');
            queryMap.put('4', 'MOQ_packing_in_k__c <= 5 ');
            queryMap.put('5', '(MOQ_packing_in_k__c >= 5 and MOQ_packing_in_k__c <= 10) ');
            queryMap.put('6', '(MOQ_packing_in_k__c >= 10 and MOQ_packing_in_k__c <= 20) ');
            queryMap.put('7', 'MOQ_packing_in_k__c >= 20 ');
            queryMap.put('8', 'Product_Attributes__c INCLUDES(\'Eco-design\') ');
            queryMap.put('9', 'Product_Attributes__c INCLUDES(\' Fast-Track\') ');
            queryMap.put('10', 'Product_Attributes__c INCLUDES(\'Airtight and or Airless\') ');
            queryMap.put('11', 'Product_Attributes__c INCLUDES(\'Halal\') ');
            queryMap.put('12', 'Product_Attributes__c INCLUDES(\'Travel size\') ');
            queryMap.put('13', 'Manufacturing_area_or_Made_in__c = \'France\' ');
            queryMap.put('14', 'Manufacturing_area_or_Made_in__c = \'Italy\' ');
            queryMap.put('15', 'Manufacturing_area_or_Made_in__c = \'Netherlands\' ');
            queryMap.put('16', 'Manufacturing_area_or_Made_in__c = \'Slovakia\' ');
            queryMap.put('17', 'Manufacturing_area_or_Made_in__c = \'United Kingdom\' ');
            queryMap.put('18', 'Manufacturing_area_or_Made_in__c = \'Russia\' ');
            queryMap.put('19', 'Manufacturing_area_or_Made_in__c = \'Germany\' ');
            queryMap.put('20', 'Manufacturing_area_or_Made_in__c = \'Spain\' ');
            queryMap.put('21', 'Manufacturing_area_or_Made_in__c = \'Poland\' ');
            queryMap.put('22', 'Manufacturing_area_or_Made_in__c = \'USA\' ');
            queryMap.put('23', 'Manufacturing_area_or_Made_in__c = \'Mexico\' ');
            queryMap.put('24', 'Manufacturing_area_or_Made_in__c = \'Brazil\' ');
            queryMap.put('25', 'Manufacturing_area_or_Made_in__c = \'Canada\' ');
            queryMap.put('26', 'Manufacturing_area_or_Made_in__c = \'China\' ');
            queryMap.put('27', 'Manufacturing_area_or_Made_in__c = \'India\' ');
            queryMap.put('28', 'Manufacturing_area_or_Made_in__c = \'Indonesia\' ');
            queryMap.put('29', 'Pack_produced_by_Albea__c = \'Yes\' ');
            queryMap.put('30', 'Pack_produced_by_Albea__c = \'No\' ');

            for(String nbr : filters){
                if(Integer.valueOf(nbr) > 0 && Integer.valueOf(nbr) <= 3){
                    if(field1 == ''){
                        field1 += 'and (';
                        field1 += queryMap.get(nbr);
                    }
                    else{
                        field1 += 'or ';
                        field1 += queryMap.get(nbr);
                    }
                }
                if(Integer.valueOf(nbr) > 3 && Integer.valueOf(nbr) <= 7){
                    if(field2 == ''){
                        field2 += 'and (';
                        field2 += queryMap.get(nbr);
                    }
                    else{
                        field2 += 'or ';
                        field2 += queryMap.get(nbr);
                    }
                }
                if(Integer.valueOf(nbr) > 7 && Integer.valueOf(nbr) <= 12){
                    if(field3 == ''){
                        field3 += 'and (';
                        field3 += queryMap.get(nbr);
                    }
                    else{
                        field3 += 'or ';
                        field3 += queryMap.get(nbr);
                    }
                }
                if(Integer.valueOf(nbr) > 12 && Integer.valueOf(nbr) <= 28){
                    if(field4 == ''){
                        field4 += 'and (';
                        field4 += queryMap.get(nbr);
                    }
                    else{
                        field4 += 'or ';
                        field4 += queryMap.get(nbr);
                    }
                }
                if(Integer.valueOf(nbr) > 28 && Integer.valueOf(nbr) <= 30){
                    if(field5 == ''){
                        field5 += 'and (';
                        field5 += queryMap.get(nbr);
                    }
                    else{
                        field5 += 'or ';
                        field5 += queryMap.get(nbr);
                    }
                }
            }

            if(field1 != ''){
                field1 += ') ';
            }
            if(field2 != ''){
                field2 += ') ';
            }
            if(field3 != ''){
                field3 += ') ';
            }
            if(field4 != ''){
                field4 += ') ';
            }
            if(field5 != ''){
                field5 += ') ';
            }



            queryfieldsfilter += field1 + field2 + field3 + field4 + field5;

            system.Debug('query on fields : ' + queryfieldsfilter);

            String familyquery = '';

           /* if(selectedFamily2 != '' && selectedFamily2 != null){
                familyquery += 'AND Product_Application__c INCLUDES(\'' + selectedFamily2 + '\') ';
            }

            else{
                for(String family2 : families2){
                    if(familyquery == ''){
                        familyquery += 'AND (Product_Application__c INCLUDES (\'' + family2 + '\') ';
                    }
                    else{
                        familyquery += 'or Product_Application__c INCLUDES (\'' + family2 + '\') ';
                    }                
                }
                if(familyquery != ''){
                    familyquery += ') ';
                }
            }*/


            for(String family2 : families2){
                    if(familyquery == ''){
                        familyquery += 'AND ((Product_Application__c INCLUDES (\'' + family2 + '\') ';
                    }
                    else{
                        familyquery += 'or Product_Application__c INCLUDES (\'' + family2 + '\') ';
                    }                
            }
            if(familyquery != ''){
                    familyquery += ') or End_Markets__c INCLUDES (\'' + selectedFamily1 + '\')) ';
            }
            else{
                    familyquery += 'AND End_Markets__c INCLUDES (\'' + selectedFamily1 + '\') ';
            }



            
            
            
            System.debug('@@ familyquery: '+ familyquery);
            System.debug('@@ queryFilters: '+ queryFilters);
            System.debug('@@ queryfieldsfilter: '+ queryfieldsfilter);
        
            queryString = 'SELECT Id,Name,Product_Application__c,Plant_commercial_reference__c,Tech_Image_1__c,Filling_capacity_ml__c,Assembled_product_Diameter_mm__c,Rank__c ' +
                    'FROM CatalogProduct__c ' +
                    'WHERE Active_product__c = true ' + familyquery +
                    queryFilters + queryfieldsfilter +
                    'ORDER BY Name DESC NULLS FIRST';

            System.debug('@@@ Query:' + queryString);
            set<String> productsInFamilyIds = new set<String>();

            if(Database.query(queryString).size()>0){
                for(CatalogProduct__c prd : Database.query(queryString)){

                    //We filter here for the fields 6 and 7 because it deals with multi select intervals
                    
                    boolean productOK6 = false;


                    if((filters.contains('31') || filters.contains('32') || filters.contains('33')) && prd.Assembled_product_Diameter_mm__c != null){
                        
                        List<string> values6 =  prd.Assembled_product_Diameter_mm__c.split(';');
                        for(string value : values6){
                            Double valueInt = Double.valueOf(value);
                            if(valueInt >= 1 && valueInt <= 15 && filters.contains('31')){
                                productOK6 = true;
                            }
                            if(valueInt >= 16 && valueInt <= 30 && filters.contains('32')){
                                productOK6 = true;
                            }
                            if(valueInt >= 31 && valueInt <= 50 && filters.contains('33')){
                                productOK6 = true;
                            }
                        }
                    }

                    else{
                        productOK6 = true;
                    }


                    boolean productOK7 = false;

                    if((filters.contains('34') || filters.contains('35') || filters.contains('36') || filters.contains('37') || filters.contains('38') || filters.contains('39')) && prd.Filling_capacity_ml__c != null){
                        
                        List<string> values7 =  prd.Filling_capacity_ml__c.split(';');
                        for(string value : values7){
                            Double valueInt = Double.valueOf(value);
                            if(valueInt >= 1 && valueInt <= 5 && filters.contains('34')){
                                productOK7 = true;
                            }
                            if(valueInt >= 6 && valueInt <= 49 && filters.contains('35')){
                                productOK7 = true;
                            }
                            if(valueInt >= 50 && valueInt <= 99 && filters.contains('36')){
                                productOK7 = true;
                            }
                            if(valueInt >= 100 && valueInt <= 199 && filters.contains('37')){
                                productOK7 = true;
                            }
                            if(valueInt >= 200 && valueInt <= 299 && filters.contains('38')){
                                productOK7 = true;
                            }
                            if(valueInt >= 300 && valueInt <= 500 && filters.contains('39')){
                                productOK7 = true;
                            }
                        }
                    }

                    else{
                        productOK7 = true;
                    }

                    if(productOK6 && productOK7){
                        productsInFamily.add(prd);
                        productsInFamilyIds.add(prd.id);
                    }
                    
                }
            }

            //Look for the main image in attachments
            if(productsInFamilyIds.size() > 0){
                for(ContentDocumentLink cdl : [Select ContentDocument.LatestPublishedVersionId, ContentDocument.Title from ContentDocumentLink Where LinkedEntityId IN :productsInFamilyIds]){
                    for(CatalogProduct__c prd : productsInFamily){
                        if(Integer.valueOf(cdl.ContentDocument.Title.substringBefore('_')) == prd.Rank__c && cdl.ContentDocument.Title.contains('_1')){
                            prd.Tech_Image_1__c = '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                        }
                    }
                }
            }
            
        filterScreen = false;

        return null;

    }

    public PageReference toCart() {
        system.debug('toCart starts');

        step = 4;
        // Directing to Cart
        return null;
    }


    public pageReference proceedCheckout() {
        system.debug('proceedCheckout starts');

        if(accId != null && accId != ''){
            Account acc = [Select Id, Street__c, Postal_code__c, City__c, Country__c from Account Where id = :accId limit 1];

            myOrder.AccountId = accId;
            myOrder.ShippingStreet = acc.Street__c;
            myOrder.ShippingPostalCode = acc.Postal_code__c;
            myOrder.ShippingCity = acc.City__c;
            myOrder.ShippingCountry = acc.Country__c;
            myOrder.EffectiveDate = system.today();
            myOrder.Status = 'New';
            if([SELECT Id, DeveloperName from RecordType Where SobjectType = 'Order' and DeveloperName = 'New' limit 1].size()>0){
                myOrder.RecordTypeId = [SELECT Id, DeveloperName from RecordType Where SobjectType = 'Order' and DeveloperName = 'New' limit 1].Id;
            }
            if([Select id, Name from PriceBook2 Where Name = 'Standard Price Book' limit 1].size()>0){
                    myOrder.PriceBook2Id = [Select id, Name from PriceBook2 Where Name = 'Standard Price Book' limit 1].id;

                    insert myOrder;
            }
            

            
        if([Select id, Name from PriceBookEntry Where Name = 'Generic sub-segment' limit 1].size()>0){
            for(OrderItem item : myLineItems){
                    
                item.OrderId = myOrder.Id;                
                item.PricebookEntryId = [Select id, Name from PriceBookEntry Where Name = 'Generic sub-segment' limit 1].id;
                item.UnitPrice = 0;
                item.Quantity = 1;

            }           

                insert myLineItems;

        }

            myOrder = new Order();
            myLineItems = new List<OrderItem>();

        }

        gotoHome();

        return null;

    }


}