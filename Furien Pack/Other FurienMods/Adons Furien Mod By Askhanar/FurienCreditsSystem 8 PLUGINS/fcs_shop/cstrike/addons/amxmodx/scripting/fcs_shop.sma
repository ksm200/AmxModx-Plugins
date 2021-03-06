/* Plugin generated by AMXX-Studio */

#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < hamsandwich >
#include < fun >
//#include < fcs >
//#include < CC_ColorChat >

#define PLUGIN "FCS Credits Shop"
#define VERSION "1.0.2"

/*
 * Returns a players credits
 * 
 * @param		client - The player index to get points of
 * 
 * @return		The credits client
 * 
 */

native fcs_get_user_credits(client);

/*
 * Sets <credits> to client
 * 
 * @param		client - The player index to set points to
 * @param		credits - The amount of credits to set to client
 * 
 * @return		The credits of client
 * 
 */

native fcs_set_user_credits(client, credits);

/*
 * Adds <credits> points to client
 * 
 * @param		client - The player index to add points to
 * @param		credits - The amount of credits to set to client
 * 
 * @return		The credits of client
 * 
 */

stock fcs_add_user_credits(client, credits)
{
	return fcs_set_user_credits(client, fcs_get_user_credits(client) + credits);
}

/*
 * Subtracts <credits>  from client
 * 
 * @param		client - The player index to subtract points from
 * @param		credits - The amount of credits to set to client
 * 
 * @return		The credits of client
 * 
 */

stock fcs_sub_user_credits(client, credits)
{
	return fcs_set_user_credits(client, fcs_get_user_credits(client) - credits);
}

enum Color
{
	NORMAL = 1, 		// Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
	GREEN, 			// Culoare Verde.
	TEAM_COLOR, 		// Culoare Rosu, Albastru, Gri.
	GREY, 			// Culoarea Gri.
	RED, 			// Culoarea Rosu.
	BLUE, 			// Culoarea Albastru.
}

new TeamName[  ][  ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

new const g_szTag[ ] = "[FCS Shop]";
new g_szMenuName[ ] = "\rFCS\y SHOP";

enum _:iCvars
{
	ENABLE,
	
	NADES_PRICE,
	NADES_TO,
	
	HP_PRICE,
	HP_AMOUNT,
	HP_TO,
	
	AP_PRICE,
	AP_AMOUNT,
	AP_TO,
	
	DEAGLE_PRICE,
	DEAGLE_BACKPACK_AMMO,
	DEAGLE_TO,
	
	SPEED_PRICE,
	SPEED_AMOUNT,
	SPEED_DURATION,
	SPEED_TO,
	
	GRAVITY_PRICE,
	GRAVITY_AMOUNT,
	GRAVITY_DURATION,
	GRAVITY_TO
	
	
}

enum _:WhatUserHas
{
	SPEED,
	GRAVITY,
}

new g_iCvar[ iCvars ];
new bool:g_bUserHas[ 33 ][ WhatUserHas ];

// Do not modify this.
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );
	register_cvar( "fcs_shop_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY ); 
	
	g_iCvar[ ENABLE ] = register_cvar( "fcsshop_enable", "1" );
	
	g_iCvar[ NADES_PRICE ] = register_cvar( "fcsshop_nades_price", "25" );
	g_iCvar[ NADES_TO ] = register_cvar( "fcsshop_nades_team", "1" );
	
	g_iCvar[ HP_PRICE ] = register_cvar( "fcsshop_hp_price", "60" );
	g_iCvar[ HP_AMOUNT ] = register_cvar( "fcsshop_hp_amount", "300" );
	g_iCvar[ HP_TO ] = register_cvar( "fcsshop_hp_team", "3" );
	
	g_iCvar[ AP_PRICE ] = register_cvar( "fcsshop_ap_price", "55" );
	g_iCvar[ AP_AMOUNT ] = register_cvar( "fcsshop_ap_amount", "500" );
	g_iCvar[ AP_TO ] = register_cvar( "fcsshop_ap_team", "3" );
	
	g_iCvar[ DEAGLE_PRICE ] = register_cvar( "fcsshop_deagle_price", "80" );
	g_iCvar[ DEAGLE_BACKPACK_AMMO ] = register_cvar( "fcsshop_deagle_ammo", "21" );
	g_iCvar[ DEAGLE_TO ] = register_cvar( "fcsshop_deagle_team", "1" );
	
	g_iCvar[ SPEED_PRICE ] = register_cvar( "fcsshop_speed_price", "75" );
	g_iCvar[ SPEED_AMOUNT ] = register_cvar( "fcsshop_speed_amount", "500" );
	g_iCvar[ SPEED_DURATION ] = register_cvar( "fcsshop_speed_duration", "1" );
	g_iCvar[ SPEED_TO ] = register_cvar( "fcsshop_speed_team", "2" );
	
	g_iCvar[ GRAVITY_PRICE ] = register_cvar( "fcsshop_gravity_price", "80" );
	g_iCvar[ GRAVITY_AMOUNT ] = register_cvar( "fcsshop_gravity_amount", "300" );
	g_iCvar[ GRAVITY_DURATION ] = register_cvar( "fcsshop_gravity_duration", "1" );
	g_iCvar[ GRAVITY_TO ] = register_cvar( "fcsshop_gravity_team", "2" );
	
	register_clcmd( "say fcshop", "ClCmdSayShop" );
	register_clcmd( "say_team fcshop", "ClCmdSayShop" );
	register_clcmd( "say /fcshop", "ClCmdSayShop" );
	register_clcmd( "say_team /fcshop", "ClCmdSayShop" );
	
	RegisterHam( Ham_Spawn, "player", "ham_PlayerSpawnPre", true );
	RegisterHam( Ham_Killed, "player", "ham_PlayerKilledPre",true );
	RegisterHam( Ham_Player_ResetMaxSpeed, "player", "ham_PlayerResetMaxSpeedPre", true );

	// Add your code here...
}

