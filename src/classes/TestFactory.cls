/**
* @author MDK
* @date 03/10/2017
* @description 
* <pre>
*
* </pre>
**/

@isTest
public class TestFactory {

    // Country
    public static List<Country__c> newCountry() {
        
        Map<String, String> countryCodeToName = new Map<String, String>{
            'SJ' => 'SVALBARD AND JAN MAY',
            'SK' => 'SLOVAKIA',
            'SL' => 'SIERRA LEONE',
            'SM' => 'SAN MARINO',
            'SN' => 'SENEGAL',
            'SO' => 'SOMALIA',
            'SR' => 'SURINAME',
            'ST' => 'SAO TOME AND PRINCIP',
            'SV' => 'EL SALVADOR',
            'SX' => 'SINT MAARTEN',
            'SY' => 'SYRIAN ARAB REPUBLIC',
            'SZ' => 'SWAZILAND',
            'TC' => 'TURKS AND CAICOS ISL',
            'YT' => 'MAYOTTE',
            'ZA' => 'SOUTH AFRICA',
            'ZM' => 'ZAMBIA',
            'ZW' => 'ZIMBABWE',
            'TH' => 'THAILAND',
            'TJ' => 'TAJIKISTAN',
            'TK' => 'TOKELAU',
            'TL' => 'TIMOR-LESTE',
            'TM' => 'TURKMENISTAN',
            'TN' => 'TUNISIA',
            'TO' => 'TONGA',
            'TR' => 'TURKEY',
            'TT' => 'TRINIDAD AND TOBAGO',
            'TV' => 'TUVALU',
            'TW' => 'TAIWAN, PROVINCE OF',
            'TZ' => 'TANZANIA, UNITED REP',
            'UA' => 'UKRAINE',
            'UG' => 'UGANDA',
            'UM' => 'UNITED STATES MINOR',
            'US' => 'UNITED STATES',
            'TD' => 'CHAD',
            'TF' => 'FRENCH SOUTHERN TERR',
            'TG' => 'TOGO',
            'UY' => 'URUGUAY',
            'UZ' => 'UZBEKISTAN',
            'VC' => 'SAINT VINCENT AND TH',
            'VE' => 'VENEZUELA, BOLIVARIA',
            'VG' => 'VIRGIN ISLANDS, BRIT',
            'VI' => 'VIRGIN ISLANDS, U.S.',
            'VN' => 'VIET NAM',
            'VU' => 'VANUATU',
            'WF' => 'WALLIS AND FUTUNA',
            'WS' => 'SAMOA',
            'YE' => 'YEMEN',
            'AE' => 'UNITED ARAB EMIRATES',
            'AF' => 'AFGHANISTAN',
            'AG' => 'ANTIGUA AND BARBUDA',
            'AI' => 'ANGUILLA',
            'AL' => 'ALBANIA',
            'AM' => 'ARMENIA',
            'AO' => 'ANGOLA',
            'AQ' => 'ANTARCTICA',
            'AR' => 'ARGENTINA',
            'AS' => 'AMERICAN SAMOA',
            'AT' => 'AUSTRIA',
            'AU' => 'AUSTRALIA',
            'AW' => 'ARUBA',
            'AX' => 'ÅLAND ISLANDS',
            'AZ' => 'AZERBAIJAN',
            'BA' => 'BOSNIA AND HERZEGOVI',
            'BB' => 'BARBADOS',
            'BD' => 'BANGLADESH',
            'AD' => 'ANDORRA',
            'BE' => 'BELGIUM',
            'BF' => 'BURKINA FASO',
            'BG' => 'BULGARIA',
            'BH' => 'BAHRAIN',
            'BI' => 'BURUNDI',
            'BJ' => 'BENIN',
            'BL' => 'SAINT BARTHÉLEMY',
            'BM' => 'BERMUDA',
            'BN' => 'BRUNEI DARUSSALAM',
            'BO' => 'BOLIVIA',
            'BQ' => 'BONAIRE, SINT EUSTAT',
            'BR' => 'BRAZIL',
            'BS' => 'BAHAMAS',
            'BT' => 'BHUTAN',
            'BV' => 'BOUVET ISLAND',
            'BW' => 'BOTSWANA',
            'BY' => 'BELARUS',
            'BZ' => 'BELIZE',
            'CA' => 'CANADA',
            'CC' => 'COCOS (KEELING) ISLA',
            'CD' => 'CONGO, THE DEMOCRATI',
            'CF' => 'CENTRAL AFRICAN REPU',
            'CG' => 'CONGO',
            'CH' => 'SWITZERLAND',
            'CK' => 'COOK ISLANDS',
            'CL' => 'CHILE',
            'CM' => 'CAMEROON',
            'CN' => 'CHINA',
            'CO' => 'COLOMBIA',
            'CR' => 'COSTA RICA',
            'CU' => 'CUBA',
            'CV' => 'CAPE VERDE',
            'CW' => 'CURAÇAO',
            'CX' => 'CHRISTMAS ISLAND',
            'CY' => 'CYPRUS',
            'CZ' => 'CZECH REPUBLIC',
            'DE' => 'GERMANY',
            'DJ' => 'DJIBOUTI',
            'DK' => 'DENMARK',
            'DM' => 'DOMINICA',
            'DO' => 'DOMINICAN REPUBLIC',
            'DZ' => 'ALGERIA',
            'EC' => 'ECUADOR',
            'EE' => 'ESTONIA',
            'EG' => 'EGYPT',
            'EH' => 'WESTERN SAHARA',
            'ER' => 'ERITREA',
            'ES' => 'SPAIN',
            'ET' => 'ETHIOPIA',
            'FI' => 'FINLAND',
            'FJ' => 'FIJI',
            'FK' => 'FALKLAND ISLANDS',
            'FM' => 'MICRONESIA, FEDERATE',
            'FO' => 'FAROE ISLANDS',
            'KM' => 'COMOROS',
            'KN' => 'SAINT KITTS AND NEVI',
            'KP' => 'KOREA, DEMOCRATIC PE',
            'KR' => 'KOREA, REPUBLIC OF',
            'KW' => 'KUWAIT',
            'KY' => 'CAYMAN ISLANDS',
            'KZ' => 'KAZAKHSTAN',
            'LB' => 'LEBANON',
            'LC' => 'SAINT LUCIA',
            'LI' => 'LIECHTENSTEIN',
            'LK' => 'SRI LANKA',
            'MF' => 'SAINT MARTIN (FRENCH',
            'MG' => 'MADAGASCAR',
            'MH' => 'MARSHALL ISLANDS',
            'MK' => 'MACEDONIA, THE FORME',
            'ML' => 'MALI',
            'MM' => 'MYANMAR',
            'MN' => 'MONGOLIA',
            'MO' => 'MACAO',
            'MP' => 'NORTHERN MARIANA ISL',
            'MQ' => 'MARTINIQUE',
            'MR' => 'MAURITANIA',
            'MS' => 'MONTSERRAT',
            'MT' => 'MALTA',
            'MU' => 'MAURITIUS',
            'MV' => 'MALDIVES',
            'MW' => 'MALAWI',
            'MX' => 'MEXICO',
            'MY' => 'MALAYSIA',
            'MZ' => 'MOZAMBIQUE',
            'NA' => 'NAMIBIA',
            'NC' => 'NEW CALEDONIA',
            'NE' => 'NIGER',
            'NF' => 'NORFOLK ISLAND',
            'NG' => 'NIGERIA',
            'NI' => 'NICARAGUA',
            'NL' => 'NETHERLANDS',
            'NO' => 'NORWAY',
            'NP' => 'NEPAL',
            'NR' => 'NAURU',
            'NU' => 'NIUE',
            'NZ' => 'NEW ZEALAND',
            'OM' => 'OMAN',
            'PA' => 'PANAMA',
            'FR' => 'FRANCE',
            'GA' => 'GABON',
            'GB' => 'UNITED KINGDOM',
            'GD' => 'GRENADA',
            'GE' => 'GEORGIA',
            'GF' => 'FRENCH GUIANA',
            'GG' => 'GUERNSEY',
            'GH' => 'GHANA',
            'GI' => 'GIBRALTAR',
            'GL' => 'GREENLAND',
            'GM' => 'GAMBIA',
            'GN' => 'GUINEA',
            'GP' => 'GUADELOUPE',
            'GQ' => 'EQUATORIAL GUINEA',
            'GR' => 'GREECE',
            'GS' => 'SOUTH GEORGIA AND TH',
            'GT' => 'GUATEMALA',
            'GU' => 'GUAM',
            'GW' => 'GUINEA-BISSAU',
            'GY' => 'GUYANA',
            'HK' => 'HONG KONG',
            'HM' => 'HEARD ISLAND AND MCD',
            'HN' => 'HONDURAS',
            'HR' => 'CROATIA',
            'HT' => 'HAITI',
            'HU' => 'HUNGARY',
            'ID' => 'INDONESIA',
            'IE' => 'IRELAND',
            'IL' => 'ISRAEL',
            'IM' => 'ISLE OF MAN',
            'IN' => 'INDIA',
            'IO' => 'BRITISH INDIAN OCEAN',
            'IQ' => 'IRAQ',
            'IR' => 'IRAN, ISLAMIC REPUBL',
            'IS' => 'ICELAND',
            'IT' => 'ITALY',
            'JE' => 'JERSEY',
            'JM' => 'JAMAICA',
            'JO' => 'JORDAN',
            'JP' => 'JAPAN',
            'KE' => 'KENYA',
            'KG' => 'KYRGYZSTAN',
            'KH' => 'CAMBODIA',
            'KI' => 'KIRIBATI',
            'LR' => 'LIBERIA',
            'LS' => 'LESOTHO',
            'LT' => 'LITHUANIA',
            'LU' => 'LUXEMBOURG',
            'LV' => 'LATVIA',
            'LY' => 'LIBYAN ARAB JAMAHIRI',
            'MA' => 'MOROCCO',
            'MC' => 'MONACO',
            'MD' => 'MOLDOVA, REPUBLIC OF',
            'ME' => 'MONTENEGRO',
            'PF' => 'FRENCH POLYNESIA',
            'PG' => 'PAPUA NEW GUINEA',
            'PH' => 'PHILIPPINES',
            'PK' => 'PAKISTAN',
            'PL' => 'POLAND',
            'PM' => 'SAINT PIERRE AND MIQ',
            'PN' => 'PITCAIRN',
            'PR' => 'PUERTO RICO',
            'PS' => 'PALESTINIAN TERRITOR',
            'PT' => 'PORTUGAL',
            'PW' => 'PALAU',
            'PY' => 'PARAGUAY',
            'QA' => 'QATAR',
            'RE' => 'REUNION',
            'RO' => 'ROMANIA',
            'RS' => 'SERBIA',
            'RU' => 'RUSSIAN FEDERATION',
            'RW' => 'RWANDA',
            'SA' => 'SAUDI ARABIA',
            'SB' => 'SOLOMON ISLANDS',
            'SC' => 'SEYCHELLES',
            'SD' => 'SUDAN',
            'SE' => 'SWEDEN',
            'SG' => 'SINGAPORE',
            'SH' => 'SAINT HELENA',
            'SI' => 'SLOVENIA',
            'PE' => 'PERU'
        };

        List<Country__c> countries = new List<Country__c>();

        for (String ctryCode : countryCodeToName.keySet()) {
            Country__c country = new Country__c(
                Name = countryCodeToName.get(ctryCode), 
                Country_Code__c = ctryCode
            );
            countries.add(country);
        }

        return countries;
    }   

