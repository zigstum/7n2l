#!/usr/bin/php
<?php

#$1 Instance, $2 Entity id, Player $3, steam ID: $4, IP: $5
#argv[] = 0 => script path, 1 => instance, 2 => entityid, 3 => player, 4 => steamID, 5 => IP. 
# Get needed vars
$iSteamID=$argv[1];

require_once('./MysqliDb.php');
#inititate db resource
$rDB = new MysqliDb ('localhost', 'n2lcom_dolphin', 'g433%jBp', 'n2lcom_dolphin');
#get this user donor date if exists.
$rDB->where ("steam_id", $iSteamID);
$aUser = $rDB->getOne ("zigs_steamcon_accounts");

echo "donor"; die();

#now check date of expiration for res slot.
if( $aUser['donor'] > time() ){
	#has reserved slot, is it admin? (10x9)
	if($aUser['donor'] == '9999999999'){
		echo "6"; die();
	}
	echo "5"; die();
} else {
	echo "7"; die();
}
die();
?>