public client_putinserver( id )
{
	if( is_user_bot( id ) || is_user_hltv( id ) )
		return;
		
	g_bUserHas[ id ][ SPEED ] = false;
	g_bUserHas[ id ][ GRAVITY ] = false;
	
}

public client_disconnect( id )
{
	if( is_user_bot( id ) || is_user_hltv( id ) )
		return;
		
	g_bUserHas[ id ][ SPEED ] = false;
	g_bUserHas[ id ][ GRAVITY ] = false;
	
}

public ClCmdSayShop( id )
{
	
	
	if( get_pcvar_num( g_iCvar[ ENABLE ] ) == 0 )
	{
		ColorChat( id, RED, "^x04%s^x03 Comanda dezactivata de catre server!", g_szTag );
		return PLUGIN_HANDLED;
	}
	
	if( !is_user_alive( id ) )
	{
		ColorChat( id, RED, "^x04%s^x03 Trebuie sa fii in viata!", g_szTag );
		return PLUGIN_HANDLED;
	}
	
	
	ShopMenu( id );
	return PLUGIN_HANDLED;
	
}

public ShopMenu( id )
{
	new szMenuName[ 64 ];
	formatex( szMenuName, sizeof ( szMenuName ) -1, "%s^n\yCredite: \r%i", g_szMenuName, fcs_get_user_credits( id ) );
	new iMenu = menu_create( szMenuName, "ShopMenuHandler" );	
	new iCallBack  =  menu_makecallback( "CallBackShop" );
	
	new szBuffer[ 6 ][ 64 ], szBufferKey[ 5 ], iBufferKey = 1;
	formatex( szBuffer[ 0 ], sizeof ( szBuffer[ ] ) -1, "\r[ \yFULL\r ] \wGrenades\y       [\r %iC\y ]", get_pcvar_num( g_iCvar[ NADES_PRICE ] ) );
	formatex( szBuffer[ 1 ], sizeof ( szBuffer[ ] ) -1, "\r[ \y%i\r ] \wHP\y                [\r %iC\y ]", get_pcvar_num( g_iCvar[ HP_AMOUNT ] ), get_pcvar_num( g_iCvar[ HP_PRICE ] ) )
	formatex( szBuffer[ 2 ], sizeof ( szBuffer[ ] ) -1, "\r[ \y%i\r ] \wAP\y                  [\r %iC\y ]", get_pcvar_num( g_iCvar[ AP_AMOUNT ] ), get_pcvar_num( g_iCvar[ AP_PRICE ] ) )
	formatex( szBuffer[ 3 ], sizeof ( szBuffer[ ] ) -1, "\r[ \y%i AMMO\r ] \wDeagle\y    [\r %iC\y ]", get_pcvar_num( g_iCvar[ DEAGLE_BACKPACK_AMMO ] ), get_pcvar_num( g_iCvar[ DEAGLE_PRICE ] ) );
	formatex( szBuffer[ 4 ], sizeof ( szBuffer[ ] ) -1, "\r[ \y%.1f\r ] \wSpeed\y          [\r %iC\y ]", float( get_pcvar_num( g_iCvar[ SPEED_AMOUNT ] ) ), get_pcvar_num( g_iCvar[ SPEED_PRICE ] ) );
	formatex( szBuffer[ 5 ], sizeof ( szBuffer[ ] ) -1, "\r[ \y%i\r ] \wGravity\y            [\r %iC\y ]", get_pcvar_num( g_iCvar[ GRAVITY_AMOUNT ] ), get_pcvar_num( g_iCvar[ GRAVITY_PRICE ] ) );
	
	for( new i = 0; i < 6; i++ )
	{
		formatex( szBufferKey, sizeof ( szBufferKey ) -1, "%i", iBufferKey );
		menu_additem( iMenu, szBuffer[ i ], szBufferKey, _, iCallBack );
		
		iBufferKey++;
	}
	
	menu_setprop( iMenu, MPROP_EXITNAME, "\wIesire" );
	
	menu_display( id, iMenu, 0 );

}