    public static Country__c getFrance(){
        return new Country__c(Name = 'France', Country_Code__c = 'FR', Language_Key__c = 'E',
                                Zone__c = 'Western Europe', Zone_Code__c = 'WE');
    }

    public static Country__c getGermany(){
        return new Country__c(Name = 'Germany', Country_Code__c = 'DE', Language_Key__c = 'E',
                                Zone__c = 'Western Europe', Zone_Code__c = 'WE');
    }

    public static Country__c getUSA(){
        return new Country__c(Name = 'US', Country_Code__c = 'US', Language_Key__c = 'E',
                                Zone__c = 'North America', Zone_Code__c = 'NA');
    }
    // End Country

	// User
    public static User newUser(String firstName, String lastName, String profileName, Boolean kam, 
        Boolean director, Boolean additional, Boolean manager, Integer matriculeADS, Id profileId) {
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newUser start');
                       
        User user = new User(  
            FirstName = firstName,
            LastName = lastName,
            Email = 'test.apex'+String.valueOf(datetime.now().getTime())+'@albea-group.com',
            Username = firstName + '.'+ lastName + String.valueOf(datetime.now().getTime())+ '@albea-group.com',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = 'test',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            Additional__c = additional,
            Director__c = director,
            KAM__c = kam,
            Matricule_ADS__c = string.valueof(matriculeADS),
            Manager__c = manager,
            ProfileId = profileId,
            By_Pass_VR__c= true,
            Bypass_Process_Builder__c= 'Sales allocation generation'
        );                              
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newUser stop');
        return user;
    }

