/**
 * @File Name          : SAP_Utility.cls
 * @Description        :
 * @Author             : Roman Hnativ
 * @Group              :
 * @Last Modified By   : Roman Hnativ
 * @Last Modified On   : 03-18-2021
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    1/20/2020          Roman Hnativ           Initial Version
 * 2.0    10/15/2025         Andrei Pivavarchyk     Account_GKA record type added
 **/
public class SAP_Utility {
    public static string NewRecordStatus = 'New';
    public static string SuccessRecordStatus = 'Success';
    public static string ErrorRecordStatus = 'Error';

    public static string AccountGroup_CustomerHirerarchy = 'ZHIE';
    public static string AccountGroup_ShipToParty = 'ZSSP';
    public static string AccountGroup_SoldToParty = 'ZSCU';
    public static string AccountGroup_BillTo = 'ZSBL';
    public static string AccountGroup_Payer = 'ZSPY';

    public static string Account_CustomerHirerarchyRT = 'Customer_Hierarchy';
    public static string Account_SalesAreaRT = 'Sales_Area'; 
    public static string Account_ShipToPartyRT = 'ShipToParty';
    public static string Account_ProspectRT = 'Prospect';
    public static string Account_GKA = 'GKA';

    public static Double toDouble1(string val) {
        if (string.isBlank(val)) {
            return 1.0; 
        }

        return Double.valueOf(val);
    }

    public static Double toDouble(string val) {
        if (string.isBlank(val)) {
            return null;
        }

        if (val.endsWith('-'))
        {
            val = '-'+val.replace('-', '');
        }



        return Double.valueOf(val);
    }


    public static string form_SA_Key(string SAP_KUNNR, string SAP_VKORG, string SAP_VTWEG, string SAP_SPART)
    {
        return SAP_KUNNR.leftPad(10, '0') + '_' + SAP_VKORG + '_' + SAP_VTWEG + '_' + SAP_SPART;
    }

    public static string cutZero(string val) {
        if (val.startsWith('0'))
        {
             return SAP_Utility.cutZero(val.removeStart('0'));
        }
             return val;
    }



    public static date toDate(String dat){
        if (string.isNotEmpty(dat)) {

            if (dat == '00000000')
            {
                return Date.today();
            }

            if (dat == '99991231')
            {
                return Date.valueOf('4000-12-31');
            }

            string dateStrSF = dat.left(4) + '-' + dat.mid(4, 2) + '-' + dat.right(2);
            Date dateSF = Date.valueOf(dateStrSF);

            if(dateSF > Date.valueOf('4000-12-31')) {
                return Date.valueOf('4000-12-31');
            } else {
                return dateSF;
            }
        }

        return null;
    }

    public static  Map<string,string> PlantMap = new map<string,string>{
        'Plant_Schladen__c' => '0500',
        'Plant_Clauen__c'=>'0800',
        'Plant_Lehrte__c'=>'0800/SI30',
        'Plant_Wierthe__c'=>'0800/SI35',
        'Plant_Uelzen__c'=>'1100',
        'Plant_LiqNST__c'=>'2500',
        'Plant_LiqMUN__c'=>'2800',
        'Plant_Nordstemmen__c'=>'3500',
        'Plant_Nakskov__c'=>'4010',
        'Plant_Nykobing__c'=>'4020',
        'Plant_Stege__c'=>'4020/SI61',
        'Plant_Sakskobing__c'=>'4020/SI60',
        'Plant_Gorlev__c'=>'4020/SI30+SI31',
        'Plant_Wanzleben__c'=>'4101',
        'Plant_Arlov__c'=>'4410',
        'Plant_Ortfota__c'=>'4440',
        'Plant_Sakyla__c'=>'4620',
        'Plant_Porkkala__c'=>'4630',
        'Plant_Kedainiai__c'=>'4700',
        'Plant_Opalenica__c'=>'5100',
        'Plant_Chelmza__c'=>'5200',
        'Plant_Tepla__c'=>'6100'
    };