/*=======================================================================================s=P=u=f=?*/

public ShopMenuHandler( id, iMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( iMenu );
		return 1PLUGIN_HANDLED;
	}
	
	new data[ 6 ], iName[ 64 ];
	new iaccess, callback;
	
	menu_item_getinfo( iMenu, iItem, iaccess, data, 5, iName, 63, callback );
	
	new key = str_to_num( data );
	//new page = floatround( str_to_float( data ) / 7.0001, floatround_floor );
	
	menu_destroy( iMenu );
	switch( key )
	{
		case 1:
		{
			new iCredits, iNeededCredits;
			iCredits = fcs_get_user_credits( id );
			iNeededCredits = get_pcvar_num( g_iCvar[ NADES_PRICE ] );
			
			if( iCredits < iNeededCredits )
			{
				ColorChat( id, RED, "^x04%s^x03 NU^x01 ai destule credite, iti mai trebuie^x03 %i credite^x01 !", g_szTag, iNeededCredits - iCredits );
				return PLUGIN_HANDLED;
			}
			
			if( bUserHasAnyNade( id ) )
			{
				ColorChat( id, RED, "^x04%s^x03 Ai cel putin o grenada in mana, nu poti cumpara altele!", g_szTag );
				return PLUGIN_HANDLED;
			}
			
			fcs_sub_user_credits( id, iNeededCredits );
			ColorChat( id, RED, "^x04%s^x01 Ai cumparat^x03 FULL Grenades^x01 pentru^x03 %i credite^x01 !", g_szTag, iNeededCredits );
			
			give_item( id, "weapon_hegrenade" );
			give_item( id, "weapon_flashbang" );
			give_item( id, "weapon_flashbang" );
			give_item( id, "weapon_smokegrenade" );
			
		}
		
		case 2:
		{
			new iCredits, iNeededCredits;
			iCredits = fcs_get_user_credits( id );
			iNeededCredits = get_pcvar_num( g_iCvar[ HP_PRICE ] );
			
			if( iCredits < iNeededCredits )
			{
				ColorChat( id, RED, "^x04%s^x03 NU^x01 ai destule credite, iti mai trebuie^x03 %i credite^x01 !", g_szTag, iNeededCredits - iCredits );
				return PLUGIN_HANDLED;
			}
			
			fcs_sub_user_credits( id, iNeededCredits );
			
			new iHP = get_pcvar_num( g_iCvar[ HP_AMOUNT ] );
			ColorChat( id, RED, "^x04%s^x01 Ai cumparat^x03 %i HP^x01 pentru^x03 %i credite^x01 !", g_szTag, iHP, iNeededCredits );
			
			set_user_health( id, get_user_health( id ) + iHP );
			
		}
		
		case 3:
		{
			new iCredits, iNeededCredits;
			iCredits = fcs_get_user_credits( id );
			iNeededCredits = get_pcvar_num( g_iCvar[ AP_PRICE ] );
			
			if( iCredits < iNeededCredits )
			{
				ColorChat( id, RED, "^x04%s^x03 NU^x01 ai destule credite, iti mai trebuie^x03 %i credite^x01 !", g_szTag, iNeededCredits - iCredits );
				return PLUGIN_HANDLED;
			}
			
			fcs_sub_user_credits( id, iNeededCredits );
			
			new iAP = get_pcvar_num( g_iCvar[ AP_AMOUNT ] );
			ColorChat( id, RED, "^x04%s^x01 Ai cumparat^x03 %i AP^x01 pentru^x03 %i credite^x01 !", g_szTag, iAP, iNeededCredits );
			
			set_user_armor( id, get_user_armor( id ) + iAP );
			
		}
		
		case 4:
		{
			new iCredits, iNeededCredits;
			iCredits = fcs_get_user_credits( id );
			iNeededCredits = get_pcvar_num( g_iCvar[ DEAGLE_PRICE ] );
			
			if( iCredits < iNeededCredits )
			{
				ColorChat( id, RED, "^x04%s^x03 NU^x01 ai destule credite, iti mai trebuie^x03 %i credite^x01 !", g_szTag, iNeededCredits - iCredits );
				return PLUGIN_HANDLED;
			}
			
			fcs_sub_user_credits( id, iNeededCredits );
			
			new iAMMO = get_pcvar_num( g_iCvar[ DEAGLE_BACKPACK_AMMO ] );
			ColorChat( id, RED, "^x04%s^x01 Ai cumparat^x03 %i AMMO Deagle^x01 pentru^x03 %i credite^x01 !", g_szTag, iAMMO, iNeededCredits );
			
			give_item( id, "weapon_deagle" );
			cs_set_user_bpammo( id, CSW_DEAGLE, iAMMO );
			
		}
		
		case 5:
		{
			new iCredits, iNeededCredits;
			iCredits = fcs_get_user_credits( id );
			iNeededCredits = get_pcvar_num( g_iCvar[ SPEED_PRICE ] );
			
			if( iCredits < iNeededCredits )
			{
				ColorChat( id, RED, "^x04%s^x03 NU^x01 ai destule credite, iti mai trebuie^x03 %i credite^x01 !", g_szTag, iNeededCredits - iCredits );
				return PLUGIN_HANDLED;
			}
			
			fcs_sub_user_credits( id, iNeededCredits );
			
			new iSpeed = get_pcvar_num( g_iCvar[ SPEED_AMOUNT ] );
			ColorChat( id, RED, "^x04%s^x01 Ai cumparat^x03 %.1f Speed^x01 pentru^x03 %i credite^x01 !", g_szTag, float( iSpeed ), iNeededCredits );
			
			g_bUserHas[ id ][ SPEED ] = true;
			engfunc( EngFunc_SetClientMaxspeed, id, float( iSpeed )  );
			set_pev( id,  pev_maxspeed, float( iSpeed ) );
			
			/*	SlowHack o_O
			client_cmd( id, "cl_forwardspeed %0.1f;cl_sidespeed %0.1f;cl_backspeed %0.1f", float( iSpeed ), float( iSpeed ), float( iSpeed ) );
			*/
		}
		
		case 6:
		{
			new iCredits, iNeededCredits;
			iCredits = fcs_get_user_credits( id );
			iNeededCredits = get_pcvar_num( g_iCvar[ GRAVITY_PRICE ] );
			
			if( iCredits < iNeededCredits )
			{
				ColorChat( id, RED, "^x04%s^x03 NU^x01 ai destule credite, iti mai trebuie^x03 %i credite^x01 !", g_szTag, iNeededCredits - iCredits );
				return PLUGIN_HANDLED;
			}
			
			fcs_sub_user_credits( id, iNeededCredits );
			
			new iGravity = get_pcvar_num( g_iCvar[ GRAVITY_AMOUNT ] );
			ColorChat( id, RED, "^x04%s^x01 Ai cumparat^x03 %i Gravity^x01 pentru^x03 %i credite^x01 !", g_szTag, iGravity, iNeededCredits );
			
			set_user_gravity( id, float( iGravity ) * 0.00125 );
			g_bUserHas[ id ][ GRAVITY ] = true;
		}
		
	}
	
	return PLUGIN_CONTINUE;
	
}