    public static User newUser(String firstName, String lastName, String profileName, Boolean kam, 
    	Boolean director, Boolean additional, Boolean manager, Integer matriculeADS) {

    	Profile profile = [
    		Select Id 
    		From Profile 
    		Where Name = :profileName
    	];

    	//UserRole role = [Select u.Id From UserRole u where u.Name = ''];
                       
        //User user = new User(  
        //	FirstName = firstName,
        //    LastName = lastName,
        //    Email = 'test.apex'+String.valueOf(datetime.now().getTime())+'@albea-group.com',
        //    Username = firstName + '.'+ lastName + String.valueOf(datetime.now().getTime())+ '@albea-group.com',
        //    EmailEncodingKey = 'ISO-8859-1',
        //    Alias = 'test',
        //    TimeZoneSidKey = 'America/Los_Angeles',
        //    LocaleSidKey = 'en_US',
        //    LanguageLocaleKey = 'en_US',
        //    Additional__c = additional,
        //    Director__c = director,
        //    KAM__c = kam,
        //    Matricule_ADS__c = string.valueof(matriculeADS),
        //    Manager__c = manager,
        //    ProfileId = profile.id
        //    //UserRoleId = role.Id
        //);                              
        
        return newUser(firstName, lastName, profileName, kam, director, additional, manager, matriculeADS, profile.Id);
    }

    public static User newUser(String firstName, String lastName, Integer matriculeADS) {
        return newUser(firstName, lastName, 'Standard User', true, true, true, true, matriculeADS);
    }
    
    public static User newUser(String profileName, Integer matriculeADS) {
        return newUser('Foo' + String.valueOf(datetime.now().getTime()), 'Bar' + String.valueOf(datetime.now().getTime()), profileName, true, true, true, true, matriculeADS);
    }
        
    public static User newUser(Integer matriculeADS) {
        return newUser('Fooo' + String.valueOf(datetime.now().getTime()), 'Barr' + String.valueOf(datetime.now().getTime()), matriculeADS);
    }

    public static User newKamUser(Integer matriculeADS) {
        return newUser('FooKam' + String.valueOf(datetime.now().getTime()), 'Kam' + String.valueOf(datetime.now().getTime()), 'SALES - KAM', true, false, false, false, matriculeADS);
    }

    public static User newKamUser(Integer matriculeADS, Id profileId) {
        return newUser('FooKamm' + String.valueOf(datetime.now().getTime()), 'Kamm' + String.valueOf(datetime.now().getTime()), 'SALES - KAM', true, false, false, false, matriculeADS, profileId);
    }

    public static User newDirectorUser(Integer matriculeADS) {
        return newUser('FooDirr' + String.valueOf(datetime.now().getTime()), 'Directorr' + String.valueOf(datetime.now().getTime()), 'SALES - KAM', false, true, false, false, matriculeADS);
    }

    public static User newDirectorUser(Integer matriculeADS, Id profileId) {
        return newUser('FooDir' + String.valueOf(datetime.now().getTime()), 'Director' + String.valueOf(datetime.now().getTime()), 'SALES - KAM', false, true, false, false, matriculeADS, profileId);
    }

    public static User newManagerUser(Integer matriculeADS) {
        return newUser('FooMgrr' + String.valueOf(datetime.now().getTime()), 'Managerr' + String.valueOf(datetime.now().getTime()), 'SALES - KAM', false, false, false, true, matriculeADS);
    }

    public static User newManagerUser(Integer matriculeADS, Id profileId) {
        return newUser('FooMgr' + String.valueOf(datetime.now().getTime()), 'Manager' + String.valueOf(datetime.now().getTime()), 'SALES - KAM', false, false, false, true, matriculeADS, profileId);
    }

    public static User newAdditionalUser(Integer matriculeADS) {
        return newUser('FooAddd' + String.valueOf(datetime.now().getTime()), 'Additional' + String.valueOf(datetime.now().getTime()), 'SALES - KAM', false, false, true, false, matriculeADS);
    }

    public static User newAdditionalUser(Integer matriculeADS, Id profileId) {
        return newUser('FooAdd' + String.valueOf(datetime.now().getTime()), 'Additionall' + String.valueOf(datetime.now().getTime()), 'SALES - KAM', false, false, true, false, matriculeADS, profileId);
    }
    // End User

   	// Account	
    public static Account newAccount(Id countryId, Id distribChannelId, Id salesAreaId, String stateID) {
    	return newAccount(countryId, distribChannelId, salesAreaId, stateID, 'XX');
	}

    public static Account newAccount(Id countryId, Id distribChannelId, Id salesAreaId, String stateID, String codeVAT) {
        
        Account acc = new Account(
            Name = StringUtils.generateRandomString(10), 
            Country__c = countryId,
            Distribution_Channel__c = distribChannelId,
            Sales_Area__c = salesAreaId,
            Account_status__c = 'Active',
            Type = 'Client',
            VAT_code__c = codeVAT,
            State_Region__c = stateID,
            Contract_filter__c = 'Yes'
        );

        return acc;
    }
    
    public static Account newAccount(Country__c country, Distribution_Channel__c testDistrib, Sales_Area__c testArea){
    	
    	Account acc = new Account(
    			Name = StringUtils.generateRandomString(10),
    			Country__c = country.Id,
    			Distribution_Channel__c=testDistrib.id,
        		Sales_Area__c=testArea.id,
        		Account_status__c = 'Active',
            	Type = 'Client',
            	Contract_filter__c = 'Yes'
        );

        return acc;
    }
    
    // End Account
    
