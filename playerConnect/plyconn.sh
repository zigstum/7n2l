#!/usr/bin/php
#Throw away script to test function output.
<?php
/*  TODO: 
    Get messages into separate file.
    Maybe some sleep times in bash scripts? TP, noob messages.
*/
ini_set("log_errors" , "1");
ini_set("error_log" , "/home/sdtd/instances/dev/phperrors.log.txt");
ini_set("display_errors" , "0");
# Get constants.
include("/home/sdtd/instances/dev/hooks/inc.php");

# $0 Script Path, $1 Instance, $2 Entity id, Player $3, steam ID: $4, IP: $5 ownerstid: $6(?)
$sInst=$argv[1];$sEntId=$argv[2];$sPlNme=$argv[3];$iStid=$argv[4];$sIP=$argv[5];

#Colours [make them into functions to wrap certain words]
function _c($sType, $sStr){
    $e="[ff4d4d]"; #Error
    $s="[99ff33]"; #Success
    $a="[4da6ff]"; #Alternative
    $d="[ffff4d]"; #Default
    $w="[ff8533]"; #Warning
    $cl="[-]"; #closer.
    return $$sType.$sStr.$cl;
}
####################################
# Geo Ip screening Section.
####################################
# Banned continents:
$sCont = getCont($sIP);
if($sCont == aBanned){
    #cont is banned kick user and exit.
    append("ban user from banned cont\n");
    $bRes = SH_Ban($iStid);
    # player kicked, exit.
    die();
}
append("legit IP, continue...\n");
$sPlyType = getPlyStat($iStid); #get player type, will need it anyway.

####################################
# Reserved Slot Section.
####################################
# set max slots
$iMaxSlots = 10;
# Get current player count.
$iPlyOn = getPlyOn();
#get player type:
# Check against max on:
if($iPlyOn >= $iMaxSlots){
    append("server full...\n");# Server full, check playinfo.
    if($sPlyType == "none"){ # non donor kick with messages.
        $sMsg = wrapSlash("Sorry to be rude {$sPlNme}, but there are no spaces left. See 7n2l.com for info on reserving a slot.");
        $bRes = SH_Kick($iStid, $sMsg);
        die(); # Player kicked, exit.
    }
}

####################################
# Welcome Messages Section.
####################################
# four scenarios; 
#   admin, welcome as admin
#   donor, welcome as donor, inform of expiration.
#   existing player:    welcome, give playtime. 
#   new player:         TP, welcome.
$iPlTme = getPlyTme($iStid);
$iPlmins = gmdate("H:i:s",$iPlTme);
# Check if donor or admin

if($sPlyType == "admin"){ # send admin message.
    $sMsg = wrapSlash("Welcome "._c('a', $sPlNme).", you are connecting to your admin slot. Your current playtime is "._c('a', $iPlmins));
    $bRes = SH_Sayplayer($iStid, _c('d', $sMsg));
    die(); #done, exit.

} elseif (is_array($sPlyType)) {
    # send donor message.
    $sExpirDate = date("d/m/y", $sPlyType[0]);
    $sMsg = wrapSlash("Welcome "._c('a', $sPlNme).", you are connecting to your donor slot. Your current playtime is "._c('a', $iPlmins).". Your reserved slot expires on the "._c('w', $sExpirDate));
    $bRes = SH_Sayplayer($iStid, _c('d', $sMsg));
    die(); #done, exit.

} else { # normal player, existing or new?
    if ($iPlTme > 40){ #existing, send welcome message, exit.
        $sMsg = wrapSlash("Welcome to 7N2L "._c('a', $sPlNme).", your current playtime is "._c('a', $iPlmins).".");
        $bRes = SH_Sayplayer($iStid, _c('d', $sMsg));
        die();
    } else { #new player, TP, welcome, exit.
        $bRes = SH_TPNoob($iStid, sCoord);
        $bRes = SH_Sayplayer($iStid, _c('d', wrapSlash("Welcome to 7N2l "._c('a', $sPlNme).", This is a safe house for new players.")));
        $bRes = SH_Sayplayer($iStid, _c('a', wrapSlash("If you spawned with no starter items, ask for an admin in main chat.")));
        $bRes = SH_Sayplayer($iStid, _c('d', wrapSlash("Once you leave this building, you will not be able to enter again.")));
        $bRes = SH_Sayplayer($iStid, _c('a', wrapSlash("Be safe Traveller "._c('d', $sPlNme).", and prosper!.")));
        $bRes = SH_Say(_c('s', wrapSlash(" We have a new player: "._c('a', $sPlNme).", let's make them welcome :)")));
        die();
    }
}


####################################
# Functions.
####################################
# Wrap a string in quotes and escape quotes
function wrapSlash($sStr){
    $sRet = addslashes($sStr);
    $sRet = "\"".$sRet."\"";
    return $sRet;
}
# Get playtime from steamid.
function getPlyTme($sStid){
    $sUrl = sAPI_Loc;
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
# Get donor/admin status:
function getPlyStat($iStid){
    require_once(sMyLib);
    #inititate db resource
    $rDB = new MysqliDb(sMyHost, sMyUser, sMyPass, sMyDB);
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
# get continent code from IP:
function getCont($sIP){
    return(geoip_continent_code_by_name($sIP));
}

# get curr player online count (counts the one who just joined).
function getPlyOn(){
    $sUrl = sAPI_Upd;
    //append(sAPI_Upd);
    $sRes = json_decode(file_get_contents($sUrl), true);
    return $sRes['players'];
}
# Appendd to logging file.
function append($sTxt){
	$sLogFile = sLog_Pth;
	$rCurrent = file_get_contents($sLogFile);
	$rCurrent .= date("F j, Y, g:i a")." ::: ".$sTxt."\n";
	file_put_contents($sLogFile, $rCurrent);
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
###################################
# Functions that call shell scripts.
###################################
function SH_Say($sMsg){
    $sPath = sScr_Pth."say.sh";
    $bExit = shell_exec("$sPath $sMsg");
    return $bExit;
}

function SH_Sayplayer($iStid, $sMsg){
    $sPath = sScr_Pth."sayplayer.sh";
    $bExit = shell_exec("$sPath $iStid $sMsg");
    return $bExit;
}

function SH_TPNoob($iStid){
    $sCoords = "685 123 1324"; #noob player TP coords
    $sPath = sScr_Pth."tpnoob.sh";
    $bExit = shell_exec("$sPath $iStid");
    return $bExit;
}

function SH_Ban($iStid){
    $sPath = sScr_Pth."bangeo.sh";
    $bExit = shell_exec("$sPath $iStid");
    return $bExit;
}

function SH_Kick($iStid, $sReason){
    $sPath = sScr_Pth."kick.sh";
    $bExit = shell_exec("$sPath $iStid $sReason");
    return $bExit;
}
####################################
?>