public CallBackShop( id, iMenu, iItem  )
{
	static _access, szInfo[ 4 ],  callback;
	menu_item_getinfo( iMenu, iItem, _access, szInfo, sizeof ( szInfo ) -1, _, _, callback );
	
	//if( szInfo[ 0 ] == '0' )	return ITEM_ENABLED;
	
 	if( szInfo[ 0 ] == '1' )
	{
		if( get_pcvar_num( g_iCvar[ NADES_TO ] ) == 3 || fcs_get_user_team( id ) == get_pcvar_num( g_iCvar[ NADES_TO ] ) )
			return ITEM_ENABLED;
	}
	else if( szInfo[ 0 ] == '2' )
	{
		if( get_pcvar_num( g_iCvar[ HP_TO ] ) == 3 || fcs_get_user_team( id ) == get_pcvar_num( g_iCvar[ HP_TO ] ) )
			return ITEM_ENABLED;
	}
	else if( szInfo[ 0 ] == '3' )
	{
		if( get_pcvar_num( g_iCvar[ AP_TO ] ) == 3 || fcs_get_user_team( id ) == get_pcvar_num( g_iCvar[ AP_TO ] ) )
			return ITEM_ENABLED;
	}
	else if( szInfo[ 0 ] == '4' )
	{
		if( get_pcvar_num( g_iCvar[ DEAGLE_TO ] ) == 3 || fcs_get_user_team( id ) == get_pcvar_num( g_iCvar[ DEAGLE_TO] ) )
			return ITEM_ENABLED;
	}
	else if( szInfo[ 0 ] == '5' )
	{
		if( get_pcvar_num( g_iCvar[ SPEED_TO ] ) == 3 || fcs_get_user_team( id ) == get_pcvar_num( g_iCvar[ SPEED_TO ] ) )
			return ITEM_ENABLED;
	}
	
	else if( szInfo[ 0 ] == '6' )
	{
		if( get_pcvar_num( g_iCvar[ GRAVITY_TO ] ) == 3 || fcs_get_user_team( id ) == get_pcvar_num( g_iCvar[ GRAVITY_TO ] ) )
			return ITEM_ENABLED;
	}
	
	return ITEM_DISABLED;
}