    // Contact
    public static Contact newContact(Id accountId) {

        Contact con = newContact(
            accountId,
            'Contact'+StringUtils.generateRandomString(10),
            'FirstName'+StringUtils.generateRandomString(10),
            'Mr.',
            'Email'+StringUtils.generateRandomString(10)+'@test.com'
        );
             
        con.Language__c = 'Danish';
        con.Job_function__c = 'Purchasing';
        con.Job_title__c = 'Purchaser';
        con.Seniority__c = 'Manager';
        con.Contact_typ__c = 'PC - Primary Contact'; 
        con.Tubes__c = 'No'; 
        con.Dispensing_systems__c = 'Yes'; 
        con.Cosmetics_Rigide_package__c = 'No'; 
        con.Beauty_Sol_Product__c ='No'; 
        con.Direct_Marketing__c = 'Yes'; 
        con.Selected_customer_Survey__c = 'Yes';

        return con;
    }

    public static Contact newContact(Id accountId, String lastName, String firstName, String salutation, String email) {

        Contact con = new contact (
            LastName = lastName,
            Salutation = salutation,
            FirstName = firstName, 
            Email = email, 
            Language__c = 'Danish',
            Accountid = accountId,
            Job_function__c = 'Purchasing',
            Job_title__c = 'Purchaser',  
            Seniority__c = 'Manager',
            Contact_typ__c = 'PC - Primary Contact', 
            Tubes__c = 'No', 
            Dispensing_systems__c = 'Yes', 
            Cosmetics_Rigide_package__c = 'No', 
            Beauty_Sol_Product__c ='No', 
            Direct_Marketing__c = 'Yes', 
            Selected_customer_Survey__c = 'Yes'
        );

        return con;
    }
    // End Contact 

    // Sales Team
    public static Sales_Team__c newSalesTeam(Id kamId, Id managerId, Id additionalId, Id directorId, String name, String salesTeam) {

    	Sales_Team__c st = new Sales_Team__c(
    		KAM__c = kamId,
        	Manager__c = managerId,
        	Additional__c = additionalId,
        	Director__c = directorId,       
        	Name = name,
        	Sales_Team__c = salesTeam,
            Valid_To__c = SalesService.FUTURE_DATE,
            Valid_From__c = SalesService.YESTERDAY_DATE 
    	);

    	return st;
    }

    public static Sales_Team__c newSalesTeam(Id kamId, Id managerId, Id additionalId, Id directorId) {
    	return newSalesTeam(kamId,managerId,additionalId,directorId,'Test Team 1','1111');
    }
    // End Sales Team
    
    // Lead
    public static Lead newLead(String status, String leadSource, Id countryId, String productLine) {

        Lead lead = newLead(status);
        lead.Product_Line__c = productLine;
        lead.LeadSource = leadSource;
        lead.Country__c = countryId;

        return Lead;
    }

    public static Lead newLead(String status) {
        return newLead(
            status,
            'Bar'+StringUtils.generateRandomString(10),
            'Foo',
            'foobar'+StringUtils.generateRandomString(10)+'@gmail.com',
            'The Company'+String.valueOf(datetime.now().getTime())
        );
    }

    public static Lead newLead(String status, String lastName, String firstName, String email, String company) {

        Lead ld = new Lead(
            Status = status,
            LastName = lastName,
            FirstName = firstName,
            Email = email,
            Company = company        
        );                  
                                            
        return ld;
    }
    // End Lead
    
	// Distribution_Channel__c
    public static Distribution_Channel__c newDistributionChannel(String name, String code, String langKey) {
    	
    	Distribution_Channel__c distChannel = new Distribution_Channel__c(
			Name = name, 
			Distribution_Channel_Code__c = code,
			Language_Key__c   = langKey
		);

    	return distChannel;
	}

    public static Distribution_Channel__c newDistributionChannel() {
        
        Distribution_Channel__c distChannel = newDistributionChannel('DIRECT SALES','00001','E');
        return distChannel;
    }
    // End Distribution_Channel__c
    
    // Sales_Area__c
    public static Sales_Area__c newSalesArea (String name, String CustomerSize, String KeySalesArea,
    												   String LabelKeySalesArea, String langKey, 
    												   string areaCode, String catego) {
    	
    	Sales_Area__c salesArea = new Sales_Area__c(
    									Name 					= name,
										Customer_Size__c  		= CustomerSize,
										Key_Sales_Area__c 		= KeySalesArea ,
										Label_Key_Sales_Area__c = LabelKeySalesArea,
										Language_Key__c  		= langKey,
										Sales_Area_Code__c  	= areaCode,
										Sales_Category__c  		= catego
		);

    	return salesArea;
	}

    public static Sales_Area__c newSalesArea() {
        
        Sales_Area__c salesArea = newSalesArea(
        								'Interco Global accounts','GA','FRC',
        								'Interco Global accounts', 'E','FRC','G');
        return salesArea;
    }
    // End Sales_Area__c 
    
    // Products
    public static List<Product2> newProducts(Set<String> productNames) {
        return newProducts(productNames,'The Family'); 
    }

    public static List<Product2> newProducts(Set<String> productNames, String family) {

        List<Product2> products = new List<Product2>();
        List<Product_Sub_segment__c> productSubSegments = new List<Product_Sub_segment__c>();

        /**
         * EWA : Correction suite à une remonté de SonarQube, il y avait un insert dans une des boucles for
         */
        for(String name : productNames) {
    		Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
    			Name = name + 'TestTest'
  			);
  			productSubSegments.add(prod2);
        }
        insert productSubSegments;
        
        for(Integer i=0; i<productSubSegments.size(); i++){
            String prod2name = productSubSegments[i].Name;
            Integer prod2NameSize = prod2name.length();	
            Product2 prod = new Product2(   
                Name = productSubSegments[i].name.substring(0, prod2NameSize-8), 
                Family = family,
                isActive = true,
  				Product_Sub_Segment__c = productSubSegments[i].Id,
                ProductCode = 'test' + i
            );
            products.add(prod);
        }  

