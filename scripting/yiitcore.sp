#include <sourcemod>
#include <SteamWorks>

public Plugin myinfo =
{
	name        = "yiitcore-poll",
	author      = "Me",
	description = "My first plugin ever",
	version     = "1.0",
	url         = "http://www.sourcemod.net/"
};

ConVar cv_Url;
ConVar cv_Auth;

public void OnPluginStart()
{
	PrintToChatAll("[SM] Loaded yiitcore-poll.");
	cv_Url  = CreateConVar("yiitcore_url_base", "url");
	cv_Auth = CreateConVar("yiitcore_auth", "D5J4Zb3IG2wJAKFretvYQsR8pCWJHryd");
	AutoExecConfig(true, "yiitcore-poll");
	CreateTimer(10.0, Timer_SendReq, _, TIMER_REPEAT);
}

public Action Timer_SendReq(Handle timer)
{
	char baseUrl[256];
	char auth[64];

	cv_Url.GetString(baseUrl, 128);
	cv_Auth.GetString(auth, 64);

	StrCat(baseUrl, 256, "/yiitcore");

	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, baseUrl);
	bool   a       = SteamWorks_SetHTTPRequestNetworkActivityTimeout(request, 10);
	bool   b       = SteamWorks_SetHTTPRequestHeaderValue(request, "authorization", auth);
	bool   c       = SteamWorks_SetHTTPRequestContextValue(request, 5);
	bool   d       = SteamWorks_SetHTTPCallbacks(request, Callback_Get);
	if (!a || !b || !c || !d)
	{
		PrintToChatAll("[SM] error yiitcore-poll: failed request (abcd)");
		CloseHandle(request);
		return Plugin_Continue;
	}
	bool b_DidSendRequest = SteamWorks_SendHTTPRequestAndStreamResponse(request);
	if (!b_DidSendRequest)
	{
		PrintToChatAll("[SM] error yiitcore-poll: failed request (shrasr)");
		CloseHandle(request);
		return Plugin_Continue;
	}
	bool e = SteamWorks_PrioritizeHTTPRequest(request);
	if (!e)
	{
		PrintToChatAll("[SM] error yiitcore-poll: failed request (e)");
		CloseHandle(request);
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public void Callback_Get(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode status, any data)
{
	if (!bRequestSuccessful || bFailure)
	{
		PrintToChatAll("[SM] error yiitcore-poll: request unsuccessful");
		CloseHandle(hRequest);
		return;
	}
	if (status != k_EHTTPStatusCode200OK)
	{
		if (status == k_EHTTPStatusCode401Unauthorized)
		{
			PrintToChatAll("[SM] error yiitcore-poll: wrong auth");
		}
		else {
			PrintToChatAll("[SM] error yiitcore-poll: unexpected response code");
		}
		delete hRequest;
		return;
	}

	SteamWorks_GetHTTPResponseBodyCallback(hRequest, Callback_Body);
	delete hRequest;
}

public void Callback_Body(char[] sData)
{
	char commands[256][128];
	int  cString = ExplodeString(sData, "\n", commands, 128, 256);
	for (int i = 0; i < cString; i++)
	{
		ServerCommand(commands[i]);
	}
}