public ham_PlayerSpawnPre(  id  )
{
	
	if( is_user_alive( id ) )
	{
		
		if( get_pcvar_num( g_iCvar[ SPEED_DURATION ] ) == 1 )
		{
			if( g_bUserHas[ id ][ SPEED ] )
			{
				new iSpeed = get_pcvar_num( g_iCvar[ SPEED_AMOUNT ] );
				engfunc( EngFunc_SetClientMaxspeed, id, float( iSpeed )  );
				set_pev( id,  pev_maxspeed, float( iSpeed ) );
				
				/*	SlowHack o_O
				client_cmd( id, "cl_forwardspeed %0.1f;cl_sidespeed %0.1f;cl_backspeed %0.1f", float( iSpeed ), float( iSpeed ), float( iSpeed ) );
				*/
			}
		}
		else
			g_bUserHas[ id ][ SPEED ] = false;
			
		if( get_pcvar_num( g_iCvar[ GRAVITY_DURATION ] ) == 1 )
		{
			if( g_bUserHas[ id ][ GRAVITY ] )
				set_user_gravity( id, float( get_pcvar_num( g_iCvar[ GRAVITY_AMOUNT ] ) ) * 0.00125 );
		}
		else
			g_bUserHas[ id ][ GRAVITY ] = false;
		
		
	}
}


/*======================================= - � Askhanar � - =======================================*/

public ham_PlayerKilledPre(  id  )
{
	g_bUserHas[ id ][ SPEED ] = false;
	g_bUserHas[ id ][ GRAVITY ] = false;
}