  public static  Map<string,string> CountryMap = new map<string,string>{'AD' => 'Andorra'
       ,'AE' => 'United Arab Emirates'
       ,'AF' => 'Afghanistan '
       ,'AG' => 'Antigua and Barbuda '
       ,'AI' => 'Anguilla'
       ,'AL' => 'Albania '
       ,'AM' => 'Armenia '
       ,'AO' => 'Angola'
       ,'AQ' => 'Antarctica'
       ,'AR' => 'Argentina '
       ,'AS' => 'American Samoa'
       ,'AT' => 'Austria '
       ,'AU' => 'Australia '
       ,'AW' => 'Aruba '
       ,'AX' => 'Åland Islands '
       ,'AZ' => 'Azerbaijan'
       ,'BA' => 'Bosnia and Herzegovina'
       ,'BB' => 'Barbados'
       ,'BD' => 'Bangladesh'
       ,'BE' => 'Belgium '
       ,'BF' => 'Burkina Faso'
       ,'BG' => 'Bulgaria'
       ,'BH' => 'Bahrain '
       ,'BI' => 'Burundi '
       ,'BJ' => 'Benin '
       ,'BL' => 'Saint Barthélemy'
       ,'BM' => 'Bermuda '
       ,'BN' => 'Brunei Darussalam'
       ,'BO' =>'Bolivia'
       ,'BR' =>'Brazil'
       ,'BS' =>'Bahamas'
       ,'BT' =>'Bhutan'
       ,'BV' =>'Bouvet Island'
       ,'BW' =>'Botswana'
       ,'BY' =>'Belarus'
       ,'BZ' =>'Belize'
       ,'CA' =>'Canada'
       ,'CC' =>'Cocos (Keeling) Islands'
       ,'CD' =>'Congo, Democratic Republic of the'
       ,'CF' =>'Central African Republic'
       ,'CG' =>'Congo'
       ,'CH' =>'Switzerland'
       ,'CI' =>'Côte dIvoire'
       ,'CK' =>'Cook Islands'
       ,'CL' =>'Chile'
       ,'CM' =>'Cameroon'
       ,'CN' =>'China'
       ,'CO' =>'Colombia'
       ,'CR' =>'Costa Rica'
       ,'CU' =>'Cuba'
       ,'CV' =>'Cabo Verde'
       ,'CW' =>'Curaçao'
       ,'CX' =>'Christmas Island'
       ,'CY' =>'Cyprus'
       ,'CZ' =>'Czechia'
       ,'DE' =>'Germany'
       ,'DJ' =>'Djibouti'
       ,'DK' =>'Denmark'
       ,'DM' =>'Dominica'
       ,'DO' =>'Dominican Republic'
       ,'DZ' =>'Algeria'
       ,'EC' =>'Ecuador'
       ,'EE' =>'Estonia'
       ,'EG' =>'Egypt'
       ,'EH' =>'Western Sahara'
       ,'ER' =>'Eritrea'
       ,'ES' =>'Spain'
       ,'ET' =>'Ethiopia'
       ,'FI' =>'Finland'
       ,'FJ' =>'Fiji'
       ,'FK' =>'Falkland Islands (Malvinas)'
       ,'FM' =>'Micronesia (Federated States of)'
       ,'FO' =>'Faroe Islands'
       ,'FR' =>'France'
       ,'GA' =>'Gabon'
       ,'GB' =>'United Kingdom of Great Britain and Northern Irela'
       ,'GD' =>'Grenada'
       ,'GE' =>'Georgia'
       ,'GF' =>'French Guiana'
       ,'GG' =>'Guernsey'
       ,'GH' =>'Ghana'
       ,'GI' =>'Gibraltar'
       ,'GL' =>'Greenland'
       ,'GM' =>'Gambia'
       ,'GN' =>'Guinea'
       ,'GP' =>'Guadeloupe'
       ,'GQ' =>'Equatorial Guinea'
       ,'GR' =>'Greece'
       ,'GS' =>'South Georgia and the South Sandwich Islands'
       ,'GT' =>'Guatemala'
       ,'GU' =>'Guam'
       ,'GW' =>'Guinea-Bissau'
       ,'GY' =>'Guyana'
       ,'HK' =>'Hong Kong'
       ,'HM' =>'Heard Island and McDonald Islands'
       ,'HN' =>'Honduras'
       ,'HR' =>'Croatia'
       ,'HT' =>'Haiti'
       ,'HU' =>'Hungary'
       ,'ID' =>'Indonesia'
       ,'IE' =>'Ireland'
       ,'IL' =>'Israel'
       ,'IM' =>'Isle of Man'
       ,'IN' =>'India'
       ,'IO' =>'British Indian Ocean Territory'
       ,'IQ' =>'Iraq'
       ,'IR' =>'Iran (Islamic Republic of)'
       ,'IS' =>'Iceland'
       ,'IT' =>'Italy'
       ,'JE' =>'Jersey'
       ,'JM' =>'Jamaica'
       ,'JO' =>'Jordan'
       ,'JP' =>'Japan'
       ,'KE' =>'Kenya'
       ,'KG' =>'Kyrgyzstan'
       ,'KH' =>'Cambodia'
       ,'KI' =>'Kiribati'
       ,'KM' =>'Comoros'
       ,'KN' =>'Saint Kitts and Nevis'
       ,'KP' =>'Korea (Democratic Peoples Republic of)'
       ,'KR' =>'Korea, Republic of'
       ,'KW' =>'Kuwait'
       ,'KY' =>'Cayman Islands'
       ,'KZ' =>'Kazakhstan'
       ,'LA' =>'Lao Peoples Democratic Republic'
       ,'LB' =>'Lebanon'
       ,'LC' =>'Saint Lucia'
       ,'LI' =>'Liechtenstein'
       ,'LK' =>'Sri Lanka'
       ,'LR' =>'Liberia'
       ,'LS' =>'Lesotho'
       ,'LT' =>'Lithuania'
       ,'LU' =>'Luxembourg'
       ,'LV' =>'Latvia'
       ,'LY' =>'Libya'
       ,'MA' =>'Morocco'
       ,'MC' =>'Monaco'
       ,'MD' =>'Moldova, Republic of'
       ,'ME' =>'Montenegro'
       ,'MF' =>'Saint Martin (French part)'
       ,'MG' =>'Madagascar'
       ,'MH' =>'Marshall Islands'
       ,'MK' =>'North Macedonia'
       ,'ML' =>'Mali'
       ,'MM' =>'Myanmar'
       ,'MN' =>'Mongolia'
       ,'MO' =>'Macao'
       ,'MP' =>'Northern Mariana Islands'
       ,'MQ' =>'Martinique'
       ,'MR' =>'Mauritania'
       ,'MS' =>'Montserrat'
       ,'MT' =>'Malta'
       ,'MU' =>'Mauritius'
       ,'MV' =>'Maldives'
       ,'MW' =>'Malawi'
       ,'MX' =>'Mexico'
       ,'MY' =>'Malaysia'
       ,'MZ' =>'Mozambique'
       ,'NA' =>'Namibia'
       ,'NC' =>'New Caledonia'
       ,'NE' =>'Niger'
       ,'NF' =>'Norfolk Island'
       ,'NG' =>'Nigeria'
       ,'NI' =>'Nicaragua'
       ,'NL' =>'Netherlands'
       ,'NO' =>'Norway'
       ,'NP' =>'Nepal'
       ,'NR' =>'Nauru'
       ,'NU' =>'Niue'
       ,'NZ' =>'New Zealand'
       ,'OM' =>'Oman'
       ,'PA' =>'Panama'
       ,'PE' =>'Peru'
       ,'PF' =>'French Polynesia'
       ,'PG' =>'Papua New Guinea'
       ,'PH' =>'Philippines'
       ,'PK' =>'Pakistan'
       ,'PL' =>'Poland'
       ,'PM' =>'Saint Pierre and Miquelon'
       ,'PN' =>'Pitcairn'
       ,'PR' =>'Puerto Rico'
       ,'PS' =>'Palestine, State of'
       ,'PT' =>'Portugal'
       ,'PW' =>'Palau'
       ,'PY' =>'Paraguay'
       ,'QA' =>'Qatar'
       ,'RE' =>'Réunion'
       ,'RO' =>'Romania'
       ,'RS' =>'Serbia'
       ,'RU' =>'Russian Federation'
       ,'RW' =>'Rwanda'
       ,'SA' =>'Saudi Arabia'
       ,'SB' =>'Solomon Islands'
       ,'SC' =>'Seychelles'
       ,'SD' =>'Sudan'
       ,'SE' =>'Sweden'
       ,'SG' =>'Singapore'
       ,'SH' =>'Saint Helena, Ascension and Tristan da Cunha'
       ,'SI' =>'Slovenia'
       ,'SJ' =>'Svalbard and Jan Mayen'
       ,'SK' =>'Slovakia'
       ,'SL' =>'Sierra Leone'
       ,'SM' =>'San Marino'
       ,'SN' =>'Senegal'
       ,'SO' =>'Somalia'
       ,'SR' =>'Suriname'
       ,'SS' =>'South Sudan'
       ,'ST' =>'Sao Tome and Principe'
       ,'SV' =>'El Salvador'
       ,'SX' =>'Sint Maarten (Dutch part)'
       ,'SY' =>'Syrian Arab Republic'
       ,'SZ' =>'Eswatini'
       ,'TC' =>'Turks and Caicos Islands'
       ,'TD' =>'Chad'
       ,'TF' =>'French Southern Territories'
       ,'TG' =>'Togo'
       ,'TH' =>'Thailand'
       ,'TJ' =>'Tajikistan'
       ,'TK' =>'Tokelau'
       ,'TL' =>'Timor-Leste'
       ,'TM' =>'Turkmenistan'
       ,'TN' =>'Tunisia'
       ,'TO' =>'Tonga'
       ,'TR' =>'Turkey'
       ,'TT' =>'Trinidad and Tobago'
       ,'TV' =>'Tuvalu'
       ,'TW' =>'Taiwan, Province of China'
       ,'TZ' =>'Tanzania, United Republic of'
       ,'UA' =>'Ukraine'
       ,'UG' =>'Uganda'
       ,'UM' =>'United States Minor Outlying Islands'
       ,'US' =>'United States of America'
       ,'UY' =>'Uruguay'
       ,'UZ' =>'Uzbekistan'
       ,'VA' =>'Holy See'
       ,'VC' =>'Saint Vincent and the Grenadines'
       ,'VE' =>'Venezuela (Bolivarian Republic of)'
       ,'VG' =>'Virgin Islands (British)'
       ,'VI' =>'Virgin Islands (U.S.)'
       ,'VN' =>'Viet Nam'
       ,'VU' =>'Vanuatu'
       ,'WF' =>'Wallis and Futuna'
       ,'WS' =>'Samoa'
       ,'YE' =>'Yemen'
       ,'YT' =>'Mayotte'
       ,'ZA' =>'South Africa'
       ,'ZM' =>'Zambia'
       ,'ZW' =>'Zimbabwe'
    };

}