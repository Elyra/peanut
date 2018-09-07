/*------------------------------------------------------------------------------

 Label, Build 77

 Peanut Collar Distribution
 Copyright © 2018 virtualdisgrace.com
 https://github.com/VirtualDisgrace/peanut

--------------------------------------------------------------------------------

 XyText:

 Copyright © 2006 Kermitt Quirk, Xylor Baysklef

--------------------------------------------------------------------------------

 XyzzyText:

 Copyright © 2007 Huney Jewell, Gigs Taggart, Salahzar Stenvaag, Strife Onizuka,
 Thraxis Epsilon
 Copyright © 2008 Huney Jewell, Ruud Lathrop, Salahzar Stenvaag,
 Uzume Grigorovich

--------------------------------------------------------------------------------

 OpenCollar v1.000 - v3.600 (OpenCollar - submission set free):

 Copyright © 2008 Lulu Pink, et al.

 The project in its original form concluded on October 19, 2011. Everything past
 this date is a derivative of OpenCollar's original SVN trunk from Google Code.

--------------------------------------------------------------------------------

 OpenCollar v3.700 - v3.720 (nirea's ocupdater):

 Copyright © 2011, 2012 nirea, Satomi Ahn

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
 Copyright © 2014 littlemousy, Romka Swallowtail, Wendy Starfall

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

 Copyright © 2015, 2016 Garvin Twine, Romka Swallowtail, Wendy Starfall
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

integer g_iBuild = 77;

string g_sAppVersion = "¹⋅⁶";

string g_sParentMenu = "Apps";
string g_sSubMenu = "Label";

key g_kWearer;
string g_sSettingToken = "label_";

integer CMD_OWNER = 500;
integer CMD_TRUSTED = 501;
integer CMD_WEARER = 503;

integer NOTIFY = 1002;
integer REBOOT = -1000;
integer LINK_DIALOG = 3;
integer LINK_SAVE = 5;
integer LINK_UPDATE = -10;
integer LM_SETTING_SAVE = 2000;
integer LM_SETTING_RESPONSE = 2002;

integer MENUNAME_REQUEST = 3000;
integer MENUNAME_RESPONSE = 3001;
integer MENUNAME_REMOVE = 3003;

integer DIALOG = -9000;
integer DIALOG_RESPONSE = -9001;
integer DIALOG_TIMEOUT = -9002;
integer BUILD_REQUEST = 17760501;

integer g_iCharLimit = -1;

string UPMENU = "BACK";

string g_sTextMenu = "Set Label";
string g_sFontMenu = "Font";
string g_sColorMenu = "Color";

list g_lMenuIDs;
integer g_iMenuStride = 3;

integer g_iScroll = FALSE;
integer g_iShow = FALSE;
vector g_vColor;
integer g_iHide;

string g_sLabelText = "";

vector g_vGridOffset;
vector g_vRepeats;
vector g_vOffset;
integer FACE = -1;

key g_kFontTexture = NULL_KEY;
list g_lFonts = [
    "Andale 1", "ccc5a5c9-6324-d8f8-e727-ced142c873da",
    "Andale 2", "8e10462f-f7e9-0387-d60b-622fa60aefbc",
    "Serif 1", "2c1e3fa3-9bdb-2537-e50d-2deb6f2fa22c",
    "Serif 2", "bf2b6c21-e3d7-877b-15dc-ad666b6c14fe",
    "LCD", "014291dc-7fd5-4587-413a-0d690a991ae1"
        ];

string g_sCharIndex;
list g_lDecode;

ResetCharIndex() {
    g_sCharIndex  = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`";
    g_sCharIndex += "abcdefghijklmnopqrstuvwxyz{|}~\n\n\n\n\n";
    g_lDecode= [ "%C3%87", "%C3%BC", "%C3%A9", "%C3%A2", "%C3%A4", "%C3%A0", "%C3%A5", "%C3%A7", "%C3%AA", "%C3%AB" ];
    g_lDecode+=[ "%C3%A8", "%C3%AF", "%C3%AE", "%C3%AC", "%C3%84", "%C3%85", "%C3%89", "%C3%A6", "%C3%AE", "xxxxxx" ];
    g_lDecode+=[ "%C3%B6", "%C3%B2", "%C3%BB", "%C3%B9", "%C3%BF", "%C3%96", "%C3%9C", "%C2%A2", "%C2%A3", "%C2%A5" ];
    g_lDecode+=[ "%E2%82%A7", "%C6%92", "%C3%A1", "%C3%AD", "%C3%B3", "%C3%BA", "%C3%B1", "%C3%91", "%C2%AA", "%C2%BA"];
    g_lDecode+=[ "%C2%BF", "%E2%8C%90", "%C2%AC", "%C2%BD", "%C2%BC", "%C2%A1", "%C2%AB", "%C2%BB", "%CE%B1", "%C3%9F" ];
    g_lDecode+=[ "%CE%93", "%CF%80", "%CE%A3", "%CF%83", "%C2%B5", "%CF%84", "%CE%A6", "%CE%98", "%CE%A9", "%CE%B4" ];
    g_lDecode+=[ "%E2%88%9E", "%CF%86", "%CE%B5", "%E2%88%A9", "%E2%89%A1", "%C2%B1", "%E2%89%A5", "%E2%89%A4", "%E2%8C%A0", "%E2%8C%A1" ];
    g_lDecode+=[ "%C3%B7", "%E2%89%88", "%C2%B0", "%E2%88%99", "%C2%B7", "%E2%88%9A", "%E2%81%BF", "%C2%B2", "%E2%82%AC", "" ];
}

vector GetGridOffset(integer iIndex) {
    integer iRow = iIndex / 10;
    integer iCol = iIndex % 10;
    return <g_vGridOffset.x + 0.1 * iCol, g_vGridOffset.y - 0.05 * iRow, g_vGridOffset.z>;
}

ShowChars(integer link,vector grkID_offset) {
    float alpha = llList2Float(llGetLinkPrimitiveParams( link,[PRIM_COLOR,FACE]),1);
    llSetLinkPrimitiveParamsFast( link,[
        PRIM_TEXTURE, FACE, (string)g_kFontTexture, g_vRepeats, grkID_offset - g_vOffset, 0.0,
        PRIM_COLOR, FACE, g_vColor, alpha]);
}

integer GetIndex(string sChar) {
    integer  iRet=llSubStringIndex(g_sCharIndex, sChar);
    if(iRet>=0) return iRet;
    string sEscaped=llEscapeURL(sChar);
    integer iFound=llListFindList(g_lDecode, [sEscaped]);
    if(iFound<0) return 0;
    return 100+iFound;
}

RenderString(integer iLink, string sStr) {
    if(iLink <= 0) return;
    vector GridOffset1 = GetGridOffset( GetIndex(llGetSubString(sStr, 0, 0)) );
    ShowChars(iLink,GridOffset1);
}

float g_fScrollTime = 0.2 ;
integer g_iSctollPos ;
string g_sScrollText;
list g_lLabelLinks ;
list g_lLabelBaseElements;
list g_lGlows;

integer LabelsCount() {
    integer ok = TRUE ;
    g_lLabelLinks = [] ;
    g_lLabelBaseElements = [];
    string sLabel;
    list lTmp;
    integer iLink;
    integer iLinkCount = llGetNumberOfPrims();
    for(iLink=2; iLink <= iLinkCount; iLink++) {
        sLabel = llList2String(llGetLinkPrimitiveParams(iLink,[PRIM_NAME]),0);
        lTmp = llParseString2List(sLabel, ["~"],[]);
        sLabel = llList2String(lTmp,0);
        if(sLabel == "Label") {
            g_lLabelLinks += [0];
            llSetLinkPrimitiveParamsFast(iLink,[PRIM_DESC,"Label~notexture~nocolor~nohide~noshiny"]);
        } else if (sLabel == "LabelBase") g_lLabelBaseElements += iLink;
    }
    g_iCharLimit = llGetListLength(g_lLabelLinks);
    for(iLink=2; iLink <= iLinkCount; iLink++) {
        sLabel = llList2String(llGetLinkPrimitiveParams(iLink,[PRIM_NAME]),0);
        lTmp = llParseString2List(sLabel, ["~"],[]);
        sLabel = llList2String(lTmp,0);
        if(sLabel == "Label") {
            integer iLabel = (integer)llList2String(lTmp,1);
            integer link = llList2Integer(g_lLabelLinks,iLabel);
            if(link == 0) g_lLabelLinks = llListReplaceList(g_lLabelLinks,[iLink],iLabel,iLabel);
            else {
                ok = FALSE;
                llOwnerSay("Warning! Found duplicated label prims: "+sLabel+" with link numbers: "+(string)link+" and "+(string)iLink);
            }
        }
    }
    return ok;
}

SetLabelBaseAlpha() {
    if (g_iHide) return ;
    integer n;
    integer iLinkElements = llGetListLength(g_lLabelBaseElements);
    for (n = 0; n < iLinkElements; n++) {
        llSetLinkAlpha(llList2Integer(g_lLabelBaseElements,n), (float)g_iShow, ALL_SIDES);
        UpdateGlow(llList2Integer(g_lLabelBaseElements,n), g_iShow);
    }
}

UpdateGlow(integer iLink, integer iAlpha) {
    if (iAlpha == 0) {
        SavePrimGlow(iLink);
        llSetLinkPrimitiveParamsFast(iLink, [PRIM_GLOW, ALL_SIDES, 0.0]);
    } else RestorePrimGlow(iLink);
}

SavePrimGlow(integer iLink) {
    float fGlow = llList2Float(llGetLinkPrimitiveParams(iLink,[PRIM_GLOW,0]),0);
    integer i = llListFindList(g_lGlows,[iLink]);
    if (i !=-1 && fGlow > 0) g_lGlows = llListReplaceList(g_lGlows,[fGlow],i+1,i+1);
    if (i !=-1 && fGlow == 0) g_lGlows = llDeleteSubList(g_lGlows,i,i+1);
    if (i == -1 && fGlow > 0) g_lGlows += [iLink, fGlow];
}

RestorePrimGlow(integer iLink) {
    integer i = llListFindList(g_lGlows,[iLink]);
    if (i != -1) llSetLinkPrimitiveParamsFast(iLink, [PRIM_GLOW, ALL_SIDES, llList2Float(g_lGlows, i+1)]);
}

SetLabel() {
    string sText ;
    if (g_iShow) sText = g_sLabelText;
    string sPadding;
    if (g_iScroll) {
        while(llStringLength(sPadding) < g_iCharLimit) sPadding += " ";
        g_sScrollText = sPadding + sText;
        llSetTimerEvent(g_fScrollTime);
    } else {
        g_sScrollText = "";
        llSetTimerEvent(0);
        while(llStringLength(sPadding + sText + sPadding) < g_iCharLimit) sPadding += " ";
        sText = sPadding + sText;
        integer iCharPosition;
        for(iCharPosition=0; iCharPosition < g_iCharLimit; iCharPosition++)
            RenderString(llList2Integer(g_lLabelLinks, iCharPosition), llGetSubString(sText, iCharPosition, iCharPosition));
    }
}

SetOffsets(key font) {
    integer link = llList2Integer(g_lLabelLinks, 0);
    list params = llGetLinkPrimitiveParams(link, [PRIM_DESC, PRIM_TYPE]);
    string desc = llGetSubString(llList2String(params, 0), 0, 4);
    if (desc == "Label") {
        integer t = (integer)llList2String(params, 1);
        if (t == PRIM_TYPE_BOX) {
            if (font == NULL_KEY) font = "bf2b6c21-e3d7-877b-15dc-ad666b6c14fe";
            g_vGridOffset = <-0.45, 0.425, 0.0>;
            g_vRepeats = <0.126, 0.097, 0>;
            g_vOffset = <0.036, 0.028, 0>;
            FACE = 0;
        } else if (t == PRIM_TYPE_CYLINDER) {
            if (font == NULL_KEY) font = "2c1e3fa3-9bdb-2537-e50d-2deb6f2fa22c";
            g_vGridOffset = <-0.725, 0.425, 0.0>;
            g_vRepeats = <1.434, 0.05, 0>;
            g_vOffset = <0.037, 0.003, 0>;
            FACE = 1;
        }
        integer o = llListFindList(g_lFonts, [(string)g_kFontTexture]);
        integer n = llListFindList(g_lFonts, [(string)font]);
        if (~o && o != n) {
            if (n < 8 && o == 9) g_vOffset.y += 0.0015;
            else if (o < 8 && n == 9) g_vOffset.y -= 0.0015;
        }
    }
    g_kFontTexture = font;
}

Dialog(key kRCPT, string sPrompt, list lChoices, list lUtilityButtons, integer iPage, integer iAuth, string iMenuType) {
    key kMenuID = llGenerateKey();
    llMessageLinked(LINK_DIALOG, DIALOG, (string)kRCPT + "|" + sPrompt + "|" + (string)iPage + "|" + llDumpList2String(lChoices, "`") + "|" + llDumpList2String(lUtilityButtons, "`") + "|" + (string)iAuth, kMenuID);
    integer iIndex = llListFindList(g_lMenuIDs, [kRCPT]);
    if (~iIndex) g_lMenuIDs = llListReplaceList(g_lMenuIDs, [kRCPT, kMenuID, iMenuType], iIndex, iIndex + g_iMenuStride - 1);
    else g_lMenuIDs += [kRCPT, kMenuID, iMenuType];
}

MainMenu(key kID, integer iAuth) {
    list lButtons= [g_sTextMenu, g_sColorMenu, g_sFontMenu];
    if (g_iShow) lButtons += ["☑ Show"];
    else lButtons += ["☐ Show"];
    if (g_iScroll) lButtons += ["☑ Scroll"];
    else lButtons += ["☐ Scroll"];
    string sPrompt = "\n[http://www.opencollar.at/label.html Label]\t"+g_sAppVersion+"\n\nCustomize the %DEVICETYPE%'s label!";
    Dialog(kID, sPrompt, lButtons, [UPMENU], 0, iAuth,"main");
}

TextMenu(key kID, integer iAuth) {
    string sPrompt = "\n[http://www.opencollar.at/label.html Label]\n\n- Submit the new label in the field below.\n- Submit a few spaces to clear the label.\n- Submit a blank field to go back to " + g_sSubMenu + ".";
    Dialog(kID, sPrompt, [], [], 0, iAuth,"textbox");
}

ColorMenu(key kID, integer iAuth) {
    string sPrompt = "\n\nSelect a colour from the list";
    Dialog(kID, sPrompt, ["colormenu please"], [UPMENU], 0, iAuth,"color");
}

FontMenu(key kID, integer iAuth) {
    list lButtons=llList2ListStrided(g_lFonts,0,-1,2);
    string sPrompt = "\n[http://www.opencollar.at/label.html Label]\n\nSelect the font for the %DEVICETYPE%'s label.";

    Dialog(kID, sPrompt, lButtons, [UPMENU], 0, iAuth,"font");
}

UserCommand(integer iAuth, string sStr, key kAv) {
    string sLowerStr = llToLower(sStr);
    if (sStr == "rm label") {
        if (kAv!=g_kWearer && iAuth!=CMD_OWNER) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kAv);
        else Dialog(kAv, "\nDo you really want to uninstall the "+g_sSubMenu+" App?", ["Yes","No","Cancel"], [], 0, iAuth,"rmlabel");
    } else if (iAuth == CMD_OWNER) {
        if (sLowerStr == "menu label" || sLowerStr == "label") {
            MainMenu(kAv, iAuth);
            return;
        }
        list lParams = llParseString2List(sStr, [" "], []);
        string sCommand = llToLower(llList2String(lParams, 0));
        string sAction = llToLower(llList2String(lParams, 1));
        string sValue = llToLower(llList2String(lParams, 2));
        if (sCommand == "label") {
            if (sAction == "font") {
                lParams = llDeleteSubList(lParams, 0, 1);
                string font = llDumpList2String(lParams, " ");
                integer iIndex = llListFindList(g_lFonts, [font]);
                if (iIndex != -1) {
                    SetOffsets((key)llList2String(g_lFonts, iIndex + 1));
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken + "font=" + (string)g_kFontTexture, "");
                }
                else FontMenu(kAv, iAuth);
            } else if (sAction == "color") {
                string sColor= llDumpList2String(llDeleteSubList(lParams,0,1)," ");
                if (sColor != "") {
                    g_vColor=(vector)sColor;
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken+"color="+(string)g_vColor, "");
                }
            } else if (sAction == "on" && sValue == "") {
                g_iShow = TRUE;
                SetLabelBaseAlpha();
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken+"show="+(string)g_iShow, "");
            } else if (sAction == "off" && sValue == "") {
                g_iShow = FALSE;
                SetLabelBaseAlpha();
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken+"show="+(string)g_iShow, "");
            } else if (sAction == "scroll") {
                if (sValue == "on") g_iScroll = TRUE;
                else if (sValue == "off") g_iScroll = FALSE;
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken+"scroll="+(string)g_iScroll, "");
            } else {
                g_sLabelText = llStringTrim(llDumpList2String(llDeleteSubList(lParams,0,0)," "),STRING_TRIM);
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken + "text=" + g_sLabelText, "");
                if (llStringLength(g_sLabelText) > g_iCharLimit) {
                    string sDisplayText = llGetSubString(g_sLabelText, 0, g_iCharLimit-1);
                    llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"Unless your set your label to scroll it will be truncted at "+sDisplayText+".", kAv);
                }
            }
            SetLabel();
        }
    } else if (iAuth >= CMD_TRUSTED && iAuth <= CMD_WEARER){
        string sCommand = llToLower(llList2String(llParseString2List(sStr, [" "], []), 0));
        if (sStr=="menu "+g_sSubMenu) {
            llMessageLinked(LINK_ROOT, iAuth, "menu "+g_sParentMenu, kAv);
            llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"%NOACCESS%", kAv);
        } else if (sCommand=="labeltext" || sCommand == "labelfont" || sCommand == "labelcolor" || sCommand == "labelshow")
            llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"%NOACCESS%", kAv);
    }
}

default {
    state_entry() {
        g_kWearer = llGetOwner();
        LabelsCount();
        SetOffsets(NULL_KEY);
        ResetCharIndex();
        if (g_iCharLimit <= 0) {
            llMessageLinked(LINK_ROOT, MENUNAME_REMOVE, g_sParentMenu + "|" + g_sSubMenu, "");
            llRemoveInventory(llGetScriptName());
        }
        g_sLabelText = llList2String(llParseString2List(llKey2Name(g_kWearer), [" "], []), 0);
        SetLabel();
    }

    on_rez(integer iNum) {
        llResetScript();
    }

    link_message(integer iSender, integer iNum, string sStr, key kID) {
        if (iNum >= CMD_OWNER && iNum <= CMD_WEARER) UserCommand(iNum, sStr, kID);
        else if (iNum == LM_SETTING_RESPONSE) {
            list lParams = llParseString2List(sStr, ["="], []);
            string sToken = llList2String(lParams, 0);
            string sValue = llList2String(lParams, 1);
            integer i = llSubStringIndex(sToken, "_");
            if (llGetSubString(sToken, 0, i) == g_sSettingToken) {
                sToken = llGetSubString(sToken, i + 1, -1);
                if (sToken == "text") g_sLabelText = sValue;
                else if (sToken == "font") SetOffsets((key)sValue);
                else if (sToken == "color") g_vColor = (vector)sValue;
                else if (sToken == "show") g_iShow = (integer)sValue;
                else if (sToken == "scroll") g_iScroll = (integer)sValue;
            }
            else if (sToken == "settings" && sValue == "sent") SetLabel();
        }
        else if (iNum == MENUNAME_REQUEST && sStr == g_sParentMenu)
            llMessageLinked(iSender, MENUNAME_RESPONSE, g_sParentMenu + "|" + g_sSubMenu, "");
        else if (iNum == DIALOG_RESPONSE) {
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            if (~iMenuIndex) {
                string sMenuType = llList2String(g_lMenuIDs, iMenuIndex + 1);
                g_lMenuIDs = llDeleteSubList(g_lMenuIDs, iMenuIndex - 1, iMenuIndex - 2 + g_iMenuStride);
                list lMenuParams = llParseString2List(sStr, ["|"], []);
                key kAv = (key)llList2String(lMenuParams, 0);
                string sMessage = llList2String(lMenuParams, 1);
                integer iAuth = (integer)llList2String(lMenuParams, 3);
                if (sMenuType=="main") {
                    if (sMessage == UPMENU) llMessageLinked(LINK_ROOT, iAuth, "menu " + g_sParentMenu, kAv);
                    else if (sMessage == g_sTextMenu) TextMenu(kAv, iAuth);
                    else if (sMessage == g_sColorMenu) ColorMenu(kAv, iAuth);
                    else if (sMessage == g_sFontMenu) FontMenu(kAv, iAuth);
                    else if (sMessage == "☐ Show") {
                        UserCommand(iAuth, "label on", kAv);
                        MainMenu(kAv, iAuth);
                    } else if (sMessage == "☑ Show") {
                        UserCommand(iAuth, "label off", kAv);
                        MainMenu(kAv, iAuth);
                    } else if (sMessage == "☐ Scroll") {
                        UserCommand(iAuth, "label scroll on", kAv);
                        MainMenu(kAv, iAuth);
                    } else if (sMessage == "☑ Scroll") {
                        UserCommand(iAuth, "label scroll off", kAv);
                        MainMenu(kAv, iAuth);
                    }
                } else if (sMenuType == "color") {
                    if (sMessage == UPMENU) MainMenu(kAv, iAuth);
                    else {
                        UserCommand(iAuth, "label color "+sMessage, kAv);
                        ColorMenu(kAv, iAuth);
                    }
                } else if (sMenuType == "font") {
                    if (sMessage == UPMENU) MainMenu(kAv, iAuth);
                    else {
                        UserCommand(iAuth, "label font " + sMessage, kAv);
                        FontMenu(kAv, iAuth);
                    }
                } else if (sMenuType == "textbox") {
                    if (sMessage != " ") UserCommand(iAuth, "label " + sMessage, kAv);
                    UserCommand(iAuth, "menu " + g_sSubMenu, kAv);
                } else if (sMenuType == "rmlabel") {
                    if (sMessage == "Yes") {
                        if (g_sScrollText) UserCommand(iAuth, "label scroll off", kAv);
                        llMessageLinked(LINK_ROOT, MENUNAME_REMOVE , g_sParentMenu + "|" + g_sSubMenu, "");
                        llMessageLinked(LINK_DIALOG, NOTIFY, "1"+g_sSubMenu+" App has been removed.", kAv);
                    if (llGetInventoryType(llGetScriptName()) == INVENTORY_SCRIPT) llRemoveInventory(llGetScriptName());
                    } else llMessageLinked(LINK_DIALOG, NOTIFY, "0"+g_sSubMenu+" App remains installed.", kAv);
                }
            }
        } else if (iNum == DIALOG_TIMEOUT) {
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            g_lMenuIDs = llDeleteSubList(g_lMenuIDs, iMenuIndex - 1, iMenuIndex +3);
        } else if (iNum == LINK_UPDATE) {
            if (sStr == "LINK_DIALOG") LINK_DIALOG = iSender;
            else if (sStr == "LINK_SAVE") LINK_SAVE = iSender;
        } else if (iNum == BUILD_REQUEST)
            llMessageLinked(iSender,iNum+g_iBuild,llGetScriptName(),"");
        else if (iNum == REBOOT && sStr == "reboot") llResetScript();
    }

    timer() {
        string sText = llGetSubString(g_sScrollText, g_iSctollPos, -1);
        integer iCharPosition;
        for(iCharPosition=0; iCharPosition < g_iCharLimit; iCharPosition++)
            RenderString(llList2Integer(g_lLabelLinks, iCharPosition), llGetSubString(sText, iCharPosition, iCharPosition));
        g_iSctollPos++;
        if (g_iSctollPos > llStringLength(g_sScrollText)) g_iSctollPos = 0 ;
    }

    changed(integer iChange) {
        if(iChange & CHANGED_LINK) {
            if (LabelsCount()) SetLabel();
        }
        if (iChange & CHANGED_COLOR) {
            integer iNewHide = !(integer)llGetAlpha(ALL_SIDES);
            if (g_iHide != iNewHide) {
                g_iHide = iNewHide;
                SetLabelBaseAlpha();
            }
        }
    }
}
