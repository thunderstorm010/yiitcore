#include <sourcemod>
#include <SteamWorks>

public Plugin myinfo =
{
	name        = "yiitcore",
	author      = "Me",
	description = "My first plugin ever",
	version     = "1.0",
	url         = "http://www.sourcemod.net/"
};

ConVar cv_Url;
// ConVar cv_Interval;
public void OnPluginStart()
{
	cv_Url = CreateConVar("yiitcore_url", "--default", "Base URL of the poll server.", FCVAR_PROTECTED);
	//	cv_Interval = CreateConVar("yiitcore_poll_interval", "10", "Interval of polling.", FCVAR_NONE, true, 1.0);
	AutoExecConfig();
	CreateTimer(10.0, Timer_Callback, _, TIMER_REPEAT);
	PrintToServer("[SM] loaded yiitcore");
}

public void HandleError(bool b, char[] name)
{
	if (!b)
	{
		PrintToServer("[SM] yiitcore error: %s", name);
	}
}

public Action Timer_Callback(Handle h_Timer)
{
	char s_Url[1033];
	cv_Url.GetString(s_Url, 1024);
	if (StrEqual(s_Url, "--default"))
	{
		return Plugin_Stop;
	}
	StrCat(s_Url, 1024, "/yiitcore");

	Handle h_Request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, s_Url);
	SteamWorks_SetHTTPRequestHeaderValue(h_Request, "authorization", "D5J4Zb3IG2wJAKFretvYQsR8pCWJHryd");
	SteamWorks_SetHTTPRequestContextValue(h_Request, h_Timer);
	SteamWorks_SetHTTPRequestNetworkActivityTimeout(h_Request, 10);
	SteamWorks_SetHTTPCallbacks(h_Request, Request_Completed);
	SteamWorks_SendHTTPRequest(h_Request);
	SteamWorks_PrioritizeHTTPRequest(h_Request);
	return Plugin_Continue;
}

public void Request_Completed(Handle h_Request, bool b_Failure, bool b_Successful, EHTTPStatusCode statusCode, Handle h_Timer)
{
	if (!b_Successful)
	{
		LogMessage("There was an error with the request.");
		delete h_Request;
		return;
	}

	if (statusCode == k_EHTTPStatusCode200OK)
	{
		int iSize;
		SteamWorks_GetHTTPResponseBodySize(h_Request, iSize);
		char[] body = new char[iSize];
		SteamWorks_GetHTTPResponseBodyData(h_Request, body, iSize);

		int command_count_value_size;
		SteamWorks_GetHTTPResponseHeaderSize(h_Request, "X-Commands-Count", command_count_value_size);
		char[] command_count_value = new char[command_count_value_size];
		SteamWorks_GetHTTPResponseHeaderValue(h_Request, "X-Commands-Count", command_count_value, command_count_value_size);

		int command_max_length_size;
		SteamWorks_GetHTTPResponseHeaderSize(h_Request, "X-Commands-Length-Max", command_max_length_size);
		char[] command_max_length_value = new char[command_max_length_size];
		SteamWorks_GetHTTPResponseHeaderValue(h_Request, "X-Commands-Length-Max", command_max_length_value, command_max_length_size);

		// don't forget \0
		int command_count      = StringToInt(command_count_value) + 1;
		int command_max_length = StringToInt(command_max_length_value) + 1;

		char[][] commands = new char[command_max_length][command_count];
		ExplodeString(body, "\n", commands, command_count, command_max_length);

		for (int i = 0; i < command_count; i++)
		{
			char[] command = new char[command_max_length];
			strcopy(command, command_max_length, commands[i]);

			ServerCommand("%s", command);
			PrintToChatAll("[SM] Discord tarafından '%s' çalıştırıldı!", command);
		}
	}
	delete h_Request;
	return;
}