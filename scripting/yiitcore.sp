#pragma semicolon 1

#define DEBUG

#include <sdktools>
#include <sourcemod>
#include <websocket>

#pragma newdecls required

public Plugin myinfo =
{
	name        = "yiitcore",
	author      = "Yiit",
	description = "yiitcore plugin for comms with bot",
	version     = "0.1.0-alpha",
	url         = "https://github.com/thunderstorm010/yiitcore"
};
bool b_didAuth;
bool b_hasClient;

public void OnPluginStart()
{
	Websocket_Open("0.0.0.0", 27020, WS_OpenIncConn, WS_OpenErr, WS_OpenClose);
}

public Action WS_OpenIncConn(WebsocketHandle websocket, WebsocketHandle newWebsocket, const char[] remoteIp, int remotePort, char protocols[256], char getPath[2000])
{
	if (!b_hasClient)
	{
		Websocket_HookChild(newWebsocket, WSHookChild_Recv, WSHookChild_Disconnect, WSHookChild_Err);
	}
	else
	{
		Websocket_Close(websocket);
	}
}

public void WS_OpenErr(WebsocketHandle websocket, const int errorType, const int errorNum)
{
}

public void WS_OpenClose(WebsocketHandle websocket)
{
}

public void WSHookChild_Disconnect(WebsocketHandle websocket)
{
}

public void WSHookChild_Err(WebsocketHandle websocket, const int errorType, const int errorNum)
{
}

public void WSHookChild_Recv(WebsocketHandle websocket, WebsocketSendType iType, const char[] receiveData, const int dataSize)
{
	if (strncmp(receiveData, "auth", 4, false) == 0)
	{
		char data[129];
		strcopy(data, 129, receiveData[4]);
		if (!StrEqual(data, "ekekrekrejıokröedaskxmöjxlnköçcmldkmnöçxfcjlkdşö"))
		{
			Websocket_Send(websocket, SendType_Text, "auth_invalid");
		}
		else {
			Websocket_Send(websocket, SendType_Text, "auth_ok");
			b_didAuth = true;
		}
	}
	else if (strncmp(receiveData, "exec", 4, false) == 0)
	{
		if (!b_didAuth)
		{
			Websocket_Send(websocket, SendType_Text, "no_auth");
			return;
		}
		char command[129];
		strcopy(command, 129, receiveData[4]);
		ServerCommand(command);
		Websocket_Send(websocket, SendType_Text, "cmd_ok");
	}
	else {
		Websocket_Send(websocket, SendType_Text, "cmd_invalid");
	}
}