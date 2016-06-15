#!/usr/bin/php
<?php
var_dump(getPlyStat("76561198055041232"));
# Get playtime from steamid.
function getPlyTme($sStid){
    $sUrl = "http://62.138.3.36:8082/api/getplayerslocation?adminuser=zigstum&admintoken=donkey";
    $aRes = json_decode(file_get_contents($sUrl), true);
    //var_dump($aRes['528']['totalplaytime'] / 60); die();
    $aMatches = array_find_deep($aRes, $sStid);
    # If array has values, return playtime.
    if(count($aMatches)){
        $iKey = $aMatches[0];
        $iPlTme = $aRes[$iKey]['totalplaytime'];
        return($iPlTme);
    } # No playtime return false.
    return false;
}
# Multidim array search:
# https://www.sitepoint.com/community/t/best-way-to-do-array-search-on-multi-dimensional-array/16382/3

function array_find_deep($array, $search, $keys = array()){
    foreach($array as $key => $value) {
        if (is_array($value)) {
            $sub = array_find_deep($value, $search, array_merge($keys, array($key)));
            if (count($sub)) {
                return $sub;
            }
        } elseif ($value === $search) {
            return array_merge($keys, array($key));
        }
    }
    return array();
}
function getPlyStat($iStid){
    require_once('/home/sdtd/instances/7n2l/hooks/scripts/MysqliDb.php');
    #inititate db resource
    $rDB = new MysqliDb ('localhost', 'n2lcom_dolphin', 'g433%jBp', 'n2lcom_dolphin');
    #get this user donor date if exists.
    $rDB->where ("steam_id", $iStid);
    $aUser = $rDB->getOne ("zigs_steamcon_accounts");
    #now check date of expiration for res slot.
    if( $aUser['donor'] > time() ){
        #has reserved slot, is it admin? (10x9)
        if($aUser['donor'] == '9999999999'){ #admin
            return "admin";
        }
        return array($aUser['donor']); #not admin, must be donor.
    } else {
        return "none"; #not admin or donor.
    }
}
?>