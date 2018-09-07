/*------------------------------------------------------------------------------

 Com, Build 169

 Peanut Collar Distribution
 Copyright © 2018 virtualdisgrace.com
 https://github.com/VirtualDisgrace/peanut

--------------------------------------------------------------------------------

 OpenCollar v1.000 - v3.600 (OpenCollar - submission set free):

 Copyright © 2008, 2009, 2010 Cleo Collins, Garvin Twine, Master Starship,
 Nandana Singh, et al.

 The project in its original form concluded on October 19, 2011. Everything past
 this date is a derivative of OpenCollar's original SVN trunk from Google Code.

--------------------------------------------------------------------------------

 OpenCollar v3.700 - v3.720 (nirea's ocupdater):

 Copyright © 2011 nirea, Satomi Ahn

 https://github.com/OpenCollarUpdates/ocupdater/commits/release

--------------------------------------------------------------------------------

 OpenCollar v3.750 - v3.809 (Satomi's OpenCollarUpdates):

 Copyright © 2012 Satomi Ahn

 https://github.com/OpenCollarUpdates/ocupdater/commits/3.8
 https://github.com/OpenCollarUpdates/ocupdater/commits/beta

--------------------------------------------------------------------------------

 OpenCollar v3.809 - v3.843 (Joy's OpenCollar Evolution):

 Copyright © 2013 Joy Stipe

 https://github.com/JoyStipe/ocupdater/commits/Project_Evolution

--------------------------------------------------------------------------------

 OpenCollar v3.844 - v3.998 (Wendy's OpenCollar API 3.9):

 Copyright © 2013 Wendy Starfall
 Copyright © 2014 littlemousy, Romka Swallowtail, Sumi Perl, Wendy Starfall

 https://github.com/OpenCollar/opencollar/commits/master
 https://github.com/WendyStarfall/opencollar/commits/master

--------------------------------------------------------------------------------

 Virtual Disgrace Collar v1.0.0 - v2.1.1 (virtualdisgrace.com):

 Copyright © 2011, 2012, 2013 Wendy Starfall
 Copyright © 2014 littlemousy, Wendy Starfall

 https://github.com/WendyStarfall/opencollar/commits/master
 https://github.com/VirtualDisgrace/opencollar/commits/master

--------------------------------------------------------------------------------

 OpenCollar v4.0.0 - v6.7.5 - Peanut build 9 (virtualdisgrace.com):

 Copyright © 2015 Garvin Twine, Romka Swallowtail, Wendy Starfall
 Copyright © 2016 Garvin Twine, stawberri, Wendy Starfall
 Copyright © 2017 Garvin Twine, Romka Swallowtail, Wendy Starfall
 Copyright © 2018 Garvin Twine, Wendy Starfall

 https://github.com/VirtualDisgrace/opencollar/commits/master
 https://github.com/WendyStarfall/opencollar/commits/master

--------------------------------------------------------------------------------

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, see www.gnu.org/licenses/gpl-2.0

------------------------------------------------------------------------------*/

integer g_iBuild = 169;

integer g_iPrivateListenChan = 1;
integer g_iPublicListenChan = TRUE;
string g_sPrefix = ".";

integer g_iLockMeisterChan = -8888;

integer g_iPublicListener;
integer g_iPrivateListener;
integer g_iLockMeisterListener;
integer g_iLeashPrim;

integer g_iHUDListener;
integer g_iHUDChan;

integer CMD_ZERO = 0;
integer CMD_OWNER = 500;
integer CMD_WEARER = 503;
integer CMD_SAFEWORD = 510;

integer NOTIFY=1002;
integer NOTIFY_OWNERS=1003;
integer LINK_AUTH = 2;
integer LINK_DIALOG = 3;
integer LINK_SAVE = 5;
integer LINK_ANIM = 6;
integer LINK_UPDATE = -10;
integer REBOOT = -1000;
integer LM_SETTING_SAVE = 2000;
integer LM_SETTING_RESPONSE = 2002;
integer LM_SETTING_DELETE = 2003;