public ham_PlayerResetMaxSpeedPre( id )
{

	if( is_user_alive( id )  /*&&  get_user_maxspeed(  id  )  !=  1.0*/  )
	{
		
		if( g_bUserHas[ id ][ SPEED ] )
		{
	
			static Float:flMaxSpeed;
			flMaxSpeed = float( get_pcvar_num( g_iCvar[ SPEED_AMOUNT ] ) );
			
			engfunc( EngFunc_SetClientMaxspeed, id, flMaxSpeed  );
			set_pev( id, pev_maxspeed, flMaxSpeed  );
			
		}
		
		
		/*	SlowHack o_O
			client_cmd(  id,  "cl_forwardspeed %0.1f;cl_sidespeed %0.1f;cl_backspeed %0.1f", flMaxSpeed, flMaxSpeed, flMaxSpeed );
		*/
	}
}

stock bool:bUserHasAnyNade( id )
{
	
	if( user_has_weapon( id, CSW_HEGRENADE ) || user_has_weapon( id, CSW_FLASHBANG )
		|| user_has_weapon( id, CSW_SMOKEGRENADE ) )
		return true;
		
	return false;
	
}

stock fcs_get_user_team( id )
{
	new iTeam = -1;
	if( cs_get_user_team( id ) == CS_TEAM_T )	iTeam = 1;
	else if( cs_get_user_team( id ) == CS_TEAM_CT )	iTeam = 2;
	
	return iTeam;
}

ColorChat(  id, Color:iType, const msg[  ], { Float, Sql, Result, _}:...  )
{
	
	// Daca nu se afla nici un jucator pe server oprim TOT. Altfel dam de erori..
	if( !get_playersnum( ) ) return;
	
	new szMessage[ 256 ];

	switch( iType )
	{
		 // Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
		case NORMAL:	szMessage[ 0 ] = 0x01;
		
		// Culoare Verde.
		case GREEN:	szMessage[ 0 ] = 0x04;
		
		// Alb, Rosu, Albastru.
		default: 	szMessage[ 0 ] = 0x03;
	}

	vformat(  szMessage[ 1 ], 251, msg, 4  );

	// Ne asiguram ca mesajul nu este mai lung de 192 de caractere.Altfel pica server-ul.
	szMessage[ 192 ] = '^0';
	

	new iTeam, iColorChange, iPlayerIndex, MSG_Type;
	
	if( id )
	{
		MSG_Type  =  MSG_ONE_UNRELIABLE;
		iPlayerIndex  =  id;
	}
	else
	{
		iPlayerIndex  =  CC_FindPlayer(  );
		MSG_Type = MSG_ALL;
	}
	
	iTeam  =  get_user_team( iPlayerIndex );
	iColorChange  =  CC_ColorSelection(  iPlayerIndex,  MSG_Type, iType);

	CC_ShowColorMessage(  iPlayerIndex, MSG_Type, szMessage  );
		
	if(  iColorChange  )	CC_Team_Info(  iPlayerIndex, MSG_Type,  TeamName[ iTeam ]  );

}

CC_ShowColorMessage(  id, const iType, const szMessage[  ]  )
{
	
	static bool:bSayTextUsed;
	static iMsgSayText;
	
	if(  !bSayTextUsed  )
	{
		iMsgSayText  =  get_user_msgid( "SayText" );
		bSayTextUsed  =  true;
	}
	
	message_begin( iType, iMsgSayText, _, id  );
	write_byte(  id  )		
	write_string(  szMessage  );
	message_end(  );
}

CC_Team_Info( id, const iType, const szTeam[  ] )
{
	static bool:bTeamInfoUsed;
	static iMsgTeamInfo;
	if(  !bTeamInfoUsed  )
	{
		iMsgTeamInfo  =  get_user_msgid( "TeamInfo" );
		bTeamInfoUsed  =  true;
	}
	
	message_begin( iType, iMsgTeamInfo, _, id  );
	write_byte(  id  );
	write_string(  szTeam  );
	message_end(  );

	return 1;
}

CC_ColorSelection(  id, const iType, Color:iColorType)
{
	switch(  iColorType  )
	{
		
		case RED:	return CC_Team_Info(  id, iType, TeamName[ 1 ]  );
		case BLUE:	return CC_Team_Info(  id, iType, TeamName[ 2 ]  );
		case GREY:	return CC_Team_Info(  id, iType, TeamName[ 0 ]  );

	}

	return 0;
}

CC_FindPlayer(  )
{
	new iMaxPlayers  =  get_maxplayers(  );
	
	for( new i = 1; i <= iMaxPlayers; i++ )
		if(  is_user_connected( i )  )
			return i;
	
	return -1;
}