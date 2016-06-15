#!/usr/bin/php
<?php
$iPlTme = getPlyTme("76561198055041232");
$iPlmins = gmdate("H:i:s",$iPlTme);
var_dump($iPlTme); die();


function getPlyTme($sStid){
    $sUrl = "http://62.138.3.36:8092/api/getplayerslocation?adminuser=zigstum&admintoken=donkey";
    $aRes = json_decode(file_get_contents($sUrl), true);
    $aMatches = array_find_deep($aRes, $sStid);
    # If array has values, return playtime.
    if(count($aMatches)){
        $iKey = $aMatches[0];
        $iPlTme = $aRes[$iKey]['totalplaytime'];
        return($iPlTme);
    } # No playtime return false.
    return false;
}

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