integer ANIM_LIST_REQUEST = 7002;
integer TOUCH_REQUEST = -9500;
integer TOUCH_CANCEL = -9501;
integer TOUCH_RESPONSE = -9502;
integer TOUCH_EXPIRE = -9503;
integer BUILD_REQUEST = 17760501;
string g_sSafeWord;

integer g_iInterfaceChannel;
integer g_iListenHandleAtt;

integer AUTH_REQUEST = 600;
integer AUTH_REPLY = 601;

key g_kWearer;
string g_sGlobalToken = "global_";
string g_sDeviceName = "Collar";
string g_sWearerName;

list g_lTouchRequests;
integer g_iStrideLength = 4;

integer FLAG_TOUCHSTART = 0x01;
integer FLAG_TOUCHEND = 0x02;

integer g_iNeedsPose;
string g_sPOSE_ANIM = "turn_180";

integer g_iTouchNotify;
integer g_iHighlander = TRUE;
list g_lCore5Scripts = ["LINK_AUTH","auth","LINK_DIALOG","dialog","LINK_RLV","rlvsys","LINK_SAVE","settings","LINK_ANIM","anim"];
list g_lFoundCore5Scripts;
list g_lWrongRootScripts;
integer g_iVerify;
string g_sObjectName;
integer g_iBuildCheck = TRUE;

string NameURI(key kID){
    return "secondlife:///app/agent/"+(string)kID+"/about";
}

ClearUser(key kRCPT, integer iNotify) {
    integer iIndex = llListFindList(g_lTouchRequests, [kRCPT]);
    while (~iIndex) {
        if (iNotify) {
            key kID = llList2Key(g_lTouchRequests, iIndex -1);
            integer iAuth = llList2Integer(g_lTouchRequests, iIndex + 2);
            llMessageLinked(LINK_THIS, TOUCH_EXPIRE, (string) kRCPT + "|" + (string) iAuth,kID);
        }
        g_lTouchRequests = llDeleteSubList(g_lTouchRequests, iIndex - 1, iIndex - 2 + g_iStrideLength);
        iIndex = llListFindList(g_lTouchRequests, [kRCPT]);
    }
    if (g_iNeedsPose && [] == g_lTouchRequests) llStopAnimation(g_sPOSE_ANIM);
}

sendCommandFromLink(integer iLinkNumber, string sType, key kToucher) {
    integer iTrig;
    integer iNTrigs = llGetListLength(g_lTouchRequests);
    for (iTrig = 0; iTrig < iNTrigs; iTrig+=g_iStrideLength) {
        if (llList2Key(g_lTouchRequests, iTrig + 1) == kToucher) {
            integer iTrigFlags = llList2Integer(g_lTouchRequests, iTrig + 2);
            if (((iTrigFlags & FLAG_TOUCHSTART) && sType == "touchstart")
                ||((iTrigFlags & FLAG_TOUCHEND)&& sType == "touchend")) {
                integer iAuth = llList2Integer(g_lTouchRequests, iTrig + 3);
                string sReply = (string) kToucher + "|" + (string) iAuth + "|" + sType +"|"+ (string) iLinkNumber;
                llMessageLinked(LINK_THIS, TOUCH_RESPONSE, sReply, llList2Key(g_lTouchRequests, iTrig));
            }
            if (sType =="touchend") ClearUser(kToucher, FALSE);
            return;
        }
    }
    string sDesc = llDumpList2String(llGetLinkPrimitiveParams(iLinkNumber,[PRIM_DESC])+llGetLinkPrimitiveParams(LINK_ROOT,[PRIM_DESC]),"~");
    list lDescTokens = llParseStringKeepNulls(sDesc, ["~"], []);
    integer iNDescTokens = llGetListLength(lDescTokens);
    integer iDescToken;
    for (iDescToken = 0; iDescToken < iNDescTokens; iDescToken++) {
        string sDescToken = llList2String(lDescTokens, iDescToken);
        if (sDescToken == sType || sDescToken == sType+":" || sDescToken == sType+":none") return;
        else if (!llSubStringIndex(sDescToken, sType+":")) {
            string sCommand = llGetSubString(sDescToken, llStringLength(sType)+1, -1);
            if (sCommand != "") llMessageLinked(LINK_AUTH, CMD_ZERO, sCommand, kToucher);
            return;
        }
    }
    if (sType == "touchstart") {
        llMessageLinked(LINK_AUTH, CMD_ZERO, "menu", kToucher);
        if (g_iTouchNotify && kToucher!=g_kWearer)
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nsecondlife:///app/agent/"+(string)kToucher+"/about touched your %DEVICETYPE%.\n",g_kWearer);
    }
}

