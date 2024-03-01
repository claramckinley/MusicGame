extends Node

var clientId = "35eb3120ba3841ddbc1b3cab8c573f80"
var clientSecret = "8288717bc1004029b002cfe9bef7a50c"
var code = null

var verifier = null

func login():
	if code == null:
		redirectToAuthCodeFlow(clientId) # get login info/ have not logged in yet
		var accessToken = getAccessToken(clientId, code) # get token with login info
		var profile = Fetch.fetch("https://api.spotify.com/v1/me", ["Authorization: Bearer ${token}"], 0, "handle_response")

func redirectToAuthCodeFlow(clientId):
	verifier = generateCodeVerifier(128);
	var challenge = generateCodeChallenge(verifier);

	var params = {};
	params["client_id"] = clientId
	params["response_type"] = "code"
	params["redirect_uri"] = "music-game-login://callback"
	params["scope"] = "user-read-private user-read-email"
	params["code_challenge_method"] = "S256"
	params["code_challenge"] = challenge

	var url = "https://accounts.spotify.com/authorize/" + _build_query_params(params)
#	request(
#		url,
#		headers,
#		true,
#		method,
#		body
#	)
	
func _build_query_params(params: Dictionary = {}) -> String:
	var param_array := PoolStringArray()

	for key in params:
		param_array.append(str(key) + "=" + str(params[key]))

	return "&".join(param_array)

func generateCodeVerifier(length):
	var text = ''
	var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
	for i in length:
		text += possible[floor(rand_range(0, possible.length()))]
	return text

func generateCodeChallenge(codeVerifier: String):
	var digest = codeVerifier.sha256_text()
	return Marshalls.utf8_to_base64(digest)

func getAccessToken(clientId, code):
	var params
	params.append("client_id", clientId)
	params.append("grant_type", "authorization_code")
	params.append("code", code)
	params.append("redirect_uri", "music-game-login://callback")
	params.append("code_verifier", verifier)

	var result = Fetch.fetch("https://accounts.spotify.com/api/token", ["Content-Type: application/x-www-form-urlencoded"], 1, "handle_response", params)

	var access_token= result.json();
	return access_token;
	
	


