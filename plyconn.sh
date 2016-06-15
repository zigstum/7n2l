#!/usr/bin/php
<?php
/*
TODO: 
    Make whole thing into a class?
    Add colours to messages - combine with wrapSlash() ?
    Get messages into separate file.
    Improve token security and move to diff file.
    Make script paths configurable by vars at top
    Make API path configurable at top.
    Maybe some sleep times in bash scripts? TP, noob messages.
*/
ini_set("log_errors" , "1");
ini_set("error_log" , "./Errors.log.txt");
ini_set("display_errors" , "0");

# $0 Script Path, $1 Instance, $2 Entity id, Player $3, steam ID: $4, IP: $5 ownerstid: $6(?)
$sInst = $argv[1];$sEntId = $argv[2];$sPlNme = $argv[3];$iStid = $argv[4];$sIP = $argv[5];

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
$aBanned = array("AS");
$sCont = getCont($sIP);
if(in_array($sCont, $aBanned)){
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
    append("server full...\n");
    # Server full, check playinfo.
    if($sPlyType == "none"){ # non donor kick with messages.
        append("$sPlNme: non donor, kick...\n"); //die();
        $sMsg = wrapSlash("Sorry to be rude {$sPlNme}, but there are no spaces left. See 7n2l.com for info on reserving a slot.");
        $bRes = SH_Kick($iStid, $sMsg);
        # Player kicked, exit.
        die();
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
$sPlTme = getPlyTme($iStid);
$iPlmins = gmdate("H:i:s",$sPlTme);
# Check if donor or admin
if($sPlyType == "admin"){
    # send admin message.
    append("$sPlNme:admin, allow...\n"); //die();
    $sMsg = wrapSlash("Welcome "._c('a', $sPlNme).", you are connecting to your admin slot. Your current playtime is "._c('a', $iPlmins));
    //append($sMsg); //die();
    $bRes = SH_Sayplayer($iStid, _c('d', $sMsg));
    die(); #done, exit.

} elseif (is_array($sPlyType)) {
    # send donor message.
    append("$sPlNme:donor, allow...\n"); //die();
    $sExpirDate = date("d/m/y", $sPlyType[0]);
    $sMsg = wrapSlash("Welcome "._c('d', $sPlNme).", you are connecting to your donor slot. Your current playtime is "._c('a', $iPlmins).". Your reserved slot expires on the "._c('w', $sExpirDate));
    $bRes = SH_Sayplayer($iStid, _c('d', $sMsg));
    die(); #done, exit.

} else { # normal player, existing or new?
    if ($iPlTme){ #existing, send welcome message, exit.
        append("$sPlNme: existing player, allow...\n"); //die();
        $sMsg = wrapSlash("$_d Welcome to 7N2L $_a{$sPlNme}$_cl, your current playtime is $_a{$iPlmins}$_cl.");
        $bRes = SH_Sayplayer($iStid, _c('d', $sMsg));
        die();
    } else { #new player, TP, welcome, exit.
        append("$sPlNme: new player, allow...\n"); //die();
        $bRes = SH_TPNoob($iStid);
        $bRes = SH_Sayplayer($iStid, wrapSlash("Welcome to 7N2L $_a{$sPlNme}$_cl, This is a safe house for new players."));
        $bRes = SH_Sayplayer($iStid, wrapSlash("If you spawned with no starter items, ask for an admin in main chat."));
        $bRes = SH_Sayplayer($iStid, wrapSlash("Once you leave this building, you will not be able to enter again."));
        $bRes = SH_Sayplayer($iStid, wrapSlash("Be safe Traveller $_a{$sPlNme}$_cl, and prosper!."));
        $bRes = SH_Say(wrapSlash(" We have a new player: $_a{$sPlNme}$_cl, let's make them welcome :)"));
        $bRes = SH_Say(wrapSlash("We have a new player: $_a{$sPlNme}$_cl, let's make them welcome :)"));
        die();
    }
}


append("shouldnt get here, problem."); die();



function wrapSlash($sStr){
    $sRet = addslashes($sStr);
    $sRet = "\"".$sRet."\"";
    return $sRet;
}
# Get playtime from steamid.
function getPlyTme($sStid){
    $sUrl = "http://62.138.3.36:8092/api/getplayerslocation?adminuser=zigstum&admintoken=donkey";
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

# Get donor/admin status:
function getPlyStat($iStid){
    require_once('/home/sdtd/instances/dev/hooks/scripts/MysqliDb.php');
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

# get continent code from IP:
function getCont($sIP){
    return(geoip_continent_code_by_name($sIP));
}

# get curr player online count (counts the one who just joined).
function getPlyOn(){
    $sUrl = "http://62.138.3.36:8092/api/getwebuiupdates?adminuser=zigstum&admintoken=donkey";
    $sRes = json_decode(file_get_contents($sUrl), true);
    return $sRes['players'];
}
# Appendd to logging file.
function append($sTxt){
	$sLogFile = "/home/sdtd/instances/dev/hooks/scripts/helpers/plyconn.txt";
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
$sScrPth = "/home/sdtd/instances/dev/hooks/scripts/helpers/";
function SH_Say($sMsg){
    $sPath = "/home/sdtd/instances/dev/hooks/scripts/helpers/say.sh";
    $bExit = shell_exec("$sPath $sMsg");
    return $bExit;
}

function SH_Sayplayer($iStid, $sMsg){
    $sPath = "/home/sdtd/instances/dev/hooks/scripts/helpers/sayplayer.sh";
    $bExit = shell_exec("$sPath $iStid $sMsg");
    return $bExit;
}

function SH_TPNoob($iStid){
    $sCoords = "685 123 1324"; #noob player TP coords
    $sPath = "/home/sdtd/instances/dev/hooks/scripts/helpers/tpnoob.sh";
    $bExit = shell_exec("$sPath $iStid");
    return $bExit;
}

function SH_Ban($iStid){
    $sPath = "/home/sdtd/instances/dev/hooks/scripts/helpers/bangeo.sh";
    $bExit = shell_exec("$sPath $iStid");
    return $bExit;
}

function SH_Kick($iStid, $sReason){
    $sPath = "/home/sdtd/instances/dev/hooks/scripts/helpers/kick.sh";
    $bExit = shell_exec("$sPath $iStid $sReason");
    return $bExit;
}
####################################
?>