MoveAnims(integer i) {
    key kAnimator = llGetLinkKey(LINK_ANIM);
    string sAnim;
    list lAnims;
    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nFetching "+(string)i+" animations from the %DEVICETYPE%'s root...\n",g_kWearer);
    while (i) {
        sAnim = llGetInventoryName(INVENTORY_ANIMATION,--i);
        llGiveInventory(kAnimator,sAnim);
        lAnims += sAnim;
        if (llGetInventoryType(sAnim) == INVENTORY_ANIMATION) {
            if (llGetInventoryPermMask(sAnim,MASK_OWNER) & PERM_COPY)
                llRemoveInventory(sAnim);
        }
    }
    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nThe following animations have been moved to the %DEVICETYPE%'s animator module and are now ready to use:\n\n"+llList2CSV(lAnims)+"\n",g_kWearer);
    llMessageLinked(LINK_ANIM,ANIM_LIST_REQUEST,"","");
}

UserCommand(key kID, integer iAuth, string sStr) {
    if (sStr == "ping") {
        llRegionSayTo(kID,g_iHUDChan,(string)g_kWearer+":pong");
        return;
    }
    list lParams = llParseString2List(sStr, [" "], []);
    string sCommand = llToLower(llList2String(lParams, 0));
    string sValue = llList2String(lParams, 1);
    if (iAuth == CMD_OWNER || kID == g_kWearer) {
        if (sCommand == "prefix") {
            if (sValue == "") {
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\n%WEARERNAME%'s prefix is: %PREFIX%\n",kID);
                return;
            } else if (sValue == "reset") {
                g_sPrefix = llToLower(llGetSubString(llKey2Name(llGetOwner()), 0,1));
                llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sGlobalToken+"prefix", "");
            } else {
                g_sPrefix = sValue;
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken+"prefix=" + g_sPrefix, "");
            }
            llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"prefix=" + g_sPrefix, "");
            llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"\n\n%WEARERNAME%'s new prefix is: %PREFIX%\n",kID);
        }
        else if (sCommand == "device" && sValue == "name") {
            string sMessage;
            string sObjectName = llGetObjectName();
            string sCmdOptions = llDumpList2String(llDeleteSubList(lParams,0,1), " ");
            if (sCmdOptions == "") return;
            else if (sCmdOptions == "reset") {
                g_sDeviceName = "Collar";
                sMessage = "The device name is reset to \""+g_sDeviceName+"\".";
                llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sGlobalToken+"DeviceName", "");
                llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"DeviceName="+g_sDeviceName, "");
            } else {
                g_sDeviceName = sCmdOptions;
                sMessage = sObjectName+"'s new device name is \""+ g_sDeviceName+"\".";
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken+"DeviceName="+g_sDeviceName, "");
                llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"DeviceName="+g_sDeviceName, "");
            }
            if (sValue) llMessageLinked(LINK_DIALOG,NOTIFY,"1"+sMessage,kID);
        } else if (sCommand == "name") {
            if (iAuth != CMD_OWNER) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
            else {
                string sMessage;
                if (sValue == "") {
                    sMessage = "\n\nsecondlife:///app/agent/"+(string)g_kWearer+"/about's current name is " + g_sWearerName;
                    sMessage += "\nName command help: <prefix>name [newname|reset]\n";
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+sMessage,kID);
                } else if(sValue == "reset") {
                    sMessage=g_sWearerName+"'s name is reset to ";
                    g_sWearerName = NameURI(g_kWearer);
                    llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sGlobalToken+"WearerName", "");
                    llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"WearerName="+g_sWearerName, "");
                    sMessage += g_sWearerName;
                    llMessageLinked(LINK_DIALOG,NOTIFY,"1"+sMessage,kID);
                } else {
                    string sNewName = llDumpList2String(llList2List(lParams, 1,-1)," ") ;
                    sMessage=g_sWearerName+"'s new name is ";
                    g_sWearerName = "["+NameURI(g_kWearer)+" "+sNewName+"]";
                    sMessage += g_sWearerName;
                    llMessageLinked(LINK_DIALOG,NOTIFY,"1"+sMessage,kID);
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken+"WearerName=" + sNewName, "");
                    llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"WearerName="+sNewName, "");
                }
            }
        } else if (sCommand == "channel") {
            integer iNewChan = (integer)sValue;
            if (sValue == "") {
                string sMessage= "The %DEVICETYPE% is listening on channel";
                if (g_iPublicListenChan) sMessage += "s 0 and";
                sMessage += " "+(string)g_iPrivateListenChan+".";
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+sMessage,kID);
            } else if (iNewChan > 0) {
                g_iPrivateListenChan =  iNewChan;
                llListenRemove(g_iPrivateListener);
                g_iPrivateListener = llListen(g_iPrivateListenChan, "", NULL_KEY, "");
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Now listening on channel " + (string)g_iPrivateListenChan,kID);
                if (g_iPublicListenChan) {
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",TRUE", "");
                    llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",TRUE", "");
                } else {
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",FALSE", "");
                    llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",FALSE", "");
                }
            } else if (iNewChan == 0) {
                g_iPublicListenChan = TRUE;
                llListenRemove(g_iPublicListener);
                g_iPublicListener = llListen(0, "", NULL_KEY, "");
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"\n\nPublic channel listener enabled.\nTo disable it type: /%CHANNEL% %PREFIX% channel -1\n",kID);
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",TRUE", "");
                llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",TRUE", "");
            } else if (iNewChan == -1) {
                g_iPublicListenChan = FALSE;
                llListenRemove(g_iPublicListener);
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"\n\nPublic channel listener disabled.\nTo enable it type: /%CHANNEL% %PREFIX% channel 0\n",kID);
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",FALSE", "");
                llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",FALSE", "");
            }
        } else if (kID == g_kWearer) {
           if (sStr == "list builds") {
                g_sObjectName = llGetObjectName();
                g_iBuildCheck = FALSE;
                llSetObjectName(llGetScriptName());
                llOwnerSay("build "+(string)g_iBuild);
                llSetObjectName(g_sObjectName);
                llMessageLinked(LINK_SET,BUILD_REQUEST,"","");
            } else if (sStr == "mv anims") {
                integer i = llGetInventoryNumber(INVENTORY_ANIMATION);
                if (i) MoveAnims(i);
            } else if (sCommand == "busted") {
                if (sValue == "on") {
                    llMessageLinked(LINK_SAVE,LM_SETTING_SAVE,g_sGlobalToken+"touchNotify=1","");
                    g_iTouchNotify=TRUE;
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Touch notification is now enabled.",g_kWearer);
                } else if (sValue == "off") {
                    llMessageLinked(LINK_SAVE,LM_SETTING_DELETE,g_sGlobalToken+"touchNotify","");
                    g_iTouchNotify=FALSE;
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Touch notification is now disabled.",g_kWearer);
                } else if (sValue == "") {
                    if (g_iTouchNotify) {
                        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Touch notification is now disabled.",g_kWearer);
                        llMessageLinked(LINK_SAVE,LM_SETTING_DELETE,g_sGlobalToken+"touchNotify","");
                        g_iTouchNotify = FALSE;
                    } else {
                        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Touch notification is now enabled.",g_kWearer);
                        llMessageLinked(LINK_SAVE,LM_SETTING_SAVE,g_sGlobalToken+"touchNotify=1","");
                        g_iTouchNotify = TRUE;
                    }
                }
            }
        }
    }
}

