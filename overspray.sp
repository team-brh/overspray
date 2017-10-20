#include <sourcemod>
#include <sdktools>


new Float:g_arrSprayTrace[MAXPLAYERS + 1][3];



public Plugin:myinfo = 
{
	name = "Overspray Preventor",
	author = "Codemonkey",
	description = "Removes sprays if they are sprayed over a spray",
	version = "0.1",
	url = "http://team-brh.com/"
};

public OnPluginStart() {
	
	AddTempEntHook("Player Decal",PlayerSpray);
	
}



public OnMapStart() {

	for(new i = 1; i <= MaxClients; i++)
		ClearVariables(i);
}

/*
	Clears all stored sprays for a disconnecting
	client if global spray tracing is disabled.
*/

public OnClientDisconnect(client) {
	ClearVariables(client);
}

/*
	Clears the stored sprays for the given client.
*/

public ClearVariables(client) {
	g_arrSprayTrace[client][0] = 0.0;
	g_arrSprayTrace[client][1] = 0.0;
	g_arrSprayTrace[client][2] = 0.0;
}

public Action:PlayerSpray(const String:szTempEntName[], const arrClients[], iClientCount, Float:flDelay) {
	new client = TE_ReadNum("m_nPlayer");
	
	if(IsValidClient(client)) {
		new Float:vecPos[3];
		
		TE_ReadVector("m_vecOrigin", vecPos);
		
		for(new i = 1; i<= MaxClients; i++) {
			if(!IsValidClient(i) || IsFakeClient(i) || i == client) {
				continue;
			}
			
			if (GetVectorDistance(vecPos, g_arrSprayTrace[i]) <= 50) {
				new String:playerName[64];
				GetClientName(i, playerName, 64);
				PrintToChat(client, "\x03You attempted to spray over %s's spray, this was blocked", playerName);
				return Plugin_Stop;
			}
			
		}
		
		g_arrSprayTrace[client] = vecPos;
	}
	
	return Plugin_Continue;
}



public bool:IsValidClient(client) {
	if(client <= 0)
		return false;
	if(client > MaxClients)
		return false;

	return IsClientInGame(client);
}