        return products;   
    }
    // End Products
    
    // Opportunity
    public static Opportunity newOpportunity (String name, String stage, String quoteType, ID contractID, Id accountId ) {
    	
    	Opportunity opp = new Opportunity(
			Name 					= name,
			StageName				= stage,
			Probability				= 60,
			Quote_Type__c			= quoteType,										
			ContractID 				= contractID,
            accountId               = accountId,
			closedate				= system.TODAY(),
			Account_manager_KAM__c  = 'Test user',
			Contract__c = 'No'
		);				

    	return opp;
	}
    // End Opportunity
    
    // Quote
    /**
     * @param String [ projectType : expected value = P0 | P0+ | P1 ] 
     * @param String [ status : expected value = Draft | Presented | Won | Killed By Albea | Killed By Customer | Lost | Under Manager Validation ]
     */
    public static Quote newQuote( String projectType, Date dueDate, string status, Id opportunityID ) {
    	
        Id priceBookId = Test.getStandardPricebookId();
    	return newQuote(projectType,dueDate,status,opportunityID,priceBookId);
	}

    public static Quote newQuote( String projectType, Date dueDate, string status, Id opportunityID, Id priceBookId) {

        Quote qte = new Quote(
                            Name ='Test Quote '+String.valueOf(datetime.now().getTime()),
                            Project_TYpe__c     = projectType,
                            Quote_Due_Date__c   = dueDate,
                            status              = status,
                            OpportunityID       = opportunityID,
                            Pricebook2Id        = priceBookId
                        );                  
                                            

        return qte;
    }
    // End Quote
   
    // QuoteLineItem
    public static QuoteLineItem newQuoteLineItem (Id quoteId, Id productId, Id priceBookEntryId, String prodCluster, String prodPlant, Double unitPrice, Integer quantity, String location) {

        QuoteLineItem qli = new QuoteLineItem (
            UnitPrice = unitPrice,
            Quantity = quantity,
            PriceBookEntryId = priceBookEntryId,
            Production_Cluster__c = prodCluster,
            Production_Plant__c = prodPlant,
            Product2Id = productId, 
            QuoteId = quoteId, 
            Location__c = location
        );

        return qli;
    }

    public static QuoteLineItem newQuoteLineItem (Id quoteId, Id productId, Id priceBookEntryId) {
        return newQuoteLineItem(quoteId, productId, pricebookEntryId,'Albea China','Hong Kong PC');
    }

    public static QuoteLineItem newQuoteLineItem (Id quoteId, Id productId, Id priceBookEntryId, String prodCluster, String prodPlant) {
        return newQuoteLineItem(quoteId,productId,priceBookEntryId,prodCluster,prodPlant,(Double) 12.0,100,'EU');
    }
    // End QuoteLineItem 
    
    // PM_Discount_corridor__c
    public static PM_Discount_corridor__c newPMDiscountCorridor(String location,string peerGroupName,string customerType,String distChannel,
    												string macroMarket,string activity,string peerGroup,integer sku,
    												string criteria1,string criteria2,string criteria3,string criteria4){
    
    	PM_Discount_corridor__c discCorr = new PM_Discount_corridor__c(
    					Location__c 			= location, 
    					peer_group_name__c 		= peerGroupName,
    					customer_type__c 		= customerType, 
    					distribution_channel__c = distChannel , 
    					macro_market__c 		= macroMarket , 
    					activity__c 			= activity, 
    					Peer_Group__c 			= peerGroup, 
    					SKU__c 					= sku,
    					Criteria_1__c 			= criteria1 ,
    					Criteria_2__c 			= criteria2,
    					Criteria_3__c 			= criteria3,
    					Criteria_4__c 			= criteria4,
    					P20__c    				= 0.05,
    					P50__c					= 0.02,
    					P80__c					= 0.01
    										
    	);
    	
    	return discCorr;	
    					 
    }
    
    public static PM_Discount_corridor__c newPMDiscountCorridor(){
    
    	PM_Discount_corridor__c discCorr = newPMDiscountCorridor('EU','Laminate_DOMESTIC ACCOUNT_30_M15','DOMESTIC ACCOUNT','',
    												'','Laminate Tube','MPG',13,
    												'30','M15',null,null);
    	
    	return discCorr;	
    					 
    }
    // End PM_Discount_corridor__c
    
    
    // PM Selected Tubes Config 
     public static PM_Selected_Tubes_Config__c newPMSelectedTubeConfig(String location , string prodSeg, ID qliId ){
     	PM_Selected_Tubes_Config__c selTC = new PM_Selected_Tubes_Config__c(
     		location__c = location, 
     		Product_segment__c = prodSeg, 
     		shape__c = 'Cylindrical', 
     		Diameter_mm__c = 30,
     		Fill_Capacity_ml__c = 75,
     		Dispensing_System_Name__c= 'M15',
     		Head_Name__c = 'M15'     		
     	);
     	
     	return selTC;	
     }
    //END PM Selected Tubes Config 
    
    // PM Selected Dispensing Config 
    public static PM_Selected_Dipsensing_config__c newPMSelectedDispConfig(String location , string prodSeg, ID qliId ){
     	PM_Selected_Dipsensing_config__c selDC = new PM_Selected_Dipsensing_config__c(
     		location__c = location, 
     		Product_segment__c = prodSeg, 
     		Attachment__c = 'Snap On', 
     		Actuator__c = 'Prodigio (Clean Point)',
     		Engine_Name__c = 'Prodigio',
     		Pack_Name__c= 'Prodigio'   		
     	);
     	
     	return selDC;	
     }
    //END PM Selected Dispensing Config 
    
	// PM_MOQ_price__c
    public static PM_MOQ_price__c newMoqPrice(decimal min,decimal max, string segmentName, ID idProductSegment,ID qliId, decimal listPrice ) {
    	
    	 PM_MOQ_price__c pmMOQ = new PM_MOQ_price__c(
                    MOQ_Min__c 						 = min,
                    MOQ_Max__c 						 = max,
                    PM_Selected_Tubes_Config__c		 = segmentName == 'Tubes' ? idProductSegment : null,
                    PM_Selected_Dipsensing_Config__c = segmentName == 'Dispensing' ? idProductSegment : null,
                    Quote_item__c = qliId,
                    List_Price__c = listPrice,
                    ExtId__c = min + '-' + idProductSegment
                );			
											

    	return pmMOQ;
	}
	
	 public static list<PM_MOQ_price__c> newMoqPrices(map<Integer,integer> mapMoqs, string segmentName, ID idProductSegment,ID qliId, decimal listPrice ) {
    	list<PM_MOQ_price__c> liMoqPrices = new list<PM_MOQ_price__c>();
    	Integer counter =0;
    	
    	for(Integer moq : mapMoqs.keyset()){
    		liMoqPrices.add(newMoqPrice(moq,mapMoqs.get(moq),segmentName,idProductSegment,qliId,listPrice+counter ));	    		
    		counter++;
    	}    														

    	return liMoqPrices;
	}
    // End PM_MOQ_price__c
    
    //state__c
     public static state__c newState(string name, string code ) {
    	
    	 state__c state = new state__c(
                  Name = name,
                  State_Code__c = code
                );			
											

    	return state;
	}
    
    //end state__c
    
    //Customer Management Area
    public static List<Customer_Management_Area__c> newCustomerManagementArea() { 

        List<String> cusManAreaNames = new List<String> {
            'HONG KONG PC',
            'Microsiga',
            'Navision Albea Slov.',
            'HPC Lodz (BAAN)',
            'Shanghai dispensing',
            'Plastic&Metal',
            'SAP',
            'KBM : TUA',
            'Microsiga : AB',
            'Business One : ACH (',
            'MFG Pro : TUA QT',
            'MFG Pro : ASA SB',
            'MFG Pro : OCE CO',
            'MFG Pro : OCE WW',
            'MFG Pro : AIN BA/GO',
            'Scala : ACH (ZH)',
            'Silog/Sage : FCF (PE',
            'Silog/Sage : FCF (PH',
            'OneS : TEE (NO)',
            'CMI Hong Kong',
            'Tex ZongShan',
            'Tex Hong Kong',
            'Albea Metal',
            'Sage BSE',
            'BI REXAM',
            'Surabaya RKT',
            'Thomaston ( BI REXAM',
            'HONG KONG PC',
            'SFG'
        };

        List<Customer_Management_Area__c> cusManAreas = new List<Customer_Management_Area__c>();

        for (String cusManAreaName : cusManAreaNames) {
            Customer_Management_Area__c cusManArea = new Customer_Management_Area__c(
                Customer_Management_Area__c = cusManAreaName
            );
            cusManAreas.add(cusManArea);
        }

        return cusManAreas;
    } 
    //End Customer Management Area
    
    //Plant Cluster
    public static List<Plant_and_Cluster__c> newPlantAndCluster(List<Customer_Management_Area__c> cusManAreas) { 

        List<list<String>> plantAndClusterRecs = new List<List<String>> {
            new List<String> {'Bernaville','Rigid Packaging Europe','SF','SFG','CRPE'},
            new List<String> {'Levice','Tubes Europe','LV','Navision Albea Slov.','TUE'},
            new List<String> {'Nesa','Albea India','NE','MFG Pro : AIN BA/GO','ASA'},
            new List<String> {'Alkmaar','Dispensing systems','AK','BI REXAM','DISP'},
            new List<String> {'Annecy','Rigid Packaging Europe','AN','BI REXAM','CRPE'},
            new List<String> {'Shanghai dispensing','Albea China','DS','Shanghai dispensing','ACH'},
            new List<String> {'Hong Kong PC','Albea China','HG','HONG KONG PC','ACH'},
            new List<String> {'Imbersago','Rigid Packaging Europe','IM','SAP','CRPE'},
            new List<String> {'Jundiai','Albea Brazil','JU','Microsiga','AB'},
            new List<String> {'Lacrost','Dispensing systems','LA','SAP','DISP'},
            new List<String> {'Le Treport','Dispensing systems','LT','SAP','DISP'},
            new List<String> {'Lodz PC','Tubes Europe','LZ','SAP','TUE'},
            new List<String> {'Trade Europe','Beauty Solutions','RB','BI REXAM','BS'}
        };

        Map<Object,SObject> cusManAreaIdsByName = SObjectUtils.toMap(cusManAreas,'Customer_Management_Area__c');
        List<Plant_and_Cluster__c> plantAndClusters = new List<Plant_and_Cluster__c>();
        for (List<String> rec : plantAndClusterRecs) {

            if (cusManAreaIdsByName.keySet().contains(rec[3])) {

                Plant_and_Cluster__c plantAndCluster = new Plant_and_Cluster__c(
                    Name = rec[0],
                    Cluster_Name__c = rec[1],
                    Plant_Code__c = rec[2],
                    Customer_Management_Area__c = cusManAreaIdsByName.get(rec[3]).Id,
                    Cluster_Code__c = rec[4]
                );

                plantAndClusters.add(plantAndCluster);                
            }

        }

        return plantAndClusters;
    }
    //End Plant Custer
   
   	//Start Sales Allocation   	
   	public static String LOG_CLASS_NAME = 'TestFactory';
   	
   	public static Sales_Allocations__c newSalesAllocations(Account account, Sales_Team__c salesTeam, String product,
    												Product2 productSubSegment, Date validFrom, Date validTo){
    													
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newSalesAllocations Start');
    													
        Sales_Allocations__c salesAllocation = new Sales_Allocations__c(
	        Account__c = account.Id,
	        Sales_Team__c = salesTeam.Id,
	        Product__c = product,
	        Product_Sub_Segment__c = productSubSegment.Id,
	        Valid_From__c = validFrom,
	        Valid_To__c = validTo
        );
        
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newSalesAllocations Stop');
        
        
        return salesAllocation;
    }
    
    //Product Sub Segment
    /**
     * [ newProductSegment description : will return a new product segment with the corresponding argument ]
     * @param String [ languageKey        : ]
     * @param String [ name               : ]
     * @param String [ productSegmentCode : ]
     * @return Product_Segment__c
     */
    public static Product_Segment__c newProductSegment(String languageKey, String name, String productSegmentCode){
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newProductSegment Start');
    	
    	Product_Segment__c newProductSegment = new Product_Segment__c(
    		Language_Key__c = languageKey,
    		Name = name,
    		Product_Segment_Code__c = productSegmentCode
    	);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newProductSegment Stop');
    	
    	return newProductSegment;
    }
    
    /**
     * [ newProductSubSegment description : will return a new product sub segment with the corresponding argument ]
     * @param String  [ ADSProductLine   : ]
     * @param String  [ languageKey      : ]
     * @param String  [ Name             : ]
     * @param Id      [ productSegmentId : ]
     * @param String  [ productSegment   : ]
     * @param Decimal [ zephyrTarget     : ]
     * @return Product_Sub_Segment__c
     */
    public static Product_Sub_Segment__c newProductSubSegment(String ADSProductLine,String languageKey, String Name, Id productSegmentId,
    										String productSegment, String shortDescription, Decimal zephyrTarget){
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newProductSubSegment Start');
    	
    	Product_Sub_Segment__c newProductSubSegment = new Product_Sub_Segment__c(
    		ADS_Product_Line__c = ADSProductLine,
    		Language_Key__c = languageKey,
    		Name = Name,
    		Product_Segment_Id__c = productSegmentId,
    		Product_Segment__c = productSegment,
    		Short_Description__c = shortDescription,
    		Zephyr_Target__c = zephyrTarget
    	);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newProductSubSegment Stop');
    	
    	return newProductSubSegment;
    }
    
    //Product2
    /**
     * [ newProduct description : will return a new Product Sub Segment (product2) with the corresponding argument ]
     * @param String  [ family            : ]
     * @param String  [ name              : ]
     * @param String  [ productCode       : ]
     * @param Id      [ productSubSegment : ]
     * @param Decimal [ renewalDate       : ]
     * @return Product2
     */
    public static Product2 newProduct(String family, String name, String productCode, Id productSubSegment, Decimal renewalDate){
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newProduct Start');
    	
    	Product2 newProduct = new Product2(
    		Family = family,
    		Name = name,
    		ProductCode = productCode,
    		Product_Sub_Segment__c = productSubSegment,
    		Renewal_rate__c = renewalDate
    	);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newProduct Stop');
    	
    	return newProduct;
    }
    
    //Opportunity creation
    /**
     * [ newOpportunity description : will return a new Opportunity with the corresponding argument ]
     * @param String [ name      : ]
     * @param String [ quoteType : ]
     * @param Id     [ accountId : ]
     */
    public static Opportunity newOpportunity(String name, String quoteType, Id accountid){
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newOpportunity Start');
    	
    	Opportunity opp = new Opportunity(
			Name 					= name,
			StageName				= 'Need Analysis',
			Probability				= 35,
			Quote_Type__c			= quoteType,	
            accountId               = accountId,
			closedate				= system.TODAY(),
			Account_manager_KAM__c  = 'No User',
			Contract__c = 'No'
		);				
		
		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newOpportunity Stop');

    	return opp;
    }
    
    /**
     * [ generateCodeVAT description : will return a randomly generated CodeVat ]
     * @param Integer [ length : if less than 3, will generate a 2 character long CodeVat]
     * @return a randomly generated CodeVat
     */
    public static String generateCodeVAT(Integer length){ 
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - generateCodeVAT Start');

    	//Generated a 2 character long starter   
    	List<Integer> charArr = new Integer[]{(Integer)(Math.random()*25) + 65, (Integer)(Math.random()*25) + 65};
    	String random2Char = String.fromCharArray(charArr);	
    	
    	//Generated a length-2 long digit only ender
    	String randomNDigit = '';
    	if(length > 3){
	    	List<Integer> complementaryNumberArr = new List<Integer>();
	    	for(Integer index = 0; index < length-2; index++){
	    		complementaryNumberArr.add((Integer)(Math.random()*9) + 48);
	    	}
	    	randomNDigit = String.fromCharArray(complementaryNumberArr);
    	}
    	
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - generateCodeVAT Stop');	

    	return random2Char + randomNDigit;
    }

    //PM_Price_Recommendation__c generation
    /**
     * [ getPMPriceRecommendation description : will return a new PM_Price_Recommendation__c for a Tubes configuration ]
     * @param  PM_Selected_Tubes_Config__c [ pmSelectedTubesConfig :                                ]
     * @param  Quote_Line_Item__c          [ qli                   :                                ]
     * @param  Integer                     [ MOQ                   :                                ]
     * @param  Integer                     [ minThreshholdPrice    :                                ]
     * @param  Integer                     [ lin1Price             :                                ]
     * @param  Integer                     [ lin2Price             :                                ]
     * @param  Integer                     [ lin3Price             :                                ]
     * @param  String                      [ maxThreshholdPrice    :                                ]
     * @return PM_Price_Recommendation__c  [ the price recommandation corresponding to the argument ]
     */
    public static PM_Price_Recommendation__c getPMPriceRecommendation(PM_Selected_Tubes_Config__c pmSelectedTubesConfig,
        QuoteLineItem qli, Integer MOQ, Integer minThreshholdPrice, Integer lin1Price, Integer lin2Price, 
        Integer lin3Price, Integer maxThreshholdPrice){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMPriceRecommendation Start');

        PM_Price_Recommendation__c newPMPriceRecommendation = new PM_Price_Recommendation__c(
            PM_Selected_Tubes_Config__c = pmSelectedTubesConfig.Id,
            Quote_Line_Item__c = qli.id,
            List_Price__c = 100,
            MOQ__c = MOQ,        
            Min_Threshhold_Price__c = minThreshholdPrice,
            Lin1_Price__c = lin1Price,
            Lin2_Price__c = lin2Price,
            Lin3_Price__c = lin3Price,
            Max_Threshhold_Price__c = maxThreshholdPrice
        );

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMPriceRecommendation Stop');

        return newPMPriceRecommendation;
    }

    /**
     * [ getPMPriceRecommendation description : will return a new PM_Price_Recommendation__c for a Dispensing configuration ]
     * @param  PM_Selected_Dipsensing_Config__c [ pmSelectedDispensingConfig :                           ]
     * @param  Quote_Line_Item__c               [ qli                        :                           ]
     * @param  Integer                          [ MOQ                        :                           ]
     * @param  Integer                          [ minThreshholdPrice         :                           ]
     * @param  Integer                          [ lin1Price                  :                           ]
     * @param  Integer                          [ lin2Price                  :                           ]
     * @param  Integer                          [ lin3Price                  :                           ]
     * @param  String                           [ maxThreshholdPrice         :                           ]
     * @return PM_Price_Recommendation__c       [ the price recommandation corresponding to the argument ]
     */
    public static PM_Price_Recommendation__c getPMPriceRecommendation(PM_Selected_Dipsensing_Config__c pmSelectedDispensingConfig,
        QuoteLineItem qli, Integer MOQ, Integer minThreshholdPrice, Integer lin1Price, Integer lin2Price, 
        Integer lin3Price, Integer maxThreshholdPrice){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMPriceRecommendation Start');

        PM_Price_Recommendation__c newPMPriceRecommendation = new PM_Price_Recommendation__c(
            PM_Selected_Dipsensing_Config__c = pmSelectedDispensingConfig.Id,
            Quote_Line_Item__c = qli.id,
            MOQ__c = MOQ,        
            Min_Threshhold_Price__c = minThreshholdPrice,
            Lin1_Price__c = lin1Price,
            Lin2_Price__c = lin2Price,
            Lin3_Price__c = lin3Price,
            Max_Threshhold_Price__c = maxThreshholdPrice
        );

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMPriceRecommendation Stop');

        return newPMPriceRecommendation;
    }

    /**
     * [ getPMSelectedTubesConfig description : will return a new PM_Selected_Tubes_Config__c for the corresponding argument ]
     * @param  String                      [ location             :                    ]
     * @param  String                      [ productSegment       :                    ]
     * @param  String                      [ shape                :                    ]
     * @param  Decimal                     [ diameterMM           :                    ]
     * @param  Decimal                     [ fillCapacityML       :                    ]
     * @param  String                      [ dispensingSystemName :                    ]
     * @param  String                      [ headName             :                    ]
     * @return PM_Selected_Tubes_Config__c [ the corresponding PM Selected Tube Config ]
     */
    public static PM_Selected_Tubes_Config__c getPMSelectedTubesConfig(String location, String productSegment, String shape,
            Decimal diameterMM, Decimal fillCapacityML, String dispensingSystemName, String headName){

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMSelectedTubesConfig Start');

        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig = new PM_Selected_Tubes_Config__c(
            Location__c = location,
            Product_segment__c= productSegment,
            Shape__c = shape,
            Diameter_mm__c = diameterMM,
            Fill_Capacity_ml__c = fillCapacityML,
            Dispensing_System_Name__c = dispensingSystemName,
            Head_Name__c = headName
        );

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMSelectedTubesConfig Stop');

        return newPMSelectedTubesConfig;
    }

    /**
     * [ getPMPriceDetail description : will return a new PM Price Detail ] 
     * @param  Integer                     [ listPrice             :  ]
     * @param  Integer                     [ MOQMax                :  ]
     * @param  Integer                     [ MOQMin                :  ]
     * @param  PM_Selected_Tubes_Config__c [ pmSelectedTubesConfig :  ]
     * @param  String                      [ name                  :  ]
     * @param  QuoteLineItem               [ qli                   :  ]
     * @param  String                      [ section               :  ]
     * @return PM_Price_Detail__c          [ a new PM_Price_Detail__c ]
     */
    public static PM_Price_Detail__c getPMPriceDetail(Integer listPrice, Integer MOQMax, Integer MOQMin,
        PM_Selected_Tubes_Config__c pmSelectedTubesConfig, String name, QuoteLineItem qli, String section){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMPriceDetail Start');

        PM_Price_Detail__c pmPriceDetail = new PM_Price_Detail__c(
            List_Price__c = listPrice,
            MOQ_Max__c = MOQMax,
            MOQ_Min__c = MOQMin,
            PM_Selected_Tubes_Config__c = pmSelectedTubesConfig.Id,
            Name = name,
            Quote_item__c = qli.id,
            Section__c = section
        );

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMPriceDetail Stop');

        return pmPriceDetail;
    }

    /**
     * [ getPMReviewNetPriceperMOQ description : return a new PM Review NetPrice per MOQ ]
     * @param  Decimal                       [ deltaVsListPrice      :               ]
     * @param  Decimal                       [ discount              :               ]
     * @param  Integer                       [ MOQUnits              :               ]
     * @param  PM_Price_Detail__c            [ pmPriceDetail         :               ]
     * @param  PM_Price_Recommendation__c    [ pmPriceRecommendation :               ]
     * @param  QuoteLineItem                 [ qli                   :               ]
     * @param  String                        [ quotedPriceColor      :               ]
     * @param  Integer                       [ reviewedPrice         :               ]
     * @param  Boolean                       [ selected              :               ]
     * @return PM_Review_NetPrice_per_MOQ__c [ The new PM_Review_NetPrice_per_MOQ__c ] 
     */
    public static PM_Review_NetPrice_per_MOQ__c getPMReviewNetPriceperMOQ(Decimal deltaVsListPrice, Decimal discount,
        Integer MOQUnits, PM_Price_Detail__c pmPriceDetail, PM_Price_Recommendation__c pmPriceRecommendation, 
        QuoteLineItem qli, String quotedPriceColor, Integer reviewedPrice, Boolean selected
    ){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMReviewNetPriceperMOQ Start');

        PM_Review_NetPrice_per_MOQ__c pmReviewNetPriceperMOQ = new PM_Review_NetPrice_per_MOQ__c(
            Delta_vs_List_Price__c = deltaVsListPrice,
            Discount__c = discount,
            MOQ_Units__c = MOQUnits,
            PM_Price_Detail__c = pmPriceDetail.Id,
            PriceReco__c = pmPriceRecommendation.Id,
            Quote_Line_item__c = qli.Id,
            Quoted_Price_Color__c = quotedPriceColor,
            Reviewed_price__c = reviewedPrice,
            Selected__c = selected
        );

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getPMReviewNetPriceperMOQ Stop');

        return pmReviewNetPriceperMOQ;
    }
	//Plant Segment Users creation
    /**
     * [ newPlant_Segment_Users description : will return a new Plant_Segment_Users__c with the corresponding argument ]
     * @param User [ User__c     : loockup to User ]
     * @param Product2 [ Product__c: loockup to Product2 if the created record has as a record type 'Sub Segment' ]
     * @param Plant_and_Cluster__c    [ Plant_and_Cluster__c : if the created record has as record type: 'Plant' ]
     */
    public static Plant_Segment_Users__c newPlant_Segment_Users(Plant_and_Cluster__c plant, Product2 subSegment, User u,String recordTypeName)
	{
		RecordType rectype=[select id, Name, sObjectType from recordType where Name = :recordTypeName and sObjectType='Plant_Segment_Users__c' limit 1];
        Plant_Segment_Users__c plantSegUser=null;

		if(recordTypeName=='Plant')
		plantSegUser=new Plant_Segment_Users__c(User__c=u.id,Plant_and_Cluster__c=plant.id,Product__c =null, RecordTypeId=rectype.id);
		if(recordTypeName=='Sub Segment') 
		plantSegUser=new Plant_Segment_Users__c(User__c=u.id,Plant_and_Cluster__c=null,Product__c =subSegment.id, RecordTypeId=rectype.id);

        return plantSegUser;
	}
}