default {
    on_rez(integer iParam) {
        llResetScript();
    }

    state_entry() {
        g_kWearer = llGetOwner();
        g_sWearerName = NameURI(g_kWearer);
        llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"DeviceName="+g_sDeviceName, "");
        g_sPrefix = llToLower(llGetSubString(llKey2Name(g_kWearer), 0,1));
        g_iHUDChan = -llAbs((integer)("0x"+llGetSubString((string)g_kWearer,-7,-1)));
        g_iInterfaceChannel = (integer)("0x" + llGetSubString(g_kWearer,30,-1));
        if (g_iInterfaceChannel > 0) g_iInterfaceChannel = -g_iInterfaceChannel;
        g_iPublicListener = llListen(0, "", NULL_KEY, "");
        g_iPrivateListener = llListen(g_iPrivateListenChan, "", NULL_KEY, "");
        g_iLockMeisterListener = llListen(g_iLockMeisterChan, "", "", "");
        g_iListenHandleAtt = llListen(g_iInterfaceChannel, "", "", "");
        g_iHUDListener = llListen(g_iHUDChan, "", NULL_KEY ,"");
        integer iAttachPt = llGetAttached();
        if ((iAttachPt > 0 && iAttachPt < 31) || iAttachPt == 39) {
            llRequestPermissions(g_kWearer, PERMISSION_TRIGGER_ANIMATION);
            llRegionSayTo(g_kWearer, g_iInterfaceChannel, "OpenCollar=Yes");
        }
    }

    attach(key kID) {
        if (kID == NULL_KEY)
            llRegionSayTo(g_kWearer, g_iInterfaceChannel, "OpenCollar=No");
    }

    listen(integer iChan, string sName, key kID, string sMsg) {
        if (iChan == g_iLockMeisterChan) {
            if(sMsg ==(string)g_kWearer+"collar")
                llSay(g_iLockMeisterChan,(string)g_kWearer + "collar ok");
            if(sMsg == (string)g_kWearer+"|LMV2|RequestPoint|collar") {
                if(g_iLeashPrim)
                    llRegionSayTo(kID, g_iLockMeisterChan, (string)g_kWearer+"|LMV2|ReplyPoint|collar|"+(string)llGetLinkKey(g_iLeashPrim));
                else
                    llRegionSayTo(kID, g_iLockMeisterChan, (string)g_kWearer+"|LMV2|ReplyPoint|collar|"+(string) llGetKey());
            }
            return;
        }
        key kOwnerID = llGetOwnerKey(kID);
        if (iChan == g_iHUDChan) {
            if (sMsg == (string)g_kWearer + ":ping")
                llMessageLinked(LINK_AUTH, CMD_ZERO, "ping", kOwnerID);
            else if (!llSubStringIndex(sMsg,(string)g_kWearer + ":")){
                sMsg = llGetSubString(sMsg, 37, -1);
                llMessageLinked(LINK_AUTH, CMD_ZERO, sMsg, kOwnerID);
            } else
                llMessageLinked(LINK_AUTH, CMD_ZERO, sMsg, kOwnerID);
        }
        if (iChan == g_iInterfaceChannel && kOwnerID == g_kWearer) {
            if (sMsg == "OpenCollar?") llRegionSayTo(g_kWearer, g_iInterfaceChannel, "OpenCollar=Yes");
            else if (sMsg == "OpenCollar=Yes" && g_iHighlander) {
                llOwnerSay("\n\nATTENTION: You are attempting to wear more than one collar core. This causes errors with other compatible accessories and your RLV relay. For a smooth experience, and to avoid wearing unnecessary script duplicates, please consider to take off \""+sName+"\" manually if it doesn't detach automatically.\n");
                llRegionSayTo(kID,g_iInterfaceChannel,"There can be only one!");
            } else if (sMsg == "There can be only one!" && g_iHighlander) {
                llOwnerSay("/me has been detached.");
                llRequestPermissions(g_kWearer,PERMISSION_ATTACH);
            } else {
                if (llSubStringIndex(sMsg, "AuthRequest")==0) {
                    llMessageLinked(LINK_AUTH,AUTH_REQUEST,(string)kID+(string)g_iInterfaceChannel,llGetSubString(sMsg,12,-1));
                }
            }
        }
        if (iChan == 0 || iChan == g_iPrivateListenChan) {
            if (kOwnerID == g_kWearer) {
                string sw = sMsg;
                if (llGetSubString(sw, 0, 3) == "/me ") sw = llGetSubString(sw, 4, -1);
                if (llGetSubString(sw, 0, 1) == "((" && llGetSubString(sw, -2, -1) == "))") sw = llStringTrim(llGetSubString(sw, 2, -3), STRING_TRIM);
                if (llSubStringIndex(sw, g_sPrefix)==0) sw = llGetSubString(sw, llStringLength(g_sPrefix), -1);
                if (sw == g_sSafeWord || sw == "RED") {
                    llMessageLinked(LINK_SET, CMD_SAFEWORD, "", "");
                    llRegionSayTo(g_kWearer,g_iInterfaceChannel,"%53%41%46%45%57%4F%52%44");
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"You used the safeword, your owners have been notified.",g_kWearer);
                    llMessageLinked(LINK_DIALOG,NOTIFY_OWNERS,"\n\n%WEARERNAME% had to use the safeword. Please check on %WEARERNAME%'s well-being in case further care is required.\n","");
                    return;
                }
            }
            if (!llSubStringIndex(sMsg, g_sPrefix)) sMsg = llGetSubString(sMsg, llStringLength(g_sPrefix), -1);
            else if (!llSubStringIndex(sMsg, "/"+g_sPrefix)) sMsg = llGetSubString(sMsg, llStringLength(g_sPrefix)+1, -1);
            else if (llGetSubString(sMsg, 0, 0) == "*") sMsg = llGetSubString(sMsg, 1, -1);
            else if ((llGetSubString(sMsg, 0, 0) == "#") && (kID != g_kWearer)) sMsg = llGetSubString(sMsg, 1, -1);
            else return;
            sMsg = llStringTrim(sMsg,STRING_TRIM_HEAD);
            if (sMsg) {
                if (kID == g_kWearer && llToLower(sMsg) == "verify") {
                    llOwnerSay("Verifying core...");
                    llMessageLinked(LINK_ALL_OTHERS,LINK_UPDATE,"LINK_REQUEST","");
                    llSetTimerEvent(2);
                    g_iVerify = TRUE;
                    g_lWrongRootScripts = [];
                    string sScriptName;
                    integer i = llGetListLength(g_lCore5Scripts) -1;
                    do {
                        sName = llList2String(g_lCore5Scripts,i);
                        if (llGetInventoryType(sScriptName) == INVENTORY_SCRIPT)
                            g_lWrongRootScripts += sScriptName;
                        i = i - 2;
                    } while (i>0);
                    return;
                }
                llMessageLinked(LINK_AUTH, CMD_ZERO, sMsg, kID);
            }
        }
    }

    link_message(integer iSender, integer iNum, string sStr, key kID) {
        if (iNum >= CMD_OWNER && iNum <= CMD_WEARER) UserCommand(kID, iNum, sStr);
        else if (iNum == LM_SETTING_RESPONSE) {
            list lParams = llParseString2List(sStr, ["="], []);
            string sToken = llList2String(lParams, 0);
            string sValue = llList2String(lParams, 1);
            if (sToken == g_sGlobalToken+"prefix") {
                if (sValue != "") g_sPrefix=sValue;
            } else if (sToken == "leashpoint") g_iLeashPrim = (integer)sValue;
            else if (sToken == g_sGlobalToken+"DeviceName") g_sDeviceName = sValue;
            else if (sToken == g_sGlobalToken+"touchNotify") g_iTouchNotify = (integer)sValue;
            else if (sToken == g_sGlobalToken+"WearerName") {
                 if (llSubStringIndex(sValue, "secondlife:///app/agent"))
                    g_sWearerName = "["+NameURI(g_kWearer)+" " + sValue + "]";
            } else if (sToken == "intern_Highlander") g_iHighlander = (integer)sValue;
            else if (sToken == g_sGlobalToken+"safeword") g_sSafeWord = sValue;
            else if (sToken == g_sGlobalToken+"channel") {
                g_iPrivateListenChan = (integer)sValue;
                if (llGetSubString(sValue, llStringLength(sValue) - 5 , -1) == "FALSE") g_iPublicListenChan = FALSE;
                else g_iPublicListenChan = TRUE;
                llListenRemove(g_iPublicListener);
                if (g_iPublicListenChan == TRUE) g_iPublicListener = llListen(0, "", NULL_KEY, "");
                llListenRemove(g_iPrivateListener);
                g_iPrivateListener = llListen(g_iPrivateListenChan, "", NULL_KEY, "");
            }
        } else if (iNum == TOUCH_REQUEST) {
            list lParams = llParseStringKeepNulls(sStr, ["|"], []);
            key kRCPT = (key)llList2String(lParams, 0);
            integer iFlags = (integer)llList2String(lParams, 1);
            integer iAuth = (integer)llList2String(lParams, 2);
            ClearUser(kRCPT, TRUE);
            g_lTouchRequests += [kID, kRCPT, iFlags, iAuth];
            if (g_iNeedsPose) llStartAnimation(g_sPOSE_ANIM);
        } else if (iNum == LINK_UPDATE) {
            if (sStr == "LINK_AUTH") LINK_AUTH = iSender;
            else if (sStr == "LINK_DIALOG") LINK_DIALOG = iSender;
            else if (sStr == "LINK_SAVE") LINK_SAVE = iSender;
            else if (sStr == "LINK_ANIM") LINK_ANIM = iSender;
            if (sStr != "LINK_REQUEST") {
                if (!~llListFindList(g_lFoundCore5Scripts,[sStr,iSender]))
                    g_lFoundCore5Scripts += [sStr,iSender];
                if (llGetListLength(g_lFoundCore5Scripts) >= 10) llSetTimerEvent(0.1);
            }
        } else if (iNum > BUILD_REQUEST && iNum < BUILD_REQUEST+9999) {
            if (!g_iBuildCheck) {
                llSetObjectName(sStr);
                llOwnerSay("build "+(string)(iNum-BUILD_REQUEST));
                llSetObjectName(g_sObjectName);
            }
        } else if (iNum == BUILD_REQUEST-1) llMessageLinked(iSender,BUILD_REQUEST+g_iBuild,llGetScriptName(),"");
        else if (iNum == TOUCH_CANCEL) {
            integer iIndex = llListFindList(g_lTouchRequests, [kID]);
            if (~iIndex) {
                g_lTouchRequests = llDeleteSubList(g_lTouchRequests, iIndex, iIndex - 1 + g_iStrideLength);
                if (g_iNeedsPose && [] == g_lTouchRequests) llStopAnimation(g_sPOSE_ANIM);
            }
        } else if (iNum == AUTH_REPLY) llRegionSayTo(kID, g_iInterfaceChannel, sStr);
        else if (iNum == REBOOT && sStr == "reboot") {
            integer i = llGetInventoryNumber(INVENTORY_SCRIPT);
            string sScriptName;
            while (i) {
                sScriptName = llGetInventoryName(INVENTORY_SCRIPT,--i);
                if (sScriptName != "com" && sScriptName != "root"
                && llGetInventoryType(sScriptName) == INVENTORY_SCRIPT
                && llGetScriptState(sScriptName) == FALSE) {
                    llSetScriptState(sScriptName,TRUE);
                    llResetOtherScript(sScriptName);
                }
            }
            if (llGetInventoryType("root") == INVENTORY_SCRIPT && !llGetScriptState("root")) {
                llSetScriptState("root",TRUE);
                llResetOtherScript("root");
            }
            llResetScript();
        }
    }

    touch_start(integer iNum) {
        sendCommandFromLink(llDetectedLinkNumber(0), "touchstart", llDetectedKey(0));
    }

    touch_end(integer iNum) {
        sendCommandFromLink(llDetectedLinkNumber(0), "touchend", llDetectedKey(0));
    }

    run_time_permissions(integer iPerm) {
        if (iPerm & PERMISSION_TRIGGER_ANIMATION) g_iNeedsPose = TRUE;
        if (iPerm & PERMISSION_ATTACH) {
            llOwnerSay("@detach=yes");
            llDetachFromAvatar();
        }
    }

    timer() {
        llSetTimerEvent(0);
        string sMessage;
        if (g_lWrongRootScripts) {
            sMessage = "\nFalse root prim placement:\n";
            do {
                sMessage += llList2String(g_lWrongRootScripts,0);
                g_lWrongRootScripts =  llDeleteSubList(g_lWrongRootScripts,0,0);
            } while (g_lWrongRootScripts);
        }
        if(sMessage) sMessage += "\n";
        integer i;
        integer index;
        list lTemp = ["Missing Scripts:"];
        do {
            index = llListFindList(g_lFoundCore5Scripts,llList2List(g_lCore5Scripts,i,i));
            if (index == -1) {
                if (llSubStringIndex(sMessage,llList2String(g_lCore5Scripts,i+1)) == -1)
                    lTemp += [llList2String(g_lCore5Scripts,i+1)];
            } else
                sMessage += "\n"+llList2String(g_lCore5Scripts,i+1) + "\t(Link# "+llList2String(g_lFoundCore5Scripts,index+1)+")";
            i = i + 2;
        } while (i<10);
        i = llGetLinkNumber();
        if (i != 1) sMessage += "\ncom\t(not in root prim!)";
        string sSaveIntegrity = "intern_integrity=";
        if (llSubStringIndex(sMessage,"False") == -1 && llGetListLength(lTemp) == 1) {
            g_lFoundCore5Scripts = llListSort(g_lFoundCore5Scripts,2, TRUE);
            if (llListFindList(g_lFoundCore5Scripts,["LINK_ANIM",6,"LINK_AUTH",2,"LINK_DIALOG",3,"LINK_RLV",4,"LINK_SAVE",5])) {
                sMessage = "All operational!";
                sSaveIntegrity += "handmade";
            } else {
                sMessage = "Optimal conditions!";
                sSaveIntegrity += "default";
            }
            llMessageLinked(LINK_THIS,LM_SETTING_RESPONSE,sSaveIntegrity,"");
            llMessageLinked(LINK_SAVE,LM_SETTING_SAVE,sSaveIntegrity,"");
            lTemp = [];
            g_lFoundCore5Scripts = [];
        } else {
            if (llGetListLength(lTemp) ==1) lTemp = [];
            sMessage = "\n\nCore corruption detected:\n"+ llDumpList2String(lTemp,"\n")+sMessage;
            if (i == 1) sMessage += "\ncom\t(root)";
            llMessageLinked(LINK_SAVE,LM_SETTING_DELETE,"intern_integrity","");
        }
        g_lFoundCore5Scripts = [];
        if (g_iVerify) {
            g_iVerify = FALSE;
            llOwnerSay(sMessage);
        }
    }
}
